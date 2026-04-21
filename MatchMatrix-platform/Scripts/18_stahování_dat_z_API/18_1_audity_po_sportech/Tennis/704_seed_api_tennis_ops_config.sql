-- 704_seed_api_tennis_ops_config.sql
-- Seed základního OPS configu pro Tennis provider
-- Pozn.: api_base_url si případně upravíš podle reálného providera

BEGIN;

-- =========================================================
-- 1) provider account
-- =========================================================
INSERT INTO ops.provider_accounts (
    provider,
    account_name,
    plan_code,
    is_active,
    daily_limit_total,
    daily_limit_per_sport,
    safety_reserve_pct,
    api_base_url,
    notes
)
SELECT
    'api_tennis',
    'default',
    'free',
    true,
    100,
    100,
    10.00,
    'https://api.api-tennis.com',
    'Tennis provider default account seed'
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.provider_accounts
    WHERE provider = 'api_tennis'
      AND account_name = 'default'
);

-- =========================================================
-- 2) ingest_entity_plan doplnění source/worker/target
-- =========================================================
UPDATE ops.ingest_entity_plan
SET
    source_endpoint = '/leagues',
    target_table    = 'staging.api_tennis_leagues_raw',
    worker_script   = 'ingest\API-Tennis\pull_api_tennis_leagues_v1.py',
    updated_at      = now()
WHERE provider = 'api_tennis'
  AND sport_code = 'TN'
  AND entity = 'leagues'
  AND (
      source_endpoint IS NULL
      OR target_table IS NULL
      OR worker_script IS NULL
  );

-- =========================================================
-- 3) provider_entity_coverage doplnění technických metadat
-- =========================================================
UPDATE ops.provider_entity_coverage
SET
    source_endpoint = COALESCE(source_endpoint, '/leagues'),
    target_table    = COALESCE(target_table, 'staging.api_tennis_leagues_raw'),
    worker_script   = COALESCE(worker_script, 'ingest\API-Tennis\pull_api_tennis_leagues_v1.py'),
    notes           = COALESCE(notes, 'Tennis leagues raw pull seed'),
    next_action     = COALESCE(next_action, 'Zprovoznit pull worker a otestovat RAW ingest'),
    updated_at      = now()
WHERE provider = 'api_tennis'
  AND sport_code = 'TN'
  AND entity = 'leagues';

COMMIT;