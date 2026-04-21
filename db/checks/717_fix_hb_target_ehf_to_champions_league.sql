select
    provider,
    sport_code,
    external_team_id,
    team_name,
    external_league_id,
    season,
    created_at,
    updated_at
from staging.stg_provider_teams
where upper(coalesce(provider, '')) = 'API_HANDBALL'
   or upper(coalesce(sport_code, '')) = 'HB'
order by updated_at desc nulls last, created_at desc nulls last
limit 20;

select count(*) as hb_stg_provider_teams_count
from staging.stg_provider_teams
where upper(coalesce(provider, '')) = 'API_HANDBALL'
   or upper(coalesce(sport_code, '')) = 'HB';

select
    id,
    provider,
    sport_code,
    entity_type,
    external_id,
    season,
    parse_status,
    parse_message,
    created_at
from staging.stg_api_payloads
where provider = 'api_handball'
  and entity_type = 'teams'
order by id desc
limit 20;

select
    id,
    provider,
    sport_code,
    canonical_league_id,
    provider_league_id,
    season,
    run_group,
    enabled,
    notes
from ops.ingest_targets
where provider = 'api_handball'
  and sport_code = 'HB';

select
    external_league_id,
    league_name,
    country_name,
    season,
    is_active
from staging.stg_provider_leagues
where provider = 'api_handball'
  and sport_code = 'HB'
  and (
        upper(league_name) like '%EHF%'
     or upper(league_name) like '%EUROPE%'
     or upper(country_name) like '%EUROPE%'
  )
order by league_name, season desc, external_league_id;

-- 717_fix_hb_target_ehf_to_champions_league.sql
-- Účel:
-- Pro první HB smoke test změnit provider_league_id z obecného EHF
-- na konkrétní API-Handball league id = 131 (Champions League)

update ops.ingest_targets
set
    provider_league_id = '131',
    notes = 'HB smoke test: Champions League (api_handball league_id=131)',
    updated_at = now()
where id = 4872
  and provider = 'api_handball'
  and sport_code = 'HB';

select
    id,
    provider,
    sport_code,
    canonical_league_id,
    provider_league_id,
    season,
    run_group,
    enabled,
    notes,
    updated_at
from ops.ingest_targets
where id = 4872;

-- 717_fix_hb_target_ehf_to_131_retry.sql

update ops.ingest_targets
set
    provider_league_id = '131',
    notes = 'HB smoke test: Champions League (api_handball league_id=131)',
    updated_at = now()
where provider = 'api_handball'
  and sport_code = 'HB'
  and provider_league_id = 'EHF';

select
    id,
    provider,
    sport_code,
    canonical_league_id,
    provider_league_id,
    season,
    run_group,
    enabled,
    notes,
    updated_at
from ops.ingest_targets
where provider = 'api_handball'
  and sport_code = 'HB';

select
    provider,
    sport_code,
    external_team_id,
    team_name,
    external_league_id,
    season,
    created_at,
    updated_at
from staging.stg_provider_teams
where provider = 'api_handball'
   or sport_code = 'HB'
order by updated_at desc nulls last, created_at desc nulls last
limit 20;

select
    id,
    provider,
    sport_code,
    entity_type,
    external_id,
    season,
    parse_status,
    parse_message,
    created_at
from staging.stg_api_payloads
where provider = 'api_handball'
  and entity_type = 'teams'
order by id desc
limit 10;

select
    id,
    provider,
    sport_code,
    entity_type,
    external_id,
    season,
    parse_status,
    parse_message,
    created_at
from staging.stg_api_payloads
where provider = 'api_handball'
  and entity_type = 'fixtures'
order by id desc
limit 10;

select count(*) as hb_stg_provider_fixtures_count
from staging.stg_provider_fixtures
where provider = 'api_handball'
   or sport_code in ('HB', 'handball');

select *
from staging.stg_provider_fixtures
where provider = 'api_handball'
   or sport_code in ('HB', 'handball')
order by coalesce(updated_at, created_at) desc nulls last
limit 20;