-- 812_hk_team_alias_dataset.sql
-- NHL/HK canonical team alias dataset

SELECT
    t.id,
    t.name,
    t.ext_source,
    t.ext_team_id
FROM public.teams t
WHERE
    (
        lower(t.name) LIKE '%hurricanes%'
        OR lower(t.name) LIKE '%canadiens%'
        OR lower(t.name) LIKE '%sabres%'
        OR lower(t.name) LIKE '%ducks%'
        OR lower(t.name) LIKE '%golden knights%'
        OR lower(t.name) LIKE '%lightning%'
        OR lower(t.name) LIKE '%panthers%'
        OR lower(t.name) LIKE '%flyers%'
        OR lower(t.name) LIKE '%wild%'
        OR lower(t.name) LIKE '%avalanche%'
    )
ORDER BY t.name;