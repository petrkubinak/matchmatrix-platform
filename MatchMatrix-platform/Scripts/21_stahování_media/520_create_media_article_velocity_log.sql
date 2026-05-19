CREATE TABLE IF NOT EXISTS ops.media_article_velocity_log (
    id bigserial PRIMARY KEY,

    article_id bigint NOT NULL,
    snapshot_time timestamptz NOT NULL DEFAULT now(),

    feed_score numeric,
    breaking_score numeric,
    hot_score numeric,
    velocity_score numeric,

    is_breaking_news boolean,
    is_video boolean,
    playoff_related boolean,

    source_name text,
    sport_code text,

    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_media_velocity_article
ON ops.media_article_velocity_log(article_id, snapshot_time DESC);

CREATE INDEX IF NOT EXISTS ix_media_velocity_snapshot
ON ops.media_article_velocity_log(snapshot_time DESC);