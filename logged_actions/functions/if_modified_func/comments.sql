COMMENT ON FUNCTION audit.if_modified_func() IS $body$ Track changes to a table at the statement
and /
or row level.Optional parameters to trigger in CREATE TRIGGER call: param 0: boolean,
whether to log the query text.Default 't'.param 1: text [],
columns to ignore in updates.Default [].Updates to ignored cols are omitted
from changed_fields.Updates with only ignored cols changed are not inserted into the audit log.Almost all the processing work is still done for updates that ignored.If you need to save the load,
    you need to use
    WHEN clause on the trigger instead.No warning
    or error is issued if ignored_cols contains columns that do not exist in the target table.This lets you specify a standard
set of ignored columns.There is no parameter to disable logging of
values.
Add this trigger as a 'FOR EACH STATEMENT' rather than 'FOR EACH ROW' trigger if you do not want to log row
values.Note that the user name logged is the login role for the session.The audit trigger cannot obtain the active role because it is reset by the SECURITY DEFINER invocation of the audit trigger its self.$body$;
