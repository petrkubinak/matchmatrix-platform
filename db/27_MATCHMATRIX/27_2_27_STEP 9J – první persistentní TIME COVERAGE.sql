/*
CO:
STEP 9J – API-SPORTS HB FIXTURES HISTORICAL COVERAGE APPLY

K ČEMU:
Trvale zapsat první dvě canonical source time coverage identity
na základě persistentního runtime evidence ID=58.

VÝZNAM:
RUNTIME_TESTED znamená:
technická dostupnost historických fixtures byla skutečně
ověřena runtime testem.

NEZNAMENÁ:
- kompletní historické pokrytí všech HB soutěží,
- CONFIRMED coverage,
- routing approval,
- PRIMARY source,
- aktivaci harvestu.

KDE:
Databáze matchmatrix.

JAK:
Jeden atomický PostgreSQL DO blok.
*/

DO $$
DECLARE
    v_id_fan         bigint;
    v_id_prediction  bigint;
    v_total          integer;
    v_bad_status     integer;
    v_bad_evidence   integer;
BEGIN

    /* =====================================================
       1. SOURCE GUARD
       ===================================================== */

    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_master
        WHERE source_id = 18
          AND source_code = 'api_sports'
          AND canonical_name = 'API-Sports'
    ) THEN
        RAISE EXCEPTION
            'STEP 9J BLOCKED: source_id=18 není očekávaná API-Sports identita.';
    END IF;


    /* =====================================================
       2. BINDING GUARD
       ===================================================== */

    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_adapter_binding
        WHERE source_id = 18
          AND adapter_id = 9
          AND sport_code = 'HB'
          AND entity = 'fixtures'
          AND binding_status = 'EVIDENCED'
    ) THEN
        RAISE EXCEPTION
            'STEP 9J BLOCKED: chybí HB fixtures source-adapter binding.';
    END IF;


    /* =====================================================
       3. EVIDENCE ID=58 GUARD
       ===================================================== */

    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_audit_evidence
        WHERE audit_evidence_id = 58
          AND source_id = 18
          AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
          AND evidence_key =
              'api_sports:HB:CORE:fixtures:league_131:season_2024'
          AND evidence_version =
              'RUN_20260929095736098'
          AND result_status = 'PASS'
          AND evidence_hash =
              '3bfa750568a3ca959f5983b096f855bf1ae4a90c38d4a5cef718b4003ce70013'
    ) THEN
        RAISE EXCEPTION
            'STEP 9J BLOCKED: persistent runtime evidence ID=58 není očekávaný PASS důkaz.';
    END IF;


    /* =====================================================
       4. DUPLICATE GUARD
       ===================================================== */

    IF EXISTS (
        SELECT 1
        FROM ops.source_entity_time_coverage
        WHERE source_id = 18
          AND sport_code = 'HB'
          AND layer_type = 'CORE'
          AND entity = 'fixtures'
          AND time_mode IN (
              'HISTORY_FAN',
              'HISTORY_PREDICTION'
          )
    ) THEN
        RAISE EXCEPTION
            'STEP 9J BLOCKED: některá cílová historical coverage již existuje.';
    END IF;


    /* =====================================================
       5. ID GENERATION

       coverage_id nemá DEFAULT/IDENTITY.
       Proto tabulku krátce uzamkneme a přidělíme dvě ID.
       ===================================================== */

    LOCK TABLE ops.source_entity_time_coverage
        IN SHARE ROW EXCLUSIVE MODE;

    SELECT COALESCE(MAX(coverage_id), 0) + 1
    INTO v_id_fan
    FROM ops.source_entity_time_coverage;

    v_id_prediction := v_id_fan + 1;


    /* =====================================================
       6. HISTORY_FAN
       ===================================================== */

    INSERT INTO ops.source_entity_time_coverage
    (
        coverage_id,
        source_id,
        sport_code,
        layer_type,
        entity,
        time_mode,
        coverage_status,
        history_from,
        history_to,
        quality_level,
        evidence_status,
        tested_at,
        notes
    )
    VALUES
    (
        v_id_fan,
        18,
        'HB',
        'CORE',
        'fixtures',
        'HISTORY_FAN',
        'RUNTIME_TESTED',

        NULL,
        NULL,

        NULL,
        'PASS',

        TIMESTAMPTZ '2026-09-29 09:57:36.098+02',

        'Runtime evidence ID=58. API-Sports HB fixtures historical replay test: '
        'provider league_id=131, season=2024, API returned 132 matches; '
        'DB scope contained 132/132 FINISHED with scores. '
        'DryRun=true, DB modified=false. '
        'RUNTIME_TESTED proves tested historical availability only; '
        'it does not assert complete HB historical coverage.'
    );


    /* =====================================================
       7. HISTORY_PREDICTION
       ===================================================== */

    INSERT INTO ops.source_entity_time_coverage
    (
        coverage_id,
        source_id,
        sport_code,
        layer_type,
        entity,
        time_mode,
        coverage_status,
        history_from,
        history_to,
        quality_level,
        evidence_status,
        tested_at,
        notes
    )
    VALUES
    (
        v_id_prediction,
        18,
        'HB',
        'CORE',
        'fixtures',
        'HISTORY_PREDICTION',
        'RUNTIME_TESTED',

        NULL,
        NULL,

        NULL,
        'PASS',

        TIMESTAMPTZ '2026-09-29 09:57:36.098+02',

        'Runtime evidence ID=58. API-Sports HB fixtures historical replay test: '
        'provider league_id=131, season=2024, API returned 132 matches; '
        'DB scope contained 132/132 FINISHED with scores. '
        'DryRun=true, DB modified=false. '
        'RUNTIME_TESTED proves tested historical fixture availability for model-oriented use only; '
        'it does not assert complete HB historical coverage.'
    );


    /* =====================================================
       8. VALIDACE
       ===================================================== */

    SELECT
        COUNT(*),

        COUNT(*) FILTER (
            WHERE coverage_status <> 'RUNTIME_TESTED'
        ),

        COUNT(*) FILTER (
            WHERE evidence_status <> 'PASS'
        )

    INTO
        v_total,
        v_bad_status,
        v_bad_evidence

    FROM ops.source_entity_time_coverage

    WHERE source_id = 18
      AND sport_code = 'HB'
      AND layer_type = 'CORE'
      AND entity = 'fixtures'
      AND time_mode IN (
          'HISTORY_FAN',
          'HISTORY_PREDICTION'
      );


    IF v_total <> 2
       OR v_bad_status <> 0
       OR v_bad_evidence <> 0
    THEN
        RAISE EXCEPTION
            'STEP 9J VALIDATION FAIL: total=%, bad_status=%, bad_evidence=%',
            v_total,
            v_bad_status,
            v_bad_evidence;
    END IF;


    RAISE NOTICE
        'STEP_9J_COVERAGE_IDS=%:HISTORY_FAN, %:HISTORY_PREDICTION',
        v_id_fan,
        v_id_prediction;

    RAISE NOTICE
        'STEP_9J_VALIDATE total=%, bad_status=%, bad_evidence=%',
        v_total,
        v_bad_status,
        v_bad_evidence;

    RAISE NOTICE
        'STEP_9J_STATUS=APPLY_PASS';

END
$$;