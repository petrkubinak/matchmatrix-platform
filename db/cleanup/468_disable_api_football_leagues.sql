-- 468_disable_api_football_leagues.sql

-- ❗ NE MAZÁME
-- jen označíme jako neaktivní pro ingest / matching

ALTER TABLE public.leagues
ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT true;

-- deaktivace API lig
UPDATE public.leagues
SET is_active = false
WHERE ext_source = 'api_football';

-- kontrola
SELECT
    ext_source,
    is_active,
    COUNT(*) 
FROM public.leagues
GROUP BY ext_source, is_active
ORDER BY ext_source, is_active;