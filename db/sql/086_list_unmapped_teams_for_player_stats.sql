-- ============================================================================
-- 086_list_unmapped_teams_for_player_stats.sql
-- Cíl:
--   Vypsat 4 chybějící team_external_id, které blokují finální merge
-- ============================================================================

SELECT
    s.provider,
    s.team_external_id,
    COUNT(*) AS stat_rows,
    MIN(s.external_league_id) AS sample_league_id,
    MIN(s.season) AS sample_season
FROM staging.stg_provider_player_season_stats s
LEFT JOIN public.team_provider_map tpm
  ON tpm.provider = s.provider
 AND tpm.provider_team_id = s.team_external_id
WHERE tpm.team_id IS NULL
GROUP BY
    s.provider,
    s.team_external_id
ORDER BY
    stat_rows DESC,
    s.team_external_id;