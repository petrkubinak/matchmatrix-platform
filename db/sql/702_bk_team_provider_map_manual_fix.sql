-- ============================================
-- 702_bk_team_provider_map_manual_fix.sql
-- Manual safe fix pro chybne BK canonical mapy
-- Spustit v DBeaveru
-- ============================================

-- 1) vycistit jen problematicke BK provider ids
DELETE FROM public.team_provider_map
WHERE provider = 'api_sport'
  AND provider_team_id IN ('2331','1125','2333','1698','2339','2341');

-- 2) vytvorit vlastni BK canonical teamy (pokud jeste neexistuji)
INSERT INTO public.teams (name, ext_source, ext_team_id)
SELECT v.team_name, 'api_sport_basketball', v.provider_team_id
FROM (
    VALUES
      ('Baskonia','2331'),
      ('Granada','1125'),
      ('Gran Canaria','2333'),
      ('Manresa','1698'),
      ('Tenerife','2339'),
      ('Valencia','2341')
) AS v(team_name, provider_team_id)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE t.ext_source = 'api_sport_basketball'
      AND t.ext_team_id = v.provider_team_id
);

-- 3) vytvorit nove provider mapy na BK canonical teamy
INSERT INTO public.team_provider_map (team_id, provider, provider_team_id)
SELECT
    t.id,
    'api_sport',
    t.ext_team_id
FROM public.teams t
WHERE t.ext_source = 'api_sport_basketball'
  AND t.ext_team_id IN ('2331','1125','2333','1698','2339','2341')
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m
      WHERE m.provider = 'api_sport'
        AND m.provider_team_id = t.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m2
      WHERE m2.team_id = t.id
        AND m2.provider = 'api_sport'
  );

-- 4) aliasy
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT
    t.id,
    t.name,
    'api_sport_basketball'
FROM public.teams t
WHERE t.ext_source = 'api_sport_basketball'
  AND t.ext_team_id IN ('2331','1125','2333','1698','2339','2341')
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_aliases a
      WHERE a.team_id = t.id
        AND lower(btrim(a.alias)) = lower(btrim(t.name))
  );