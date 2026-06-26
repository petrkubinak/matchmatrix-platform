/*
MATCHMATRIX SCRIPT
NÁZEV: 20_3_D_media_readiness_by_sport_before_harvest_v3.sql

CO TO JE:
Rychlý audit Media vrstvy podle sportů před velkým harvestem dat.

K ČEMU TO JE:
Změří články a media vazby podle sportu přes:
- article_team_map
- article_player_map
- article_match_map

KDE TO UVIDÍME:
Výstup v DBeaveru, později OPS / Media Command Center.

JAK SE TO VYUŽIJE:
Určí READY / PARTIAL / DATA_GAP pro Media vrstvu před velkým harvestem.

POZNÁMKA:
Verze V3 neopakuje těžký join teams + players + matches najednou.
Každé počítání je oddělené, aby dotaz neběžel dlouho.
*/

WITH sport_base AS (
    SELECT
        s.id AS sport_id,
        s.code AS sport_code,
        s.name AS sport_name
    FROM public.sports s
),

teams_total AS (
    SELECT
        sport_id,
        COUNT(*) AS teams_total
    FROM public.teams
    GROUP BY sport_id
),

players_total AS (
    SELECT
        sport_id,
        COUNT(*) AS players_total
    FROM public.players
    GROUP BY sport_id
),

matches_total AS (
    SELECT
        sport_id,
        COUNT(*) AS matches_total
    FROM public.matches
    GROUP BY sport_id
),

team_media AS (
    SELECT
        t.sport_id,
        COUNT(DISTINCT atm.article_id) AS article_team_map,
        COUNT(DISTINCT atm.team_id) AS teams_with_media
    FROM public.article_team_map atm
    JOIN public.teams t
        ON t.id = atm.team_id
    GROUP BY t.sport_id
),

player_media AS (
    SELECT
        p.sport_id,
        COUNT(DISTINCT apm.article_id) AS article_player_map,
        COUNT(DISTINCT apm.player_id) AS players_with_media
    FROM public.article_player_map apm
    JOIN public.players p
        ON p.id = apm.player_id
    GROUP BY p.sport_id
),

match_media AS (
    SELECT
        m.sport_id,
        COUNT(DISTINCT amm.article_id) AS article_match_map,
        COUNT(DISTINCT amm.match_id) AS matches_with_media
    FROM public.article_match_map amm
    JOIN public.matches m
        ON m.id = amm.match_id
    GROUP BY m.sport_id
),

article_union AS (
    SELECT
        t.sport_id,
        atm.article_id
    FROM public.article_team_map atm
    JOIN public.teams t
        ON t.id = atm.team_id

    UNION

    SELECT
        p.sport_id,
        apm.article_id
    FROM public.article_player_map apm
    JOIN public.players p
        ON p.id = apm.player_id

    UNION

    SELECT
        m.sport_id,
        amm.article_id
    FROM public.article_match_map amm
    JOIN public.matches m
        ON m.id = amm.match_id
),

article_counts AS (
    SELECT
        sport_id,
        COUNT(DISTINCT article_id) AS articles
    FROM article_union
    GROUP BY sport_id
)

SELECT
    sb.sport_code,
    sb.sport_name,

    COALESCE(ac.articles, 0) AS articles,

    COALESCE(tm.article_team_map, 0) AS article_team_map,
    COALESCE(pm.article_player_map, 0) AS article_player_map,
    COALESCE(mm.article_match_map, 0) AS article_match_map,

    COALESCE(tt.teams_total, 0) AS teams_total,
    COALESCE(tm.teams_with_media, 0) AS teams_with_media,

    COALESCE(pt.players_total, 0) AS players_total,
    COALESCE(pm.players_with_media, 0) AS players_with_media,

    COALESCE(mt.matches_total, 0) AS matches_total,
    COALESCE(mm.matches_with_media, 0) AS matches_with_media,

    ROUND(
        CASE
            WHEN COALESCE(tt.teams_total, 0) = 0 THEN 0
            ELSE COALESCE(tm.teams_with_media, 0)::numeric / tt.teams_total * 100
        END,
        2
    ) AS team_media_coverage_pct,

    ROUND(
        CASE
            WHEN COALESCE(pt.players_total, 0) = 0 THEN 0
            ELSE COALESCE(pm.players_with_media, 0)::numeric / pt.players_total * 100
        END,
        2
    ) AS player_media_coverage_pct,

    ROUND(
        CASE
            WHEN COALESCE(mt.matches_total, 0) = 0 THEN 0
            ELSE COALESCE(mm.matches_with_media, 0)::numeric / mt.matches_total * 100
        END,
        2
    ) AS match_media_coverage_pct,

    CASE
        WHEN COALESCE(ac.articles, 0) = 0
            THEN 'DATA_GAP'

        WHEN COALESCE(tm.article_team_map, 0) > 0
         AND COALESCE(pm.article_player_map, 0) > 0
         AND COALESCE(mm.article_match_map, 0) > 0
            THEN 'READY'

        ELSE 'PARTIAL'
    END AS media_readiness_status,

    CASE
        WHEN COALESCE(ac.articles, 0) = 0
            THEN 'Chybí články nebo nejsou napojené na sport.'
        WHEN COALESCE(tm.article_team_map, 0) = 0
            THEN 'Chybí napojení článků na týmy.'
        WHEN COALESCE(pm.article_player_map, 0) = 0
            THEN 'Chybí napojení článků na hráče.'
        WHEN COALESCE(mm.article_match_map, 0) = 0
            THEN 'Chybí napojení článků na zápasy.'
        ELSE 'Media vrstva má základní vazby.'
    END AS next_action

FROM sport_base sb
LEFT JOIN teams_total tt
    ON tt.sport_id = sb.sport_id
LEFT JOIN players_total pt
    ON pt.sport_id = sb.sport_id
LEFT JOIN matches_total mt
    ON mt.sport_id = sb.sport_id
LEFT JOIN team_media tm
    ON tm.sport_id = sb.sport_id
LEFT JOIN player_media pm
    ON pm.sport_id = sb.sport_id
LEFT JOIN match_media mm
    ON mm.sport_id = sb.sport_id
LEFT JOIN article_counts ac
    ON ac.sport_id = sb.sport_id
ORDER BY
    CASE
        WHEN COALESCE(ac.articles, 0) = 0 THEN 3
        WHEN COALESCE(mm.article_match_map, 0) = 0 THEN 2
        ELSE 1
    END,
    COALESCE(ac.articles, 0) DESC,
    sb.sport_code;