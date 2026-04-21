-- 719_insert_public_matches_hb_145_183.sql
-- Cíl:
-- Smoke/public merge HB fixtures do public.matches
-- pro:
-- league 145 -> canonical league 24882
-- league 183 -> canonical league 24883
-- season 2024

WITH hb_sport AS (
    SELECT id AS sport_id
    FROM public.sports
    WHERE code = 'HB'
    LIMIT 1
),
src AS (
    SELECT
        f.external_fixture_id,
        f.external_league_id,
        f.season,
        f.home_team_external_id,
        f.away_team_external_id,
        f.fixture_date,
        f.status_text,
        f.home_score,
        f.away_score
    FROM staging.stg_provider_fixtures f
    WHERE f.provider = 'api_handball'
      AND f.sport_code = 'handball'
      AND f.external_league_id IN ('145', '183')
      AND f.season = '2024'
),
mapped AS (
    SELECT
        CASE
            WHEN s.external_league_id = '145' THEN 24882
            WHEN s.external_league_id = '183' THEN 24883
        END AS league_id,
        hs.sport_id,
        h.team_id AS home_team_id,
        a.team_id AS away_team_id,
        s.external_fixture_id,
        s.fixture_date,
        CASE
            WHEN UPPER(COALESCE(s.status_text, '')) IN ('FT', 'AET', 'PEN', 'AP') THEN 'FINISHED'
            WHEN UPPER(COALESCE(s.status_text, '')) IN ('NS', 'TBD', 'SCHEDULED') THEN 'SCHEDULED'
            WHEN UPPER(COALESCE(s.status_text, '')) IN ('1H', '2H', 'HT', 'LIVE', 'ET', 'BT') THEN 'LIVE'
            WHEN UPPER(COALESCE(s.status_text, '')) IN ('PST', 'POSTPONED') THEN 'POSTPONED'
            WHEN UPPER(COALESCE(s.status_text, '')) IN ('CANC', 'CANCELLED', 'ABD', 'AWD', 'WO') THEN 'CANCELLED'
            ELSE 'SCHEDULED'
        END AS mapped_status,
        CASE
            WHEN UPPER(COALESCE(s.status_text, '')) IN ('FT', 'AET', 'PEN', 'AP')
                 AND NULLIF(TRIM(s.home_score), '') IS NOT NULL
            THEN s.home_score::int
            ELSE NULL
        END AS mapped_home_score,
        CASE
            WHEN UPPER(COALESCE(s.status_text, '')) IN ('FT', 'AET', 'PEN', 'AP')
                 AND NULLIF(TRIM(s.away_score), '') IS NOT NULL
            THEN s.away_score::int
            ELSE NULL
        END AS mapped_away_score,
        s.season
    FROM src s
    CROSS JOIN hb_sport hs
    JOIN public.team_provider_map h
      ON h.provider = 'api_handball'
     AND h.provider_team_id = s.home_team_external_id
    JOIN public.team_provider_map a
      ON a.provider = 'api_handball'
     AND a.provider_team_id = s.away_team_external_id
    WHERE h.team_id <> a.team_id
)
INSERT INTO public.matches (
    league_id,
    home_team_id,
    away_team_id,
    kickoff,
    ext_source,
    ext_match_id,
    status,
    home_score,
    away_score,
    season,
    sport_id,
    updated_at
)
SELECT
    m.league_id,
    m.home_team_id,
    m.away_team_id,
    m.fixture_date::timestamp without time zone AS kickoff,
    'api_handball' AS ext_source,
    m.external_fixture_id AS ext_match_id,
    m.mapped_status AS status,
    m.mapped_home_score AS home_score,
    m.mapped_away_score AS away_score,
    m.season,
    m.sport_id,
    NOW()
FROM mapped m
WHERE NOT EXISTS (
    SELECT 1
    FROM public.matches x
    WHERE x.ext_source = 'api_handball'
      AND x.ext_match_id = m.external_fixture_id
);

-- kontrola 1
SELECT
    league_id,
    season,
    COUNT(*) AS matches_total
FROM public.matches
WHERE ext_source = 'api_handball'
  AND league_id IN (24882, 24883)
GROUP BY league_id, season
ORDER BY league_id, season;

-- kontrola 2
SELECT
    m.id,
    m.league_id,
    l.name AS league_name,
    th.name AS home_team,
    ta.name AS away_team,
    m.kickoff,
    m.ext_match_id,
    m.status,
    m.home_score,
    m.away_score,
    m.season
FROM public.matches m
JOIN public.leagues l
  ON l.id = m.league_id
JOIN public.teams th
  ON th.id = m.home_team_id
JOIN public.teams ta
  ON ta.id = m.away_team_id
WHERE m.ext_source = 'api_handball'
  AND m.league_id IN (24882, 24883)
ORDER BY m.league_id, m.kickoff DESC
LIMIT 100;