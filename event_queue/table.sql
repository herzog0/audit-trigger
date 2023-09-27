-- Audited data. Lots of information is available, it's just a matter of how much
-- you really want to record. See:
--
CREATE TABLE audit.event_queue
(
    created_at   TIMESTAMP(3) NOT NULL,
    event_id     BIGSERIAL    NOT NULL,
    processed    BOOLEAN      NOT NULL DEFAULT FALSE,
    attempts     INTEGER      NOT NULL DEFAULT 0,
    retry_after  TIMESTAMP(3),
    processed_at TIMESTAMP(3),

    CONSTRAINT event_queue_pkey PRIMARY KEY (event_id)
);

ALTER TABLE audit.event_queue
    ADD CONSTRAINT event_queue_event_id_fkey FOREIGN KEY (event_id) REFERENCES audit.logged_actions (event_id) ON DELETE RESTRICT ON UPDATE CASCADE;

REVOKE ALL ON audit.event_queue
    FROM public;

COMMENT ON COLUMN audit.event_queue.processed IS '''t'' if event listener has collected and processed the row successfully, ''f'' otherwise';
COMMENT ON COLUMN audit.event_queue.attempts IS 'The amount of attempts to process the row';
COMMENT ON COLUMN audit.event_queue.processed_at IS 'The date when the event was processed';
