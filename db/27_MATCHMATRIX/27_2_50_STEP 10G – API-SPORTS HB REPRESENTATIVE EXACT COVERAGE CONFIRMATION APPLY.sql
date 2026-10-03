/*
CO:
STEP 10G – API-SPORTS HB REPRESENTATIVE EXACT COVERAGE CONFIRMATION APPLY

K ČEMU:
Povýšit 10 reprezentativních exact coverage scope:

scope_coverage_id 3–12

z:
RUNTIME_TESTED

na:
CONFIRMED

ROZSAH:
provider leagues:
34, 104, 145, 154, 155

time modes:
HISTORY_FAN
HISTORY_PREDICTION

DŮLEŽITÉ:
- parent coverage zůstává RUNTIME_TESTED,
- binding zůstává neaktivní,
- routing nevzniká,
- harvest se neaktivuje.

JAK:
Jeden atomický PostgreSQL DO blok.
*/

DO $$
DECLARE
    v_updated            integer;
    v_confirmed          integer;
    v_parent_confirmed   integer;
    v_active_bindings    integer;
    v_routes             integer;
BEGIN

    /* =====================================================
       1. EXPECTED SCOPE GUARD
       ===================================================== */

    IF (
        SELECT COUNT(*)
        FROM ops.source_entity_time_scope_coverage d
        JOIN ops.source_entity_time_coverage c
          ON c.coverage_id = d.coverage_id
        WHERE d.scope_coverage_id BETWEEN 3 AND 12

          AND c.source_id = 18
          AND c.sport_code = 'HB'
          AND c.layer_type = 'CORE'
          AND c.entity = 'fixtures'

          AND c.time_mode IN (
              'HISTORY_FAN',
              'HISTORY_PREDICTION'
          )

          AND c.coverage_status = 'RUNTIME_TESTED'

          AND d.source_competition_key IN (
              '34',
              '104',
              '145',
              '154',
              '155'
          )

          AND d.source_season_key = '2024'

          AND d.scope_status = 'RUNTIME_TESTED'

          AND d.audit_evidence_id BETWEEN 59 AND 63
    ) <> 10 THEN

        RAISE EXCEPTION
            'STEP 10G BLOCKED: očekávaných 10 RUNTIME_TESTED exact scope nebylo nalezeno.';

    END IF;


    /* =====================================================
       2. EVIDENCE GUARD
       ===================================================== */

    IF (
        SELECT COUNT(*)
        FROM ops.source_audit_evidence
        WHERE audit_evidence_id BETWEEN 59 AND 63
          AND source_id = 18
          AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
          AND result_status = 'PASS'
    ) <> 5 THEN

        RAISE EXCEPTION
            'STEP 10G BLOCKED: evidence ID 59–63 nejsou očekávaných 5 PASS důkazů.';

    END IF;


    /* =====================================================
       3. CONFIRM EXACT SCOPES
       ===================================================== */

    UPDATE ops.source_entity_time_scope_coverage
    SET
        scope_status = 'CONFIRMED',

        notes =
            COALESCE(notes, '')
            ||
            E'\nSTEP 10G: exact scope confirmed after STEP 10F readiness audit. '
            ||
            'Confirmation applies only to the exact competition/season scope. '
            ||
            'Parent coverage remains RUNTIME_TESTED.',

        updated_at = now()

    WHERE scope_coverage_id BETWEEN 3 AND 12
      AND scope_status = 'RUNTIME_TESTED';


    GET DIAGNOSTICS v_updated = ROW_COUNT;


    IF v_updated <> 10 THEN
        RAISE EXCEPTION
            'STEP 10G FAIL: aktualizováno % exact scope místo 10.',
            v_updated;
    END IF;


    /* =====================================================
       4. EXACT CONFIRMATION VALIDATION
       ===================================================== */

    SELECT COUNT(*)
    INTO v_confirmed

    FROM ops.source_entity_time_scope_coverage d

    JOIN ops.source_entity_time_coverage c
      ON c.coverage_id = d.coverage_id

    WHERE d.scope_coverage_id BETWEEN 3 AND 12

      AND c.source_id = 18
      AND c.sport_code = 'HB'
      AND c.layer_type = 'CORE'
      AND c.entity = 'fixtures'

      AND d.source_competition_key IN (
          '34',
          '104',
          '145',
          '154',
          '155'
      )

      AND d.source_season_key = '2024'

      AND d.scope_status = 'CONFIRMED'

      AND d.audit_evidence_id BETWEEN 59 AND 63;


    /* =====================================================
       5. GOVERNANCE GUARDS
       ===================================================== */

    SELECT COUNT(*)
    INTO v_parent_confirmed
    FROM ops.source_entity_time_coverage
    WHERE source_id = 18
      AND sport_code = 'HB'
      AND layer_type = 'CORE'
      AND entity = 'fixtures'
      AND coverage_status = 'CONFIRMED';


    SELECT COUNT(*)
    INTO v_active_bindings
    FROM ops.source_adapter_binding
    WHERE source_id = 18
      AND is_active = true;


    SELECT COUNT(*)
    INTO v_routes
    FROM ops.data_acquisition_source_routing
    WHERE source_id = 18;


    IF v_confirmed <> 10
       OR v_parent_confirmed <> 0
       OR v_active_bindings <> 0
       OR v_routes <> 0
    THEN

        RAISE EXCEPTION
            'STEP 10G VALIDATION FAIL: confirmed=%, parent_confirmed=%, active_bindings=%, routes=%',
            v_confirmed,
            v_parent_confirmed,
            v_active_bindings,
            v_routes;

    END IF;


    /* =====================================================
       6. RESULT
       ===================================================== */

    RAISE NOTICE
        'STEP_10G_UPDATED=%',
        v_updated;

    RAISE NOTICE
        'STEP_10G_EXACT_CONFIRMED=%',
        v_confirmed;

    RAISE NOTICE
        'STEP_10G_PARENT_CONFIRMED=%',
        v_parent_confirmed;

    RAISE NOTICE
        'STEP_10G_ACTIVE_BINDINGS=%',
        v_active_bindings;

    RAISE NOTICE
        'STEP_10G_ROUTES=%',
        v_routes;

    RAISE NOTICE
        'STEP_10G_STATUS=APPLY_PASS';

END
$$;