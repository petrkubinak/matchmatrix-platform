/*
CO:
STEP 8B – DIRECT SINGLE INSERT DIAGNOSTIC

K ČEMU:
Izolovaně ověřit, zda fyzický INSERT do
ops.source_adapter_binding skutečně funguje.

KDE:
matchmatrix / DBeaver

JAK:
Jeden dočasný INSERT s RETURNING.
Na konci ROLLBACK.
Nic nezůstane trvale uložené.
*/

BEGIN;

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
    -8001,
    18,
    9,
    'HB',
    'fixtures',
    5,
    NULL,
    'EVIDENCED',
    false,
    'STEP 8B DIRECT INSERT DIAGNOSTIC - temporary row only'
)
RETURNING
    source_adapter_binding_id,
    source_id,
    adapter_id,
    sport_code,
    entity,
    account_id,
    worker_binding_id,
    binding_status,
    is_active;


SELECT
    COUNT(*) AS rows_inside_transaction
FROM ops.source_adapter_binding
WHERE source_adapter_binding_id = -8001;


ROLLBACK;


SELECT
    COUNT(*) AS rows_after_rollback
FROM ops.source_adapter_binding
WHERE source_adapter_binding_id = -8001;