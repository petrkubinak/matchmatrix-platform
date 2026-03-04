SELECT template_id, COUNT(*) AS variable_blocks
FROM template_blocks
WHERE block_type = 'VARIABLE'
GROUP BY template_id
ORDER BY template_id;
