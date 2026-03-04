SELECT
  tb.template_id,
  t.name AS template_name,
  tb.block_index,
  tb.block_type,
  m.id AS match_id,
  ht.name AS home,
  at.name AS away,
  tb.market_outcome_id
FROM template_blocks tb
JOIN templates t ON t.id = tb.template_id
JOIN matches m ON m.id = tb.match_id
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
ORDER BY tb.template_id, tb.block_index;
