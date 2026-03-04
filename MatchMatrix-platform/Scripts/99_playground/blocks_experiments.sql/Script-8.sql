SELECT
  tb.block_index,
  tb.block_type,
  ht.name AS home,
  at.name AS away,
  mk.code AS market,
  mo.code AS fixed_outcome
FROM template_blocks tb
JOIN matches m ON m.id = tb.match_id
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
LEFT JOIN market_outcomes mo ON mo.id = tb.market_outcome_id
LEFT JOIN markets mk ON mk.id = mo.market_id
WHERE tb.template_id = 1
ORDER BY tb.block_index;
