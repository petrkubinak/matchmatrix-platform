-- CO: STEP 11J – uložení HB Refresh Policy návrhů (APPLY)
-- K ČEMU: Zapsat 422 historických scope jako návrhy bez určeného režimu obnovy.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Zápis do databáze; spustit celý skript včetně BEGIN a COMMIT.

BEGIN;

DO $step_11j$
DECLARE
    v_inserted bigint;
    v_fan bigint;
    v_prediction bigint;
    v_exact bigint;
    v_drafts bigint;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ops.harvest_scope_refresh_policy
        WHERE source_id = 18
          AND sport_code = 'HB'
          AND layer_type = 'CORE'
          AND entity = 'fixtures'
          AND time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
    ) THEN
        RAISE EXCEPTION 'STEP 11J: HB historické politiky již existují';
    END IF;

    INSERT INTO ops.harvest_scope_refresh_policy (
        source_id,
        sport_code,
        layer_type,
        entity,
        time_mode,
        scope_type,
        scope_key,
        canonical_league_id,
        canonical_season_id,
        source_competition_key,
        source_season_key,
        scope_from,
        scope_to,
        ingest_target_id,
        scope_coverage_id,
        policy_status,
        refresh_mode
    )
    SELECT
        h.source_id,
        h.sport_code,
        h.layer_type,
        h.entity,
        h.time_mode,
        h.scope_type,
        h.scope_key,
        h.canonical_league_id,
        h.canonical_season_id,
        h.source_competition_key,
        h.source_season_key,
        h.scope_from,
        h.scope_to,
        h.ingest_target_id,
        h.scope_coverage_id,
        'DRAFT',
        'UNDECIDED'
    FROM ops.harvest_scope_completion h
    WHERE h.source_id = 18
      AND h.sport_code = 'HB'
      AND h.layer_type = 'CORE'
      AND h.entity = 'fixtures'
      AND h.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
    ORDER BY h.completion_id;

    GET DIAGNOSTICS v_inserted = ROW_COUNT;

    SELECT
        count(*) FILTER (WHERE time_mode = 'HISTORY_FAN'),
        count(*) FILTER (WHERE time_mode = 'HISTORY_PREDICTION'),
        count(*) FILTER (WHERE scope_coverage_id IS NOT NULL),
        count(*) FILTER (
            WHERE policy_status = 'DRAFT'
              AND refresh_mode = 'UNDECIDED'
        )
    INTO v_fan, v_prediction, v_exact, v_drafts
    FROM ops.harvest_scope_refresh_policy
    WHERE source_id = 18
      AND sport_code = 'HB'
      AND layer_type = 'CORE'
      AND entity = 'fixtures'
      AND time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION');

    IF v_inserted <> 422
       OR v_fan <> 211
       OR v_prediction <> 211
       OR v_exact <> 12
       OR v_drafts <> 422 THEN
        RAISE EXCEPTION
            'STEP 11J: kontrola selhala (inserted %, FAN %, PREDICTION %, exact %, drafts %)',
            v_inserted, v_fan, v_prediction, v_exact, v_drafts;
    END IF;
END
$step_11j$;

COMMIT;

SELECT
    count(*) AS persisted_rows,
    count(*) FILTER (WHERE time_mode = 'HISTORY_FAN') AS history_fan,
    count(*) FILTER (WHERE time_mode = 'HISTORY_PREDICTION') AS history_prediction,
    count(*) FILTER (WHERE scope_coverage_id IS NOT NULL) AS exact_coverage_links,
    count(*) FILTER (
        WHERE policy_status = 'DRAFT' AND refresh_mode = 'UNDECIDED'
    ) AS undecided_drafts
FROM ops.harvest_scope_refresh_policy
WHERE source_id = 18
  AND sport_code = 'HB'
  AND layer_type = 'CORE'
  AND entity = 'fixtures'
  AND time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION');