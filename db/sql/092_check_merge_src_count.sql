-- ============================================================================
-- 092_check_merge_src_count.sql
-- Cíl:
--   Ověřit, kolik řádků ve skutečnosti vyrábí merge source (src)
-- ============================================================================

WITH src AS (
    SELECT
        ppm.player_id,
        tpm.team_id,
        sp.id AS sport_id,
        lpm.league_id,
        s.season
    FROM staging.stg_provider_player_season_stats s
    JOIN public.sports sp
      ON lower(sp.code) = lower(s.sport_code)
    JOIN public.player_provider_map ppm
      ON ppm.provider = s.provider
     AND ppm.provider_player_id = s.player_external_id
    JOIN public.team_provider_map tpm
      ON tpm.provider = s.provider
     AND tpm.provider_team_id = s.team_external_id
    JOIN public.league_provider_map lpm
      ON lpm.provider = s.provider
     AND lpm.provider_league_id = s.external_league_id
    GROUP BY
        ppm.player_id,
        tpm.team_id,
        sp.id,
        lpm.league_id,
        s.season
)
SELECT COUNT(*) AS src_cnt
FROM src;