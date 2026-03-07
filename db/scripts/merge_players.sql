-- =====================================================
-- MatchMatrix
-- Merge script: players
-- Purpose: merge hráčů z ingest tabulky
-- =====================================================

INSERT INTO public.players (
    player_name,
    birth_date,
    nationality,
    position
)
SELECT
    player_name,
    birth_date,
    nationality,
    position
FROM staging.players_import
ON CONFLICT (player_name, birth_date)
DO UPDATE SET
    nationality = EXCLUDED.nationality,
    position = EXCLUDED.position;