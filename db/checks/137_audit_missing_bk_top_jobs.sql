SELECT
    t.provider AS target_provider,
    t.sport_code AS target_sport_code,
    t.run_group,
    COUNT(*) AS target_rows,
    COUNT(iep.entity) AS matched_entity_rows
FROM ops.v_top_ingest_targets t
LEFT JOIN ops.ingest_entity_plan iep
  ON iep.provider = t.provider
 AND iep.sport_code = t.sport_code
 AND iep.enabled = TRUE
WHERE t.sport_code = 'BK'
GROUP BY
    t.provider,
    t.sport_code,
    t.run_group;