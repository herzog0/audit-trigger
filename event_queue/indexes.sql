CREATE INDEX idx_event_queue_id ON audit.event_queue (event_id);
CREATE INDEX idx_event_queue_processed ON audit.event_queue (processed);
CREATE INDEX idx_event_queue_created_at ON audit.event_queue (created_at);
