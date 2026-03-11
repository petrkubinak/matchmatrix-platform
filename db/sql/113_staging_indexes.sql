CREATE INDEX IF NOT EXISTS idx_stg_provider_fixtures_lookup
ON staging.stg_provider_fixtures(provider, sport_code, external_fixture_id);

CREATE INDEX IF NOT EXISTS idx_stg_provider_teams_lookup
ON staging.stg_provider_teams(provider, external_team_id);

CREATE INDEX IF NOT EXISTS idx_stg_provider_players_lookup
ON staging.stg_provider_players(provider, external_player_id);