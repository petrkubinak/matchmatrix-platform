-- =========================================================
-- MATCHMATRIX
-- MEDIA ASSET ENRICHMENT QUEUE
-- =========================================================
--
-- Co tabulka dělá:
-- ---------------------------------------------------------
-- Fronta pro doplňování media assetů:
-- - player photos
-- - team logos
-- - league logos
-- - flags
--
-- K čemu to je:
-- ---------------------------------------------------------
-- Řízený enrichment systém pro:
-- - web
-- - mobilní aplikaci
-- - AI feed
-- - player/team pages
--
-- Výhoda:
-- ---------------------------------------------------------
-- Assety se nestahují chaoticky,
-- ale přes centrální queue systém.
--
-- Budoucí využití:
-- ---------------------------------------------------------
-- - CDN
-- - image optimization
-- - caching
-- - AI thumbnails
-- - avatar generation
--
-- =========================================================

CREATE TABLE IF NOT EXISTS ops.media_asset_enrichment_queue
(
    id BIGSERIAL PRIMARY KEY,

    entity_type TEXT NOT NULL,
    entity_id BIGINT NOT NULL,

    asset_type TEXT NOT NULL,

    provider TEXT,

    source_url TEXT,

    downloaded_url TEXT,

    local_path TEXT,

    priority INTEGER DEFAULT 100,

    status TEXT DEFAULT 'pending',

    error_message TEXT,

    retry_count INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- INDEXY
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_media_asset_queue_status
ON ops.media_asset_enrichment_queue(status);

CREATE INDEX IF NOT EXISTS idx_media_asset_queue_entity
ON ops.media_asset_enrichment_queue(entity_type, entity_id);

CREATE INDEX IF NOT EXISTS idx_media_asset_queue_priority
ON ops.media_asset_enrichment_queue(priority DESC);

-- =========================================================
-- UNIQUE
-- =========================================================

ALTER TABLE ops.media_asset_enrichment_queue
ADD CONSTRAINT uq_media_asset_queue
UNIQUE(entity_type, entity_id, asset_type);