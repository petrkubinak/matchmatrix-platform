-- create_ai_entity_summaries_v1.sql
--
-- CO TO DĚLÁ:
-- Vytváří tabulku pro AI souhrny nad sportovními entitami.
-- Entita může být:
-- league, team, player, match, country, topic.
--
-- KAM TO VEDE:
-- public.ai_entity_summaries
--
-- K ČEMU TO BUDE:
-- AI vezme mnoho informací:
-- články, videa, trending, hráče, týmy, ligy, zápasy
-- a vytvoří jeden srozumitelný souhrn.
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Team page:
-- "Co je nového kolem týmu"
--
-- Player page:
-- "Proč je hráč trending"
--
-- League page:
-- "Aktuální přehled soutěže"
--
-- Homepage:
-- "AI sports briefing"
--
-- Mobilní aplikace:
-- personalizované sportovní shrnutí.

CREATE TABLE IF NOT EXISTS public.ai_entity_summaries (
    id bigserial PRIMARY KEY,

    entity_type text NOT NULL,
    entity_id bigint,
    entity_name text,

    sport_code text,
    country_code text,
    language_code text NOT NULL DEFAULT 'cs',

    summary_title text,
    summary_short text,
    summary_long text,

    key_points text[],
    related_article_ids bigint[],
    related_video_article_ids bigint[],

    source_count integer NOT NULL DEFAULT 0,
    article_count integer NOT NULL DEFAULT 0,
    video_count integer NOT NULL DEFAULT 0,

    ai_model text,
    ai_prompt_version text,
    confidence_score numeric,

    summary_status text NOT NULL DEFAULT 'draft',

    generated_at timestamptz,
    valid_until timestamptz,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_ai_entity_summary UNIQUE (
        entity_type,
        entity_id,
        sport_code,
        language_code
    )
);

CREATE INDEX IF NOT EXISTS ix_ai_entity_summaries_entity
ON public.ai_entity_summaries(entity_type, entity_id);

CREATE INDEX IF NOT EXISTS ix_ai_entity_summaries_status
ON public.ai_entity_summaries(summary_status);

CREATE INDEX IF NOT EXISTS ix_ai_entity_summaries_sport
ON public.ai_entity_summaries(sport_code);


-- KONTROLA
SELECT
    COUNT(*) AS ai_summaries
FROM public.ai_entity_summaries;