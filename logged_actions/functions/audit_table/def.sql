CREATE OR REPLACE FUNCTION audit.audit_table(
    target_table regclass,
    audit_rows boolean,
    audit_query_text boolean,
    audit_inserts boolean,
    ignored_cols text[]
) RETURNS void AS
$body$
DECLARE
    stm_targets        text = 'INSERT OR UPDATE OR DELETE OR TRUNCATE';
    _q_txt             text;
    _ignored_cols_snip text = '';
BEGIN
    PERFORM audit.deaudit_table(target_table);
    IF audit_rows THEN
        IF array_length(ignored_cols, 1) > 0 THEN
            _ignored_cols_snip = ', ' || quote_literal(ignored_cols);
        END IF;
        _q_txt = 'CREATE TRIGGER audit_trigger_row AFTER ' || CASE
                                                                  WHEN audit_inserts THEN 'INSERT OR '
                                                                  ELSE ''
            END || 'UPDATE OR DELETE ON ' || target_table ||
                 ' FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func(' || quote_literal(audit_query_text) ||
                 _ignored_cols_snip || ');';
        RAISE NOTICE '%',
            _q_txt;
        EXECUTE _q_txt;
        stm_targets = 'TRUNCATE';
    ELSE
    END IF;
    _q_txt = 'CREATE TRIGGER audit_trigger_stm AFTER ' || stm_targets || ' ON ' || target_table ||
             ' FOR EACH STATEMENT EXECUTE PROCEDURE audit.if_modified_func(' || quote_literal(audit_query_text) || ');';
    RAISE NOTICE '%',
        _q_txt;
    EXECUTE _q_txt;
END;
$body$ language 'plpgsql';

-- Adaptor to older variant without the audit_inserts parameter for backwards compatibility
CREATE OR REPLACE FUNCTION audit.audit_table(
    target_table regclass,
    audit_rows boolean,
    audit_query_text boolean,
    ignored_cols text[]
) RETURNS void AS
$body$
SELECT audit.audit_table($1, $2, $3, BOOLEAN 't', ignored_cols);
$body$ LANGUAGE SQL;

-- Pg doesn't allow variadic calls with 0 params, so provide a wrapper
CREATE OR REPLACE FUNCTION audit.audit_table(
    target_table regclass,
    audit_rows boolean,
    audit_query_text boolean,
    audit_inserts boolean
) RETURNS void AS
$body$
SELECT audit.audit_table($1, $2, $3, $4, ARRAY []::text[]);
$body$ LANGUAGE SQL;
-- Older wrapper for backwards compatibility
CREATE OR REPLACE FUNCTION audit.audit_table(
    target_table regclass,
    audit_rows boolean,
    audit_query_text boolean
) RETURNS void AS
$body$
SELECT audit.audit_table($1, $2, $3, BOOLEAN 't', ARRAY []::text[]);
$body$ LANGUAGE SQL;
-- And provide a convenience call wrapper for the simplest case
-- of row-level logging with no excluded cols and query logging enabled.
--
CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass) RETURNS void AS
$body$
SELECT audit.audit_table($1, BOOLEAN 't', BOOLEAN 't', BOOLEAN 't');
$body$ LANGUAGE 'sql';
