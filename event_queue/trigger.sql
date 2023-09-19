CREATE TRIGGER audit_logged_actions
    AFTER INSERT
    ON audit.logged_actions
    FOR EACH ROW
EXECUTE PROCEDURE audit.push_event();
