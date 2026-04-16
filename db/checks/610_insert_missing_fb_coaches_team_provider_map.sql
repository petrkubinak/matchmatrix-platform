-- 610_insert_missing_fb_coaches_team_provider_map.sql
-- verze kompatibilní s tvou DB strukturou

insert into public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
select
    x.team_id,
    'api_football',
    x.provider_team_id,
    now(),
    now()
from (
    values
        (95::bigint,  '194'::text),  -- Ajax
        (55::bigint,  '33'::text),   -- Manchester United
        (562::bigint, '207'::text),  -- Utrecht
        (568::bigint, '410'::text)   -- Go Ahead Eagles
) as x(team_id, provider_team_id)
where not exists (
    select 1
    from public.team_provider_map tpm
    where tpm.provider = 'api_football'
      and tpm.provider_team_id = x.provider_team_id
);

-- kontrola
select
    tpm.provider_team_id,
    tpm.team_id,
    t.name as canonical_team_name
from public.team_provider_map tpm
left join public.teams t
    on t.id = tpm.team_id
where tpm.provider = 'api_football'
  and tpm.provider_team_id in ('194','33','207','410')
order by tpm.provider_team_id;