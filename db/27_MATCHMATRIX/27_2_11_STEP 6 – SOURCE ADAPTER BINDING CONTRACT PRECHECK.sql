/*
CO:
STEP 6 – SOURCE ADAPTER BINDING CONTRACT PRECHECK

K ČEMU:
Zjistit přesnou strukturu a FK kontrakt ops.source_adapter_binding
před vytvořením první vazby API-Sports -> api_handball.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT. Nic se nemění.
*/


-- =========================================================
-- 1. SLOUPCE SOURCE_ADAPTER_BINDING
-- =========================================================

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'source_adapter_binding'
ORDER BY ordinal_position;


-- =========================================================
-- 2. CONSTRAINTY A CIZÍ KLÍČE
-- =========================================================

SELECT
    c.conname AS constraint_name,
    c.contype AS constraint_type,
    pg_get_constraintdef(c.oid) AS definition
FROM pg_constraint c
WHERE c.conrelid = 'ops.source_adapter_binding'::regclass
ORDER BY c.contype, c.conname;


-- =========================================================
-- 3. KDE SE V OPS POUŽÍVAJÍ KLÍČOVÉ IDENTIFIKÁTORY
-- =========================================================

SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND column_name IN (
        'worker_binding_id',
        'worker_registry_id',
        'adapter_id',
        'account_id'
      )
ORDER BY table_name, ordinal_position;


-- =========================================================
-- 4. REGISTROVANÉ HB WORKERY – POTVRZENÍ
-- =========================================================

SELECT
    id AS worker_registry_id,
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active
FROM ops.provider_worker_registry
WHERE id IN (31, 32, 33, 49)
ORDER BY id;


-- =========================================================
-- 5. AKTUÁLNÍ BINDINGY API-SPORTS / API_HANDBALL
-- =========================================================

SELECT
    *
FROM ops.source_adapter_binding
WHERE source_id = 18
   OR adapter_id = 9
ORDER BY source_adapter_binding_id;