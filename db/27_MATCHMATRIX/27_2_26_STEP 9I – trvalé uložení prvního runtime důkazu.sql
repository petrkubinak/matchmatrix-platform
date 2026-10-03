/*
CO:
STEP 9I – API-SPORTS HB HISTORICAL RUNTIME EVIDENCE APPLY

K ČEMU:
Trvale uložit reprodukovatelný důkaz z úspěšného STEP 9G
do canonical registru ops.source_audit_evidence.

DŮLEŽITÉ:
Tento zápis:
- NEVYTVÁŘÍ coverage,
- NEVYTVÁŘÍ routing,
- NEAKTIVUJE harvest,
- pouze eviduje skutečně provedený runtime test.

KDE:
Databáze matchmatrix.

JAK:
Jeden atomický PostgreSQL DO blok.
*/

DO $$
DECLARE
    v_new_id bigint;
    v_count  integer;
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
            'STEP 9I BLOCKED: source_id=18 není očekávaná API-Sports identita.';
    END IF;


    /* =====================================================
       2. TECHNICAL BINDING GUARD
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
            'STEP 9I BLOCKED: chybí evidovaný HB fixtures source-adapter binding.';
    END IF;


    /* =====================================================
       3. DUPLICATE GUARD
       ===================================================== */

    IF EXISTS (
        SELECT 1
        FROM ops.source_audit_evidence
        WHERE source_id = 18
          AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
          AND evidence_key =
              'api_sports:HB:CORE:fixtures:league_131:season_2024'
          AND evidence_version =
              'RUN_20260929095736098'
    ) THEN
        RAISE EXCEPTION
            'STEP 9I BLOCKED: evidence pro RUN_20260929095736098 již existuje.';
    END IF;


    /* =====================================================
       4. ID GENERATION

       Tabulka nemá DEFAULT/IDENTITY pro PK.
       Proto ji na okamžik zamkneme a bezpečně vezmeme MAX+1.
       ===================================================== */

    LOCK TABLE ops.source_audit_evidence
        IN SHARE ROW EXCLUSIVE MODE;

    SELECT COALESCE(MAX(audit_evidence_id), 0) + 1
    INTO v_new_id
    FROM ops.source_audit_evidence;


    /* =====================================================
       5. PERSISTENT EVIDENCE INSERT
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
    (
        v_new_id,
        18,
        'RUNTIME_COVERAGE_TEST',

        'api_sports:HB:CORE:fixtures:league_131:season_2024',

        'RUN_20260929095736098',

        'PASS',

        TIMESTAMPTZ '2026-09-29 09:57:36.098+02',

        'https://v1.handball.api-sports.io/games?league=131&season=2024',

        jsonb_build_object(
            'canonical_source',          'API-Sports',
            'source_id',                 18,
            'runtime_adapter',           'api_handball',
            'adapter_id',                9,

            'sport_code',                'HB',
            'layer_type',                'CORE',
            'entity',                    'fixtures',

            'tested_time_modes',
                jsonb_build_array(
                    'HISTORY_FAN',
                    'HISTORY_PREDICTION'
                ),

            'public_league_id',          24881,
            'provider_league_id',        131,
            'season',                    '2024',

            'db_expected_matches',       132,
            'db_finished',               132,
            'db_finished_with_score',    132,
            'db_scheduled',              0,
            'db_cancelled',              0,

            'api_returned_matches',      132,

            'api_base',
                'https://v1.handball.api-sports.io',

            'endpoint',                  'games',

            'request_url',
                'https://v1.handball.api-sports.io/games?league=131&season=2024',

            'run_id',                    '20260929095736098',

            'dry_run',                   true,
            'db_modified',               false,

            'payload_sha256',
                '3bfa750568a3ca959f5983b096f855bf1ae4a90c38d4a5cef718b4003ce70013',

            'conclusion',
                'API-Sports runtime historical fixtures availability verified for tested HB scope. This evidence does not by itself prove complete HB historical coverage.'
        )::text,

        NULL,       -- důkaz historického testu sám neexpiruje
        NULL,       -- reviewer zatím není formálně přiřazen

        '3bfa750568a3ca959f5983b096f855bf1ae4a90c38d4a5cef718b4003ce70013'
    );


    /* =====================================================
       6. VALIDACE
       ===================================================== */

    SELECT COUNT(*)
    INTO v_count
    FROM ops.source_audit_evidence
    WHERE audit_evidence_id = v_new_id
      AND source_id = 18
      AND audit_dimension = 'RUNTIME_COVERAGE_TEST'
      AND evidence_key =
          'api_sports:HB:CORE:fixtures:league_131:season_2024'
      AND evidence_version =
          'RUN_20260929095736098'
      AND result_status = 'PASS'
      AND evidence_hash =
          '3bfa750568a3ca959f5983b096f855bf1ae4a90c38d4a5cef718b4003ce70013';


    IF v_count <> 1 THEN
        RAISE EXCEPTION
            'STEP 9I VALIDATION FAIL: persistent evidence row nebyl jednoznačně ověřen.';
    END IF;


    RAISE NOTICE
        'STEP_9I_EVIDENCE_ID=%',
        v_new_id;

    RAISE NOTICE
        'STEP_9I_SCOPE=API-Sports/HB/CORE/fixtures/league_131/season_2024';

    RAISE NOTICE
        'STEP_9I_RESULT=API_132 DB_132 DRY_RUN_TRUE DB_MODIFIED_FALSE';

    RAISE NOTICE
        'STEP_9I_STATUS=APPLY_PASS';

END
$$;