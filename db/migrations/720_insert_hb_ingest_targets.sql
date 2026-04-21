-- 720_insert_hb_ingest_targets.sql
-- HANDball (HB) – ingest_targets pro planner

-- Nejprve kontrola (pro debug)
SELECT *
FROM ops.ingest_targets
WHERE sport_code = 'HB';


-- INSERT HB targets (pokud neexistují)
INSERT INTO ops.ingest_targets (
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    fixtures_days_back,
    fixtures_days_forward,
    odds_days_forward,
    max_requests_per_run,
    notes,
    run_group
)
SELECT
    'HB'                                AS sport_code,
    l.id                                AS canonical_league_id,
    'api_handball'                      AS provider,
    l.ext_league_id                     AS provider_league_id,
    '2024'                              AS season,
    true                                AS enabled,
    1                                   AS tier,
    7                                   AS fixtures_days_back,
    14                                  AS fixtures_days_forward,
    3                                   AS odds_days_forward,
    100                                 AS max_requests_per_run,
    'HB_CORE auto target'               AS notes,
    'HB_CORE'                           AS run_group
FROM public.leagues l
WHERE l.ext_source = 'api_handball'
  AND l.ext_league_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_targets t
      WHERE t.sport_code = 'HB'
        AND t.provider = 'api_handball'
        AND t.provider_league_id = l.ext_league_id
        AND t.season = '2024'
  );


-- Kontrola po insertu
SELECT sport_code, provider, provider_league_id, season, run_group
FROM ops.ingest_targets
WHERE sport_code = 'HB'
ORDER BY provider_league_id;