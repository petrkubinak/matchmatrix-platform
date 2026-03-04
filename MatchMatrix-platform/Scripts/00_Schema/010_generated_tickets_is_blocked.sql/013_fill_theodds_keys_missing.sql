BEGIN;

-- UEFA Champions League (už máš, ale dávám pro jistotu idempotentně)
UPDATE leagues
SET theodds_key = 'soccer_uefa_champs_league'
WHERE name = 'UEFA Champions League'
  AND (theodds_key IS NULL OR theodds_key = '');

-- European Championship (EURO)
UPDATE leagues
SET theodds_key = 'soccer_uefa_euro'
WHERE name = 'European Championship'
  AND (theodds_key IS NULL OR theodds_key = '');

-- Copa Libertadores
UPDATE leagues
SET theodds_key = 'soccer_conmebol_copa_libertadores'
WHERE name = 'Copa Libertadores'
  AND (theodds_key IS NULL OR theodds_key = '');

-- FIFA World Cup
UPDATE leagues
SET theodds_key = 'soccer_fifa_world_cup'
WHERE name = 'FIFA World Cup'
  AND (theodds_key IS NULL OR theodds_key = '');

COMMIT;
