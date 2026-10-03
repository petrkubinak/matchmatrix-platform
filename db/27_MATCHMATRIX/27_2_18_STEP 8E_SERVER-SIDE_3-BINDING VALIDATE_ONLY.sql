/*
CO:
STEP 8E – SERVER-SIDE 3-BINDING VALIDATE_ONLY

K ČEMU:
Ověřit uvnitř jediného PostgreSQL server-side příkazu
tři bindingy API-Sports -> api_handball:
fixtures, leagues, teams.

JAK:
INSERT proběhne v interním subtransaction bloku.
Po ověření je záměrně vyvolán rollback tohoto subtransactionu.
Do DB nezůstane žádný řádek.
*/

DO $$
DECLARE
    v_total       integer := -1;
    v_distinct    integer := -1;
    v_players     integer := -1;
    v_bad_status  integer := -1;
    v_bad_active  integer := -1;
    v_after       integer := -1;
BEGIN

    /* -----------------------------------------------------
       1. GUARD – před testem nesmí existovat naše testovací ID
       ----------------------------------------------------- */

    IF EXISTS (
        SELECT 1
        FROM ops.source_adapter_binding
        WHERE source_adapter_binding_id IN (-8201, -8202, -8203)
    ) THEN
        RAISE EXCEPTION
            'STEP 8E GUARD FAIL: testovací ID již existují.';
    END IF;


    /* -----------------------------------------------------
       2. INTERNÍ SUBTRANSACTION
       ----------------------------------------------------- */

    BEGIN

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
            -8201,
            18,
            9,
            'HB',
            'fixtures',
            5,
            NULL,
            'EVIDENCED',
            false,
            'STEP 8E SERVER-SIDE VALIDATE_ONLY / fixtures'
        ),
        (
            -8202,
            18,
            9,
            'HB',
            'leagues',
            5,
            NULL,
            'EVIDENCED',
            false,
            'STEP 8E SERVER-SIDE VALIDATE_ONLY / leagues'
        ),
        (
            -8203,
            18,
            9,
            'HB',
            'teams',
            5,
            NULL,
            'EVIDENCED',
            false,
            'STEP 8E SERVER-SIDE VALIDATE_ONLY / teams'
        );


        SELECT
            COUNT(*),
            COUNT(DISTINCT entity),
            COUNT(*) FILTER (
                WHERE binding_status <> 'EVIDENCED'
            ),
            COUNT(*) FILTER (
                WHERE is_active IS DISTINCT FROM false
            )
        INTO
            v_total,
            v_distinct,
            v_bad_status,
            v_bad_active
        FROM ops.source_adapter_binding
        WHERE source_adapter_binding_id IN (-8201, -8202, -8203);


        SELECT COUNT(*)
        INTO v_players
        FROM ops.source_adapter_binding
        WHERE source_id = 18
          AND adapter_id = 9
          AND sport_code = 'HB'
          AND entity = 'players';


        RAISE NOTICE
            'STEP_8E_INSIDE total=%, distinct=%, players=%, bad_status=%, bad_active=%',
            v_total,
            v_distinct,
            v_players,
            v_bad_status,
            v_bad_active;


        IF v_total <> 3
           OR v_distinct <> 3
           OR v_players <> 0
           OR v_bad_status <> 0
           OR v_bad_active <> 0
        THEN
            RAISE EXCEPTION
                'STEP 8E VALIDATION FAIL: total=%, distinct=%, players=%, bad_status=%, bad_active=%',
                v_total,
                v_distinct,
                v_players,
                v_bad_status,
                v_bad_active;
        END IF;


        /* Záměrný rollback pouze interního bloku */
        RAISE EXCEPTION USING
            ERRCODE = 'P0002',
            MESSAGE = 'STEP_8E_FORCE_ROLLBACK';

    EXCEPTION
        WHEN SQLSTATE 'P0002' THEN
            NULL;
    END;


    /* -----------------------------------------------------
       3. DŮKAZ ROLLBACKU
       ----------------------------------------------------- */

    SELECT COUNT(*)
    INTO v_after
    FROM ops.source_adapter_binding
    WHERE source_adapter_binding_id IN (-8201, -8202, -8203);


    RAISE NOTICE
        'STEP_8E_AFTER_ROLLBACK=%',
        v_after;


    IF v_after <> 0 THEN
        RAISE EXCEPTION
            'STEP 8E ROLLBACK FAIL: po rollbacku zůstalo % řádků.',
            v_after;
    END IF;


    RAISE NOTICE
        'STEP_8E_STATUS=PASS';

END
$$;