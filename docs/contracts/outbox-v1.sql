PRAGMA foreign_keys = ON;

CREATE TABLE outbox_actions (
  id TEXT PRIMARY KEY,
  env TEXT NOT NULL,
  service TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  entity_id INTEGER NOT NULL,
  action_type TEXT NOT NULL CHECK(action_type IN (
    'create_ticket',
    'add_followup',
    'add_solution',
    'change_status',
    'claim_ticket',
    'upload_attachment'
  )),
  local_entity_id TEXT,
  remote_entity_id INTEGER,
  payload TEXT NOT NULL,
  payload_digest TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN (
    'pending',
    'processing',
    'auth_required',
    'retry_wait',
    'blocked_dependency',
    'reconciling',
    'remote_unknown',
    'blob_lost',
    'cancelled',
    'synced',
    'failed_terminal',
    'discarded_human'
  )),
  attempts INTEGER NOT NULL DEFAULT 0 CHECK(attempts >= 0),
  next_attempt_at INTEGER,
  last_error TEXT,
  depends_on TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  discarded_by TEXT,
  discarded_at INTEGER,
  discard_reason TEXT,
  FOREIGN KEY (depends_on) REFERENCES outbox_actions (id) ON DELETE RESTRICT,
  CHECK (
    status <> 'discarded_human'
    OR (
      discarded_by IS NOT NULL
      AND discarded_at IS NOT NULL
      AND discard_reason IS NOT NULL
      AND length(trim(discard_reason)) > 0
    )
  )
);

CREATE INDEX idx_outbox_sync
  ON outbox_actions (
    env,
    service,
    user_id,
    entity_id,
    status,
    next_attempt_at
  );

CREATE INDEX idx_outbox_dependency
  ON outbox_actions (depends_on);

CREATE TABLE outbox_attachments (
  id TEXT PRIMARY KEY,
  outbox_action_id TEXT NOT NULL,
  item_type TEXT NOT NULL CHECK(item_type IN (
    'Ticket',
    'ITILFollowup',
    'ITILSolution'
  )),
  target_item_id INTEGER NOT NULL CHECK(target_item_id > 0),
  mime_type TEXT NOT NULL,
  file_size INTEGER NOT NULL CHECK(file_size >= 0),
  file_digest TEXT NOT NULL,
  staging_blob_ref TEXT,
  committed_blob_ref TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (outbox_action_id)
    REFERENCES outbox_actions (id)
    ON DELETE CASCADE
);

CREATE INDEX idx_outbox_attachment_action
  ON outbox_attachments (outbox_action_id);

CREATE TABLE migration_markers (
  marker_key TEXT NOT NULL,
  env TEXT NOT NULL,
  service TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  entity_id INTEGER NOT NULL,
  migrated_at INTEGER NOT NULL,
  PRIMARY KEY (marker_key, env, service, user_id, entity_id)
);
