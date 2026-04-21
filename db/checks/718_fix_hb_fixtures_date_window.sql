-- 718_fix_hb_fixtures_date_window.sql
-- Přidáme date window pro HB fixtures

update ops.ingest_targets
set
    fixtures_days_back = 30,
    fixtures_days_forward = 30,
    updated_at = now(),
    notes = coalesce(notes, '') || ' | fixtures date window enabled (±30 days)'
where provider = 'api_handball'
  and sport_code = 'HB';

select
    id,
    provider,
    sport_code,
    provider_league_id,
    season,
    fixtures_days_back,
    fixtures_days_forward,
    notes,
    updated_at
from ops.ingest_targets
where provider = 'api_handball'
  and sport_code = 'HB';