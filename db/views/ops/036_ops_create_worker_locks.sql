-- ==========================================================
-- MATCHMATRIX
-- 036_ops_create_worker_locks.sql
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\036_ops_create_worker_locks.sql
--
-- Co dělá:
-- Vytvoří tabulku ops.worker_locks pro ochranu proti
-- souběžnému spuštění stejných workerů / orchestrátorů.
-- ==========================================================

CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE IF NOT EXISTS ops.worker_locks
(
    lock_name           text PRIMARY KEY,
    owner_id            text NULL,
    acquired_at         timestamptz NULL,
    expires_at          timestamptz NULL,
    heartbeat_at        timestamptz NULL,
    note                text NULL,
    created_at          timestamptz NOT NULL DEFAULT NOW(),
    updated_at          timestamptz NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE ops.worker_locks IS
'Locks for MatchMatrix workers and orchestrators. Prevents duplicate concurrent runs.';

COMMENT ON COLUMN ops.worker_locks.lock_name IS
'Unique lock key, e.g. ingest_cycle_v2';

COMMENT ON COLUMN ops.worker_locks.owner_id IS
'Identifier of current lock owner, e.g. hostname:pid:timestamp';

COMMENT ON COLUMN ops.worker_locks.acquired_at IS
'When the lock was acquired';

COMMENT ON COLUMN ops.worker_locks.expires_at IS
'When the lock is considered expired and may be stolen';

COMMENT ON COLUMN ops.worker_locks.heartbeat_at IS
'Last heartbeat from lock owner';

COMMENT ON COLUMN ops.worker_locks.note IS
'Optional diagnostic note';

CREATE INDEX IF NOT EXISTS ix_worker_locks_expires_at
    ON ops.worker_locks (expires_at);