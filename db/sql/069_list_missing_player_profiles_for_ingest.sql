-- ============================================================================
-- 069_list_missing_player_profiles_for_ingest.sql
-- Cíl:
--   Vypsat hráče ze season stats, kteří chybí v public.players
--   i ve staging.stg_provider_player_profiles
--   = kandidáti pro další ingest player profiles
-- ============================================================================

WITH missing_stats_players AS (
    SELECT DISTINCT
        s.provider,
        s.sport_code,
        s.player_external_id,
        s.team_external_id,
        s.external_league_id,
        s.season
    FROM staging.stg_provider_player_season_stats s
    LEFT JOIN public.players p
      ON p.ext_source = s.provider
     AND p.ext_player_id = s.player_external_id
    LEFT JOIN staging.stg_provider_player_profiles spp
      ON spp.provider = s.provider
     AND spp.sport_code = s.sport_code
     AND spp.external_player_id = s.player_external_id
    WHERE p.id IS NULL
      AND spp.id IS NULL
)
SELECT
    provider,
    sport_code,
    player_external_id,
    team_external_id,
    external_league_id,
    season
FROM missing_stats_players
ORDER BY
    external_league_id,
    team_external_id,
    player_external_id;