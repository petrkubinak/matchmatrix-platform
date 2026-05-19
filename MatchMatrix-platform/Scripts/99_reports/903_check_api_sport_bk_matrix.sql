-- 903_check_api_sport_bk_matrix.sql

SELECT
    provider,
    sport_code,
    sport_name,
    is_enabled,
    supports_leagues,
    supports_teams,
    supports_fixtures,
    supports_players,
    supports_player_stats,
    supports_odds,
    supports_coaches,
    supports_standings,
    notes,
    updated_at
FROM ops.provider_sport_matrix
WHERE provider = 'api_sport'
  AND sport_code = 'BK';