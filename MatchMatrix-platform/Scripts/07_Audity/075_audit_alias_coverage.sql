-- 70_Audity/75_audit_alias_coverage.sql

select
  t.id,
  t.name,
  t.ext_source,
  t.ext_team_id
from public.teams t
left join public.team_aliases a
  on a.team_id = t.id
where t.ext_source = 'api_football'
group by t.id, t.name, t.ext_source, t.ext_team_id
having count(a.id) = 0
order by t.name;