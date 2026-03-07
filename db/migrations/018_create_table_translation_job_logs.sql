-- =========================================================
-- Soubor: 018_create_table_translation_job_logs.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: logování průběhu překladových úloh
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.translation_job_logs (
    id                  BIGSERIAL PRIMARY KEY,

    translation_job_id  BIGINT NOT NULL,
    log_level           TEXT NOT NULL DEFAULT 'info',   -- info / warning / error
    message             TEXT NOT NULL,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_translation_job_logs_job
        FOREIGN KEY (translation_job_id)
        REFERENCES public.translation_jobs(id)
        ON DELETE CASCADE,

    CONSTRAINT ck_translation_job_logs_level
        CHECK (log_level IN ('info', 'warning', 'error'))
);

-- rychlé načítání logů úlohy
CREATE INDEX IF NOT EXISTS ix_translation_job_logs_job_id
    ON public.translation_job_logs (translation_job_id);

-- filtrování podle typu logu
CREATE INDEX IF NOT EXISTS ix_translation_job_logs_level
    ON public.translation_job_logs (log_level);

-- rychlé řazení podle času
CREATE INDEX IF NOT EXISTS ix_translation_job_logs_created_at
    ON public.translation_job_logs (created_at);

COMMIT;