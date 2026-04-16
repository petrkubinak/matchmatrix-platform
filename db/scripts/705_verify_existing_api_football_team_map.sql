-- 708_verify_existing_api_football_team_map.sql

-- 1) Kolik api_football map už v tabulce je
SELECT
    provider,
    COUNT(*) AS row_count
FROM public.team_provider_map
WHERE provider = 'api_football'
GROUP BY provider;

-- 2) Zobraz konkrétní existující mapy pro týmy, které naráží do insertu
SELECT
    m.team_id,
    t.name AS canonical_team_name,
    m.provider,
    m.provider_team_id,
    m.created_at,
    m.updated_at
FROM public.team_provider_map m
JOIN public.teams t
  ON t.id = m.team_id
WHERE m.provider = 'api_football'
  AND m.team_id = 118199
ORDER BY m.team_id, m.provider_team_id;

-- 3) Najdi konflikty: staging chce vložit nový provider_team_id,
-- ale team_id+provider už existuje
WITH candidate_map AS (
    SELECT
        t.id AS team_id,
        t.name AS canonical_team_name,
        s.provider,
        s.external_team_id AS new_provider_team_id,
        s.team_name AS staging_team_name
    FROM staging.stg_provider_teams s
    JOIN public.teams t
      ON LOWER(TRIM(t.name)) = LOWER(TRIM(s.team_name))
    WHERE s.provider = 'api_football'
),
existing_map AS (
    SELECT
        m.team_id,
        m.provider,
        m.provider_team_id AS existing_provider_team_id
    FROM public.team_provider_map m
    WHERE m.provider = 'api_football'
)
SELECT
    c.team_id,
    c.canonical_team_name,
    c.provider,
    e.existing_provider_team_id,
    c.new_provider_team_id,
    c.staging_team_name
FROM candidate_map c
JOIN existing_map e
  ON e.team_id = c.team_id
 AND e.provider = c.provider
WHERE e.existing_provider_team_id <> c.new_provider_team_id
ORDER BY c.canonical_team_name, c.new_provider_team_id;

-- 4) Najdi staging týmy, které už mapu mají přes stejné provider_team_id
WITH already_ok AS (
    SELECT
        s.provider,
        s.external_team_id,
        s.team_name,
        m.team_id,
        t.name AS canonical_team_name
    FROM staging.stg_provider_teams s
    JOIN public.team_provider_map m
      ON m.provider = s.provider
     AND m.provider_team_id = s.external_team_id
    JOIN public.teams t
      ON t.id = m.team_id
    WHERE s.provider = 'api_football'
)
SELECT *
FROM already_ok
ORDER BY canonical_team_name, external_team_id
LIMIT 200;