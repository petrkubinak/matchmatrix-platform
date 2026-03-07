-- =========================================================
-- Soubor: 017_create_table_translation_jobs.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.translation_jobs
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.translation_jobs (
    id                  BIGSERIAL PRIMARY KEY,

    entity_type         TEXT NOT NULL,   -- article / league / team / player
    entity_id           BIGINT NOT NULL,
    source_language     TEXT NOT NULL,
    target_language     TEXT NOT NULL,

    translation_source  TEXT NULL,       -- deepl / google / openai / manual
    status              TEXT NOT NULL DEFAULT 'pending',  -- pending / processing / success / failed / reviewed

    attempt_count       INTEGER NOT NULL DEFAULT 0,
    last_attempt_at     TIMESTAMPTZ NULL,
    completed_at        TIMESTAMPTZ NULL,

    error_message       TEXT NULL,
    notes               TEXT NULL,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT ck_translation_jobs_entity_type
        CHECK (entity_type IN ('article', 'league', 'team', 'player')),

    CONSTRAINT ck_translation_jobs_status
        CHECK (status IN ('pending', 'processing', 'success', 'failed', 'reviewed'))
);

-- jedna konkrétní překladová úloha jen jednou
CREATE UNIQUE INDEX IF NOT EXISTS ux_translation_jobs_entity_lang
    ON public.translation_jobs (entity_type, entity_id, source_language, target_language);

-- rychlé načítání čekajících úloh
CREATE INDEX IF NOT EXISTS ix_translation_jobs_status
    ON public.translation_jobs (status);

-- rychlé načítání podle typu entity
CREATE INDEX IF NOT EXISTS ix_translation_jobs_entity_type
    ON public.translation_jobs (entity_type);

-- rychlé načítání podle cílového jazyka
CREATE INDEX IF NOT EXISTS ix_translation_jobs_target_language
    ON public.translation_jobs (target_language);

-- pomocný index pro frontu
CREATE INDEX IF NOT EXISTS ix_translation_jobs_queue
    ON public.translation_jobs (status, created_at);

COMMIT;