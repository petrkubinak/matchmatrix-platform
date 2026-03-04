-- 1) kolik týmů historicky v membership
SELECT COUNT(DISTINCT team_id) AS distinct_teams
FROM league_teams
WHERE league_id = 30;

-- 2) alias coverage (kdo má málo aliasů)
SELECT t.id, t.name AS canonical, COUNT(a.id) AS alias_count
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 30
GROUP BY t.id, t.name
ORDER BY alias_count ASC, t.name;

-- 3) bezpačný review (kdo má málo aliasů)
WITH cand(old_id, new_id, note) AS (
VALUES
  (1131, 99,  'Benfica short -> Sport Lisboa e Benfica'),
  (1129, 576, 'Porto short -> FC Porto'),
  (1121, 579, 'Arouca short -> FC Arouca'),
  (1122, 584, 'Famalicao short -> FC Famalicão'),
  (1124, 589, 'Alverca short -> FC Alverca'),
  (1120, 582, 'Nacional short -> CD Nacional'),
  (1123, 583, 'Santa Clara short -> CD Santa Clara'),
  (1126, 580, 'Tondela short -> CD Tondela'),
  (1127, 577, 'Estoril short -> GD Estoril Praia'),
  (1130, 586, 'Guimaraes short -> Vitória SC')
)
SELECT
  c.note,
  t1.id AS old_id, t1.name AS old_name, t1.ext_source AS old_src, t1.ext_team_id AS old_ext,
  t2.id AS new_id, t2.name AS new_name, t2.ext_source AS new_src, t2.ext_team_id AS new_ext
FROM cand c
JOIN teams t1 ON t1.id = c.old_id
JOIN teams t2 ON t2.id = c.new_id
ORDER BY c.note;

-- 4) kontrola po merge 
SELECT COUNT(DISTINCT team_id)
FROM league_teams
WHERE league_id = 30;



-- 4) kontrola po merge -"30_merge_estrela.sql"
SELECT t.name, COUNT(a.id)
FROM league_teams lt
JOIN teams t ON t.id = lt.team_id
LEFT JOIN team_aliases a ON a.team_id = t.id
WHERE lt.league_id = 30
GROUP BY t.name
ORDER BY t.name;

BEGIN;

SELECT public.merge_team(
    (SELECT id FROM teams WHERE name = 'Estrela'),
    (SELECT id FROM teams WHERE name = 'CF Estrela da Amadora'),
    'Primeira Liga 30: Estrela short -> CF Estrela da Amadora official',
    'manual'
);

COMMIT;