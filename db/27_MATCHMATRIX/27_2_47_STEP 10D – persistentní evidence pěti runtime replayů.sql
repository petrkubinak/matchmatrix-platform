/*
CO:
STEP 10D – API-SPORTS HB REPRESENTATIVE RUNTIME EVIDENCE APPLY

K ČEMU:
Trvale uložit 5 reprezentativních runtime replay důkazů
z úspěšných STEP 10B + STEP 10C.

ROZSAH:
api_handball / HB / CORE / fixtures / season 2024

provider leagues:
34, 104, 145, 154, 155

DŮLEŽITÉ:
Tento krok:
- NEPŘIDÁVÁ exact coverage scope,
- NEMĚNÍ parent coverage,
- NEVYTVÁŘÍ routing,
- NEAKTIVUJE binding,
- pouze ukládá persistentní audit evidence.

JAK:
Jeden atomický PostgreSQL DO blok.
*/

DO $$
DECLARE
    v_first_id bigint;
    v_inserted integer;
    v_verified integer;
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
            'STEP 10D BLOCKED: source_id=18 není očekávaná API-Sports identita.';
    END IF;


    /* =====================================================
       2. FIXTURES BINDING GUARD
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
            'STEP 10D BLOCKED: chybí očekávaný HB fixtures binding.';
    END IF;


    /* =====================================================
       3. DUPLICATE GUARD
       ===================================================== */

    IF EXISTS (
        SELECT 1
        FROM ops.source_audit_evidence
        WHERE source_id = 18
          AND evidence_version IN (
              'RUN_20260929121945937',
              'RUN_20260929121946393',
              'RUN_20260929121946820',
              'RUN_20260929121947263',
              'RUN_20260929121947655'
          )
    ) THEN
        RAISE EXCEPTION
            'STEP 10D BLOCKED: některý runtime evidence RUN již existuje.';
    END IF;


    /* =====================================================
       4. SAFE ID ALLOCATION
       ===================================================== */

    LOCK TABLE ops.source_audit_evidence
        IN SHARE ROW EXCLUSIVE MODE;

    SELECT COALESCE(MAX(audit_evidence_id), 0) + 1
    INTO v_first_id
    FROM ops.source_audit_evidence;


    /* =====================================================
       5. INSERT 5 REPRESENTATIVE EVIDENCE ROWS
       ===================================================== */

    INSERT INTO ops.source_audit_evidence
    (
        audit_evidence_id,
        source_id,
        audit_dimension,
        evidence_key,
        evidence_version,
        result_status,
        evidence_date,
        evidence_url,
        result_detail,
        valid_until,
        reviewer,
        evidence_hash
    )
    VALUES

    /* -----------------------------------------------------
       LEAGUE 34 – Starligue
       ----------------------------------------------------- */
    (
        v_first_id,
        18,
        'RUNTIME_COVERAGE_TEST',
        'api_sports:HB:CORE:fixtures:league_34:season_2024',
        'RUN_20260929121945937',
        'PASS',
        TIMESTAMPTZ '2026-09-29 12:19:45.937+02',

        'https://v1.handball.api-sports.io/games?league=34&season=2024',

        jsonb_build_object(
            'canonical_source',       'API-Sports',
            'source_id',              18,
            'runtime_adapter',        'api_handball',
            'adapter_id',             9,

            'sport_code',             'HB',
            'layer_type',             'CORE',
            'entity',                 'fixtures',

            'tested_time_modes',
                jsonb_build_array(
                    'HISTORY_FAN',
                    'HISTORY_PREDICTION'
                ),

            'canonical_league_id',    24942,
            'canonical_league_name',  'Starligue',
            'provider_league_id',     34,
            'season',                 '2024',

            'api_returned_matches',   240,
            'db_expected_matches',    240,
            'db_finished',            240,
            'db_finished_with_score', 240,
            'db_scheduled',           0,
            'db_cancelled',           0,

            'first_kickoff',          '2024-09-06 18:00:00',
            'last_kickoff',           '2025-06-07 18:30:00',

            'run_id',                 '20260929121945937',
            'dry_run',                true,
            'db_modified',            false,

            'payload_sha256',
                'be7dcf3ba9b68b5d1e852282996e062e1b6a9729b866545380e49724875ae5d6',

            'reconciliation_status',  'PASS'
        )::text,

        NULL,
        NULL,

        'be7dcf3ba9b68b5d1e852282996e062e1b6a9729b866545380e49724875ae5d6'
    ),


    /* -----------------------------------------------------
       LEAGUE 104 – Division de Honor Plata
       ----------------------------------------------------- */
    (
        v_first_id + 1,
        18,
        'RUNTIME_COVERAGE_TEST',
        'api_sports:HB:CORE:fixtures:league_104:season_2024',
        'RUN_20260929121946393',
        'PASS',
        TIMESTAMPTZ '2026-09-29 12:19:46.393+02',

        'https://v1.handball.api-sports.io/games?league=104&season=2024',

        jsonb_build_object(
            'canonical_source',       'API-Sports',
            'source_id',              18,
            'runtime_adapter',        'api_handball',
            'adapter_id',             9,

            'sport_code',             'HB',
            'layer_type',             'CORE',
            'entity',                 'fixtures',

            'tested_time_modes',
                jsonb_build_array(
                    'HISTORY_FAN',
                    'HISTORY_PREDICTION'
                ),

            'canonical_league_id',    24913,
            'canonical_league_name',  'Division de Honor Plata',
            'provider_league_id',     104,
            'season',                 '2024',

            'api_returned_matches',   245,
            'db_expected_matches',    245,
            'db_finished',            245,
            'db_finished_with_score', 245,
            'db_scheduled',           0,
            'db_cancelled',           0,

            'first_kickoff',          '2024-09-14 14:00:00',
            'last_kickoff',           '2025-05-25 10:30:00',

            'run_id',                 '20260929121946393',
            'dry_run',                true,
            'db_modified',            false,

            'payload_sha256',
                '280bbea33ecfdc82edf9fb434542446e6470286689268d48bb96244a4184c919',

            'reconciliation_status',  'PASS'
        )::text,

        NULL,
        NULL,

        '280bbea33ecfdc82edf9fb434542446e6470286689268d48bb96244a4184c919'
    ),


    /* -----------------------------------------------------
       LEAGUE 145 – EHF European League
       ----------------------------------------------------- */
    (
        v_first_id + 2,
        18,
        'RUNTIME_COVERAGE_TEST',
        'api_sports:HB:CORE:fixtures:league_145:season_2024',
        'RUN_20260929121946820',
        'PASS',
        TIMESTAMPTZ '2026-09-29 12:19:46.820+02',

        'https://v1.handball.api-sports.io/games?league=145&season=2024',

        jsonb_build_object(
            'canonical_source',       'API-Sports',
            'source_id',              18,
            'runtime_adapter',        'api_handball',
            'adapter_id',             9,

            'sport_code',             'HB',
            'layer_type',             'CORE',
            'entity',                 'fixtures',

            'tested_time_modes',
                jsonb_build_array(
                    'HISTORY_FAN',
                    'HISTORY_PREDICTION'
                ),

            'canonical_league_id',    24882,
            'canonical_league_name',  'EHF European League',
            'provider_league_id',     145,
            'season',                 '2024',

            'api_returned_matches',   168,
            'db_expected_matches',    168,
            'db_finished',            168,
            'db_finished_with_score', 168,
            'db_scheduled',           0,
            'db_cancelled',           0,

            'first_kickoff',          '2024-08-31 12:00:00',
            'last_kickoff',           '2025-05-25 16:00:00',

            'run_id',                 '20260929121946820',
            'dry_run',                true,
            'db_modified',            false,

            'payload_sha256',
                'd724b11d9f1dbbc1199c53d3affc68ba04fe0bb537eafab5ee2d3b21cdc50dcc',

            'reconciliation_status',  'PASS'
        )::text,

        NULL,
        NULL,

        'd724b11d9f1dbbc1199c53d3affc68ba04fe0bb537eafab5ee2d3b21cdc50dcc'
    ),


    /* -----------------------------------------------------
       LEAGUE 154 – World Championship Women
       ----------------------------------------------------- */
    (
        v_first_id + 3,
        18,
        'RUNTIME_COVERAGE_TEST',
        'api_sports:HB:CORE:fixtures:league_154:season_2024',
        'RUN_20260929121947263',
        'PASS',
        TIMESTAMPTZ '2026-09-29 12:19:47.263+02',

        'https://v1.handball.api-sports.io/games?league=154&season=2024',

        jsonb_build_object(
            'canonical_source',       'API-Sports',
            'source_id',              18,
            'runtime_adapter',        'api_handball',
            'adapter_id',             9,

            'sport_code',             'HB',
            'layer_type',             'CORE',
            'entity',                 'fixtures',

            'tested_time_modes',
                jsonb_build_array(
                    'HISTORY_FAN',
                    'HISTORY_PREDICTION'
                ),

            'canonical_league_id',    25072,
            'canonical_league_name',  'World Championship Women',
            'provider_league_id',     154,
            'season',                 '2024',

            'api_returned_matches',   142,
            'db_expected_matches',    142,
            'db_finished',            142,
            'db_finished_with_score', 142,
            'db_scheduled',           0,
            'db_cancelled',           0,

            'first_kickoff',          '2024-10-24 15:00:00',
            'last_kickoff',           '2025-12-14 16:30:00',

            'run_id',                 '20260929121947263',
            'dry_run',                true,
            'db_modified',            false,

            'payload_sha256',
                '87001ebc1fa3439c8a2f6b168239814d71d0c58c1863e6260b54e8757fbdaded',

            'reconciliation_status',  'PASS'
        )::text,

        NULL,
        NULL,

        '87001ebc1fa3439c8a2f6b168239814d71d0c58c1863e6260b54e8757fbdaded'
    ),


    /* -----------------------------------------------------
       LEAGUE 155 – Olympic Games
       ----------------------------------------------------- */
    (
        v_first_id + 4,
        18,
        'RUNTIME_COVERAGE_TEST',
        'api_sports:HB:CORE:fixtures:league_155:season_2024',
        'RUN_20260929121947655',
        'PASS',
        TIMESTAMPTZ '2026-09-29 12:19:47.655+02',

        'https://v1.handball.api-sports.io/games?league=155&season=2024',

        jsonb_build_object(
            'canonical_source',       'API-Sports',
            'source_id',              18,
            'runtime_adapter',        'api_handball',
            'adapter_id',             9,

            'sport_code',             'HB',
            'layer_type',             'CORE',
            'entity',                 'fixtures',

            'tested_time_modes',
                jsonb_build_array(
                    'HISTORY_FAN',
                    'HISTORY_PREDICTION'
                ),

            'canonical_league_id',    24930,
            'canonical_league_name',  'Olympic Games',
            'provider_league_id',     155,
            'season',                 '2024',

            'api_returned_matches',   88,
            'db_expected_matches',    88,
            'db_finished',            88,
            'db_finished_with_score', 88,
            'db_scheduled',           0,
            'db_cancelled',           0,

            'first_kickoff',          '2023-10-18 08:00:00',
            'last_kickoff',           '2024-08-11 11:30:00',

            'run_id',                 '20260929121947655',
            'dry_run',                true,
            'db_modified',            false,

            'payload_sha256',
                'd1f598d6c73d4fd86583d5d20266bf6af24fc8693c2ad5b4de67d2648091799b',

            'reconciliation_status',  'PASS'
        )::text,

        NULL,
        NULL,

        'd1f598d6c73d4fd86583d5d20266bf6af24fc8693c2ad5b4de67d2648091799b'
    );


    GET DIAGNOSTICS v_inserted = ROW_COUNT;


    /* =====================================================
       6. VALIDATION
       ===================================================== */

    SELECT COUNT(*)
    INTO v_verified
    FROM ops.source_audit_evidence
    WHERE source_id = 18
      AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
      AND result_status = 'PASS'
      AND evidence_version IN (
          'RUN_20260929121945937',
          'RUN_20260929121946393',
          'RUN_20260929121946820',
          'RUN_20260929121947263',
          'RUN_20260929121947655'
      );


    IF v_inserted <> 5
       OR v_verified <> 5
    THEN
        RAISE EXCEPTION
            'STEP 10D VALIDATION FAIL: inserted=%, verified=%',
            v_inserted,
            v_verified;
    END IF;


    RAISE NOTICE
        'STEP_10D_FIRST_EVIDENCE_ID=%',
        v_first_id;

    RAISE NOTICE
        'STEP_10D_INSERTED=%',
        v_inserted;

    RAISE NOTICE
        'STEP_10D_VERIFIED=%',
        v_verified;

    RAISE NOTICE
        'STEP_10D_SCOPE_COUNT=5';

    RAISE NOTICE
        'STEP_10D_MATCHES_VERIFIED=883';

    RAISE NOTICE
        'STEP_10D_PARENT_COVERAGE_UNCHANGED=RUNTIME_TESTED';

    RAISE NOTICE
        'STEP_10D_STATUS=APPLY_PASS';

END
$$;