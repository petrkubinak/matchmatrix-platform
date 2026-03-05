insert into public.league_provider_map (
    league_id,
    provider,
    provider_league_id,
    created_at,
    updated_at
)
select
    l.id,
    'api_hockey',
    l.ext_league_id,
    now(),
    now()
from public.leagues l
left join public.league_provider_map m
  on m.provider = 'api_hockey'
 and m.provider_league_id = l.ext_league_id
where l.ext_source = 'api_hockey'
  and m.league_id is null;