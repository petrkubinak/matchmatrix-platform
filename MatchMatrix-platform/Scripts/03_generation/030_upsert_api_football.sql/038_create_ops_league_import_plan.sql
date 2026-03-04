-- 038_create_ops_league_import_plan.sql
-- Tabulka pro řízený výběr lig po regionech / batche.

BEGIN;

CREATE TABLE IF NOT EXISTS ops.league_import_plan (
    provider              text    NOT NULL,
    provider_league_id    text    NOT NULL,
    sport_code            text    NOT NULL DEFAULT 'football',
    season                text    NOT NULL DEFAULT '',
    enabled               boolean NOT NULL DEFAULT true,
    tier                  integer NOT NULL DEFAULT 1,

    fixtures_days_back    integer NOT NULL DEFAULT 7,
    fixtures_days_forward integer NOT NULL DEFAULT 14,
    odds_days_forward     integer NOT NULL DEFAULT 3,

    max_requests_per_run  integer,
    notes                 text,

    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT league_import_plan_pkey PRIMARY KEY (provider, provider_league_id, season)
);

-- Auto-updated_at (máš už funkci public.set_updated_at())
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'trg_ops_league_import_plan_updated_at'
    ) THEN
        CREATE TRIGGER trg_ops_league_import_plan_updated_at
        BEFORE UPDATE ON ops.league_import_plan
        FOR EACH ROW
        EXECUTE FUNCTION public.set_updated_at();
    END IF;
END $$;

COMMIT;