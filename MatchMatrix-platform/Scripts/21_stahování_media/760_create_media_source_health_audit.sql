BEGIN;

CREATE TABLE IF NOT EXISTS ops.media_source_health_audit (
    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    entity TEXT NOT NULL DEFAULT 'articles',

    source_name TEXT NOT NULL,
    source_type TEXT NOT NULL,
    source_url TEXT NOT NULL,

    http_status INTEGER,
    found_urls INTEGER NOT NULL DEFAULT 0,
    inserted_rows INTEGER NOT NULL DEFAULT 0,
    updated_rows INTEGER NOT NULL DEFAULT 0,
    skipped_rows INTEGER NOT NULL DEFAULT 0,

    worker_script TEXT,
    worker_type TEXT,

    health_status TEXT NOT NULL DEFAULT 'UNKNOWN',
    health_note TEXT,

    last_run_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_media_source_health_status
    CHECK (
        health_status IN (
            'UNKNOWN',
            'OK',
            'PARTIAL',
            'EMPTY',
            'BLOCKED',
            'RSS_DEAD',
            'JS_RENDERED',
            'ERROR'
        )
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_media_source_health_audit_source
ON ops.media_source_health_audit(provider, sport_code, source_name, source_type, source_url);

CREATE INDEX IF NOT EXISTS ix_media_source_health_audit_status
ON ops.media_source_health_audit(health_status);

CREATE INDEX IF NOT EXISTS ix_media_source_health_audit_last_run
ON ops.media_source_health_audit(last_run_at DESC);

COMMIT;