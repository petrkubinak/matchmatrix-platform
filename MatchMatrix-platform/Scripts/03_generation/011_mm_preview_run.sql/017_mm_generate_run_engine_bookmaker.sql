create or replace function public.mm_generate_run_engine(
  p_template_id bigint,
  p_bookmaker_id int,
  p_max_tickets int default null,
  p_min_probability numeric default null,
  p_batch_size int default 200000
)
returns bigint
language plpgsql
as $$
declare
  v_run_id bigint;
  v_estimated_tickets bigint;
  v_warnings text[];
  v_max int := coalesce(p_max_tickets, public.mm_get_max_tickets());
  v_nonlimit_warnings text[];
begin
  -- 1) Preview pro konkrétního bookmakera (fail-fast)
  select pr.estimated_tickets, pr.preview_warnings
    into v_estimated_tickets, v_warnings
  from public.mm_preview_run(p_template_id, p_bookmaker_id) pr;

  v_estimated_tickets := coalesce(v_estimated_tickets, 0);

  -- validační problémy (kromě LIMIT) = stop
  select coalesce(array_agg(w), array[]::text[])
    into v_nonlimit_warnings
  from unnest(coalesce(v_warnings, array[]::text[])) w
  where w not like 'LIMIT:%';

  if array_length(v_nonlimit_warnings, 1) is not null then
    raise exception using
      errcode = 'P0001',
      message = format(
        'MatchMatrix: template validation failed for template_id=%s bookmaker_id=%s. Warnings: %s',
        p_template_id,
        p_bookmaker_id,
        array_to_string(v_nonlimit_warnings, ' | ')
      );
  end if;

  -- hard limit
  if v_estimated_tickets > v_max then
    raise exception using
      errcode = 'P0001',
      message = format(
        'MatchMatrix: LIMIT exceeded. estimated_tickets=%s > max_tickets=%s for template_id=%s bookmaker_id=%s',
        v_estimated_tickets, v_max, p_template_id, p_bookmaker_id
      );
  end if;

  -- 2) Založení runu (uložíme bookmaker)
  insert into public.generated_runs(template_id, created_at, max_tickets, min_probability, bookmaker_id)
  values (p_template_id, now(), v_max, p_min_probability, p_bookmaker_id)
  returning id into v_run_id;

  -- 3) Generování tiketů
  perform public.mm_generate_tickets_engine(
    v_run_id,
    p_template_id,
    v_max,
    p_min_probability,
    p_batch_size
  );

  -- 4) Risk layer (SOFT), pokud už máš funkci
  -- perform public.mm_apply_risk_team_max(v_run_id, 3, false);

  return v_run_id;
end;
$$;
