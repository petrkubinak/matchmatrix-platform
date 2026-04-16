-- ============================================
-- 701_bk_team_provider_map_fix.sql
-- BK / API_SPORT -> vytvoreni vlastnich canonical BK tymu
-- a bezpecne napojeni do team_provider_map
-- Spustit v DBeaveru
-- ============================================

-- 1) BK zdroj: 1 radek na 1 provider tym
WITH bk_src AS (
    SELECT DISTINCT ON (s.external_team_id)
           s.external_team_id,
           s.team_name
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_sport'
      AND s.sport_code = 'basketball'
      AND s.external_team_id IS NOT NULL
      AND btrim(s.external_team_id) <> ''
      AND s.team_name IS NOT NULL
      AND btrim(s.team_name) <> ''
    ORDER BY s.external_team_id, s.updated_at DESC NULLS LAST, s.team_name
)

-- 2) vytvor vlastni BK canonical tymy v public.teams
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id
)
SELECT
    b.team_name,
    'api_sport_basketball',
    b.external_team_id
FROM bk_src b
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE t.ext_source = 'api_sport_basketball'
      AND t.ext_team_id = b.external_team_id
);

-- 3) smaz stavajici chybne api_sport mapy pro BK provider_team_id
DELETE FROM public.team_provider_map m
WHERE m.provider = 'api_sport'
  AND m.provider_team_id IN (
      SELECT DISTINCT s.external_team_id
      FROM staging.stg_provider_teams s
      WHERE s.provider = 'api_sport'
        AND s.sport_code = 'basketball'
        AND s.external_team_id IS NOT NULL
  );

-- 4) vloz spravne BK mapy na nove BK canonical tymy
WITH bk_src AS (
    SELECT DISTINCT ON (s.external_team_id)
           s.external_team_id,
           s.team_name
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_sport'
      AND s.sport_code = 'basketball'
      AND s.external_team_id IS NOT NULL
      AND btrim(s.external_team_id) <> ''
      AND s.team_name IS NOT NULL
      AND btrim(s.team_name) <> ''
    ORDER BY s.external_team_id, s.updated_at DESC NULLS LAST, s.team_name
),
bk_teams AS (
    SELECT
        t.id AS team_id,
        t.ext_team_id AS external_team_id
    FROM public.teams t
    WHERE t.ext_source = 'api_sport_basketball'
)
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT
    t.team_id,
    'api_sport',
    t.external_team_id
FROM bk_teams t
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map m
    WHERE m.provider = 'api_sport'
      AND m.provider_team_id = t.external_team_id
)
AND NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map m2
    WHERE m2.team_id = t.team_id
      AND m2.provider = 'api_sport'
);

-- 5) aliasy pro nove BK canonical tymy
WITH bk_src AS (
    SELECT DISTINCT ON (s.external_team_id)
           s.external_team_id,
           s.team_name
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_sport'
      AND s.sport_code = 'basketball'
      AND s.external_team_id IS NOT NULL
      AND btrim(s.external_team_id) <> ''
      AND s.team_name IS NOT NULL
      AND btrim(s.team_name) <> ''
    ORDER BY s.external_team_id, s.updated_at DESC NULLS LAST, s.team_name
)
INSERT INTO public.team_aliases (
    team_id,
    alias,
    source
)
SELECT
    t.id,
    b.team_name,
    'api_sport_basketball'
FROM bk_src b
JOIN public.teams t
  ON t.ext_source = 'api_sport_basketball'
 AND t.ext_team_id = b.external_team_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = t.id
      AND lower(btrim(a.alias)) = lower(btrim(b.team_name))
);