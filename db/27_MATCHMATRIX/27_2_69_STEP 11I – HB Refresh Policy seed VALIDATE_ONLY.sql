-- CO: STEP 11I – HB Refresh Policy seed VALIDATE_ONLY
-- K ČEMU: Ověřit vložení 422 návrhů politik do fyzické tabulky.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Spustit celý skript včetně ROLLBACK; testovací řádky nezůstanou uložené.

BEGIN;

WITH inserted AS (
    INSERT INTO ops.harvest_scope_refresh_policy (
        policy_id,
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
        -h.completion_id,
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
    RETURNING time_mode, scope_coverage_id, policy_status, refresh_mode
)
SELECT
    count(*) AS inserted_rows,
    count(*) FILTER (WHERE time_mode = 'HISTORY_FAN') AS history_fan,
    count(*) FILTER (WHERE time_mode = 'HISTORY_PREDICTION') AS history_prediction,
    count(*) FILTER (WHERE scope_coverage_id IS NOT NULL) AS exact_coverage_links,
    count(*) FILTER (
        WHERE policy_status = 'DRAFT' AND refresh_mode = 'UNDECIDED'
    ) AS undecided_drafts,
    CASE
        WHEN count(*) = 422
         AND count(*) FILTER (WHERE time_mode = 'HISTORY_FAN') = 211
         AND count(*) FILTER (WHERE time_mode = 'HISTORY_PREDICTION') = 211
         AND count(*) FILTER (WHERE scope_coverage_id IS NOT NULL) = 12
         AND count(*) FILTER (
             WHERE policy_status = 'DRAFT' AND refresh_mode = 'UNDECIDED'
         ) = 422
        THEN 'VALIDATE_ONLY_OK'
        ELSE 'REVIEW'
    END AS result
FROM inserted;

ROLLBACK;