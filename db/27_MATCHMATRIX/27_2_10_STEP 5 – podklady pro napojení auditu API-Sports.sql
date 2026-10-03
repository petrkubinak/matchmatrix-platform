/*
CO: STEP 5 – podklady pro napojení auditu API-Sports.
K ČEMU: Zjistit adaptér, účet, úlohy a existující vazby.
KDE: Databáze matchmatrix.
JAK: Pouze SELECT.
*/

-- 1. Technický adaptér.
SELECT
    adapter_id,
    adapter_code,
    adapter_type,
    runtime_status,
    provider_class,
    base_worker
FROM ops.runtime_adapter
WHERE adapter_code = 'api_handball';


-- 2. Evidované účty a jejich limity.
SELECT
    id AS account_id,
    provider,
    account_name,
    plan_code,
    is_active,
    daily_limit_total,
    daily_limit_per_sport,
    safety_reserve_pct,
    api_base_url
FROM ops.provider_accounts
WHERE provider = 'api_handball'
ORDER BY id;


-- 3. Úlohy registrované pro házenou.
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
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY entity, id;


-- 4. Případné vazby zdroje nebo adaptéru, včetně neaktivních.
SELECT
    b.source_adapter_binding_id,
    b.source_id,
    s.canonical_name,
    b.adapter_id,
    a.adapter_code,
    b.sport_code,
    b.entity,
    b.account_id,
    b.worker_binding_id,
    b.binding_status,
    b.is_active
FROM ops.source_adapter_binding b
JOIN ops.source_master s
  ON s.source_id = b.source_id
JOIN ops.runtime_adapter a
  ON a.adapter_id = b.adapter_id
WHERE b.source_id = 18
   OR a.adapter_code = 'api_handball'
ORDER BY b.source_adapter_binding_id;