-- Souhrn, kde to padá
WITH raw_events AS (
    SELECT
        arp.id AS raw_id,
        ev AS event_json
    FROM public.api_raw_payloads arp
    CROSS JOIN LATERAL jsonb_array_elements(arp.payload->'payload') ev
    WHERE lower(coalesce(arp.source, '')) = 'theodds'
      AND jsonb_typeof(arp.payload->'payload') = 'array'
),
mapped AS (
    SELECT
        r.raw_id,
        r.event_json->>'sport_key' AS sport_key,
        r.event_json->>'home_team' AS home_team_name,
        r.event_json->>'away_team' AS away_team_name,
        ta_home.team_id AS home_team_id,
        ta_away.team_id AS away_team_id,
        m.id AS matched_match_id
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
    CASE
        WHEN home_team_id IS NULL AND away_team_id IS NULL THEN 'MISSING_BOTH_ALIASES'
        WHEN home_team_id IS NULL THEN 'MISSING_HOME_ALIAS'
        WHEN away_team_id IS NULL THEN 'MISSING_AWAY_ALIAS'
        WHEN matched_match_id IS NULL THEN 'ALIAS_OK_MATCH_MISSING'
        ELSE 'MATCHED_OK'
    END AS status,
    COUNT(*) AS rows_count
FROM mapped
GROUP BY 1
ORDER BY rows_count DESC;