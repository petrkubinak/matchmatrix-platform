/*
CO:
STEP 9Y – API-SPORTS HB EXACT COVERAGE CONFIRMATION APPLY

K ČEMU:
Povýšit pouze dva přesně doložené HB exact coverage scope:

league 24881
provider league 131
source season 2024

z:
RUNTIME_TESTED

na:
CONFIRMED

DŮLEŽITÉ:
- parent coverage zůstává RUNTIME_TESTED,
- binding zůstává is_active=false,
- routing se nevytváří,
- harvest se neaktivuje,
- canonical season může zůstat UNRESOLVED.

KDE:
Databáze matchmatrix.

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
       1. EXPECTED EXACT SCOPE GUARD
       ===================================================== */

    IF (
        SELECT COUNT(*)
        FROM ops.source_entity_time_scope_coverage d
        JOIN ops.source_entity_time_coverage c
          ON c.coverage_id = d.coverage_id
        WHERE d.scope_coverage_id IN (1, 2)
          AND c.source_id = 18
          AND c.sport_code = 'HB'
          AND c.layer_type = 'CORE'
          AND c.entity = 'fixtures'
          AND c.time_mode IN (
              'HISTORY_FAN',
              'HISTORY_PREDICTION'
          )
          AND c.coverage_status = 'RUNTIME_TESTED'
          AND d.canonical_league_id = 24881
          AND d.source_competition_key = '131'
          AND d.source_season_key = '2024'
          AND d.scope_status = 'RUNTIME_TESTED'
          AND d.audit_evidence_id = 58
    ) <> 2 THEN

        RAISE EXCEPTION
            'STEP 9Y BLOCKED: očekávané dva RUNTIME_TESTED exact scope nebyly nalezeny.';

    END IF;


    /* =====================================================
       2. EVIDENCE GUARD
       ===================================================== */

    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_audit_evidence
        WHERE audit_evidence_id = 58
          AND source_id = 18
          AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
          AND result_status = 'PASS'
          AND evidence_key =
              'api_sports:HB:CORE:fixtures:league_131:season_2024'
          AND evidence_version =
              'RUN_20260929095736098'
    ) THEN

        RAISE EXCEPTION
            'STEP 9Y BLOCKED: evidence ID=58 není očekávaný PASS důkaz.';

    END IF;


    /* =====================================================
       3. CONFIRM EXACT SCOPES ONLY
       ===================================================== */

    UPDATE ops.source_entity_time_scope_coverage
    SET
        scope_status = 'CONFIRMED',

        notes =
            COALESCE(notes, '')
            ||
            E'\nSTEP 9Y: exact scope confirmed after STEP 9X readiness audit. '
            ||
            'Confirmation applies only to league 24881 / '
            ||
            'source competition 131 / source season 2024. '
            ||
            'Parent coverage remains RUNTIME_TESTED.',

        updated_at = now()

    WHERE scope_coverage_id IN (1, 2)
      AND scope_status = 'RUNTIME_TESTED';


    GET DIAGNOSTICS v_updated = ROW_COUNT;


    IF v_updated <> 2 THEN
        RAISE EXCEPTION
            'STEP 9Y FAIL: aktualizováno % exact scope místo 2.',
            v_updated;
    END IF;


    /* =====================================================
       4. EXACT SCOPE VALIDATION
       ===================================================== */

    SELECT COUNT(*)
    INTO v_confirmed
    FROM ops.source_entity_time_scope_coverage
    WHERE scope_coverage_id IN (1, 2)
      AND scope_status = 'CONFIRMED'
      AND canonical_league_id = 24881
      AND source_competition_key = '131'
      AND source_season_key = '2024'
      AND audit_evidence_id = 58;


    /* =====================================================
       5. GOVERNANCE GUARDS

       Parent NESMÍ být CONFIRMED.
       Binding NESMÍ být aktivní.
       Routing NESMÍ vzniknout.
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


    IF v_confirmed <> 2
       OR v_parent_confirmed <> 0
       OR v_active_bindings <> 0
       OR v_routes <> 0
    THEN

        RAISE EXCEPTION
            'STEP 9Y VALIDATION FAIL: exact_confirmed=%, parent_confirmed=%, active_bindings=%, routes=%',
            v_confirmed,
            v_parent_confirmed,
            v_active_bindings,
            v_routes;

    END IF;


    /* =====================================================
       6. RESULT
       ===================================================== */

    RAISE NOTICE
        'STEP_9Y_UPDATED=%',
        v_updated;

    RAISE NOTICE
        'STEP_9Y_EXACT_CONFIRMED=%',
        v_confirmed;

    RAISE NOTICE
        'STEP_9Y_PARENT_CONFIRMED=%',
        v_parent_confirmed;

    RAISE NOTICE
        'STEP_9Y_ACTIVE_BINDINGS=%',
        v_active_bindings;

    RAISE NOTICE
        'STEP_9Y_ROUTES=%',
        v_routes;

    RAISE NOTICE
        'STEP_9Y_SCOPE=HB/CORE/fixtures/league_24881/source_league_131/source_season_2024';

    RAISE NOTICE
        'STEP_9Y_STATUS=APPLY_PASS';

END
$$;