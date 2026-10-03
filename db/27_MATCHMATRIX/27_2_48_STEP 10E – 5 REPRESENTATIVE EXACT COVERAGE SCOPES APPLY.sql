/*
CO:
STEP 10E – API-SPORTS HB REPRESENTATIVE EXACT COVERAGE APPLY

K ČEMU:
Z persistentních runtime evidence ID 59–63 vytvořit
exact coverage scope pro 5 reprezentativních HB soutěží.

PRO KAŽDOU SOUTĚŽ:
- HISTORY_FAN
- HISTORY_PREDICTION

CELKEM:
5 × 2 = 10 exact coverage řádků.

DŮLEŽITÉ:
- scope_status = RUNTIME_TESTED,
- parent coverage zůstává RUNTIME_TESTED,
- routing se nevytváří,
- binding se neaktivuje,
- canonical season zatím zůstává UNRESOLVED.

JAK:
Jeden atomický PostgreSQL DO blok.
*/

DO $$
DECLARE
    v_inserted          integer;
    v_verified          integer;
    v_parent_confirmed  integer;
    v_active_bindings   integer;
    v_routes            integer;
BEGIN

    /* =====================================================
       1. EVIDENCE GUARD – MUSÍ EXISTOVAT PŘESNĚ 5 DŮKAZŮ
       ===================================================== */

    IF (
        SELECT COUNT(*)
        FROM ops.source_audit_evidence
        WHERE audit_evidence_id BETWEEN 59 AND 63
          AND source_id = 18
          AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
          AND result_status = 'PASS'
          AND evidence_version IN (
              'RUN_20260929121945937',
              'RUN_20260929121946393',
              'RUN_20260929121946820',
              'RUN_20260929121947263',
              'RUN_20260929121947655'
          )
    ) <> 5 THEN
        RAISE EXCEPTION
            'STEP 10E BLOCKED: evidence ID 59–63 nejsou očekávaných 5 PASS runtime důkazů.';
    END IF;


    /* =====================================================
       2. PARENT COVERAGE GUARD
       ===================================================== */

    IF (
        SELECT COUNT(*)
        FROM ops.source_entity_time_coverage
        WHERE coverage_id IN (1, 2)
          AND source_id = 18
          AND sport_code = 'HB'
          AND layer_type = 'CORE'
          AND entity = 'fixtures'
          AND coverage_status = 'RUNTIME_TESTED'
          AND time_mode IN (
              'HISTORY_FAN',
              'HISTORY_PREDICTION'
          )
    ) <> 2 THEN
        RAISE EXCEPTION
            'STEP 10E BLOCKED: očekávané parent coverage ID 1/2 nejsou RUNTIME_TESTED.';
    END IF;


    /* =====================================================
       3. DUPLICATE GUARD
       ===================================================== */

    IF EXISTS (
        SELECT 1
        FROM ops.source_entity_time_scope_coverage d
        WHERE d.coverage_id IN (1, 2)
          AND d.source_competition_key IN (
              '34',
              '104',
              '145',
              '154',
              '155'
          )
          AND d.source_season_key = '2024'
    ) THEN
        RAISE EXCEPTION
            'STEP 10E BLOCKED: některý cílový exact scope již existuje.';
    END IF;


    /* =====================================================
       4. INSERT 10 EXACT SCOPES

       Evidence JSON je zde jediný zdroj konkrétního
       league/provider/season scope.
       ===================================================== */

    WITH evidence AS (
        SELECT
            e.audit_evidence_id,
            e.evidence_date,
            e.result_detail::jsonb AS detail
        FROM ops.source_audit_evidence e
        WHERE e.audit_evidence_id BETWEEN 59 AND 63
          AND e.source_id = 18
          AND e.audit_dimension = 'RUNTIME_COVERAGE_TEST'
          AND e.result_status = 'PASS'
    ),

    parent AS (
        SELECT
            coverage_id,
            time_mode
        FROM ops.source_entity_time_coverage
        WHERE coverage_id IN (1, 2)
          AND source_id = 18
          AND sport_code = 'HB'
          AND layer_type = 'CORE'
          AND entity = 'fixtures'
          AND coverage_status = 'RUNTIME_TESTED'
    )

    INSERT INTO ops.source_entity_time_scope_coverage
    (
        coverage_id,
        scope_type,
        scope_key,

        canonical_league_id,
        canonical_season_id,

        source_competition_key,
        source_season_key,

        season_resolution_status,

        scope_status,
        audit_evidence_id,
        tested_at,

        notes
    )

    SELECT
        p.coverage_id,

        'COMPETITION_SEASON',

        format(
            'league:%s|source_competition:%s|source_season:%s',
            e.detail ->> 'canonical_league_id',
            e.detail ->> 'provider_league_id',
            e.detail ->> 'season'
        ),

        (e.detail ->> 'canonical_league_id')::integer,

        NULL,

        e.detail ->> 'provider_league_id',

        e.detail ->> 'season',

        'UNRESOLVED',

        'RUNTIME_TESTED',

        e.audit_evidence_id,

        e.evidence_date,

        format(
            'STEP 10E exact scope generated from runtime evidence ID=%s. '
            'Time mode=%s. API=%s, DB=%s, reconciliation=%s. '
            'Canonical season intentionally unresolved.',
            e.audit_evidence_id,
            p.time_mode,
            e.detail ->> 'api_returned_matches',
            e.detail ->> 'db_expected_matches',
            e.detail ->> 'reconciliation_status'
        )

    FROM evidence e
    CROSS JOIN parent p;


    GET DIAGNOSTICS v_inserted = ROW_COUNT;


    /* =====================================================
       5. VALIDACE EXACT SCOPE
       ===================================================== */

    SELECT COUNT(*)
    INTO v_verified

    FROM ops.source_entity_time_scope_coverage d

    JOIN ops.source_entity_time_coverage c
      ON c.coverage_id = d.coverage_id

    WHERE c.source_id = 18
      AND c.sport_code = 'HB'
      AND c.layer_type = 'CORE'
      AND c.entity = 'fixtures'

      AND c.time_mode IN (
          'HISTORY_FAN',
          'HISTORY_PREDICTION'
      )

      AND d.source_competition_key IN (
          '34',
          '104',
          '145',
          '154',
          '155'
      )

      AND d.source_season_key = '2024'

      AND d.scope_status = 'RUNTIME_TESTED'

      AND d.season_resolution_status = 'UNRESOLVED'

      AND d.audit_evidence_id BETWEEN 59 AND 63;


    /* =====================================================
       6. GOVERNANCE GUARDS
       ===================================================== */

    SELECT COUNT(*)
    INTO v_parent_confirmed
    FROM ops.source_entity_time_coverage
    WHERE source_id = 18
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


    IF v_inserted <> 10
       OR v_verified <> 10
       OR v_parent_confirmed <> 0
       OR v_active_bindings <> 0
       OR v_routes <> 0
    THEN
        RAISE EXCEPTION
            'STEP 10E VALIDATION FAIL: inserted=%, verified=%, parent_confirmed=%, active_bindings=%, routes=%',
            v_inserted,
            v_verified,
            v_parent_confirmed,
            v_active_bindings,
            v_routes;
    END IF;


    /* =====================================================
       7. RESULT
       ===================================================== */

    RAISE NOTICE
        'STEP_10E_INSERTED=%',
        v_inserted;

    RAISE NOTICE
        'STEP_10E_VERIFIED=%',
        v_verified;

    RAISE NOTICE
        'STEP_10E_COMPETITIONS=34,104,145,154,155';

    RAISE NOTICE
        'STEP_10E_TIME_MODES=HISTORY_FAN,HISTORY_PREDICTION';

    RAISE NOTICE
        'STEP_10E_EXACT_STATUS=RUNTIME_TESTED';

    RAISE NOTICE
        'STEP_10E_PARENT_CONFIRMED=%',
        v_parent_confirmed;

    RAISE NOTICE
        'STEP_10E_ACTIVE_BINDINGS=%',
        v_active_bindings;

    RAISE NOTICE
        'STEP_10E_ROUTES=%',
        v_routes;

    RAISE NOTICE
        'STEP_10E_STATUS=APPLY_PASS';

END
$$;