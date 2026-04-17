-- ============================================
-- 700_bk_team_provider_map.sql
-- BK / API_SPORT -> public.teams + public.team_provider_map + public.team_aliases
-- Spustit v DBeaveru
-- ============================================

-- 0) deduplikovany staging vstup:
-- 1 radek na (provider, external_team_id)
WITH bk_src AS (
    SELECT DISTINCT ON (s.provider, s.external_team_id)
           s.provider,
           s.external_team_id,
           s.team_name,
           s.external_league_id,
           s.season,
           s.updated_at
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_sport'
      AND s.external_team_id IS NOT NULL
      AND btrim(s.external_team_id) <> ''
      AND s.team_name IS NOT NULL
      AND btrim(s.team_name) <> ''
    ORDER BY
      s.provider,
      s.external_team_id,
      s.updated_at DESC NULLS LAST,
      s.external_league_id NULLS LAST,
      s.season NULLS LAST
),

-- 1) kandidati canonical teamu podle jmena
bk_named AS (
    SELECT
        b.provider,
        b.external_team_id,
        b.team_name
    FROM bk_src b
)

-- 2) vloz nove tymy do public.teams, pokud jeste neexistuji podle jmena
INSERT INTO public.teams (name)
SELECT DISTINCT b.team_name
FROM bk_named b
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE lower(btrim(t.name)) = lower(btrim(b.team_name))
);

-- 3) vytvor provider mapu
WITH bk_src AS (
    SELECT DISTINCT ON (s.provider, s.external_team_id)
           s.provider,
           s.external_team_id,
           s.team_name,
           s.external_league_id,
           s.season,
           s.updated_at
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_sport'
      AND s.external_team_id IS NOT NULL
      AND btrim(s.external_team_id) <> ''
      AND s.team_name IS NOT NULL
      AND btrim(s.team_name) <> ''
    ORDER BY
      s.provider,
      s.external_team_id,
      s.updated_at DESC NULLS LAST,
      s.external_league_id NULLS LAST,
      s.season NULLS LAST
)
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT
    t.id AS team_id,
    b.provider,
    b.external_team_id AS provider_team_id
FROM bk_src b
JOIN public.teams t
  ON lower(btrim(t.name)) = lower(btrim(b.team_name))
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map m
    WHERE m.provider = b.provider
      AND m.provider_team_id = b.external_team_id
)
AND NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map m2
    WHERE m2.team_id = t.id
      AND m2.provider = b.provider
);

-- 4) vloz aliasy
WITH bk_src AS (
    SELECT DISTINCT ON (s.provider, s.external_team_id)
           s.provider,
           s.external_team_id,
           s.team_name,
           s.external_league_id,
           s.season,
           s.updated_at
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_sport'
      AND s.external_team_id IS NOT NULL
      AND btrim(s.external_team_id) <> ''
      AND s.team_name IS NOT NULL
      AND btrim(s.team_name) <> ''
    ORDER BY
      s.provider,
      s.external_team_id,
      s.updated_at DESC NULLS LAST,
      s.external_league_id NULLS LAST,
      s.season NULLS LAST
)
INSERT INTO public.team_aliases (
    team_id,
    alias,
    source
)
SELECT
    t.id,
    b.team_name,
    b.provider
FROM bk_src b
JOIN public.teams t
  ON lower(btrim(t.name)) = lower(btrim(b.team_name))
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = t.id
      AND lower(btrim(a.alias)) = lower(btrim(b.team_name))
);