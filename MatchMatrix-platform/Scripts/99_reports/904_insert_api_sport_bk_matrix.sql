-- 904_insert_api_sport_bk_matrix.sql

INSERT INTO ops.provider_sport_matrix (
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
    created_at,
    updated_at
)
VALUES (
    'api_sport',
    'BK',
    'Basketball',
    true,
    true,
    true,
    true,
    true,
    false,
    true,
    false,
    false,
    'API-Sport Basketball enabled for controlled harvest. Core leagues/teams/fixtures ready; players tested separately.',
    now(),
    now()
)
ON CONFLICT DO NOTHING;

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