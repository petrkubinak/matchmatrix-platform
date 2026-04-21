-- =====================================================================
-- 272_find_canonical_candidates_for_encoding_batch.sql
-- Najdi realne canonical kandidaty pro prvni encoding batch
-- =====================================================================

SELECT
    id,
    name
FROM public.teams
WHERE
       LOWER(name) LIKE '%cura%'
    OR LOWER(name) LIKE '%turk%'
    OR LOWER(name) LIKE '%monz%'
    OR LOWER(name) LIKE '%meri%'
    OR LOWER(name) LIKE '%baku%'
    OR LOWER(name) LIKE '%dinamo bak%'
ORDER BY name;