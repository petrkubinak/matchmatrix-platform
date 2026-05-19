-- check_media_team_provider_map_v1.sql
-- Cíl:
-- Ověřit, jak jsou media týmy napojené na provider mapu
-- a jestli existují jiné team_id se stejným provider/ext_team_id.

WITH media_teams AS (
    SELECT DISTINCT
        t.id,
        t.name,
        t.ext_source,
        t.ext_team_id
    FROM public.article_team_map atm
    JOIN public.teams t ON t.id = atm.team_id
)
SELECT
    mt.id AS media_team_id,
    mt.name AS media_team_name,
    mt.ext_source,
    mt.ext_team_id,
    tpm.provider,
    tpm.provider_team_id,
    tpm.team_id AS mapped_team_id,
    t2.name AS mapped_team_name,
    COUNT(m.id) AS mapped_team_matches
FROM media_teams mt
LEFT JOIN public.team_provider_map tpm
  ON tpm.team_id = mt.id
LEFT JOIN public.teams t2
  ON t2.id = tpm.team_id
LEFT JOIN public.matches m
  ON m.home_team_id = tpm.team_id
  OR m.away_team_id = tpm.team_id
GROUP BY
    mt.id,
    mt.name,
    mt.ext_source,
    mt.ext_team_id,
    tpm.provider,
    tpm.provider_team_id,
    tpm.team_id,
    t2.name
ORDER BY
    mapped_team_matches ASC,
    mt.name;