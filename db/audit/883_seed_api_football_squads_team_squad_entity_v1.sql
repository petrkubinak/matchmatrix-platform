-- ============================================================
-- 883_seed_api_football_squads_team_squad_entity_v1.sql
-- MatchMatrix - seed API Football squads/team_squad entity
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\audit\883_seed_api_football_squads_team_squad_entity_v1.sql
--
-- Spustit v DBeaveru.
-- ============================================================

BEGIN;

INSERT INTO ops.ingest_entity_plan
(
    provider,
    sport_code,
    entity,
    enabled,
    priority,
    scope_type,
    requires_league,
    requires_season,
    default_run_group,
    ingest_mode,
    source_endpoint,
    target_table,
    worker_script,
    notes,
    created_at,
    updated_at
)
VALUES
(
    'api_football_squads',
    'football',
    'team_squad',
    TRUE,
    250,
    'league_season',
    TRUE,
    TRUE,
    'PLAYERS_SQUADS_TEAM_BASED_V1',
    'daily',
    'players/squads',
    'staging.stg_provider_players',
    'workers/run_players_fetch_only_v1.py',
    'Team squad people layer - reads pending rows from ops.player_enrichment_plan.',
    NOW(),
    NOW()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    enabled = EXCLUDED.enabled,
    priority = EXCLUDED.priority,
    scope_type = EXCLUDED.scope_type,
    requires_league = EXCLUDED.requires_league,
    requires_season = EXCLUDED.requires_season,
    default_run_group = EXCLUDED.default_run_group,
    ingest_mode = EXCLUDED.ingest_mode,
    source_endpoint = EXCLUDED.source_endpoint,
    target_table = EXCLUDED.target_table,
    worker_script = EXCLUDED.worker_script,
    notes = EXCLUDED.notes,
    updated_at = NOW();

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    enabled,
    default_run_group,
    target_table,
    worker_script,
    notes
FROM ops.ingest_entity_plan
WHERE provider = 'api_football_squads'
  AND sport_code = 'football'
  AND entity = 'team_squad';