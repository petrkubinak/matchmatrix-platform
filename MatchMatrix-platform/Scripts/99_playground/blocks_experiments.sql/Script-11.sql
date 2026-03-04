SELECT
  tb.block_index,
  tb.block_type,
  ht.name AS home,
  at.name AS away,
  tb.market_outcome_id
FROM template_blocks tb
JOIN matches m ON m.id = tb.match_id
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
WHERE tb.template_id = 1
ORDER BY tb.block_index;
