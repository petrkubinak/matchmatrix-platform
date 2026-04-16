-- 485_cleanup_wrong_team_aliases.sql
-- Smaže jen prokazatelně špatné aliasy z theodds/manual vrstvy

DELETE FROM public.team_aliases
WHERE
    (lower(alias) = 'barcelona sc' AND team_id = 80)
 OR (lower(alias) = 'czech republic' AND team_id = 28510)
 OR (lower(alias) = 'junior fc' AND team_id = 594)
 OR (lower(alias) = 'rosario central' AND team_id = 25886)
 OR (lower(alias) = 'sporting cristal' AND team_id = 28013);

-- kontrola
SELECT
    ta.team_id,
    t.name AS mapped_team_name,
    ta.alias,
    ta.source,
    t.ext_source,
    t.ext_team_id
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE lower(ta.alias) IN (
    'barcelona sc',
    'czech republic',
    'junior fc',
    'rosario central',
    'sporting cristal',
    'corinthians-sp',
    'flamengo-rj',
    'independiente del valle',
    'libertad asuncion',
    'nacional de montevideo',
    'palmeiras-sp',
    'universidad católica (chi)'
)
ORDER BY lower(ta.alias), t.name;