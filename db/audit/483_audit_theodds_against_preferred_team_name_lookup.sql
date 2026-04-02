-- 483_audit_theodds_against_preferred_team_name_lookup.sql
-- Cíl:
-- znovu otestovat TheOdds eventy,
-- ale tentokrát přes preferred team name lookup + canonical match lookup

WITH latest_theodds AS (
    SELECT
        arp.run_id,
        arp.payload
    FROM public.api_raw_payloads arp
    WHERE arp.source = 'theodds'
      AND arp.run_id = 163
),
events AS (
    SELECT
        lt.run_id,
        (e.value ->> 'home_team') AS home_team_name,
        (e.value ->> 'away_team') AS away_team_name,
        (e.value ->> 'commence_time')::timestamptz AS commence_time,
        lt.payload ->> 'sport_key' AS sport_key
    FROM latest_theodds lt
    CROSS JOIN LATERAL jsonb_array_elements(
        CASE
            WHEN jsonb_typeof(lt.payload -> 'payload') = 'array' THEN lt.payload -> 'payload'
            ELSE '[]'::jsonb
        END
    ) e(value)
),
resolved_events AS (
    SELECT
        ev.run_id,
        ev.sport_key,
        ev.home_team_name,
        ev.away_team_name,
        ev.commence_time,

        ph.canonical_team_id AS canonical_home_team_id,
        ph.canonical_team_name AS canonical_home_team_name,
        ph.source_type AS home_source_type,

        pa.canonical_team_id AS canonical_away_team_id,
        pa.canonical_team_name AS canonical_away_team_name,
        pa.source_type AS away_source_type
    FROM events ev
    LEFT JOIN public.v_preferred_team_name_lookup ph
      ON lower(trim(ev.home_team_name)) = ph.team_name_key
    LEFT JOIN public.v_preferred_team_name_lookup pa
      ON lower(trim(ev.away_team_name)) = pa.team_name_key
),
matched AS (
    SELECT
        re.*,
        v.match_id,
        v.league_name,
        v.kickoff,
        ABS(EXTRACT(EPOCH FROM (v.kickoff - re.commence_time))) AS diff_seconds,
        ROW_NUMBER() OVER (
            PARTITION BY re.home_team_name, re.away_team_name, re.commence_time
            ORDER BY ABS(EXTRACT(EPOCH FROM (v.kickoff - re.commence_time))) ASC
        ) AS rn
    FROM resolved_events re
    LEFT JOIN public.v_canonical_match_lookup v
      ON v.canonical_home_team_id = re.canonical_home_team_id
     AND v.canonical_away_team_id = re.canonical_away_team_id
     AND v.kickoff BETWEEN re.commence_time - interval '72 hours'
                      AND re.commence_time + interval '72 hours'
)
SELECT
    sport_key,
    COUNT(*) AS events_total,
    COUNT(*) FILTER (WHERE canonical_home_team_id IS NULL OR canonical_away_team_id IS NULL) AS unresolved_teams,
    COUNT(*) FILTER (WHERE match_id IS NOT NULL AND rn = 1) AS matched_events,
    COUNT(*) FILTER (WHERE match_id IS NULL) AS unmatched_events
FROM matched
WHERE rn = 1 OR rn IS NULL
GROUP BY sport_key
ORDER BY sport_key;


-- detail nespárovaných řádků
WITH latest_theodds AS (
    SELECT
        arp.run_id,
        arp.payload
    FROM public.api_raw_payloads arp
    WHERE arp.source = 'theodds'
      AND arp.run_id = 163
),
events AS (
    SELECT
        lt.run_id,
        (e.value ->> 'home_team') AS home_team_name,
        (e.value ->> 'away_team') AS away_team_name,
        (e.value ->> 'commence_time')::timestamptz AS commence_time,
        lt.payload ->> 'sport_key' AS sport_key
    FROM latest_theodds lt
    CROSS JOIN LATERAL jsonb_array_elements(
        CASE
            WHEN jsonb_typeof(lt.payload -> 'payload') = 'array' THEN lt.payload -> 'payload'
            ELSE '[]'::jsonb
        END
    ) e(value)
),
resolved_events AS (
    SELECT
        ev.run_id,
        ev.sport_key,
        ev.home_team_name,
        ev.away_team_name,
        ev.commence_time,

        ph.canonical_team_id AS canonical_home_team_id,
        ph.canonical_team_name AS canonical_home_team_name,
        ph.source_type AS home_source_type,

        pa.canonical_team_id AS canonical_away_team_id,
        pa.canonical_team_name AS canonical_away_team_name,
        pa.source_type AS away_source_type
    FROM events ev
    LEFT JOIN public.v_preferred_team_name_lookup ph
      ON lower(trim(ev.home_team_name)) = ph.team_name_key
    LEFT JOIN public.v_preferred_team_name_lookup pa
      ON lower(trim(ev.away_team_name)) = pa.team_name_key
),
matched AS (
    SELECT
        re.*,
        v.match_id,
        v.league_name,
        v.kickoff,
        ABS(EXTRACT(EPOCH FROM (v.kickoff - re.commence_time))) AS diff_seconds,
        ROW_NUMBER() OVER (
            PARTITION BY re.home_team_name, re.away_team_name, re.commence_time
            ORDER BY ABS(EXTRACT(EPOCH FROM (v.kickoff - re.commence_time))) ASC
        ) AS rn
    FROM resolved_events re
    LEFT JOIN public.v_canonical_match_lookup v
      ON v.canonical_home_team_id = re.canonical_home_team_id
     AND v.canonical_away_team_id = re.canonical_away_team_id
     AND v.kickoff BETWEEN re.commence_time - interval '72 hours'
                      AND re.commence_time + interval '72 hours'
)
SELECT
    sport_key,
    home_team_name,
    canonical_home_team_name,
    home_source_type,
    away_team_name,
    canonical_away_team_name,
    away_source_type,
    commence_time,
    match_id,
    league_name,
    kickoff
FROM matched
WHERE (rn = 1 OR rn IS NULL)
  AND match_id IS NULL
ORDER BY sport_key, commence_time, home_team_name, away_team_name
LIMIT 100;