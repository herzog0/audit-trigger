CREATE OR REPLACE FUNCTION audit.if_modified_func() RETURNS TRIGGER AS
$body$
DECLARE
    audit_row      audit.logged_actions;
    include_values boolean;
    log_diffs      boolean;
    h_old          jsonb;
    h_new          jsonb;
    excluded_cols  text[] = ARRAY []::text[];
BEGIN
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'audit.if_modified_func() may only run as an AFTER trigger';
    END IF;
    audit_row = ROW (
        nextval('audit.logged_actions_event_id_seq'),
        -- event_id
        TG_TABLE_SCHEMA::text,
        -- schema_name
        TG_TABLE_NAME::text,
        -- table_name
        TG_RELID,
        -- relation OID for much quicker searches
                session_user::text,
        -- session_user_name
                current_timestamp,
        -- action_tstamp_tx
        statement_timestamp(),
        -- action_tstamp_stm
        clock_timestamp(),
        -- action_tstamp_clk
        txid_current(),
        -- transaction ID
        current_setting('application_name'),
        -- client application
        inet_client_addr(),
        -- client_addr
        inet_client_port(),
        -- client_port
        current_query(),
        -- top-level query or queries (if multistatement) from client
        substring(TG_OP, 1, 1),
        -- action
        NULL,
        NULL,
        -- row_data, changed_fields
        'f', -- statement_only,
        'f', -- processed
        0, -- attempts
        null -- processed_at
        );
    IF NOT TG_ARGV[0]::boolean IS DISTINCT FROM 'f'::boolean THEN
        audit_row.client_query = NULL;
    END IF;
    IF TG_ARGV[1] IS NOT NULL THEN
        excluded_cols = TG_ARGV[1]::text[];
    END IF;
    IF (
                TG_OP = 'UPDATE'
            AND TG_LEVEL = 'ROW'
        ) THEN
        audit_row.row_data = row_to_json(OLD)::JSONB - excluded_cols;
--Computing differences
        SELECT jsonb_object_agg(tmp_new_row.key, tmp_new_row.value) AS new_data
        INTO audit_row.changed_fields
        FROM jsonb_each_text(row_to_json(NEW)::JSONB) AS tmp_new_row
                 JOIN jsonb_each_text(audit_row.row_data) AS tmp_old_row ON (
                    tmp_new_row.key = tmp_old_row.key
                AND tmp_new_row.value IS DISTINCT FROM tmp_old_row.value
            );
        IF audit_row.changed_fields = '{}'::JSONB THEN -- All changed fields are ignored. Skip this update.
            RETURN NULL;
        END IF;
    ELSIF (
                TG_OP = 'DELETE'
            AND TG_LEVEL = 'ROW'
        ) THEN
        audit_row.row_data = row_to_json(OLD)::JSONB - excluded_cols;
    ELSIF (
                TG_OP = 'INSERT'
            AND TG_LEVEL = 'ROW'
        ) THEN
        audit_row.row_data = row_to_json(NEW)::JSONB - excluded_cols;
    ELSIF (
                TG_LEVEL = 'STATEMENT'
            AND TG_OP IN ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')
        ) THEN
        audit_row.statement_only = 't';
    ELSE
        RAISE EXCEPTION '[audit.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',
            TG_OP,
            TG_LEVEL;
        RETURN NULL;
    END IF;

    IF (audit_row.changed_fields is null) THEN
        RETURN NULL;
    ELSE
        INSERT INTO audit.logged_actions
        VALUES (audit_row.*);
    END IF;

    RETURN NULL;
END;
$body$ LANGUAGE plpgsql SECURITY DEFINER
                        SET search_path = pg_catalog,
                            public;
