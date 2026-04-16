-- 616_hk_teams_public_merge_check_v2.sql

-- 1) mapped teams do public
SELECT
    'mapped_hockey_teams_to_public' AS check_name,
    COUNT(*) AS cnt
FROM public.team_provider_map tpm
JOIN public.teams t
  ON t.id = tpm.team_id
WHERE LOWER(tpm.provider) LIKE '%hockey%';


-- 2) distinct external ids
SELECT
    'distinct_hockey_external_ids_mapped' AS check_name,
    COUNT(DISTINCT tpm.provider_team_id) AS cnt
FROM public.team_provider_map tpm
WHERE LOWER(tpm.provider) LIKE '%hockey%';


-- 3) staging bez mapování (FIX CAST)
SELECT
    'hk_staging_without_provider_map' AS check_name,
    COUNT(*) AS cnt
FROM staging.api_hockey_teams s
LEFT JOIN public.team_provider_map tpm
  ON LOWER(tpm.provider) LIKE '%hockey%'
 AND tpm.provider_team_id = CAST(s.team_id AS TEXT)
WHERE tpm.team_id IS NULL;


-- 4) sample mapping (FIX CAST)
SELECT
    s.league_id,
    s.season,
    s.team_id AS provider_team_id,
    s.name AS provider_team_name,
    tpm.team_id AS public_team_id,
    t.name AS public_team_name
FROM staging.api_hockey_teams s
JOIN public.team_provider_map tpm
  ON LOWER(tpm.provider) LIKE '%hockey%'
 AND tpm.provider_team_id = CAST(s.team_id AS TEXT)
JOIN public.teams t
  ON t.id = tpm.team_id
ORDER BY s.fetched_at DESC, s.team_id
LIMIT 20;