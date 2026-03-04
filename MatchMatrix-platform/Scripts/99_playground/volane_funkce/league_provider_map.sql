insert into public.league_provider_map(league_id, provider, provider_league_id)
values (6, 'api_football', '39')
on conflict (league_id, provider) do update
set provider_league_id = excluded.provider_league_id,
    updated_at = now();

select l.id, l.name, m.provider, m.provider_league_id
from public.leagues l
join public.league_provider_map m on m.league_id=l.id
order by l.id, m.provider;