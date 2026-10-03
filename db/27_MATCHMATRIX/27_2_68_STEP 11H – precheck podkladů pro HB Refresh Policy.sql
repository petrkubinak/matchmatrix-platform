-- CO: STEP 11H – precheck podkladů pro HB Refresh Policy
-- K ČEMU: Ověřit identitu targetů, přesných coverage a nepřítomnost duplicit.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

WITH candidates AS (
    SELECT
        h.*,
        t.id AS target_found_id,
        t.provider AS target_provider,
        t.sport_code AS target_sport_code,
        t.canonical_league_id AS target_league_id,
        t.provider_league_id AS target_competition_key,
        t.season AS target_season_key,
        t.enabled AS target_enabled,
        sc.scope_coverage_id AS coverage_found_id,
        sc.scope_key AS coverage_scope_key,
        sc.scope_type AS coverage_scope_type,
        sc.canonical_league_id AS coverage_league_id,
        sc.source_competition_key AS coverage_competition_key,
        sc.source_season_key AS coverage_season_key,
        parent.source_id AS coverage_source_id,
        parent.sport_code AS coverage_sport_code,
        parent.layer_type AS coverage_layer_type,
        parent.entity AS coverage_entity,
        parent.time_mode AS coverage_time_mode,
        rp.policy_id AS existing_policy_id
    FROM ops.harvest_scope_completion h
    LEFT JOIN ops.ingest_targets t
        ON t.id = h.ingest_target_id
    LEFT JOIN ops.source_entity_time_scope_coverage sc
        ON sc.scope_coverage_id = h.scope_coverage_id
    LEFT JOIN ops.source_entity_time_coverage parent
        ON parent.coverage_id = sc.coverage_id
    LEFT JOIN ops.harvest_scope_refresh_policy rp
        ON rp.source_id = h.source_id
       AND rp.sport_code = h.sport_code
       AND rp.layer_type = h.layer_type
       AND rp.entity = h.entity
       AND rp.time_mode = h.time_mode
       AND rp.scope_key = h.scope_key
    WHERE h.source_id = 18
      AND h.sport_code = 'HB'
      AND h.layer_type = 'CORE'
      AND h.entity = 'fixtures'
      AND h.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
),
audit AS (
    SELECT
        count(*) AS candidate_rows,
        count(DISTINCT ingest_target_id) AS distinct_targets,
        count(*) FILTER (
            WHERE target_found_id IS NULL
        ) AS missing_targets,
        count(*) FILTER (
            WHERE target_found_id IS NOT NULL
              AND target_enabled IS DISTINCT FROM true
        ) AS disabled_targets,
        count(*) FILTER (
            WHERE target_found_id IS NOT NULL
              AND (
                  target_provider IS DISTINCT FROM 'api_handball'
                  OR target_sport_code IS DISTINCT FROM sport_code
                  OR target_league_id IS DISTINCT FROM canonical_league_id
                  OR target_competition_key IS DISTINCT FROM source_competition_key
                  OR target_season_key IS DISTINCT FROM source_season_key
              )
        ) AS target_identity_mismatches,
        count(*) FILTER (
            WHERE nullif(btrim(source_season_key), '') IS NULL
        ) AS missing_source_season_keys,
        count(*) FILTER (
            WHERE scope_coverage_id IS NOT NULL
        ) AS exact_coverage_links,
        count(*) FILTER (
            WHERE scope_coverage_id IS NOT NULL
              AND (
                  coverage_found_id IS NULL
                  OR coverage_scope_key IS DISTINCT FROM scope_key
                  OR coverage_scope_type IS DISTINCT FROM scope_type
                  OR coverage_league_id IS DISTINCT FROM canonical_league_id
                  OR coverage_competition_key IS DISTINCT FROM source_competition_key
                  OR coverage_season_key IS DISTINCT FROM source_season_key
                  OR coverage_source_id IS DISTINCT FROM source_id
                  OR coverage_sport_code IS DISTINCT FROM sport_code
                  OR coverage_layer_type IS DISTINCT FROM layer_type
                  OR coverage_entity IS DISTINCT FROM entity
                  OR coverage_time_mode IS DISTINCT FROM time_mode
              )
        ) AS exact_coverage_mismatches,
        count(*) FILTER (
            WHERE existing_policy_id IS NOT NULL
        ) AS already_registered
    FROM candidates
)
SELECT *,
       CASE
           WHEN candidate_rows = 422
            AND distinct_targets = 211
            AND missing_targets = 0
            AND disabled_targets = 0
            AND target_identity_mismatches = 0
            AND missing_source_season_keys = 0
            AND exact_coverage_links = 12
            AND exact_coverage_mismatches = 0
            AND already_registered = 0
           THEN 'PASS'
           ELSE 'REVIEW'
       END AS audit_result
FROM audit;