-- CO: STEP 11K – kontrola uložených HB Refresh Policy návrhů
-- K ČEMU: Ověřit úplnost, shodu identity a bezpečný stav DRAFT / UNDECIDED.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz po dokončení STEP 11J.

WITH completion_scopes AS (
    SELECT *
    FROM ops.harvest_scope_completion
    WHERE source_id = 18
      AND sport_code = 'HB'
      AND layer_type = 'CORE'
      AND entity = 'fixtures'
      AND time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
),
policies AS (
    SELECT *
    FROM ops.harvest_scope_refresh_policy
    WHERE source_id = 18
      AND sport_code = 'HB'
      AND layer_type = 'CORE'
      AND entity = 'fixtures'
      AND time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
),
paired AS (
    SELECT
        h.completion_id,
        p.policy_id,
        coalesce(h.time_mode, p.time_mode) AS time_mode,
        h.scope_type AS h_scope_type,
        p.scope_type AS p_scope_type,
        h.canonical_league_id AS h_league_id,
        p.canonical_league_id AS p_league_id,
        h.canonical_season_id AS h_season_id,
        p.canonical_season_id AS p_season_id,
        h.source_competition_key AS h_competition_key,
        p.source_competition_key AS p_competition_key,
        h.source_season_key AS h_season_key,
        p.source_season_key AS p_season_key,
        h.scope_from AS h_scope_from,
        p.scope_from AS p_scope_from,
        h.scope_to AS h_scope_to,
        p.scope_to AS p_scope_to,
        h.ingest_target_id AS h_target_id,
        p.ingest_target_id AS p_target_id,
        h.scope_coverage_id AS h_coverage_id,
        p.scope_coverage_id AS p_coverage_id,
        p.policy_status,
        p.refresh_mode,
        p.min_refresh_interval_seconds,
        p.approved_at,
        p.approved_by
    FROM completion_scopes h
    FULL OUTER JOIN policies p
        USING (source_id, sport_code, layer_type, entity, time_mode, scope_key)
),
audit AS (
    SELECT
        count(*) FILTER (WHERE completion_id IS NOT NULL) AS completion_scopes,
        count(*) FILTER (WHERE policy_id IS NOT NULL) AS persisted_policies,
        count(*) FILTER (WHERE completion_id IS NOT NULL AND policy_id IS NULL)
            AS missing_policies,
        count(*) FILTER (WHERE completion_id IS NULL AND policy_id IS NOT NULL)
            AS orphan_policies,
        count(*) FILTER (WHERE policy_id IS NOT NULL AND time_mode = 'HISTORY_FAN')
            AS history_fan,
        count(*) FILTER (WHERE policy_id IS NOT NULL AND time_mode = 'HISTORY_PREDICTION')
            AS history_prediction,
        count(*) FILTER (WHERE p_coverage_id IS NOT NULL)
            AS exact_coverage_links,
        count(*) FILTER (
            WHERE completion_id IS NOT NULL
              AND policy_id IS NOT NULL
              AND (
                  h_scope_type IS DISTINCT FROM p_scope_type
                  OR h_league_id IS DISTINCT FROM p_league_id
                  OR h_season_id IS DISTINCT FROM p_season_id
                  OR h_competition_key IS DISTINCT FROM p_competition_key
                  OR h_season_key IS DISTINCT FROM p_season_key
                  OR h_scope_from IS DISTINCT FROM p_scope_from
                  OR h_scope_to IS DISTINCT FROM p_scope_to
                  OR h_target_id IS DISTINCT FROM p_target_id
                  OR h_coverage_id IS DISTINCT FROM p_coverage_id
              )
        ) AS metadata_mismatches,
        count(*) FILTER (
            WHERE policy_id IS NOT NULL
              AND (
                  policy_status <> 'DRAFT'
                  OR refresh_mode <> 'UNDECIDED'
                  OR min_refresh_interval_seconds IS NOT NULL
                  OR approved_at IS NOT NULL
                  OR approved_by IS NOT NULL
              )
        ) AS unexpected_policy_settings
    FROM paired
)
SELECT *,
       CASE
           WHEN completion_scopes = 422
            AND persisted_policies = 422
            AND missing_policies = 0
            AND orphan_policies = 0
            AND history_fan = 211
            AND history_prediction = 211
            AND exact_coverage_links = 12
            AND metadata_mismatches = 0
            AND unexpected_policy_settings = 0
           THEN 'PASS'
           ELSE 'REVIEW'
       END AS audit_result
FROM audit;