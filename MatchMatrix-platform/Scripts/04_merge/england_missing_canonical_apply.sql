BEGIN;

SELECT public.merge_team(
  (SELECT id FROM teams WHERE name = 'Cardiff'),
  (SELECT id FROM teams WHERE name = 'Cardiff City FC'),
  'England: Cardiff -> Cardiff City FC'::text,
  'manual'::text
);

SELECT public.merge_team(
  (SELECT id FROM teams WHERE name = 'Huddersfield'),
  (SELECT id FROM teams WHERE name = 'Huddersfield Town AFC'),
  'England: Huddersfield -> Huddersfield Town AFC'::text,
  'manual'::text
);

-- Pozor: u tebe canonical už je "Leicester City FC"
SELECT public.merge_team(
  public.get_team_id('leicester%'),              -- pokud existuje i "Leicester" jako old
  (SELECT id FROM teams WHERE name = 'Leicester City FC'),
  'England: Leicester -> Leicester City FC'::text,
  'manual'::text
);

-- Pozor: u tebe canonical už je "Norwich City FC"
SELECT public.merge_team(
  public.get_team_id('norwich%'),                -- pokud existuje i "Norwich" jako old
  (SELECT id FROM teams WHERE name = 'Norwich City FC'),
  'England: Norwich -> Norwich City FC'::text,
  'manual'::text
);

-- West Bromwich Albion: canonical je "West Bromwich Al..." (zjisti přesně názvem, viz níž)
-- Tady to uděláme bezpečně přes pattern:
SELECT public.merge_team(
  public.get_team_id('west brom%'),
  public.get_team_id('west bromwich%'),
  'England: West Brom -> West Bromwich Albion FC'::text,
  'manual'::text
);

SELECT public.merge_team(
  (SELECT id FROM teams WHERE name = 'Luton'),
  (SELECT id FROM teams WHERE name = 'Luton Town FC'),
  'England: Luton -> Luton Town FC'::text,
  'manual'::text
);

COMMIT;