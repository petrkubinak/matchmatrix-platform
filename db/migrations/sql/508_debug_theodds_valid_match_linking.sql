-- 508_debug_theodds_valid_match_linking.sql
-- Cíl:
-- debug validních TheOdds payloadů z api_raw_payloads
-- home_team / away_team jsou uvnitř payload->'payload' jako pole zápasů

WITH raw_events AS (
    SELECT
        arp.id AS raw_id,
        arp.run_id,
        arp.endpoint,
        arp.fetched_at,
        ev AS event_json
    FROM public.api_raw_payloads arp
    CROSS JOIN LATERAL jsonb_array_elements(arp.payload->'payload') ev
    WHERE lower(coalesce(arp.source, '')) = 'theodds'
      AND jsonb_typeof(arp.payload->'payload') = 'array'
),
mapped AS (
    SELECT
        r.raw_id,
        r.run_id,
        r.endpoint,
        r.fetched_at,

        r.event_json->>'id' AS theodds_event_id,
        r.event_json->>'sport_key' AS sport_key,
        r.event_json->>'home_team' AS home_team_name,
        r.event_json->>'away_team' AS away_team_name,
        (r.event_json->>'commence_time')::timestamp AS commence_time,

        ta_home.team_id AS home_team_id,
        ta_away.team_id AS away_team_id,

        m.id AS matched_match_id,
        m.kickoff AS matched_kickoff,
        m.ext_source,
        m.ext_match_id
    FROM raw_events r
    LEFT JOIN public.team_aliases ta_home
        ON lower(trim(public.unaccent(ta_home.alias))) =
           lower(trim(public.unaccent(r.event_json->>'home_team')))
    LEFT JOIN public.team_aliases ta_away
        ON lower(trim(public.unaccent(ta_away.alias))) =
           lower(trim(public.unaccent(r.event_json->>'away_team')))
    LEFT JOIN public.matches m
        ON m.home_team_id = ta_home.team_id
       AND m.away_team_id = ta_away.team_id
       AND abs(extract(epoch from (m.kickoff - (r.event_json->>'commence_time')::timestamp))) < 86400
)
SELECT
    raw_id,
    run_id,
    endpoint,
    sport_key,
    home_team_name,
    away_team_name,
    commence_time,
    home_team_id,
    away_team_id,
    matched_match_id,
    matched_kickoff,
    ext_source,
    ext_match_id
FROM mapped
ORDER BY raw_id DESC, commence_time
LIMIT 200;