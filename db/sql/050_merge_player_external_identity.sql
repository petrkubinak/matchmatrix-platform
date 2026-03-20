-- 050_merge_player_external_identity.sql
-- Doplnění public.player_external_identity z aktuálních player map a staging profilů

INSERT INTO public.player_external_identity (
    player_id,
    provider,
    external_player_id,
    external_team_id,
    external_league_id,
    season,
    confidence_score,
    match_method,
    is_primary,
    is_active,
    created_at,
    updated_at
)
SELECT DISTINCT
    ppm.player_id,
    ppm.provider,
    ppm.provider_player_id AS external_player_id,
    COALESCE(pp.external_team_id, sp.external_team_id, ppm.provider_team_id) AS external_team_id,
    COALESCE(pp.external_league_id, sp.external_league_id) AS external_league_id,
    COALESCE(pp.season, sp.season) AS season,
    1.00::numeric AS confidence_score,
    'provider_player_map' AS match_method,
    true AS is_primary,
    COALESCE(ppm.is_active, true) AS is_active,
    now(),
    now()
FROM public.player_provider_map ppm
LEFT JOIN staging.stg_provider_player_profiles pp
       ON pp.provider = ppm.provider
      AND pp.external_player_id = ppm.provider_player_id
LEFT JOIN staging.stg_provider_players sp
       ON sp.provider = ppm.provider
      AND sp.external_player_id = ppm.provider_player_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.player_external_identity pei
    WHERE pei.player_id = ppm.player_id
      AND pei.provider = ppm.provider
      AND pei.external_player_id = ppm.provider_player_id
      AND COALESCE(pei.external_team_id, '') = COALESCE(COALESCE(pp.external_team_id, sp.external_team_id, ppm.provider_team_id), '')
      AND COALESCE(pei.external_league_id, '') = COALESCE(COALESCE(pp.external_league_id, sp.external_league_id), '')
      AND COALESCE(pei.season, '') = COALESCE(COALESCE(pp.season, sp.season), '')
);