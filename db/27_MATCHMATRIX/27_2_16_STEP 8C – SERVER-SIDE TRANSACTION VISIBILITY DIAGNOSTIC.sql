/*
CO:
STEP 8C – SERVER-SIDE TRANSACTION VISIBILITY DIAGNOSTIC

K ČEMU:
Ověřit přímo uvnitř PostgreSQL serveru, zda je právě vložený
SOURCE_ADAPTER_BINDING řádek okamžitě viditelný ve stejné transakci.

KDE:
matchmatrix / PostgreSQL

JAK:
BEGIN -> jeden DO blok -> kontrola -> ROLLBACK.
Žádná trvalá změna.
*/

BEGIN;


DO $$
DECLARE
    v_inserted_id bigint;
    v_visible_rows integer;
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
        -8002,
        18,
        9,
        'HB',
        'fixtures',
        5,
        NULL,
        'EVIDENCED',
        false,
        'STEP 8C SERVER-SIDE VISIBILITY DIAGNOSTIC'
    )
    RETURNING source_adapter_binding_id
    INTO v_inserted_id;


    SELECT COUNT(*)
    INTO v_visible_rows
    FROM ops.source_adapter_binding
    WHERE source_adapter_binding_id = -8002;


    RAISE NOTICE 'STEP_8C_INSERTED_ID=%', v_inserted_id;
    RAISE NOTICE 'STEP_8C_ROWS_VISIBLE_INSIDE_DO=%', v_visible_rows;

END
$$;


SELECT
    source_adapter_binding_id,
    source_id,
    adapter_id,
    sport_code,
    entity,
    binding_status,
    is_active
FROM ops.source_adapter_binding
WHERE source_adapter_binding_id = -8002;


ROLLBACK;


SELECT
    COUNT(*) AS rows_after_rollback
FROM ops.source_adapter_binding
WHERE source_adapter_binding_id = -8002;