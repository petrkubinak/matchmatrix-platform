/*
MATCHMATRIX SQL 117_O
PEOPLE PROVIDER HUNT MATRIX V1

CO TO JE:
- Centrální matice pro hledání a řízení PEOPLE providerů.

K ČEMU TO JE:
- Ukáže co chybí pro každý sport.
- Ukáže jakého providera máme.
- Ukáže jestli potřebujeme FREE nebo PRO zdroj.
- Bude řídit budoucí provider hunting.

KDE TO UVIDÍME:
- OPS Panel -> PEOPLE
- OPS Panel -> PROVIDEŘI
- OPS Panel -> ROADMAP

JAK SE TO VYUŽIJE:
- Před PRO harvestem.
- Při hledání nových providerů.
- Při plánování rozšíření People vrstvy.
*/

CREATE OR REPLACE VIEW ops.v_people_provider_hunt_matrix_v1 AS
WITH readiness AS (
    SELECT
        sport_code,
        sport_name,
        players_count,
        coaches_count,
        people_master_score,
        people_master_status
    FROM ops.v_people_master_readiness_v1
),
providers AS (
    SELECT
        sport_code,

        COUNT(*) AS provider_count,

        STRING_AGG(
            DISTINCT people_provider,
            ', '
            ORDER BY people_provider
        ) AS providers,

        MAX(
            CASE
                WHEN provider_status = 'PUBLIC_CONFIRMED' THEN 5
                WHEN provider_status = 'STAGING_CONFIRMED' THEN 4
                WHEN provider_status = 'WAIT_SCOPE_FIX' THEN 3
                WHEN provider_status = 'WAIT_PROVIDER_DOC_CHECK' THEN 2
                WHEN provider_status = 'WAIT_PROVIDER' THEN 1
                ELSE 0
            END
        ) AS provider_score

    FROM ops.people_master_provider_matrix
    GROUP BY sport_code
),
audit_summary AS (
    SELECT
        sport_code,

        COUNT(*) FILTER (
            WHERE final_verdict IN (
                'PUBLIC_CONFIRMED',
                'STAGING_CONFIRMED'
            )
        ) AS confirmed_endpoints,

        COUNT(*) FILTER (
            WHERE requires_pro = true
        ) AS requires_pro_endpoints,

        COUNT(*) FILTER (
            WHERE alternative_provider_needed = true
        ) AS alternative_provider_needed

    FROM ops.provider_people_audit
    GROUP BY sport_code
)
SELECT

    r.sport_code,
    r.sport_name,

    r.players_count,
    r.coaches_count,

    COALESCE(p.provider_count,0) AS provider_count,
    COALESCE(p.providers,'NENÍ') AS providers,

    COALESCE(a.confirmed_endpoints,0) AS confirmed_endpoints,
    COALESCE(a.requires_pro_endpoints,0) AS requires_pro_endpoints,
    COALESCE(a.alternative_provider_needed,0) AS alternative_provider_needed,

    r.people_master_score,
    r.people_master_status,

    CASE

        WHEN r.players_count = 0
        THEN 'HRÁČI'

        WHEN r.people_master_status = 'STATS_GAP'
        THEN 'SEASON_STATS, MATCH_STATS'

        WHEN COALESCE(a.alternative_provider_needed,0) > 0
        THEN 'NOVÝ_PROVIDER'

        ELSE 'ENRICHMENT'

    END AS missing_area,

    CASE

        WHEN r.sport_code IN ('HB','VB','RGB','FH')
        THEN 'KRITICKÁ'

        WHEN r.sport_code IN ('HK','BK','BSB','CK','MMA')
        THEN 'VYSOKÁ'

        WHEN r.sport_code IN ('TN','AFB')
        THEN 'STŘEDNÍ'

        ELSE 'NÍZKÁ'

    END AS provider_hunt_priority,

    CASE

        WHEN r.players_count = 0
        THEN 'Najít provider pro hráče a trenéry.'

        WHEN r.people_master_status = 'STATS_GAP'
        THEN 'Najít provider pro player season stats a match stats.'

        WHEN COALESCE(a.alternative_provider_needed,0) > 0
        THEN 'Prověřit alternativního providera.'

        ELSE 'Rozšiřovat coverage a enrichment.'

    END AS next_action

FROM readiness r
LEFT JOIN providers p
    ON p.sport_code = r.sport_code
LEFT JOIN audit_summary a
    ON a.sport_code = r.sport_code

ORDER BY
    CASE
        WHEN r.sport_code IN ('HB','VB','RGB','FH') THEN 1
        WHEN r.sport_code IN ('HK','BK','BSB','CK','MMA') THEN 2
        WHEN r.sport_code IN ('TN','AFB') THEN 3
        ELSE 4
    END,
    r.people_master_score;