-- CO: STEP 11Q – návrh ruční obnovy dokončených HB scope
-- K ČEMU: Nastavit MANUAL u 12 dokončených řádků; 410 ostatních ponechat beze změny.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Zápis do databáze; spustit celý skript včetně COMMIT.

BEGIN;

DO $step_11q$
DECLARE
    v_updated integer;
BEGIN
    UPDATE ops.harvest_scope_refresh_policy p
    SET refresh_mode = 'MANUAL',
        policy_reason = 'Dokončený historický sběr; opakovaná kontrola na pokyn operátora.'
    FROM ops.harvest_scope_completion h
    WHERE h.source_id = p.source_id
      AND h.sport_code = p.sport_code
      AND h.layer_type = p.layer_type
      AND h.entity = p.entity
      AND h.time_mode = p.time_mode
      AND h.scope_key = p.scope_key
      AND h.completion_status = 'COMPLETE'
      AND p.source_id = 18
      AND p.sport_code = 'HB'
      AND p.layer_type = 'CORE'
      AND p.entity = 'fixtures'
      AND p.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
      AND p.policy_status = 'DRAFT'
      AND p.refresh_mode = 'UNDECIDED';

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated <> 12 THEN
        RAISE EXCEPTION 'STEP 11Q: očekáváno 12 změn, provedeno %; transakci neukládat',
            v_updated;
    END IF;
END
$step_11q$;

COMMIT;

SELECT
    count(*) FILTER (
        WHERE policy_status = 'DRAFT' AND refresh_mode = 'MANUAL'
    ) AS manual_draft,
    count(*) FILTER (
        WHERE policy_status = 'DRAFT' AND refresh_mode = 'UNDECIDED'
    ) AS undecided_draft
FROM ops.harvest_scope_refresh_policy
WHERE source_id = 18
  AND sport_code = 'HB'
  AND layer_type = 'CORE'
  AND entity = 'fixtures'
  AND time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION');