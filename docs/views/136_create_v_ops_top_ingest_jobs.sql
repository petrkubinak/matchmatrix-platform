CREATE OR REPLACE VIEW ops.v_top_ingest_jobs AS
SELECT
    t.id AS ingest_target_id,
    t.sport_code,
    t.canonical_league_id,
    t.provider,
    t.provider_league_id,
    t.season,
    t.enabled AS target_enabled,
    t.tier,
    t.fixtures_days_back,
    t.fixtures_days_forward,
    t.odds_days_forward,
    t.max_requests_per_run,
    t.notes,
    t.run_group,

    iep.entity,
    iep.priority,
    iep.enabled AS entity_enabled

FROM ops.v_top_ingest_targets t
JOIN ops.ingest_entity_plan iep
  ON iep.provider = t.provider
 AND iep.sport_code = t.sport_code
WHERE t.enabled = TRUE
  AND iep.enabled = TRUE;