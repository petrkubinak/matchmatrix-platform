/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_B_core_harvest_operator_queue_v1.sql

CO TO JE:
Zdrojová fronta pro Operator Panel – řízený CORE harvest podle sportů.

K ČEMU TO JE:
Panel uvidí, které sporty jsou připravené pro historický CORE harvest
a následně pro aktuální sezónu + PEOPLE + MEDIA + ODDS.

KDE TO UVIDÍME:
OPS Panel → Denní práce / Operator Console.

JAK SE TO VYUŽIJE:
Operátor nebude ručně hledat, co spustit.
Panel ukáže další bezpečný krok v pořadí:
HISTORICAL_CORE → CURRENT_CORE → CURRENT_PEOPLE → CURRENT_MEDIA → CURRENT_ODDS.
*/

CREATE OR REPLACE VIEW ops.v_operator_core_harvest_queue_v1 AS
WITH core_counts AS (
    SELECT
        s.id AS sport_id,
        s.code AS sport_code,
        s.name AS sport_name,
        COUNT(DISTINCT l.id) AS leagues,
        COUNT(DISTINCT t.id) AS teams,
        COUNT(DISTINCT m.id) AS matches
    FROM public.sports s
    LEFT JOIN public.leagues l ON l.sport_id = s.id
    LEFT JOIN public.teams t ON t.sport_id = s.id
    LEFT JOIN public.matches m ON m.sport_id = s.id
    GROUP BY s.id, s.code, s.name
),

people_counts AS (
    SELECT
        p.sport_id,
        COUNT(*) AS players
    FROM public.players p
    GROUP BY p.sport_id
),

media_counts AS (
    SELECT
        x.sport_id,
        COUNT(DISTINCT x.article_id) AS articles
    FROM (
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
    ) x
    GROUP BY x.sport_id
),

base AS (
    SELECT
        c.sport_code,
        c.sport_name,
        c.leagues,
        c.teams,
        c.matches,
        COALESCE(p.players, 0) AS players,
        COALESCE(md.articles, 0) AS media_articles,

        CASE
            WHEN c.leagues > 0 AND c.teams > 0 AND c.matches > 0
                THEN 'HARVEST_READY'
            ELSE 'HARVEST_REVIEW'
        END AS core_harvest_status

    FROM core_counts c
    LEFT JOIN people_counts p ON p.sport_id = c.sport_id
    LEFT JOIN media_counts md ON md.sport_id = c.sport_id
)

SELECT
    sport_code,
    sport_name,

    leagues,
    teams,
    matches,
    players,
    media_articles,

    core_harvest_status,

    CASE
        WHEN sport_code = 'FB' THEN 1
        WHEN sport_code = 'HB' THEN 2
        WHEN sport_code = 'HK' THEN 3
        WHEN sport_code = 'BK' THEN 4
        WHEN sport_code = 'BSB' THEN 5
        WHEN sport_code IN ('AFB', 'VB', 'TN', 'CK', 'RGB') THEN 6
        ELSE 9
    END AS harvest_priority,

    CASE
        WHEN core_harvest_status = 'HARVEST_READY'
            THEN 'HISTORICAL_CORE'
        ELSE 'CORE_REVIEW'
    END AS next_layer_step,

    CASE
        WHEN core_harvest_status = 'HARVEST_READY'
            THEN 'SPUSTIT HISTORICKÝ CORE HARVEST'
        ELSE 'NEJDŘÍVE DOPLNIT / OVĚŘIT CORE'
    END AS operator_action_cz,

    CASE
        WHEN core_harvest_status = 'HARVEST_READY'
            THEN 'Po historickém CORE navázat CURRENT_CORE → PEOPLE → MEDIA → ODDS.'
        ELSE 'Sport zatím není bezpečný pro velký CORE harvest.'
    END AS operator_note_cz,

    now() AS generated_at

FROM base
ORDER BY
    harvest_priority,
    matches DESC,
    sport_code;