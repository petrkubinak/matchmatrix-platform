SELECT
    entity_order,
    entity,

    CASE entity
        WHEN 'leagues'  THEN 'Leagues'
        WHEN 'teams'    THEN 'Teams'
        WHEN 'fixtures' THEN 'Fixtures'
        WHEN 'odds'     THEN 'Odds'
        WHEN 'players'  THEN 'Players'
        WHEN 'coaches'  THEN 'Coaches'
        ELSE entity
    END AS entity_label,

    COUNT(*) AS jobs_count

FROM ops.v_ops_hk_top_full_execution_order
GROUP BY entity_order, entity
ORDER BY entity_order, entity;