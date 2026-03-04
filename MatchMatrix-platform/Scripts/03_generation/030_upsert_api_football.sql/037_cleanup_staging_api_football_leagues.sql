-- 037_cleanup_staging_api_football_leagues.sql
-- Fyzicky smaže duplikáty, nechá 1 řádek na league_id (nejvyšší run_id, fetched_at).
-- Bezpečné: nechává "poslední" záznam, ostatní pryč.

BEGIN;

WITH keep AS (
    SELECT DISTINCT ON (league_id)
        ctid,
        league_id
    FROM staging.api_football_leagues
    ORDER BY league_id, run_id DESC, fetched_at DESC, ctid DESC
)
DELETE FROM staging.api_football_leagues s
WHERE NOT EXISTS (
    SELECT 1
    FROM keep k
    WHERE k.league_id = s.league_id
      AND k.ctid      = s.ctid
);

-- doporučení po velkém delete:
-- VACUUM (ANALYZE) staging.api_football_leagues;

COMMIT;