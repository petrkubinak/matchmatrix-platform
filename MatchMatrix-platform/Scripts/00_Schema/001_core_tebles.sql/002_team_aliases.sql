INSERT INTO team_aliases(team_id, alias, source)
SELECT
  t.id,
  trim(
    regexp_replace(
      regexp_replace(lower(t.name), '\s+(fc|afc|cf|sc|ac)$', '', 'g'),
      '[^a-z0-9\s]', '',
      'g'
    )
  ) AS alias_norm,
  'theodds' AS source
FROM teams t
WHERE t.name IS NOT NULL
ON CONFLICT DO NOTHING;
