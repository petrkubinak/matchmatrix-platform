/*
================================================================================
MATCHMATRIX 104_Q - BACKFILL PLAYERS SPORT_ID V1
================================================================================

Co skript dělá:
- doplní sport_id do public.players
- jen pro hráče s jednoznačným sportem podle:
  1) player_match_statistics -> matches
  2) player_season_statistics -> leagues

Bezpečnost:
- multi-sport riziko zůstane NULL
- hráči bez evidence zůstanou NULL
================================================================================
*/

WITH player_sports AS (
    SELECT
        pms.player_id,
        m.sport_id
    FROM public.player_match_statistics pms
    JOIN public.matches m
        ON m.id = pms.match_id
    WHERE m.sport_id IS NOT NULL

    UNION

    SELECT
        pss.player_id,
        l.sport_id
    FROM public.player_season_statistics pss
    JOIN public.leagues l
        ON l.id = pss.league_id
    WHERE l.sport_id IS NOT NULL
),
resolved AS (
    SELECT
        player_id,
        COUNT(DISTINCT sport_id) AS sport_count,
        MIN(sport_id) AS resolved_sport_id
    FROM player_sports
    GROUP BY player_id
)
UPDATE public.players p
SET sport_id = r.resolved_sport_id
FROM resolved r
WHERE p.id = r.player_id
  AND r.sport_count = 1
  AND p.sport_id IS NULL;