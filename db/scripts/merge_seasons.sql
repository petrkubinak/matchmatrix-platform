-- =====================================================
-- MatchMatrix
-- Merge script: seasons
-- Purpose: merge sezón z ingest tabulky do canonical
-- =====================================================

INSERT INTO public.seasons (
    league_id,
    season_year,
    start_date,
    end_date,
    is_current
)
SELECT
    league_id,
    season_year,
    start_date,
    end_date,
    is_current
FROM staging.seasons_import
ON CONFLICT (league_id, season_year)
DO UPDATE SET
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date,
    is_current = EXCLUDED.is_current;