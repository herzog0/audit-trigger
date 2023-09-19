CREATE OR REPLACE FUNCTION audit.deaudit_table(target_table regclass) RETURNS void AS
$body$
BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_row ON ' || target_table;
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_stm ON ' || target_table;
END;
$body$ language 'plpgsql';
