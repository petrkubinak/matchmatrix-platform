-- 487_extract_missing_teams_from_theodds.sql
-- Cíl:
-- vytáhnout týmy, které se nepodařilo vůbec namapovat

WITH latest_theodds AS (
    SELECT
        arp.payload
    FROM public.api_raw_payloads arp
    WHERE arp.source = 'theodds'
      AND arp.run_id = 163
),
events AS (
    SELECT
        (e.value ->> 'home_team') AS home_team_name,
        (e.value ->> 'away_team') AS away_team_name
    FROM latest_theodds lt
    CROSS JOIN LATERAL jsonb_array_elements(
        CASE
            WHEN jsonb_typeof(lt.payload -> 'payload') = 'array' THEN lt.payload -> 'payload'
            ELSE '[]'::jsonb
        END
    ) e(value)
),
all_teams AS (
    SELECT home_team_name AS team_name FROM events
    UNION
    SELECT away_team_name FROM events
),
resolved AS (
    SELECT
        at.team_name,
        p.canonical_team_id
    FROM all_teams at
    LEFT JOIN public.v_preferred_team_name_lookup p
      ON lower(trim(at.team_name)) = p.team_name_key
)
SELECT
    team_name
FROM resolved
WHERE canonical_team_id IS NULL
ORDER BY team_name;