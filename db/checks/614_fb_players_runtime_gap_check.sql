-- 614_fb_players_runtime_gap_check.sql
-- verze kompatibilní s tvou DB

-- 1) completion audit
select
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    provider_primary,
    provider_fallback,
    key_gap,
    next_step,
    evidence_note
from ops.sport_completion_audit
where sport_code = 'FB'
  and entity = 'players';

-- 2) staging players
select
    provider,
    sport_code,
    count(*) as stg_rows,
    count(distinct external_player_id) as distinct_players
from staging.stg_provider_players
where sport_code = 'FB'
group by provider, sport_code
order by provider;

-- 3) public players
select
    count(*) as public_players_cnt
from public.players;

-- 4) player provider map
select
    provider,
    count(*) as provider_map_rows
from public.player_provider_map
where provider = 'api_football'
group by provider;

-- 5) preview dat (bez team_external_id)
select
    provider,
    sport_code,
    external_player_id,
    player_name,
    created_at
from staging.stg_provider_players
where sport_code = 'FB'
order by id desc
limit 50;