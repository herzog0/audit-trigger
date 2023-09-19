CREATE OR REPLACE FUNCTION audit.push_event() RETURNS TRIGGER AS
$body$
DECLARE
    event_row audit.event_queue;
BEGIN
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'audit.push_event() may only run as an AFTER trigger';
    END IF;

    event_row = ROW (
        NOW(),
        NEW.event_id,
        'f', -- processed
        0, -- attempts
        null -- processed_at
        );
    INSERT INTO audit.event_queue VALUES (event_row.*);
    RETURN NULL;
END;
$body$ LANGUAGE plpgsql SECURITY DEFINER
                        SET search_path = pg_catalog,
                            public;

