-- 503_debug_theodds_from_raw.sql
-- Cíl:
-- vytáhnout TheOdds zápasy z raw JSON a zkusit je napojit na DB

SELECT
    p.id,
    p.payload->>'sport_key' AS sport_key,

    -- týmy z TheOdds
    p.payload->>'home_team' AS home_team_name,
    p.payload->>'away_team' AS away_team_name,

    (p.payload->>'commence_time')::timestamp AS commence_time,

    -- alias mapping
    ta_home.team_id AS home_team_id,
    ta_away.team_id AS away_team_id,

    -- match lookup
    m.id AS matched_match_id

FROM public.api_raw_payloads p

LEFT JOIN public.team_aliases ta_home
    ON lower(ta_home.alias) = lower(p.payload->>'home_team')

LEFT JOIN public.team_aliases ta_away
    ON lower(ta_away.alias) = lower(p.payload->>'away_team')

LEFT JOIN public.matches m
    ON m.home_team_id = ta_home.team_id
   AND m.away_team_id = ta_away.team_id
   AND abs(extract(epoch from (
        m.match_date - (p.payload->>'commence_time')::timestamp
   ))) < 86400

WHERE p.payload ? 'home_team'
LIMIT 100;