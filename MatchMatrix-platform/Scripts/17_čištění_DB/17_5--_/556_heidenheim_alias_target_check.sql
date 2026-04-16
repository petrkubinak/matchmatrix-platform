-- 556_heidenheim_alias_target_check.sql
-- Cíl:
-- ověřit správný canonical target pro Heidenheim
-- a připravit bezpečný alias fix

SELECT
    t.id,
    t.name
FROM public.teams t
WHERE t.id IN (530, 533, 534)
ORDER BY t.id;

SELECT
    tpm.team_id,
    t.name AS team_name,
    tpm.provider,
    tpm.provider_team_id
FROM public.team_provider_map tpm
JOIN public.teams t
  ON t.id = tpm.team_id
WHERE tpm.team_id IN (530, 533, 534)
ORDER BY tpm.team_id, tpm.provider, tpm.provider_team_id;

SELECT
    ta.team_id,
    t.name AS team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE ta.team_id IN (530, 533, 534)
ORDER BY ta.team_id, ta.alias, ta.source;

-- rychlá kontrola, že 534 je opravdu Heidenheim větev používaná v matches
SELECT
    t.id,
    t.name,
    SUM(CASE WHEN m.home_team_id = t.id THEN 1 ELSE 0 END) AS home_matches,
    SUM(CASE WHEN m.away_team_id = t.id THEN 1 ELSE 0 END) AS away_matches
FROM public.teams t
LEFT JOIN public.matches m
  ON m.home_team_id = t.id
  OR m.away_team_id = t.id
WHERE t.id IN (530, 533, 534)
GROUP BY t.id, t.name
ORDER BY t.id;