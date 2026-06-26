/*
MATCHMATRIX SQL 117_P
PEOPLE PROVIDER HUNT MATRIX V2

CO TO JE:
- Vylepšená matice pro hledání PEOPLE providerů.

K ČEMU TO JE:
- Rozlišuje obyčejný DATA_GAP od konkrétního stavu:
  PEOPLE_FALLBACK_REQUIRED.

KDE TO UVIDÍME:
- OPS Panel -> PEOPLE
- OPS Panel -> PROVIDEŘI
- OPS Panel -> ROADMAP

JAK SE TO VYUŽIJE:
- Pro sporty jako HB, kde CORE funguje,
  ale aktuální people provider vrací 0 hráčů.
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
routing AS (
    SELECT
        sport_code,
        entity,
        primary_provider AS provider,
        provider_route_state AS provider_status,
        provider_gap AS gap_status,
        routing_candidate AS is_runtime_confirmed,
        runtime_state AS runtime_status,
        coverage_status,
        db_evidence_summary AS evidence_note,
        next_action
    FROM ops.v_provider_routing_master_v2
    WHERE entity IN ('players', 'coaches')
),
providers AS (
    SELECT
        sport_code,
        COUNT(*) AS provider_count,
        array_to_string(
            array_agg(DISTINCT people_provider ORDER BY people_provider),
            ', '
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
            WHERE final_verdict IN ('PUBLIC_CONFIRMED','STAGING_CONFIRMED')
        ) AS confirmed_endpoints,
        COUNT(*) FILTER (
            WHERE requires_pro = true
        ) AS requires_pro_endpoints,
        COUNT(*) FILTER (
            WHERE alternative_provider_needed = true
        ) AS alternative_provider_needed
    FROM ops.provider_people_audit
    GROUP BY sport_code
),
routing_summary AS (
    SELECT
        sport_code,
        COUNT(*) FILTER (
            WHERE entity = 'players'
              AND provider_status = 'BLOCKED_PROVIDER'
        ) AS blocked_player_providers,
        COUNT(*) FILTER (
            WHERE entity = 'coaches'
              AND provider_status = 'BLOCKED_PROVIDER'
        ) AS blocked_coach_providers,
        STRING_AGG(
            DISTINCT provider || ':' || entity || ':' || provider_status,
            ', '
        ) AS routing_people_status
    FROM routing
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

    COALESCE(rs.blocked_player_providers,0) AS blocked_player_providers,
    COALESCE(rs.blocked_coach_providers,0) AS blocked_coach_providers,
    COALESCE(rs.routing_people_status,'') AS routing_people_status,

    r.people_master_score,
    r.people_master_status,

    CASE
        WHEN COALESCE(rs.blocked_player_providers,0) > 0
            THEN 'PEOPLE_FALLBACK_REQUIRED'
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
        WHEN COALESCE(rs.blocked_player_providers,0) > 0
            THEN 'Aktuální people provider je blokovaný. Najít fallback provider pro hráče/trenéry.'
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
LEFT JOIN routing_summary rs
    ON rs.sport_code = r.sport_code
ORDER BY
    CASE
        WHEN r.sport_code IN ('HB','VB','RGB','FH') THEN 1
        WHEN r.sport_code IN ('HK','BK','BSB','CK','MMA') THEN 2
        WHEN r.sport_code IN ('TN','AFB') THEN 3
        ELSE 4
    END,
    r.people_master_score;