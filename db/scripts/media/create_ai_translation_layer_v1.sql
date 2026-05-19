-- create_ai_translation_layer_v1.sql
--
-- CO TO JE:
-- MULTI-LANGUAGE + AI TRANSLATION LAYER
--
-- CO TO DĚLÁ:
-- Umožní ukládat překlady článků, video popisků a AI souhrnů
-- do různých jazykových verzí.
--
-- K ČEMU TO JE:
-- MatchMatrix bude použitelný globálně:
-- Česko, Německo, Španělsko, Anglie, USA, Francie atd.
--
-- KAM TO VEDE:
-- public.ai_translations
--
-- KDE TO UVIDÍME:
-- homepage
-- league page
-- team page
-- player page
-- AI summaries
-- personalized feed
--
-- JAK TO BUDE VYPADAT NA WEBU/APLIKACI:
--
-- Uživatel zvolí jazyk:
-- CZ / EN / DE / ES / FR
--
-- Web mu zobrazí:
-- - přeložený titulek
-- - přeložený souhrn
-- - AI briefing v jeho jazyce
-- - lokální i globální zdroje v jednotném jazyce
--
-- NAVAZUJE NA:
-- articles
-- videos
-- ai_entity_summaries
-- ai_content_tags
-- personalized feed

CREATE TABLE IF NOT EXISTS public.ai_translations (
    id bigserial PRIMARY KEY,

    source_entity_type text NOT NULL,
    source_entity_id bigint NOT NULL,

    original_language_code text,
    target_language_code text NOT NULL,

    translated_title text,
    translated_short text,
    translated_long text,

    translation_status text NOT NULL DEFAULT 'draft',

    ai_model text,
    ai_prompt_version text,
    confidence_score numeric,

    generated_at timestamptz,
    valid_until timestamptz,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_ai_translation UNIQUE (
        source_entity_type,
        source_entity_id,
        target_language_code
    )
);

CREATE INDEX IF NOT EXISTS ix_ai_translations_entity
ON public.ai_translations(source_entity_type, source_entity_id);

CREATE INDEX IF NOT EXISTS ix_ai_translations_language
ON public.ai_translations(target_language_code);

CREATE INDEX IF NOT EXISTS ix_ai_translations_status
ON public.ai_translations(translation_status);


-- KONTROLA
SELECT
    COUNT(*) AS ai_translations
FROM public.ai_translations;