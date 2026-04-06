BEGIN;

-- 540_repoint_ucv_league_standings_27876_to_35254.sql
-- Cíl:
-- Přepsat FK reference v public.league_standings
-- z duplicitního team_id=27876 na canonical team_id=35254.

-- 1) Kontrola před změnou
SELECT
    id,
    league_id,
    season,
    team_id,
    position,
    points
FROM public.league_standings
WHERE team_id IN (27876, 35254)
ORDER BY season, league_id, position, id;

-- 2) Přepis FK reference
UPDATE public.league_standings
SET team_id = 35254
WHERE team_id = 27876;

-- 3) Kontrola po změně
SELECT
    id,
    league_id,
    season,
    team_id,
    position,
    points
FROM public.league_standings
WHERE team_id IN (27876, 35254)
ORDER BY season, league_id, position, id;

COMMIT;