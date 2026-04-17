-- 505_debug_theodds_match_linking.sql
-- Cíl:
-- zjistit proč TheOdds nepropojuje zápasy (FINÁLNÍ VERZE)

SELECT
    p.id,

    -- raw data
    p.payload->>'sport_key' AS sport_key,
    p.payload->>'home_team' AS home_team_name,
    p.payload->>'away_team' AS away_team_name,
    (p.payload->>'commence_time')::timestamp AS commence_time,

    -- alias mapping
    ta_home.team_id AS home_team_id,
    ta_away.team_id AS away_team_id,

    -- match lookup
    m.id AS matched_match_id,
    m.kickoff AS match_kickoff

FROM public.api_raw_payloads p

LEFT JOIN public.team_aliases ta_home
    ON lower(ta_home.alias) = lower(p.payload->>'home_team')

LEFT JOIN public.team_aliases ta_away
    ON lower(ta_away.alias) = lower(p.payload->>'away_team')

LEFT JOIN public.matches m
    ON m.home_team_id = ta_home.team_id
   AND m.away_team_id = ta_away.team_id
   AND abs(extract(epoch from (
        m.kickoff - (p.payload->>'commence_time')::timestamp
   ))) < 86400   -- 1 den tolerance

WHERE p.payload ? 'home_team'
LIMIT 100;