/*
MATCHMATRIX SCRIPT

NÁZEV:
20_3_G_final_pre_harvest_readiness_summary_v2.sql

CO TO JE:
Rychlý finální souhrn připravenosti CORE + PEOPLE + MEDIA před velkým harvestem.

K ČEMU TO JE:
Spojí CORE, PEOPLE a MEDIA připravenost bez těžkých násobících JOINů.

KDE TO UVIDÍME:
DBeaver, později OPS / Harvest Readiness panel.

JAK SE TO VYUŽIJE:
Rozhodnutí, které sporty jsou připravené na velký harvest.
*/

WITH sport_base AS (
    SELECT
        id AS sport_id,
        code AS sport_code,
        name AS sport_name
    FROM public.sports
),

league_counts AS (
    SELECT sport_id, COUNT(*) AS leagues
    FROM public.leagues
    GROUP BY sport_id
),

team_counts AS (
    SELECT sport_id, COUNT(*) AS teams
    FROM public.teams
    GROUP BY sport_id
),

match_counts AS (
    SELECT sport_id, COUNT(*) AS matches
    FROM public.matches
    GROUP BY sport_id
),

player_counts AS (
    SELECT sport_id, COUNT(*) AS players
    FROM public.players
    GROUP BY sport_id
),

player_map_counts AS (
    SELECT
        p.sport_id,
        COUNT(DISTINCT ppm.id) AS player_maps
    FROM public.player_provider_map ppm
    JOIN public.players p
        ON p.id = ppm.player_id
    GROUP BY p.sport_id
),

media_article_sports AS (
    SELECT t.sport_id, atm.article_id
    FROM public.article_team_map atm
    JOIN public.teams t ON t.id = atm.team_id

    UNION

    SELECT p.sport_id, apm.article_id
    FROM public.article_player_map apm
    JOIN public.players p ON p.id = apm.player_id

    UNION

    SELECT m.sport_id, amm.article_id
    FROM public.article_match_map amm
    JOIN public.matches m ON m.id = amm.match_id
),

media_counts AS (
    SELECT
        sport_id,
        COUNT(DISTINCT article_id) AS media_articles
    FROM media_article_sports
    GROUP BY sport_id
)

SELECT
    sb.sport_code,
    sb.sport_name,

    COALESCE(lc.leagues, 0) AS leagues,
    COALESCE(tc.teams, 0) AS teams,
    COALESCE(mc.matches, 0) AS matches,

    COALESCE(pc.players, 0) AS players,
    COALESCE(pmc.player_maps, 0) AS player_maps,

    COALESCE(mdc.media_articles, 0) AS media_articles,

    CASE
        WHEN COALESCE(lc.leagues, 0) > 0
         AND COALESCE(tc.teams, 0) > 0
         AND COALESCE(mc.matches, 0) > 0
            THEN 'READY'
        WHEN COALESCE(lc.leagues, 0) > 0
          OR COALESCE(tc.teams, 0) > 0
          OR COALESCE(mc.matches, 0) > 0
            THEN 'PARTIAL'
        ELSE 'DATA_GAP'
    END AS core_status,

    CASE
        WHEN COALESCE(pc.players, 0) > 0
         AND COALESCE(pmc.player_maps, 0) >= COALESCE(pc.players, 0)
            THEN 'READY'
        WHEN COALESCE(pc.players, 0) > 0
            THEN 'PARTIAL'
        ELSE 'DATA_GAP'
    END AS people_status,

    CASE
        WHEN COALESCE(mdc.media_articles, 0) > 0
            THEN 'PARTIAL_READY'
        ELSE 'DATA_GAP'
    END AS media_status,

    CASE
        WHEN COALESCE(lc.leagues, 0) > 0
         AND COALESCE(tc.teams, 0) > 0
         AND COALESCE(mc.matches, 0) > 0
            THEN 'HARVEST_READY'
        ELSE 'HARVEST_REVIEW'
    END AS final_pre_harvest_status,

    CASE
        WHEN COALESCE(mc.matches, 0) = 0
            THEN 'Nejdříve doplnit CORE zápasy.'
        WHEN COALESCE(pc.players, 0) = 0
            THEN 'CORE lze harvestovat, PEOPLE má datovou mezeru.'
        WHEN COALESCE(mdc.media_articles, 0) = 0
            THEN 'CORE/PEOPLE lze harvestovat, MEDIA není blokace.'
        ELSE 'Sport je připravený pro další harvest.'
    END AS next_action

FROM sport_base sb
LEFT JOIN league_counts lc ON lc.sport_id = sb.sport_id
LEFT JOIN team_counts tc ON tc.sport_id = sb.sport_id
LEFT JOIN match_counts mc ON mc.sport_id = sb.sport_id
LEFT JOIN player_counts pc ON pc.sport_id = sb.sport_id
LEFT JOIN player_map_counts pmc ON pmc.sport_id = sb.sport_id
LEFT JOIN media_counts mdc ON mdc.sport_id = sb.sport_id
ORDER BY
    CASE
        WHEN COALESCE(mc.matches, 0) > 0 THEN 1 ELSE 2
    END,
    COALESCE(mc.matches, 0) DESC,
    sb.sport_code;