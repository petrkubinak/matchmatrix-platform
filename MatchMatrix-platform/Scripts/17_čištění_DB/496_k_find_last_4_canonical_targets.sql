-- 496_k_find_last_4_canonical_targets.sql
-- Cíl:
-- najít canonical team_id pro poslední 4 zbývající aliasy

WITH wanted(alias) AS (
    VALUES
        ('universidad catolica chi'),
        ('corinthians sp'),
        ('flamengo rj'),
        ('palmeiras sp')
)
SELECT
    w.alias,
    t.id AS team_id,
    t.name AS team_name
FROM wanted w
JOIN public.teams t
  ON LOWER(unaccent(t.name)) LIKE '%' || REPLACE(LOWER(unaccent(w.alias)), ' ', '%') || '%'
ORDER BY w.alias, t.name;


WITH wanted(alias) AS (
    VALUES
        ('universidad catolica chi'),
        ('corinthians sp'),
        ('flamengo rj'),
        ('palmeiras sp')
)
SELECT
    w.alias,
    t.id AS team_id,
    t.name AS team_name
FROM wanted w
JOIN public.teams t
  ON LOWER(t.name) LIKE '%' || REPLACE(LOWER(w.alias), ' ', '%') || '%'
ORDER BY w.alias, t.name;