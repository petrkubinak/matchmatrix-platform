BEGIN;

-- 531_repoint_universidad_catolica_league_standings.sql
-- Cíl:
-- Přepsat FK reference v public.league_standings
-- z duplicitního team_id=10979 na canonical team_id=603.

-- 1) Kontrola před změnou
SELECT
    id,
    league_id,
    season,
    team_id,
    position,
    points
FROM public.league_standings
WHERE team_id IN (603, 10979)
ORDER BY season, league_id, position, id;

-- 2) Přepis FK reference
UPDATE public.league_standings
SET team_id = 603
WHERE team_id = 10979;

-- 3) Kontrola po změně
SELECT
    id,
    league_id,
    season,
    team_id,
    position,
    points
FROM public.league_standings
WHERE team_id IN (603, 10979)
ORDER BY season, league_id, position, id;

COMMIT;