-- 813_hk_core_team_coverage_check.sql
-- HK / NHL core coverage reality check

SELECT
    ext_source,
    COUNT(*) AS teams_count
FROM public.teams
WHERE
    lower(name) LIKE '%canadiens%'
    OR lower(name) LIKE '%sabres%'
    OR lower(name) LIKE '%golden knights%'
    OR lower(name) LIKE '%ducks%'
    OR lower(name) LIKE '%lightning%'
    OR lower(name) LIKE '%avalanche%'
    OR lower(name) LIKE '%wild%'
    OR lower(name) LIKE '%panthers%'
GROUP BY ext_source
ORDER BY teams_count DESC;

-- detail
SELECT
    id,
    name,
    ext_source,
    ext_team_id
FROM public.teams
WHERE
    lower(name) LIKE '%canadiens%'
    OR lower(name) LIKE '%sabres%'
    OR lower(name) LIKE '%golden knights%'
    OR lower(name) LIKE '%ducks%'
    OR lower(name) LIKE '%lightning%'
    OR lower(name) LIKE '%avalanche%'
    OR lower(name) LIKE '%wild%'
    OR lower(name) LIKE '%panthers%'
ORDER BY name;