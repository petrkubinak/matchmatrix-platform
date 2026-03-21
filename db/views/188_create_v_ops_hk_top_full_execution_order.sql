CREATE OR REPLACE VIEW ops.v_ops_hk_top_full_execution_order AS
SELECT
    j.provider,
    j.sport_code,
    j.entity,
    j.provider_league_id,
    j.season,
    j.run_group,
    CASE j.entity
        WHEN 'leagues'  THEN 1
        WHEN 'teams'    THEN 2
        WHEN 'fixtures' THEN 3
        WHEN 'odds'     THEN 4
        WHEN 'players'  THEN 5
        WHEN 'coaches'  THEN 6
        ELSE 999
    END AS entity_order
FROM ops.v_ops_hk_top_ingest_jobs j
WHERE j.entity IN ('leagues', 'teams', 'fixtures', 'odds', 'players', 'coaches');