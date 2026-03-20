WITH src AS (
    SELECT
        team_id::text AS ext_team_id,
        max(logo) AS logo_url
    FROM staging.api_football_teams
    WHERE logo IS NOT NULL
      AND btrim(logo) <> ''
    GROUP BY team_id::text
)
UPDATE public.teams t
SET logo_url = src.logo_url
FROM src
WHERE t.ext_source = 'api_football'
  AND t.ext_team_id = src.ext_team_id
  AND COALESCE(t.logo_url, '') <> src.logo_url;