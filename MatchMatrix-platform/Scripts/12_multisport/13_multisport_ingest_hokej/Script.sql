SELECT entity, entity_order, COUNT(*) AS rows_count
FROM ops.v_ops_hk_top_full_execution_order
GROUP BY entity, entity_order
ORDER BY entity_order, entity;