COMMENT ON FUNCTION audit.audit_table(regclass, boolean, boolean, boolean, text[]) IS $body$
Add auditing support to a table.Arguments: target_table: Table name,
    schema qualified if not on search_path audit_rows: Record each row change,
    or only audit at a statement level audit_query_text: Record the text of the client query that triggered the audit event ? audit_inserts: Audit
insert statements
    or only updates / deletes / truncates ? ignored_cols: Columns to exclude
from
update diffs,
    ignore updates that change only ignored cols.$body$;

COMMENT ON FUNCTION audit.audit_table(regclass) IS $body$
Add auditing support to the given table.Row - level changes will be logged with full client query text.No cols are ignored.$body$;
