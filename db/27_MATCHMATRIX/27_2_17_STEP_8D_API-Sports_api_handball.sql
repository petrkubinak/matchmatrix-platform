/*
CO:
STEP 8D – API-Sports -> api_handball
3 BINDINGS VALIDATE_ONLY

K ČEMU:
Ověřit dočasně tři technicky doložené bindingy:
fixtures, leagues, teams.

KDE:
matchmatrix / PostgreSQL

JAK:
Jedna transakce.
Na konci ROLLBACK.
Players zůstávají mimo.
*/

BEGIN;


/* =========================================================
   1. VLOŽENÍ TŘÍ DOČASNÝCH BINDINGŮ
   ========================================================= */

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
    -8101,
    18,
    9,
    'HB',
    'fixtures',
    5,
    NULL,
    'EVIDENCED',
    false,
    'STEP 8D VALIDATE_ONLY - API-Sports -> api_handball / HB / fixtures'
),
(
    -8102,
    18,
    9,
    'HB',
    'leagues',
    5,
    NULL,
    'EVIDENCED',
    false,
    'STEP 8D VALIDATE_ONLY - API-Sports -> api_handball / HB / leagues'
),
(
    -8103,
    18,
    9,
    'HB',
    'teams',
    5,
    NULL,
    'EVIDENCED',
    false,
    'STEP 8D VALIDATE_ONLY - API-Sports -> api_handball / HB / teams'
);


/* =========================================================
   2. KONTROLA TŘÍ ŘÁDKŮ
   ========================================================= */

SELECT
    source_adapter_binding_id,
    source_id,
    adapter_id,
    sport_code,
    entity,
    account_id,
    worker_binding_id,
    binding_status,
    is_active
FROM ops.source_adapter_binding
WHERE source_adapter_binding_id IN (-8101, -8102, -8103)
ORDER BY entity;


/* =========================================================
   3. SOUHRNNÁ KONTROLA
   ========================================================= */

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT entity) AS distinct_entities
FROM ops.source_adapter_binding
WHERE source_adapter_binding_id IN (-8101, -8102, -8103);


/* =========================================================
   4. PLAYERS MUSÍ ZŮSTAT MIMO
   ========================================================= */

SELECT
    COUNT(*) AS players_rows
FROM ops.source_adapter_binding
WHERE source_id = 18
  AND adapter_id = 9
  AND sport_code = 'HB'
  AND entity = 'players';


/* =========================================================
   5. ROLLBACK
   ========================================================= */

ROLLBACK;


/* =========================================================
   6. DŮKAZ NÁVRATU
   ========================================================= */

SELECT
    COUNT(*) AS rows_after_rollback
FROM ops.source_adapter_binding
WHERE source_adapter_binding_id IN (-8101, -8102, -8103);