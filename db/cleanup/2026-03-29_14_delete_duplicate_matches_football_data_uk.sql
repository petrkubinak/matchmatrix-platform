-- =========================================================
-- MatchMatrix
-- Soubor: C:\MatchMatrix-platform\db\cleanup\2026-03-29_15_delete_duplicate_matches_fd_uk_by_match_identity.sql
-- Účel: smazat duplicity football_data_uk podle identity zápasu
-- Logika:
-- - pro stejný league_id + season + kickoff + home_team_id + away_team_id + ext_source
--   necháme jen 1 řádek (nejmenší id)
-- - ext_match_id ignorujeme, protože se liší prefixem a dělá falešně unikátní řádky
-- =========================================================

WITH ranked AS (
    SELECT
        m.id,
        ROW_NUMBER() OVER (
            PARTITION BY
                m.league_id,
                m.season,
                m.kickoff,
                m.home_team_id,
                m.away_team_id,
                COALESCE(m.ext_source, '')
            ORDER BY m.id
        ) AS rn
    FROM public.matches m
    WHERE m.ext_source = 'football_data_uk'
)
DELETE FROM public.matches m
USING ranked r
WHERE m.id = r.id
  AND r.rn > 1;