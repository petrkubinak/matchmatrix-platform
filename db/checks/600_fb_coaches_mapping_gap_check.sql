-- 600_fb_coaches_mapping_gap_check.sql
-- Účel:
-- zjistit, jaké coach tabulky/map vrstvy už v DB existují
-- a co případně chybí pro dotažení FB coaches mappingu
-- Spouštět v DBeaveru

-- 1) relevantní public tabulky
select
    table_schema,
    table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in (
      'coaches',
      'coach_provider_map',
      'team_coaches',
      'team_coach_history',
      'teams',
      'team_provider_map'
  )
order by table_name;

-- 2) relevantní staging tabulky
select
    table_schema,
    table_name
from information_schema.tables
where table_schema = 'staging'
  and table_name in (
      'stg_provider_coaches',
      'stg_provider_teams'
  )
order by table_name;

-- 3) struktura coach related public tabulek
select
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.data_type
from information_schema.columns c
where c.table_schema = 'public'
  and c.table_name in (
      'coaches',
      'coach_provider_map',
      'team_coaches',
      'team_coach_history'
  )
order by c.table_name, c.ordinal_position;

-- 4) struktura staging coach tabulky
select
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.data_type
from information_schema.columns c
where c.table_schema = 'staging'
  and c.table_name in (
      'stg_provider_coaches'
  )
order by c.table_name, c.ordinal_position;