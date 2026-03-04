SELECT
  tb.block_index,
  tb.block_type,
  tbm.match_order,
  m.id AS match_id,
  ht.name AS home,
  at.name AS away,
  m.kickoff
FROM template_blocks tb
JOIN template_block_matches tbm ON tbm.block_id = tb.id
JOIN matches m ON m.id = tbm.match_id
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
WHERE tb.template_id = 1 AND tb.block_index = 1
ORDER BY tbm.match_order;
