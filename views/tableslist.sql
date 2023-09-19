CREATE OR REPLACE VIEW audit.tableslist AS

SELECT DISTINCT triggers.trigger_schema     AS schema,
                triggers.event_object_table AS auditedtable
FROM information_schema.triggers
WHERE triggers.trigger_name::text IN (
                                      'audit_trigger_row'::text,
                                      'audit_trigger_stm'::text
    )
ORDER BY schema,
         auditedtable;

COMMENT ON VIEW audit.tableslist IS $body$ View showing all tables with auditing
set up.Ordered by schema,
    then table.$body$;
