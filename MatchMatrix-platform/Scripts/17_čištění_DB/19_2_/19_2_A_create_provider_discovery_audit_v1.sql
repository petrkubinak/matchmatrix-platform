/*
MATCHMATRIX SQL 20_A

PROVIDER DISCOVERY AUDIT V1

CO TO JE:
- Centrální audit chybějících a částečných providerů před PC2.

K ČEMU TO JE:
- Ukáže, kde máme providera připraveného.
- Ukáže, kde máme pouze částečnou podporu.
- Ukáže, kde musíme hledat nového providera.
- Připraví plán pro FREE / PAID provider expansion.

KDE TO UVIDÍME:
- OPS Panel
- Provider Command Center
- PC2 Harvest Readiness
- People / Media / Odds roadmap

JAK SE TO VYUŽIJE:
- Před PC2 rozhodneme, které providery otestovat.
- Před PRO aktivací rozhodneme, co má největší hodnotu.
- Panel ukáže konkrétní missing oblasti místo obecných procent.

NAVAZUJE NA:
- 19_A až 19_E Player Duplicate Prevention
- 23_3_M Provider Research Master Plan
- 23_3_N Provider Priority Matrix

DALŠÍ KROK:
- 20_B_create_missing_provider_matrix_v1.sql
*/

DROP VIEW IF EXISTS ops.v_provider_discovery_audit_v1;

CREATE OR REPLACE VIEW ops.v_provider_discovery_audit_v1 AS

WITH people_base AS (
    SELECT
        sport_code,
        sport_name,
        people_provider AS provider,
        'PEOPLE'::text AS discovery_layer,

        players_supported,
        coaches_supported,
        profiles_supported,
        season_stats_supported,
        match_stats_supported,
        rankings_supported,
        photos_supported,

        provider_status,
        priority_order,
        notes,
        updated_at
    FROM ops.people_master_provider_matrix
),

expanded AS (
    SELECT
        sport_code,
        sport_name,
        provider,
        discovery_layer,
        'PLAYERS'::text AS target_entity,
        players_supported AS is_supported,
        provider_status,
        priority_order,
        notes,
        updated_at
    FROM people_base

    UNION ALL

    SELECT
        sport_code,
        sport_name,
        provider,
        discovery_layer,
        'COACHES',
        coaches_supported,
        provider_status,
        priority_order,
        notes,
        updated_at
    FROM people_base

    UNION ALL

    SELECT
        sport_code,
        sport_name,
        provider,
        discovery_layer,
        'PROFILES',
        profiles_supported,
        provider_status,
        priority_order,
        notes,
        updated_at
    FROM people_base

    UNION ALL

    SELECT
        sport_code,
        sport_name,
        provider,
        discovery_layer,
        'SEASON_STATS',
        season_stats_supported,
        provider_status,
        priority_order,
        notes,
        updated_at
    FROM people_base

    UNION ALL

    SELECT
        sport_code,
        sport_name,
        provider,
        discovery_layer,
        'MATCH_STATS',
        match_stats_supported,
        provider_status,
        priority_order,
        notes,
        updated_at
    FROM people_base

    UNION ALL

    SELECT
        sport_code,
        sport_name,
        provider,
        discovery_layer,
        'RANKINGS',
        rankings_supported,
        provider_status,
        priority_order,
        notes,
        updated_at
    FROM people_base

    UNION ALL

    SELECT
        sport_code,
        sport_name,
        provider,
        discovery_layer,
        'PHOTOS',
        photos_supported,
        provider_status,
        priority_order,
        notes,
        updated_at
    FROM people_base
),

classified AS (
    SELECT
        sport_code,
        sport_name,
        provider,
        discovery_layer,
        target_entity,
        is_supported,
        provider_status,
        priority_order,
        notes,
        updated_at,

        CASE
            WHEN is_supported = true
             AND provider_status IN ('READY','CONFIRMED','PUBLIC_CONFIRMED','runtime_tested','tech_ready')
                THEN 'READY'

            WHEN is_supported = true
             AND provider_status IN ('PARTIAL','planned','tech_ready','runtime_tested')
                THEN 'PARTIAL'

            WHEN provider_status ILIKE '%paid%'
              OR provider_status ILIKE '%pro%'
              OR provider_status ILIKE '%subscription%'
                THEN 'WAIT_FOR_PAID_PLAN'

            WHEN is_supported = false
                THEN 'MISSING'

            ELSE 'RESEARCH_REQUIRED'
        END AS discovery_status,

        CASE
            WHEN target_entity = 'PLAYERS' THEN 100
            WHEN target_entity = 'PHOTOS' THEN 95
            WHEN target_entity = 'COACHES' THEN 85
            WHEN target_entity IN ('SEASON_STATS','MATCH_STATS') THEN 80
            WHEN target_entity = 'PROFILES' THEN 75
            WHEN target_entity = 'RANKINGS' THEN 60
            ELSE 50
        END AS strategic_score,

        CASE
            WHEN is_supported = true
             AND provider_status IN ('READY','CONFIRMED','PUBLIC_CONFIRMED','runtime_tested','tech_ready')
                THEN 'Použít pro PC2 harvest nebo další smoke test.'

            WHEN is_supported = true
                THEN 'Doplnit runtime test / worker / merge.'

            WHEN target_entity = 'PHOTOS'
                THEN 'Najít provider fotek hráčů/trenérů.'

            WHEN target_entity = 'COACHES'
                THEN 'Najít nebo otestovat coaches endpoint.'

            WHEN target_entity IN ('SEASON_STATS','MATCH_STATS')
                THEN 'Najít statistický endpoint nebo placený plán.'

            ELSE 'Provést provider research.'
        END AS recommended_next_step

    FROM expanded
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE discovery_status
                WHEN 'MISSING' THEN 1
                WHEN 'RESEARCH_REQUIRED' THEN 2
                WHEN 'PARTIAL' THEN 3
                WHEN 'WAIT_FOR_PAID_PLAN' THEN 4
                WHEN 'READY' THEN 5
                ELSE 9
            END,
            strategic_score DESC,
            sport_code,
            provider,
            target_entity
    ) AS discovery_rank,

    sport_code,
    sport_name,
    provider,
    discovery_layer,
    target_entity,
    is_supported,
    provider_status,
    discovery_status,
    strategic_score,
    recommended_next_step,
    priority_order,
    notes,
    updated_at,
    now() AS refreshed_at
FROM classified;