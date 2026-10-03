-- CO: STEP 11R – schválení ruční obnovy dokončených HB scope
-- K ČEMU: Schválit 12 pravidel MANUAL pro šest dokončených datasetů.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Zápis do databáze; spustit celý skript včetně COMMIT.

BEGIN;

DO $step_11r$
DECLARE
    v_updated integer;
BEGIN
    UPDATE ops.harvest_scope_refresh_policy p
    SET policy_status = 'APPROVED',
        approved_at = now(),
        approved_by = 'Petr'
    FROM ops.harvest_scope_completion h
    WHERE h.source_id = p.source_id
      AND h.sport_code = p.sport_code
      AND h.layer_type = p.layer_type
      AND h.entity = p.entity
      AND h.time_mode = p.time_mode
      AND h.scope_key = p.scope_key
      AND h.completion_status = 'COMPLETE'
      AND h.verification_status IN ('COUNT_MATCH', 'RECONCILED')
      AND h.expected_count = h.merged_count
      AND p.source_id = 18
      AND p.sport_code = 'HB'
      AND p.layer_type = 'CORE'
      AND p.entity = 'fixtures'
      AND p.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
      AND p.scope_coverage_id IS NOT NULL
      AND p.policy_status = 'DRAFT'
      AND p.refresh_mode = 'MANUAL';

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated <> 12 THEN
        RAISE EXCEPTION 'STEP 11R: očekáváno 12 schválení, provedeno %; transakci neukládat',
            v_updated;
    END IF;
END
$step_11r$;

COMMIT;

SELECT
    count(*) FILTER (
        WHERE policy_status = 'APPROVED' AND refresh_mode = 'MANUAL'
    ) AS approved_manual,
    count(*) FILTER (
        WHERE policy_status = 'DRAFT' AND refresh_mode = 'UNDECIDED'
    ) AS undecided_draft
FROM ops.harvest_scope_refresh_policy
WHERE source_id = 18
  AND sport_code = 'HB'
  AND layer_type = 'CORE'
  AND entity = 'fixtures'
  AND time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION');