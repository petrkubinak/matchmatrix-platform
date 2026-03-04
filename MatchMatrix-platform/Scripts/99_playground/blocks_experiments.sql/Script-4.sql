SELECT
  m.id,
  ht.name AS home,
  at.name AS away,
  mk.code AS market,
  o.code AS outcome,
  od.odd_value
FROM odds od
JOIN matches m ON m.id = od.match_id
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
JOIN market_outcomes o ON o.id = od.market_outcome_id
JOIN markets mk ON mk.id = o.market_id;
