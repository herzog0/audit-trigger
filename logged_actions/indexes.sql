CREATE INDEX idx_logged_actions_relid ON audit.logged_actions (relid);
CREATE INDEX idx_logged_actions_action_tstamp_tx_stm ON audit.logged_actions (action_tstamp_stm);
CREATE INDEX idx_logged_actions_action ON audit.logged_actions (action);
