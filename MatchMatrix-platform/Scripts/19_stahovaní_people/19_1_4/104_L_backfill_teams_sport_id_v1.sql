/*
================================================================================
MATCHMATRIX 104_L - BACKFILL TEAMS SPORT_ID V1
================================================================================

Co skript dělá:
- doplní public.teams.sport_id
- pouze pro týmy s jednoznačným sportem

BEZPEČNOST:
- multi-sport týmy zůstanou NULL
- týmy bez evidence ve matches zůstanou NULL

K čemu to slouží:
- canonical multisport architecture
- cleaner joins
- AI layer
- media/entity matching
================================================================================
*/

WITH team_sports AS (

    SELECT
        home_team_id AS team_id,
        sport_id
    FROM public.matches
    WHERE home_team_id IS NOT NULL
      AND sport_id IS NOT NULL

    UNION

    SELECT
        away_team_id AS team_id,
        sport_id
    FROM public.matches
    WHERE away_team_id IS NOT NULL
      AND sport_id IS NOT NULL
),

resolved AS (

    SELECT
        team_id,
        COUNT(DISTINCT sport_id) AS sport_count,
        MIN(sport_id) AS resolved_sport_id
    FROM team_sports
    GROUP BY team_id
)

UPDATE public.teams t
SET
    sport_id = r.resolved_sport_id
FROM resolved r
WHERE t.id = r.team_id
  AND r.sport_count = 1
  AND t.sport_id IS NULL;