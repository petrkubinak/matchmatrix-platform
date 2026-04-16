-- 577_fb_execution_flow_snapshot.sql
-- Účel:
-- rychlý snapshot execution flow pro FB audit
-- Spouštět v DBeaveru

-- 1) FB audit tabulka - jen hlavní execution sloupce
select
    entity,
    primary_provider,
    fallback_provider,
    execution_mode,
    automator_ready,
    requires_pro,
    staging_table,
    public_dependency,
    post_process
from ops.fb_entity_audit
order by id;

-- 2) existence hlavních staging tabulek pro FB
select
    table_schema,
    table_name
from information_schema.tables
where (table_schema, table_name) in (
    ('staging', 'stg_provider_leagues'),
    ('staging', 'stg_provider_teams'),
    ('staging', 'stg_provider_fixtures'),
    ('staging', 'stg_provider_players'),
    ('staging', 'stg_provider_player_stats'),
    ('staging', 'stg_provider_player_season_stats')
)
order by table_schema, table_name;

-- 3) existence hlavních public tabulek / cílů
select
    table_schema,
    table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in (
      'leagues',
      'teams',
      'team_provider_map',
      'team_aliases',
      'matches',
      'odds',
      'players',
      'player_provider_map',
      'player_season_statistics',
      'league_standings'
  )
order by table_name;

-- 4) existence klíčových FB / downstream funkcí
select
    routine_schema,
    routine_name,
    routine_type
from information_schema.routines
where routine_schema = 'public'
  and routine_name in (
      'refresh_league_standings',
      'refresh_product_league_standings'
  )
order by routine_name;

-- 5) existence klíčového OPS control view
select
    table_schema,
    table_name
from information_schema.views
where table_schema = 'ops'
  and table_name in (
      'v_harvest_e2e_control',
      'v_fb_job_catalog',
      'v_fb_test_mode_orchestrator'
  )
order by table_name;