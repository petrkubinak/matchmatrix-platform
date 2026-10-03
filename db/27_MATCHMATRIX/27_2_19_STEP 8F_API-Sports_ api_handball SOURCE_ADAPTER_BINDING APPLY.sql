/*
CO:
STEP 8F – API-Sports -> api_handball SOURCE_ADAPTER_BINDING APPLY

K ČEMU:
Trvale zapsat první tři prokázané source -> runtime adapter bindingy:
fixtures, leagues, teams.

KDE:
Databáze matchmatrix.

JAK:
Jeden atomický PostgreSQL DO blok.
Při jakékoliv chybě se celý příkaz zruší.
Při PASS se změna v Auto-commit režimu trvale uloží.

DŮLEŽITÉ:
- players se nevkládají,
- worker_binding_id zůstává NULL,
- binding není coverage confirmation,
- binding není routing approval,
- is_active zůstává false.
*/

DO $$
DECLARE
    v_total        integer;
    v_distinct     integer;
    v_players      integer;
    v_bad_status   integer;
    v_bad_active   integer;
    v_bad_account  integer;
    v_bad_worker   integer;
    v_ids          text;
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
          AND canonical_domain = 'api-sports.io'
    ) THEN
        RAISE EXCEPTION
            'STEP 8F BLOCKED: source_id=18 není očekávaná API-Sports identita.';
    END IF;


    /* =====================================================
       2. SPORT GUARD
       ===================================================== */

    IF NOT EXISTS (
        SELECT 1
        FROM ops.source_sport
        WHERE source_id = 18
          AND sport_code = 'HB'
    ) THEN
        RAISE EXCEPTION
            'STEP 8F BLOCKED: API-Sports nemá potvrzený vztah ke sportu HB.';
    END IF;


    /* =====================================================
       3. ADAPTER GUARD
       ===================================================== */

    IF NOT EXISTS (
        SELECT 1
        FROM ops.runtime_adapter
        WHERE adapter_id = 9
          AND adapter_code = 'api_handball'
          AND runtime_status = 'REGISTERED'
    ) THEN
        RAISE EXCEPTION
            'STEP 8F BLOCKED: adapter_id=9 není očekávaný api_handball.';
    END IF;


    /* =====================================================
       4. ACCOUNT / ENDPOINT GUARD
       ===================================================== */

    IF NOT EXISTS (
        SELECT 1
        FROM ops.provider_accounts
        WHERE id = 5
          AND provider = 'api_handball'
          AND is_active = true
          AND api_base_url = 'https://v1.handball.api-sports.io'
    ) THEN
        RAISE EXCEPTION
            'STEP 8F BLOCKED: account_id=5 neodpovídá aktivnímu API-Sports HB účtu.';
    END IF;


    /* =====================================================
       5. WORKER EVIDENCE GUARD
       Musí existovat právě tři podporované CORE entity.
       ===================================================== */

    IF (
        SELECT COUNT(*)
        FROM ops.provider_worker_registry
        WHERE provider = 'api_handball'
          AND sport_code = 'HB'
          AND entity IN ('fixtures', 'leagues', 'teams')
          AND is_supported = true
          AND is_active = true
    ) <> 3 THEN
        RAISE EXCEPTION
            'STEP 8F BLOCKED: fixtures/leagues/teams worker evidence není kompletní.';
    END IF;


    /* =====================================================
       6. DUPLICATE / RERUN GUARD
       APPLY se nesmí spustit podruhé.
       ===================================================== */

    IF EXISTS (
        SELECT 1
        FROM ops.source_adapter_binding
        WHERE source_id = 18
          AND adapter_id = 9
          AND sport_code = 'HB'
          AND entity IN ('fixtures', 'leagues', 'teams')
    ) THEN
        RAISE EXCEPTION
            'STEP 8F BLOCKED: některý z cílových bindingů už existuje.';
    END IF;


    /* =====================================================
       7. PERSISTENT INSERT
       Sequence použijeme explicitně, protože PK zatím
       nemá DEFAULT.
       ===================================================== */

    INSERT INTO ops.source_adapter_binding
    (
        source_adapter_binding_id,
        source_id,
        adapter_id,
        sport_code,
        entity,
        account_id,
        worker_binding_id,
        binding_status,
        is_active,
        notes
    )
    VALUES
    (
        nextval('ops.source_adapter_binding_source_adapter_binding_id_seq'::regclass),
        18,
        9,
        'HB',
        'fixtures',
        5,
        NULL,
        'EVIDENCED',
        false,
        'HB pilot. API-Sports -> api_handball / fixtures. '
        'Canonical identity, endpoint, account and runtime path evidenced. '
        'Not coverage confirmation and not routing approval.'
    ),
    (
        nextval('ops.source_adapter_binding_source_adapter_binding_id_seq'::regclass),
        18,
        9,
        'HB',
        'leagues',
        5,
        NULL,
        'EVIDENCED',
        false,
        'HB pilot. API-Sports -> api_handball / leagues. '
        'Canonical identity, endpoint, account and runtime path evidenced. '
        'Not coverage confirmation and not routing approval.'
    ),
    (
        nextval('ops.source_adapter_binding_source_adapter_binding_id_seq'::regclass),
        18,
        9,
        'HB',
        'teams',
        5,
        NULL,
        'EVIDENCED',
        false,
        'HB pilot. API-Sports -> api_handball / teams. '
        'Canonical identity, endpoint, account and runtime path evidenced. '
        'Not coverage confirmation and not routing approval.'
    );


    /* =====================================================
       8. VALIDACE PERSISTENTNÍHO STAVU
       ===================================================== */

    SELECT
        COUNT(*),
        COUNT(DISTINCT entity),
        COUNT(*) FILTER (
            WHERE binding_status <> 'EVIDENCED'
        ),
        COUNT(*) FILTER (
            WHERE is_active IS DISTINCT FROM false
        ),
        COUNT(*) FILTER (
            WHERE account_id IS DISTINCT FROM 5
        ),
        COUNT(*) FILTER (
            WHERE worker_binding_id IS NOT NULL
        )
    INTO
        v_total,
        v_distinct,
        v_bad_status,
        v_bad_active,
        v_bad_account,
        v_bad_worker
    FROM ops.source_adapter_binding
    WHERE source_id = 18
      AND adapter_id = 9
      AND sport_code = 'HB'
      AND entity IN ('fixtures', 'leagues', 'teams');


    SELECT COUNT(*)
    INTO v_players
    FROM ops.source_adapter_binding
    WHERE source_id = 18
      AND adapter_id = 9
      AND sport_code = 'HB'
      AND entity = 'players';


    IF v_total <> 3
       OR v_distinct <> 3
       OR v_players <> 0
       OR v_bad_status <> 0
       OR v_bad_active <> 0
       OR v_bad_account <> 0
       OR v_bad_worker <> 0
    THEN
        RAISE EXCEPTION
            'STEP 8F VALIDATION FAIL: total=%, distinct=%, players=%, bad_status=%, bad_active=%, bad_account=%, bad_worker=%',
            v_total,
            v_distinct,
            v_players,
            v_bad_status,
            v_bad_active,
            v_bad_account,
            v_bad_worker;
    END IF;


    /* =====================================================
       9. VÝPIS PŘIDĚLENÝCH ID
       ===================================================== */

    SELECT string_agg(
               source_adapter_binding_id::text || ':' || entity,
               ', '
               ORDER BY source_adapter_binding_id
           )
    INTO v_ids
    FROM ops.source_adapter_binding
    WHERE source_id = 18
      AND adapter_id = 9
      AND sport_code = 'HB'
      AND entity IN ('fixtures', 'leagues', 'teams');


    RAISE NOTICE
        'STEP_8F_BINDINGS=%',
        v_ids;

    RAISE NOTICE
        'STEP_8F_VALIDATE total=%, distinct=%, players=%, bad_status=%, bad_active=%, bad_account=%, bad_worker=%',
        v_total,
        v_distinct,
        v_players,
        v_bad_status,
        v_bad_active,
        v_bad_account,
        v_bad_worker;

    RAISE NOTICE
        'STEP_8F_STATUS=APPLY_PASS';

END
$$;