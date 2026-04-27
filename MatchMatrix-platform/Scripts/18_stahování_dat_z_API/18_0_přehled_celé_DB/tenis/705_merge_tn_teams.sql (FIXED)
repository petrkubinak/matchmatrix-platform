-- =====================================================
-- 705_merge_tn_teams.sql (FIXED)
-- TN teams (players) → public.teams + team_provider_map
-- bezpečné proti duplicitám
-- =====================================================

-- 1) INSERT do public.teams
INSERT INTO public.teams (name)
SELECT DISTINCT
    s.team_name
FROM staging.stg_provider_teams s
WHERE s.provider = 'api_tennis'
  AND s.sport_code = 'TN'
  AND NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE lower(trim(t.name)) = lower(trim(s.team_name))
);

-- 2) INSERT do team_provider_map bezpečně
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT DISTINCT
    t.id,
    s.provider,
    s.external_team_id
FROM staging.stg_provider_teams s
JOIN public.teams t
    ON lower(trim(t.name)) = lower(trim(s.team_name))
WHERE s.provider = 'api_tennis'
  AND s.sport_code = 'TN'
ON CONFLICT DO NOTHING;

-- 3) Kontrola
SELECT
    COUNT(*) AS api_tennis_provider_map_rows
FROM public.team_provider_map
WHERE provider = 'api_tennis';