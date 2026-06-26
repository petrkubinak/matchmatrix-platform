/*
MATCHMATRIX 19_6_C – PLAYER ENRICHMENT PRIORITY QUEUE

CO TO JE:
Prioritní fronta konkrétních hráčů k obohacení profilu.

K ČEMU TO JE:
Ukáže, kteří hráči mají nejvíce chybějících údajů.

KDE TO UVIDÍME:
OPS Panel -> PEOPLE -> PLAYER ENRICHMENT QUEUE

JAK SE TO VYUŽIJE:
Bude vstupem pro budoucí enrichment workery, Photo Layer 2.0 a Source Discovery.
*/

CREATE OR REPLACE VIEW ops.v_player_enrichment_priority_queue_v1 AS
SELECT
    p.id AS player_id,
    s.code AS sport_code,
    s.name AS sport_name,
    p.team_id,
    p.name,
    p.first_name,
    p.last_name,
    p.ext_source,
    p.ext_player_id,

    concat_ws(', ',
        CASE WHEN p.birth_date IS NULL THEN 'birth_date' END,
        CASE WHEN p.nationality IS NULL OR btrim(p.nationality) = '' THEN 'nationality' END,
        CASE WHEN p.position IS NULL OR btrim(p.position) = '' THEN 'position' END,
        CASE WHEN p.height_cm IS NULL THEN 'height_cm' END,
        CASE WHEN p.weight_kg IS NULL THEN 'weight_kg' END,
        CASE WHEN p.photo_url IS NULL OR btrim(p.photo_url) = '' THEN 'photo_url' END,
        CASE WHEN p.team_id IS NULL THEN 'team_id' END
    ) AS missing_fields,

    (
        CASE WHEN p.birth_date IS NULL THEN 150 ELSE 0 END +
        CASE WHEN p.photo_url IS NULL OR btrim(p.photo_url) = '' THEN 130 ELSE 0 END +
        CASE WHEN p.team_id IS NULL THEN 120 ELSE 0 END +
        CASE WHEN p.nationality IS NULL OR btrim(p.nationality) = '' THEN 100 ELSE 0 END +
        CASE WHEN p.position IS NULL OR btrim(p.position) = '' THEN 90 ELSE 0 END +
        CASE WHEN p.height_cm IS NULL THEN 60 ELSE 0 END +
        CASE WHEN p.weight_kg IS NULL THEN 60 ELSE 0 END
    ) AS enrichment_score,

    CASE
        WHEN p.birth_date IS NULL THEN 'DOPLNIT DATUM NAROZENÍ'
        WHEN p.photo_url IS NULL OR btrim(p.photo_url) = '' THEN 'DOPLNIT FOTO'
        WHEN p.team_id IS NULL THEN 'DOPLNIT TÝM'
        WHEN p.nationality IS NULL OR btrim(p.nationality) = '' THEN 'DOPLNIT NÁRODNOST'
        WHEN p.position IS NULL OR btrim(p.position) = '' THEN 'DOPLNIT POZICI'
        ELSE 'KONTROLA PROFILU'
    END AS next_action,

    CASE
        WHEN s.code = 'FB' THEN 'api_football / official club site / photo layer'
        WHEN s.code IN ('HK','BK','BSB','AFB') THEN 'sportsdataio / official team site / wikidata'
        WHEN s.code IN ('TN','MMA','CK') THEN 'provider research / wikidata / official profile'
        ELSE 'source discovery'
    END AS suggested_source,

    CASE
        WHEN (
            CASE WHEN p.birth_date IS NULL THEN 150 ELSE 0 END +
            CASE WHEN p.photo_url IS NULL OR btrim(p.photo_url) = '' THEN 130 ELSE 0 END +
            CASE WHEN p.team_id IS NULL THEN 120 ELSE 0 END +
            CASE WHEN p.nationality IS NULL OR btrim(p.nationality) = '' THEN 100 ELSE 0 END +
            CASE WHEN p.position IS NULL OR btrim(p.position) = '' THEN 90 ELSE 0 END +
            CASE WHEN p.height_cm IS NULL THEN 60 ELSE 0 END +
            CASE WHEN p.weight_kg IS NULL THEN 60 ELSE 0 END
        ) >= 500 THEN 'HIGH_PRIORITY'
        WHEN (
            CASE WHEN p.birth_date IS NULL THEN 150 ELSE 0 END +
            CASE WHEN p.photo_url IS NULL OR btrim(p.photo_url) = '' THEN 130 ELSE 0 END +
            CASE WHEN p.team_id IS NULL THEN 120 ELSE 0 END +
            CASE WHEN p.nationality IS NULL OR btrim(p.nationality) = '' THEN 100 ELSE 0 END +
            CASE WHEN p.position IS NULL OR btrim(p.position) = '' THEN 90 ELSE 0 END +
            CASE WHEN p.height_cm IS NULL THEN 60 ELSE 0 END +
            CASE WHEN p.weight_kg IS NULL THEN 60 ELSE 0 END
        ) >= 300 THEN 'MEDIUM_PRIORITY'
        ELSE 'LOW_PRIORITY'
    END AS priority_level

FROM public.players p
LEFT JOIN public.sports s
    ON s.id = p.sport_id
WHERE
    p.birth_date IS NULL
    OR p.nationality IS NULL OR btrim(p.nationality) = ''
    OR p.position IS NULL OR btrim(p.position) = ''
    OR p.height_cm IS NULL
    OR p.weight_kg IS NULL
    OR p.photo_url IS NULL OR btrim(p.photo_url) = ''
    OR p.team_id IS NULL;