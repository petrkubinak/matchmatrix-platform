-- 810_media_article_team_mapping_v1.sql
-- MEDIA ARTICLE -> TEAM MAP V1 (simple URL heuristic)

INSERT INTO public.article_team_map (
    article_id,
    team_id
)
SELECT DISTINCT
    a.id,
    t.id
FROM public.articles a
JOIN public.teams t
    ON lower(a.url) LIKE '%' || lower(replace(t.name, ' ', '-')) || '%'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.article_team_map atm
    WHERE atm.article_id = a.id
      AND atm.team_id = t.id
);

-- kontrola
SELECT
    COUNT(*) AS article_team_maps
FROM public.article_team_map;

-- ukázky
SELECT
    atm.article_id,
    t.name AS team_name,
    a.url
FROM public.article_team_map atm
JOIN public.teams t
    ON t.id = atm.team_id
JOIN public.articles a
    ON a.id = atm.article_id
ORDER BY atm.article_id DESC
LIMIT 20;