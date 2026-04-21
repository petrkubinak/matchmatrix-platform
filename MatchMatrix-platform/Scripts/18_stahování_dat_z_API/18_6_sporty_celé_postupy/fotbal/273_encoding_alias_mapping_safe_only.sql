-- =====================================================================
-- 273_encoding_alias_mapping_safe_only.sql
-- Jen 100% bezpecne encoding aliasy
-- =====================================================================

-- Atlético Monzón
INSERT INTO public.team_aliases (team_id, alias)
SELECT 27517, 'atltico monzn'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 27517
      AND LOWER(BTRIM(alias)) = 'atltico monzn'
);

-- Curaçao
INSERT INTO public.team_aliases (team_id, alias)
SELECT 669, 'curaao'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 669
      AND LOWER(BTRIM(alias)) = 'curaao'
);

-- Türkiye -> Turkey
INSERT INTO public.team_aliases (team_id, alias)
SELECT 119, 'trkiye'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases
    WHERE team_id = 119
      AND LOWER(BTRIM(alias)) = 'trkiye'
);