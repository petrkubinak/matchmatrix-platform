-- create_media_source_discovery_v1.sql
--
-- CO TO DĚLÁ:
-- Vytváří databázový základ pro automatické hledání nových media zdrojů
-- z celého světa podle ligy, týmu, hráče, země nebo sportu.
--
-- Současně zavádí sekce obsahu:
-- ARTICLE, VIDEO, LIVE, PHOTO, SOCIAL, PROFILE, ANALYSIS, OFFICIAL.
--
-- KAM TO VEDE:
-- Vzniknou tabulky:
-- public.media_content_sections
-- ops.media_source_discovery_candidates
--
-- K ČEMU TO BUDE:
-- MatchMatrix nebude závislý jen na ručně zadaných zdrojích.
-- Bude umět najít kandidátní zdroje, zařadit je, otestovat,
-- a po schválení použít pro ingest článků/videí.
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Uživatel zadá ligu/tým/hráče:
-- - web ukáže články
-- - videa
-- - live blogy
-- - analýzy
-- - oficiální zprávy
-- - lokální zdroje z dané země
--
-- Budoucí použití:
-- homepage feed
-- league page
-- team page
-- player page
-- country sport pages
-- admin panel pro schvalování zdrojů
-- personalizovaný news/video feed

CREATE TABLE IF NOT EXISTS public.media_content_sections (
    id bigserial PRIMARY KEY,
    section_code text NOT NULL UNIQUE,
    section_name text NOT NULL,
    description text,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO public.media_content_sections (
    section_code,
    section_name,
    description
)
VALUES
    ('ARTICLE', 'Article', 'Běžný článek, zpráva, preview nebo recap.'),
    ('VIDEO', 'Video', 'Video, highlights, rozhovor, sestřih nebo press conference.'),
    ('LIVE', 'Live', 'Live blog, live updates nebo průběžné online zpravodajství.'),
    ('PHOTO', 'Photo', 'Fotogalerie nebo obrazový report.'),
    ('SOCIAL', 'Social', 'Sociální příspěvky nebo embed obsah.'),
    ('PROFILE', 'Profile', 'Profil hráče, biografie, kariérní příběh.'),
    ('ANALYSIS', 'Analysis', 'Analytický článek, taktika, expert komentář.'),
    ('OFFICIAL', 'Official', 'Oficiální oznámení ligy, klubu, federace nebo organizace.')
ON CONFLICT (section_code)
DO UPDATE SET
    section_name = EXCLUDED.section_name,
    description = EXCLUDED.description,
    updated_at = now();


CREATE TABLE IF NOT EXISTS ops.media_source_discovery_candidates (
    id bigserial PRIMARY KEY,

    -- Co jsme hledali
    query_text text NOT NULL,
    sport_code text,
    country_code text,
    language_code text,

    league_id bigint,
    team_id bigint,
    player_id bigint,

    -- Nalezený zdroj
    source_name text,
    source_url text NOT NULL,
    source_domain text,
    source_type text,

    -- Zařazení obsahu
    primary_section_code text,
    detected_sections text[],

    -- Kvalita a důvěryhodnost
    is_official_candidate boolean NOT NULL DEFAULT false,
    trust_level text NOT NULL DEFAULT 'unknown',
    discovery_score numeric,
    evidence_note text,

    -- Stav schvalování
    review_status text NOT NULL DEFAULT 'pending',
    reviewed_by text,
    reviewed_at timestamptz,
    review_note text,

    -- Technická kontrola
    http_status integer,
    is_reachable boolean,
    has_rss boolean,
    has_sitemap boolean,
    has_video_content boolean,
    has_article_content boolean,
    last_checked_at timestamptz,

    -- Budoucí ingest
    approved_content_source_id bigint,
    next_action text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_media_source_discovery_url UNIQUE (source_url),

    CONSTRAINT fk_media_source_discovery_section
        FOREIGN KEY (primary_section_code)
        REFERENCES public.media_content_sections(section_code)
);

CREATE INDEX IF NOT EXISTS ix_media_source_discovery_status
ON ops.media_source_discovery_candidates(review_status);

CREATE INDEX IF NOT EXISTS ix_media_source_discovery_entity
ON ops.media_source_discovery_candidates(sport_code, league_id, team_id, player_id);

CREATE INDEX IF NOT EXISTS ix_media_source_discovery_domain
ON ops.media_source_discovery_candidates(source_domain);