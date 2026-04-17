-- ============================================================================
-- 085_check_final_merge_gaps_after_player_fix.sql
-- Cíl:
--   Zjistit, kde se po doplnění players + player_provider_map
--   ještě láme merge do public.player_season_statistics
-- ============================================================================

SELECT 'staging_rows' AS metric, COUNT(*)::text AS value
FROM staging.stg_provider_player_season_stats s

UNION ALL

SELECT 'mapped_players_rows', COUNT(*)::text
FROM staging.stg_provider_player_season_stats s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id

UNION ALL

SELECT 'mapped_teams_rows', COUNT(*)::text
FROM staging.stg_provider_player_season_stats s
JOIN public.team_provider_map tpm
  ON tpm.provider = s.provider
 AND tpm.provider_team_id = s.team_external_id

UNION ALL

SELECT 'mapped_leagues_rows', COUNT(*)::text
FROM staging.stg_provider_player_season_stats s
JOIN public.league_provider_map lpm
  ON lpm.provider = s.provider
 AND lpm.provider_league_id = s.external_league_id

UNION ALL

SELECT 'fully_mapped_rows', COUNT(*)::text
FROM staging.stg_provider_player_season_stats s
JOIN public.player_provider_map ppm
  ON ppm.provider = s.provider
 AND ppm.provider_player_id = s.player_external_id
JOIN public.team_provider_map tpm
  ON tpm.provider = s.provider
 AND tpm.provider_team_id = s.team_external_id
JOIN public.league_provider_map lpm
  ON lpm.provider = s.provider
 AND lpm.provider_league_id = s.external_league_id

UNION ALL

SELECT 'distinct_fully_mapped_business_keys', COUNT(*)::text
FROM (
    SELECT DISTINCT
        ppm.player_id,
        tpm.team_id,
        lpm.league_id,
        s.season,
        s.sport_code
    FROM staging.stg_provider_player_season_stats s
    JOIN public.player_provider_map ppm
      ON ppm.provider = s.provider
     AND ppm.provider_player_id = s.player_external_id
    JOIN public.team_provider_map tpm
      ON tpm.provider = s.provider
     AND tpm.provider_team_id = s.team_external_id
    JOIN public.league_provider_map lpm
      ON lpm.provider = s.provider
     AND lpm.provider_league_id = s.external_league_id
) q

UNION ALL

SELECT 'distinct_unmapped_players', COUNT(*)::text
FROM (
    SELECT DISTINCT s.provider, s.player_external_id
    FROM staging.stg_provider_player_season_stats s
    LEFT JOIN public.player_provider_map ppm
      ON ppm.provider = s.provider
     AND ppm.provider_player_id = s.player_external_id
    WHERE ppm.player_id IS NULL
) q

UNION ALL

SELECT 'distinct_unmapped_teams', COUNT(*)::text
FROM (
    SELECT DISTINCT s.provider, s.team_external_id
    FROM staging.stg_provider_player_season_stats s
    LEFT JOIN public.team_provider_map tpm
      ON tpm.provider = s.provider
     AND tpm.provider_team_id = s.team_external_id
    WHERE tpm.team_id IS NULL
) q;