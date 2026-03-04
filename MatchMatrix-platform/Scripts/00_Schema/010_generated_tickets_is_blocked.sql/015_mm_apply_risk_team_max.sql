create or replace function public.mm_apply_risk_team_max(
  p_run_id bigint,
  p_team_max int default 3,
  p_hard_block boolean default false
)
returns void
language plpgsql
as $$
declare
  v_template_id bigint;
begin
  select gr.template_id into v_template_id
  from public.generated_runs gr
  where gr.id = p_run_id;

  if v_template_id is null then
    raise exception 'Run % not found', p_run_id;
  end if;

  delete from public.generated_ticket_risk
  where run_id = p_run_id
    and rule_code = 'MAX_TEAM_PER_TICKET';

  with ticket_matches as (
    select
      gtb.ticket_index,
      tbm.match_id
    from public.generated_ticket_blocks gtb
    join public.template_block_matches tbm
      on tbm.template_id = v_template_id
     and tbm.block_index = gtb.block_index
    where gtb.run_id = p_run_id
  ),
  ticket_teams as (
    select
      tm.ticket_index,
      x.team_id
    from ticket_matches tm
    join public.matches m
      on m.id = tm.match_id
    cross join lateral (
      values (m.home_team_id), (m.away_team_id)
    ) as x(team_id)
    where x.team_id is not null
  ),
  team_counts as (
    select
      ticket_index,
      team_id,
      count(*) as occurrences
    from ticket_teams
    group by ticket_index, team_id
  ),
  violations as (
    select
      ticket_index,
      jsonb_agg(
        jsonb_build_object('team_id', team_id, 'occurrences', occurrences)
        order by occurrences desc
      ) as details
    from team_counts
    where occurrences > p_team_max
    group by ticket_index
  )
  insert into public.generated_ticket_risk(run_id, ticket_id, rule_code, details)
  select
    p_run_id,
    v.ticket_index::bigint, -- do risk tabulky ukládáme ticket_id = ticket_index (identifikátor v rámci runu)
    'MAX_TEAM_PER_TICKET',
    jsonb_build_object('team_max', p_team_max, 'violations', v.details)
  from violations v
  on conflict do nothing;

  if p_hard_block then
    update public.generated_tickets gt
    set is_blocked = exists (
      select 1
      from public.generated_ticket_risk r
      where r.run_id = gt.run_id
        and r.ticket_id = gt.ticket_index::bigint
        and r.rule_code = 'MAX_TEAM_PER_TICKET'
    )
    where gt.run_id = p_run_id;
  end if;

end;
$$;
