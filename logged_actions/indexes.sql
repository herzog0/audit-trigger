CREATE INDEX logged_actions_relid_idx ON audit.logged_actions (relid);
CREATE INDEX logged_actions_action_tstamp_tx_stm_idx ON audit.logged_actions (action_tstamp_stm);
CREATE INDEX logged_actions_action_idx ON audit.logged_actions (action);
