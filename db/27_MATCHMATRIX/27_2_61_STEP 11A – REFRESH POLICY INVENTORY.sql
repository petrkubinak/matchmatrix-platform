-- CO: STEP 11A – REFRESH POLICY INVENTORY, zjednodušený dotaz
-- K ČEMU: Najít názvy tabulek a pohledů souvisejících s plánováním harvestu.
-- KDE: Databáze matchmatrix na PC2.
-- JAK: Pouze čtení; bez agregací, které způsobily chybu DBeaveru.

SELECT DISTINCT
    table_schema,
    table_name
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
  AND (
      table_name  ~* 'refresh|cadence|frequen|schedul|interval|recheck|poll|planner|dispatch|queue|ingest_target|harvest|cron|job'
      OR column_name ~* 'refresh|cadence|frequen|schedul|interval|recheck|poll|retry|backoff|lookback|cooldown|throttle|cron|ttl|policy|next_|last_|due_at|run_at|run_every'
  )
ORDER BY table_schema, table_name;

-- CO: STEP 11A – struktura kandidátů pro Refresh Policy
-- K ČEMU: Zjistit, kde se dnes ukládají pravidla plánování a opakování.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení.

SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name IN (
      'ingest_targets',
      'ingest_planner',
      'scheduler_queue',
      'dispatch_queue',
      'jobs',
      'provider_jobs',
      'harvest_scope_completion'
  )
ORDER BY table_name, ordinal_position;

-- CO: STEP 11A – konfigurace provider jobs pro házenou
-- K ČEMU: Ověřit význam existujících nastavení ingest_mode a cooldown.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení.

SELECT
    id,
    provider,
    sport_code,
    job_code,
    endpoint_code,
    ingest_mode,
    enabled,
    priority,
    batch_size,
    max_requests_per_run,
    retry_limit,
    cooldown_seconds,
    days_back,
    days_forward,
    notes
FROM ops.provider_jobs
WHERE sport_code = 'HB'
   OR provider = 'api_handball'
ORDER BY provider, job_code, endpoint_code;

-- CO: STEP 11A – inventura časových pravidel v tabulkách ops
-- K ČEMU: Najít uložené parametry pro opakování, kontrolu a plánování.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení.

SELECT
    c.table_name,
    c.column_name,
    c.data_type
FROM information_schema.columns AS c
JOIN information_schema.tables AS t
  ON t.table_schema = c.table_schema
 AND t.table_name = c.table_name
WHERE c.table_schema = 'ops'
  AND t.table_type = 'BASE TABLE'
  AND c.column_name ~* 'refresh|cadence|frequen|schedul|interval|recheck|poll|cooldown|next_run|last_run|last_checked|retry|days_back|days_forward|policy|ttl|backoff|lookback|period'
ORDER BY c.table_name, c.ordinal_position;