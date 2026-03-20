ALTER TABLE public.teams
ADD COLUMN IF NOT EXISTS logo_url text;

WITH src AS (
    SELECT DISTINCT ON (team_id)
        team_id::text AS provider_team_id,
        logo
    FROM staging.api_football_teams
    WHERE logo IS NOT NULL
      AND btrim(logo) <> ''
    ORDER BY team_id, fetched_at DESC
)
UPDATE public.teams t
SET logo_url = src.logo
FROM src
WHERE t.ext_source = 'api_football'
  AND t.ext_team_id = src.provider_team_id
  AND (t.logo_url IS DISTINCT FROM src.logo);