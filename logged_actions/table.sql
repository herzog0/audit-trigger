-- Audited data. Lots of information is available, it's just a matter of how much
-- you really want to record. See:
--
--   http://www.postgresql.org/docs/9.1/static/functions-info.html
--
-- Remember, every column you add takes up more audit table space and slows audit
-- inserts.
--
-- Every index you add has a big impact too, so avoid adding indexes to the
-- audit table unless you REALLY need them. The json GIN/GIST indexes are
-- particularly expensive.
--
-- It is sometimes worth copying the audit table, or a coarse subset of it that
-- you're interested in, into a temporary table where you CREATE any useful
-- indexes and do your analysis.
--
CREATE TABLE audit.logged_actions
(
    event_id          bigserial primary key,
    schema_name       text                     not null,
    table_name        text                     not null,
    relid             oid                      not null,
    session_user_name text,
    action_tstamp_tx  TIMESTAMP WITH TIME ZONE NOT NULL,
    action_tstamp_stm TIMESTAMP WITH TIME ZONE NOT NULL,
    action_tstamp_clk TIMESTAMP WITH TIME ZONE NOT NULL,
    transaction_id    bigint,
    application_name  text,
    client_addr       inet,
    client_port       integer,
    client_query      text,
    action            TEXT                     NOT NULL CHECK (action IN ('I', 'D', 'U', 'T')),
    row_data          jsonb,
    changed_fields    jsonb,
    statement_only    boolean                  not null,
    processed         boolean                  not null default false,
    attempts          integer                  not null default 0,
    processed_at      TIMESTAMP(3)
);
REVOKE ALL ON audit.logged_actions
    FROM public;
