-- ============================================================================
-- 071_create_work_missing_player_profile_ids.sql
-- Cíl:
--   Uložit 220 chybějících player IDs do pracovní tabulky
--   pro další ingest player profiles
-- ============================================================================

DROP TABLE IF EXISTS work.missing_player_profile_ids;

CREATE TABLE work.missing_player_profile_ids AS
WITH missing_stats_players AS (
    SELECT DISTINCT
        s.provider,
        s.sport_code,
        s.player_external_id
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
    player_external_id
FROM missing_stats_players
ORDER BY provider, sport_code, player_external_id;

-- kontrola
SELECT COUNT(*) AS cnt
FROM work.missing_player_profile_ids;