/*
===============================================================================
MATCHMATRIX SQL 19_5_N_FIX
PLAYER DETAIL COVERAGE PLAN - FIX
===============================================================================

CO TO JE:
- Oprava view pro plán hloubky informací o hráči.

K ČEMU TO JE:
- Původní verze padala na ORDER BY priority_order.

KDE TO UVIDÍME:
- ops.v_player_detail_coverage_plan_v1

JAK SE TO VYUŽIJE:
- Ukáže, jestli u sportu máme jen základní hráče, nebo i profily,
  statistiky, fotky, trenéry a další detailní vrstvy.
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_player_detail_coverage_plan_v1;

CREATE OR REPLACE VIEW ops.v_player_detail_coverage_plan_v1 AS
WITH base AS (
    SELECT
        sport_code,
        sport_name,
        people_provider,
        players_supported,
        coaches_supported,
        profiles_supported,
        season_stats_supported,
        match_stats_supported,
        rankings_supported,
        photos_supported,
        provider_status,
        priority_order,
        notes
    FROM ops.people_master_provider_matrix
),
runtime_players AS (
    SELECT
        sport_code,
        MAX(current_state) FILTER (WHERE entity = 'players') AS players_runtime_state,
        MAX(last_run_group) FILTER (WHERE entity = 'players') AS players_last_run_group,
        MAX(db_evidence_summary) FILTER (WHERE entity = 'players') AS players_evidence
    FROM ops.runtime_entity_audit
    GROUP BY sport_code
),
coverage AS (
    SELECT
        sport_code,
        MAX(coverage_status) FILTER (WHERE entity IN ('players','player_profiles','profiles')) AS player_profile_coverage,
        MAX(coverage_status) FILTER (WHERE entity IN ('player_stats','player_season_stats')) AS player_stats_coverage,
        MAX(coverage_status) FILTER (WHERE entity ILIKE '%photo%') AS photo_coverage
    FROM ops.provider_entity_coverage
    GROUP BY sport_code
)
SELECT
    b.sport_code,
    b.sport_name,
    b.people_provider,
    b.priority_order,

    CASE
        WHEN rp.players_runtime_state IN ('CONFIRMED','PUBLIC_CONFIRMED') THEN 'READY'
        WHEN rp.players_runtime_state IN ('PARTIAL') THEN 'TECH_READY_EMPTY_OR_PARTIAL'
        WHEN b.players_supported THEN 'SUPPORTED_NOT_CONFIRMED'
        ELSE 'MISSING'
    END AS players_layer_status,

    CASE
        WHEN b.profiles_supported THEN 'SUPPORTED'
        ELSE 'MISSING'
    END AS profile_layer_status,

    CASE
        WHEN b.season_stats_supported OR c.player_stats_coverage IS NOT NULL THEN COALESCE(c.player_stats_coverage, 'SUPPORTED')
        ELSE 'MISSING'
    END AS season_stats_layer_status,

    CASE
        WHEN b.match_stats_supported OR c.player_stats_coverage IS NOT NULL THEN COALESCE(c.player_stats_coverage, 'SUPPORTED')
        ELSE 'MISSING'
    END AS match_stats_layer_status,

    CASE
        WHEN b.photos_supported OR c.photo_coverage IS NOT NULL THEN COALESCE(c.photo_coverage, 'SUPPORTED')
        ELSE 'MISSING'
    END AS photo_layer_status,

    CASE
        WHEN b.coaches_supported THEN 'SUPPORTED_OR_PARTIAL'
        ELSE 'MISSING'
    END AS coaches_layer_status,

    'NOT_MAPPED_YET'::text AS injuries_layer_status,
    'NOT_MAPPED_YET'::text AS transfers_layer_status,

    rp.players_last_run_group,
    rp.players_evidence,

    CASE
        WHEN b.photos_supported = false THEN 'Doplnit photo provider / Wikimedia / official site image mapping.'
        WHEN b.profiles_supported = false THEN 'Doplnit player profile provider.'
        WHEN b.season_stats_supported = false THEN 'Doplnit season stats provider.'
        ELSE 'Rozšířit detail hráče podle priorit sportu.'
    END AS next_action
FROM base b
LEFT JOIN runtime_players rp
    ON rp.sport_code = b.sport_code
LEFT JOIN coverage c
    ON c.sport_code = b.sport_code;

SELECT *
FROM ops.v_player_detail_coverage_plan_v1
ORDER BY priority_order NULLS LAST, sport_code;