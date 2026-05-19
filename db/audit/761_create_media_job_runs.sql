BEGIN;

CREATE TABLE IF NOT EXISTS ops.media_job_runs (
    id BIGSERIAL PRIMARY KEY,

    pipeline_name TEXT NOT NULL,
    worker_name TEXT,
    layer TEXT NOT NULL DEFAULT 'media',

    status TEXT NOT NULL DEFAULT 'running',

    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at TIMESTAMPTZ,

    duration_seconds INTEGER,

    processed_rows INTEGER NOT NULL DEFAULT 0,
    inserted_rows INTEGER NOT NULL DEFAULT 0,
    updated_rows INTEGER NOT NULL DEFAULT 0,
    skipped_rows INTEGER NOT NULL DEFAULT 0,
    error_rows INTEGER NOT NULL DEFAULT 0,

    message TEXT,
    details_json JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_media_job_runs_status
    CHECK (
        status IN (
            'running',
            'ok',
            'partial',
            'error',
            'timeout',
            'skipped'
        )
    )
);

CREATE INDEX IF NOT EXISTS ix_media_job_runs_started_at
ON ops.media_job_runs(started_at DESC);

CREATE INDEX IF NOT EXISTS ix_media_job_runs_pipeline
ON ops.media_job_runs(pipeline_name);

CREATE INDEX IF NOT EXISTS ix_media_job_runs_status
ON ops.media_job_runs(status);

COMMIT;
