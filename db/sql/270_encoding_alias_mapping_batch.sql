-- =====================================================================
-- 270_encoding_alias_mapping_batch.sql
-- Manualni alias mapping pro encoding problemy
-- =====================================================================

-- Curaçao
INSERT INTO public.team_aliases (team_id, alias)
SELECT id, 'curaao'
FROM public.teams
WHERE LOWER(name) LIKE '%curacao%';

-- Türkiye
INSERT INTO public.team_aliases (team_id, alias)
SELECT id, 'rkiye'
FROM public.teams
WHERE LOWER(name) LIKE '%turkiye%';

-- Atlético Monzón
INSERT INTO public.team_aliases (team_id, alias)
SELECT id, 'atltico monzn'
FROM public.teams
WHERE LOWER(name) LIKE '%monzon%';

-- Mérida AD
INSERT INTO public.team_aliases (team_id, alias)
SELECT id, 'mrida ad'
FROM public.teams
WHERE LOWER(name) LIKE '%merida%';

-- Dinamo Bakı
INSERT INTO public.team_aliases (team_id, alias)
SELECT id, 'dinamo bak'
FROM public.teams
WHERE LOWER(name) LIKE '%dinamo baku%';