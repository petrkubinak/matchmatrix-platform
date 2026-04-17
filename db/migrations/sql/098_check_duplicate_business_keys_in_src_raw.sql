-- ============================================================================
-- 098_check_duplicate_business_keys_in_src_raw.sql
-- Cíl:
--   Najít konkrétní duplicity v src_raw před finálním merge
-- ============================================================================

WITH s_clean AS (
    SELECT DISTINCT
        provider,
        sport_code,
        external_league_id,
        team_external_id,
        player_external_id,
        season,
        stat_name,
        stat_value
    FROM staging.stg_provider_player_season_stats
    WHERE lower(sport_code) = 'football'
),

pivot AS (
    SELECT
        provider,
        external_league_id,
        team_external_id,
        player_external_id,
        season
    FROM s_clean
    GROUP BY
        provider,
        external_league_id,
        team_external_id,
        player_external_id,
        season
),

ppm_u AS (
    SELECT provider, provider_player_id, player_id
    FROM public.player_provider_map
),

tpm_u AS (
    SELECT provider, provider_team_id, team_id
    FROM public.team_provider_map
),

lpm_u AS (
    SELECT provider, provider_league_id, league_id
    FROM public.league_provider_map
),

src_raw AS (
    SELECT
        ppm_u.player_id,
        tpm_u.team_id,
        lpm_u.league_id,
        p.season,
        p.provider,
        p.player_external_id,
        p.team_external_id,
        p.external_league_id
    FROM pivot p
    JOIN ppm_u
      ON ppm_u.provider = p.provider
     AND ppm_u.provider_player_id = p.player_external_id
    JOIN tpm_u
      ON tpm_u.provider = p.provider
     AND tpm_u.provider_team_id = p.team_external_id
    JOIN lpm_u
      ON lpm_u.provider = p.provider
     AND lpm_u.provider_league_id = p.external_league_id
)

SELECT
    player_id,
    team_id,
    league_id,
    season,
    COUNT(*) AS dup_count,
    MIN(provider) AS provider,
    MIN(player_external_id) AS sample_player_external_id,
    MIN(team_external_id) AS sample_team_external_id,
    MIN(external_league_id) AS sample_external_league_id
FROM src_raw
GROUP BY
    player_id,
    team_id,
    league_id,
    season
HAVING COUNT(*) > 1
ORDER BY dup_count DESC, player_id, team_id, league_id, season;