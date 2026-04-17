INSERT INTO public.matches (
    league_id,
    home_team_id,
    away_team_id,
    kickoff,
    status,
    home_score,
    away_score,
    ext_source,
    ext_match_id,
    sport_id
)
SELECT
    NULL AS league_id,
    mph.team_id AS home_team_id,
    mpa.team_id AS away_team_id,
    f.fixture_date::timestamp AS kickoff,
    CASE
        WHEN f.status_text IN ('FT', 'AOT') THEN 'FINISHED'
        WHEN f.status_text IN ('NS', 'TBD') THEN 'SCHEDULED'
        WHEN f.status_text IN ('1Q', '2Q', '3Q', '4Q', 'HT', 'LIVE') THEN 'LIVE'
        WHEN f.status_text IN ('POSTP', 'PST') THEN 'POSTPONED'
        WHEN f.status_text IN ('CANC', 'CAN') THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END AS status,

    CASE
        WHEN f.status_text IN ('FT', 'AOT')
        THEN NULLIF(
               (
                 replace(
                   replace(f.home_score, '''', '"'),
                   'None',
                   'null'
                 )::jsonb ->> 'total'
               ),
               ''
             )::int
        ELSE NULL
    END AS home_score,

    CASE
        WHEN f.status_text IN ('FT', 'AOT')
        THEN NULLIF(
               (
                 replace(
                   replace(f.away_score, '''', '"'),
                   'None',
                   'null'
                 )::jsonb ->> 'total'
               ),
               ''
             )::int
        ELSE NULL
    END AS away_score,

    f.provider AS ext_source,
    f.external_fixture_id AS ext_match_id,
    2 AS sport_id
FROM staging.stg_provider_fixtures f
JOIN public.team_provider_map mph
    ON mph.provider = f.provider
   AND mph.provider_team_id = f.home_team_external_id
JOIN public.team_provider_map mpa
    ON mpa.provider = f.provider
   AND mpa.provider_team_id = f.away_team_external_id
WHERE f.provider = 'api_sport'
  AND f.sport_code = 'basketball'
  AND NOT EXISTS (
      SELECT 1
      FROM public.matches m
      WHERE m.ext_source = f.provider
        AND m.ext_match_id = f.external_fixture_id
  );