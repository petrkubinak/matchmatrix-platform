-- =====================================================================
-- 276_find_canonical_candidates_for_remaining_encoding_cases.sql
-- Lookup canonical kandidatu pro zbyvajici encoding klubove pripady
-- =====================================================================

SELECT
    id,
    name
FROM public.teams
WHERE
       LOWER(name) LIKE '%almud%'
    OR LOWER(name) LIKE '%bin%'
    OR LOWER(name) LIKE '%meri%'
    OR LOWER(name) LIKE '%epila%'
    OR LOWER(name) LIKE '%dinamo bak%'
    OR LOWER(name) LIKE '%baku%'
    OR LOWER(name) LIKE '%samax%'
    OR LOWER(name) LIKE '%ahda%'
    OR LOWER(name) LIKE '%sim%al%'
    OR LOWER(name) LIKE '%imal%'
    OR LOWER(name) LIKE '%smkir%'
    OR LOWER(name) LIKE '%shamkir%'
    OR LOWER(name) LIKE '%ada%'
ORDER BY name;