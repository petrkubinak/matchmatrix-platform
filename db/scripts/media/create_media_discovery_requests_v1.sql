-- create_media_discovery_requests_v1.sql
--
-- =========================================================
-- MATCHMATRIX MEDIA DISCOVERY REQUESTS V1
-- =========================================================
--
-- CO TO DĚLÁ:
-- Vytváří tabulku pro automatické požadavky
-- na hledání nových media zdrojů.
--
-- =========================================================
-- KAM TO VEDE:
-- ops.media_discovery_requests
--
-- =========================================================
-- K ČEMU TO BUDE:
--
-- Uživatel zadá:
--
-- - tým
-- - ligu
-- - hráče
-- - sport
-- - zemi
-- - highlights
-- - články
-- - live feed
--
-- a systém:
--
-- ✔ automaticky vyhledá nové zdroje
-- ✔ vytvoří kandidáty
-- ✔ provede health check
-- ✔ klasifikuje content typ
-- ✔ připraví zdroje pro approval
--
-- =========================================================
-- VYUŽITÍ NA WEBU/APLIKACI:
--
-- SEARCH:
-- "Sparta Praha"
-- "NHL highlights"
-- "Bundesliga news"
-- "Victor Wembanyama videos"
--
-- PERSONALIZED FEED:
-- oblíbené týmy/ligy
--
-- AUTO DISCOVERY:
-- nové ligy
-- lokální média
-- regionální sportovní weby
--
-- =========================================================
-- BUDOUCÍ WORKFLOW:
--
-- USER REQUEST
-- → discovery request
-- → discovery worker
-- → source candidates
-- → review
-- → ingest
--
-- =========================================================

CREATE TABLE IF NOT EXISTS ops.media_discovery_requests (
    id bigserial PRIMARY KEY,

    -- USER REQUEST
    request_text text NOT NULL,

    sport_code text,
    country_code text,
    language_code text,

    league_id bigint,
    team_id bigint,
    player_id bigint,

    -- CO UŽIVATEL CHCE
    requested_section_code text,

    -- PRIORITA
    priority_level text NOT NULL DEFAULT 'normal',

    -- STAV
    request_status text NOT NULL DEFAULT 'pending',

    -- WORKER INFO
    worker_started_at timestamptz,
    worker_finished_at timestamptz,

    -- VÝSLEDKY
    discovered_sources integer NOT NULL DEFAULT 0,
    approved_sources integer NOT NULL DEFAULT 0,
    rejected_sources integer NOT NULL DEFAULT 0,

    -- LOG
    processing_note text,
    error_note text,

    created_by text DEFAULT 'system',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT fk_media_discovery_section
        FOREIGN KEY (requested_section_code)
        REFERENCES public.media_content_sections(section_code)
);

CREATE INDEX IF NOT EXISTS ix_media_discovery_status
ON ops.media_discovery_requests(request_status);

CREATE INDEX IF NOT EXISTS ix_media_discovery_entity
ON ops.media_discovery_requests(
    sport_code,
    league_id,
    team_id,
    player_id
);

CREATE INDEX IF NOT EXISTS ix_media_discovery_created
ON ops.media_discovery_requests(created_at);


-- =========================================================
-- TEST REQUESTS
-- =========================================================

INSERT INTO ops.media_discovery_requests (
    request_text,
    sport_code,
    country_code,
    language_code,
    requested_section_code,
    priority_level,
    created_by
)
VALUES

(
    'Sparta Praha news',
    'FB',
    'CZ',
    'cs',
    'ARTICLE',
    'high',
    'demo_user'
),

(
    'NHL highlights',
    'HK',
    'US',
    'en',
    'VIDEO',
    'high',
    'demo_user'
),

(
    'Victor Wembanyama videos',
    'BK',
    'US',
    'en',
    'VIDEO',
    'normal',
    'demo_user'
)

ON CONFLICT DO NOTHING;


-- =========================================================
-- KONTROLA
-- =========================================================

SELECT
    request_status,
    request_text,
    sport_code,
    requested_section_code,
    priority_level,
    discovered_sources,
    approved_sources
FROM ops.media_discovery_requests
ORDER BY created_at DESC;