/*
===============================================================================
MATCHMATRIX 20_3_B – CORE READINESS BY SPORT BEFORE HARVEST / FAST FIX
===============================================================================

CO TO JE:
Rychlý audit CORE vrstvy po sportech bez velkých násobících joinů.

K ČEMU TO JE:
Bezpečně zjistíme počet lig, týmů a zápasů po sportech před harvestem.

KDE TO UVIDÍME:
DBeaver / OPS Harvest Readiness.

JAK SE TO VYUŽIJE:
Určíme CORE status: READY / PARTIAL / DATA_GAP.

SOUBOR:
20_3_B_core_readiness_by_sport_before_harvest.sql

KAM ULOŽIT:
C:\MatchMatrix-platform\db\ops\20_3\

JAK SPUSTIT:
DBeaver → spustit celý SQL skript.
===============================================================================
*/

WITH
league_counts AS (
    SELECT sport_id, COUNT(*) AS leagues_count
    FROM public.leagues
    GROUP BY sport_id
),
team_counts AS (
    SELECT sport_id, COUNT(*) AS teams_count
    FROM public.teams
    GROUP BY sport_id
),
match_counts AS (
    SELECT sport_id, COUNT(*) AS matches_count
    FROM public.matches
    GROUP BY sport_id
)
SELECT
    s.code AS sport_code,
    s.name AS sport_name,
    COALESCE(l.leagues_count, 0) AS leagues_count,
    COALESCE(t.teams_count, 0) AS teams_count,
    COALESCE(m.matches_count, 0) AS matches_count,
    CASE
        WHEN COALESCE(m.matches_count, 0) >= 1000
         AND COALESCE(t.teams_count, 0) >= 100
         AND COALESCE(l.leagues_count, 0) >= 10
            THEN 'READY'
        WHEN COALESCE(m.matches_count, 0) > 0
          OR COALESCE(t.teams_count, 0) > 0
          OR COALESCE(l.leagues_count, 0) > 0
            THEN 'PARTIAL'
        ELSE 'DATA_GAP'
    END AS core_status
FROM public.sports s
LEFT JOIN league_counts l ON l.sport_id = s.id
LEFT JOIN team_counts t ON t.sport_id = s.id
LEFT JOIN match_counts m ON m.sport_id = s.id
ORDER BY
    matches_count DESC,
    teams_count DESC;