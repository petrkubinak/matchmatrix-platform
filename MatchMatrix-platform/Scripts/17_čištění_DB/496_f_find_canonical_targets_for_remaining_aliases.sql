-- 496_f_find_canonical_targets_for_remaining_aliases.sql
-- Cíl:
-- najít v public.teams kandidátní canonical názvy pro zbývající aliasy

WITH wanted(alias) AS (
    VALUES
        ('gremio'),
        ('cerro porteno'),
        ('ucv'),
        ('universidad catolica chi'),
        ('corinthians sp'),
        ('flamengo rj'),
        ('independiente medellin'),
        ('junior'),
        ('la guaira'),
        ('palmeiras sp')
)
SELECT
    w.alias,
    t.id AS team_id,
    t.name AS team_name
FROM wanted w
JOIN public.teams t
  ON LOWER(unaccent(t.name)) LIKE '%' || LOWER(unaccent(w.alias)) || '%'
ORDER BY w.alias, t.name;