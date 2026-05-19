CREATE TABLE IF NOT EXISTS ops.media_refresh_queue (
    id bigserial PRIMARY KEY,

    request_type text NOT NULL,
    sport_code text,
    source_name text,
    content_source_id bigint,
    entity_type text,
    entity_id bigint,
    article_id bigint,

    priority integer NOT NULL DEFAULT 100,

    status text NOT NULL DEFAULT 'pending',
    requested_by text NOT NULL DEFAULT 'system',

    min_refresh_interval_minutes integer NOT NULL DEFAULT 15,

    last_refresh_at timestamptz,
    next_allowed_refresh_at timestamptz,

    attempts integer NOT NULL DEFAULT 0,
    max_attempts integer NOT NULL DEFAULT 3,

    request_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    result_message text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_media_refresh_queue_status
ON ops.media_refresh_queue(status, priority, created_at);

CREATE INDEX IF NOT EXISTS ix_media_refresh_queue_request_type
ON ops.media_refresh_queue(request_type);

CREATE INDEX IF NOT EXISTS ix_media_refresh_queue_sport_source
ON ops.media_refresh_queue(sport_code, source_name);