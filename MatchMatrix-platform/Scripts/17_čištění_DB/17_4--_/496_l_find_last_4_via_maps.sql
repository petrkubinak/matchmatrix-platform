-- 496_l_find_last_4_via_maps.sql
-- Cíl:
-- dohledat poslední 4 aliasy přes existující mapy a aliasy, ne jen přes teams.name

WITH wanted(alias) AS (
    VALUES
        ('universidad catolica chi'),
        ('corinthians sp'),
        ('flamengo rj'),
        ('palmeiras sp')
)

-- 1) hledání v team_aliases
SELECT
    'team_aliases' AS source_table,
    w.alias AS searched_alias,
    a.team_id,
    t.name AS canonical_team_name,
    a.alias AS matched_value
FROM wanted w
JOIN public.team_aliases a
  ON LOWER(unaccent(a.alias)) LIKE '%' || REPLACE(LOWER(unaccent(w.alias)), ' ', '%') || '%'
JOIN public.teams t
  ON t.id = a.team_id

UNION ALL

-- 2) hledání v teams.name
SELECT
    'teams' AS source_table,
    w.alias AS searched_alias,
    t.id AS team_id,
    t.name AS canonical_team_name,
    t.name AS matched_value
FROM wanted w
JOIN public.teams t
  ON LOWER(unaccent(t.name)) LIKE '%' || REPLACE(LOWER(unaccent(w.alias)), ' ', '%') || '%'

UNION ALL

-- 3) hledání v team_provider_map.provider_team_id
SELECT
    'team_provider_map.provider_team_id' AS source_table,
    w.alias AS searched_alias,
    m.team_id,
    t.name AS canonical_team_name,
    m.provider_team_id AS matched_value
FROM wanted w
JOIN public.team_provider_map m
  ON LOWER(unaccent(m.provider_team_id)) LIKE '%' || REPLACE(LOWER(unaccent(w.alias)), ' ', '%') || '%'
JOIN public.teams t
  ON t.id = m.team_id

ORDER BY searched_alias, source_table, canonical_team_name;