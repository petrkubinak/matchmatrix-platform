-- 109_create_ops_runtime_entity_audit.sql
-- Centrální runtime audit sport × entity × provider
-- Určeno pro průběžné ruční i poloautomatické doplňování po reálných runech.

CREATE TABLE IF NOT EXISTS ops.runtime_entity_audit (
    id                          BIGSERIAL PRIMARY KEY,

    provider                    TEXT NOT NULL,
    sport_code                  TEXT NOT NULL,
    entity                      TEXT NOT NULL,

    current_state               TEXT NOT NULL DEFAULT 'NOT_TESTED',
    state_reason                TEXT NULL,

    panel_runner_exists         BOOLEAN NOT NULL DEFAULT FALSE,
    planner_target_exists       BOOLEAN NOT NULL DEFAULT FALSE,
    batch_target_exists         BOOLEAN NOT NULL DEFAULT FALSE,

    pull_confirmed              BOOLEAN NOT NULL DEFAULT FALSE,
    raw_confirmed               BOOLEAN NOT NULL DEFAULT FALSE,
    staging_confirmed           BOOLEAN NOT NULL DEFAULT FALSE,
    provider_map_confirmed      BOOLEAN NOT NULL DEFAULT FALSE,
    public_merge_confirmed      BOOLEAN NOT NULL DEFAULT FALSE,
    downstream_confirmed        BOOLEAN NOT NULL DEFAULT FALSE,

    last_run_group              TEXT NULL,
    last_run_at                 TIMESTAMPTZ NULL,
    last_check_at               TIMESTAMPTZ NULL,

    last_log_summary            TEXT NULL,
    db_evidence_summary         TEXT NULL,
    next_action                 TEXT NULL,
    audit_note                  TEXT NULL,

    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_runtime_entity_audit UNIQUE (provider, sport_code, entity),

    CONSTRAINT chk_runtime_entity_audit_state CHECK (
        current_state IN (
            'NOT_TESTED',
            'PLANNED',
            'RUNNABLE',
            'PARTIAL',
            'CONFIRMED',
            'BROKEN',
            'BLOCKED'
        )
    )
);

CREATE INDEX IF NOT EXISTS ix_runtime_entity_audit_sport
    ON ops.runtime_entity_audit (sport_code);

CREATE INDEX IF NOT EXISTS ix_runtime_entity_audit_provider
    ON ops.runtime_entity_audit (provider);

CREATE INDEX IF NOT EXISTS ix_runtime_entity_audit_state
    ON ops.runtime_entity_audit (current_state);

CREATE INDEX IF NOT EXISTS ix_runtime_entity_audit_last_run_at
    ON ops.runtime_entity_audit (last_run_at DESC);

CREATE OR REPLACE FUNCTION ops.set_updated_at_runtime_entity_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_updated_at_runtime_entity_audit ON ops.runtime_entity_audit;

CREATE TRIGGER trg_set_updated_at_runtime_entity_audit
BEFORE UPDATE ON ops.runtime_entity_audit
FOR EACH ROW
EXECUTE FUNCTION ops.set_updated_at_runtime_entity_audit();