/*
MATCHMATRIX BK FIXTURES MERGE FIX V1

Co to je:
- Merge BK fixtures ze staging.stg_provider_fixtures do public.matches.

K čemu to je:
- Aktualizuje / doplní basketbalové zápasy z API-Sport Basketball.

Kde se výsledek projeví:
- public.matches

Jak se využije na webu:
- BK zápasy budou mít správný status, skóre a půjdou použít pro výsledky,
  tabulky, statistiky, team power a AI výpočty.
*/

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
    lpm.league_id AS league_id,
    mph.team_id AS home_team_id,
    mpa.team_id AS away_team_id,
    f.fixture_date::timestamp AS kickoff,

    CASE
        WHEN f.status_text IN ('FT', 'AOT') THEN 'FINISHED'
        WHEN f.status_text IN ('NS', 'TBD') THEN 'SCHEDULED'
        WHEN f.status_text IN ('1Q', '2Q', '3Q', '4Q', 'HT', 'LIVE') THEN 'LIVE'
        WHEN f.status_text IN ('POSTP', 'PST', 'POST') THEN 'POSTPONED'
        WHEN f.status_text IN ('CANC', 'CAN') THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END AS status,

    CASE
        WHEN f.status_text IN ('FT', 'AOT')
        THEN NULLIF(f.home_score, '')::int
        ELSE NULL
    END AS home_score,

    CASE
        WHEN f.status_text IN ('FT', 'AOT')
        THEN NULLIF(f.away_score, '')::int
        ELSE NULL
    END AS away_score,

    f.provider AS ext_source,
    f.external_fixture_id AS ext_match_id,
    3 AS sport_id
FROM staging.stg_provider_fixtures f
JOIN public.league_provider_map lpm
    ON lpm.provider = f.provider
   AND lpm.provider_league_id = f.external_league_id
JOIN public.team_provider_map mph
    ON mph.provider = f.provider
   AND mph.provider_team_id = f.home_team_external_id
JOIN public.team_provider_map mpa
    ON mpa.provider = f.provider
   AND mpa.provider_team_id = f.away_team_external_id
WHERE f.provider = 'api_sport'
  AND f.sport_code = 'BK'
ON CONFLICT (ext_source, ext_match_id) DO UPDATE
SET
    league_id = EXCLUDED.league_id,
    home_team_id = EXCLUDED.home_team_id,
    away_team_id = EXCLUDED.away_team_id,
    kickoff = EXCLUDED.kickoff,
    status = EXCLUDED.status,
    home_score = EXCLUDED.home_score,
    away_score = EXCLUDED.away_score,
    sport_id = EXCLUDED.sport_id;

SELECT
    status,
    COUNT(*) AS matches_count
FROM public.matches
WHERE sport_id = 3
GROUP BY status
ORDER BY matches_count DESC;