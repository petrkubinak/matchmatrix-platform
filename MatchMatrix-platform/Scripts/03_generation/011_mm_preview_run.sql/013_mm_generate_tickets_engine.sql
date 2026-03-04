create or replace function public.mm_generate_tickets_engine(
  p_run_id bigint,
  p_template_id bigint,
  p_max_tickets int default null,
  p_min_probability numeric default null,
  p_batch_size int default null   -- ignorujeme, jen pro kompatibilitu volání
)
returns void
language plpgsql
as $$
declare
  v_inserted int;
begin
  -- čistý re-run pro stejné run_id
  delete from public.generated_ticket_blocks where run_id = p_run_id;
  delete from public.generated_ticket_fixed  where run_id = p_run_id;
  delete from public.generated_tickets       where run_id = p_run_id;

  -- 0) ověř: každý blok má jen jeden market_id (uniformní logika)
  if exists (
    select 1
    from (
      select tbm.block_index
      from public.template_block_matches tbm
      where tbm.template_id = p_template_id
      group by tbm.block_index
      having count(distinct tbm.market_id) <> 1
    ) x
  ) then
    raise exception
      'Template %: některý blok obsahuje více než 1 market_id. Uniformní blok to nepodporuje.',
      p_template_id;
  end if;

  with recursive
  -- A) bloky + jejich market_id + počet zápasů v bloku
  blocks as (
    select
      tbm.block_index,
      min(tbm.market_id) as market_id,
      count(*) as match_cnt
    from public.template_block_matches tbm
    where tbm.template_id = p_template_id
    group by tbm.block_index
  ),

  -- B) best odds per (match_id, market_id, code) pro zápasy, které jsou v template blocích
  best_odds as (
    select
      o.match_id,
      mo.market_id,
      mo.code,
      max(o.odd_value) as best_odd
    from public.template_block_matches tbm
    join public.market_outcomes mo
      on mo.market_id = tbm.market_id
    join public.odds o
      on o.match_id = tbm.match_id
     and o.market_outcome_id = mo.id
    where tbm.template_id = p_template_id
      and o.odd_value is not null
      and o.odd_value > 0
    group by o.match_id, mo.market_id, mo.code
  ),

  -- C) povolené kódy pro blok = code, které má best_odds pro VŠECHNY match v bloku
  block_codes as (
    select
      b.block_index,
      array_agg(x.code order by x.code) as codes
    from blocks b
    join (
      select
        tbm.block_index,
        mo.code,
        count(distinct tbm.match_id) as covered_matches
      from public.template_block_matches tbm
      join public.market_outcomes mo
        on mo.market_id = tbm.market_id
      join best_odds bo
        on bo.match_id  = tbm.match_id
       and bo.market_id = tbm.market_id
       and bo.code      = mo.code
      where tbm.template_id = p_template_id
      group by tbm.block_index, mo.code
    ) x
      on x.block_index = b.block_index
     and x.covered_matches = b.match_cnt
    group by b.block_index
  ),

  ordered_blocks as (
    select
      row_number() over(order by bc.block_index) as rn,
      bc.block_index,
      unnest(bc.codes) as code
    from block_codes bc
  ),

  -- D) kombinace = 1 code na blok (žádné kombinace uvnitř bloku)
  combos as (
    select
      ob.rn,
      jsonb_build_array(
        jsonb_build_object('block', ob.block_index, 'code', ob.code)
      ) as blocks_json
    from ordered_blocks ob
    where ob.rn = 1

    union all

    select
      ob.rn,
      c.blocks_json ||
      jsonb_build_array(
        jsonb_build_object('block', ob.block_index, 'code', ob.code)
      ) as blocks_json
    from combos c
    join ordered_blocks ob
      on ob.rn = c.rn + 1
  ),

  final_combos as (
    select blocks_json
    from combos
    where rn = (select max(rn) from ordered_blocks)
  ),

  -- E) pravděpodobnost variable části (součin přes všechny match v blocích dle zvoleného code)
  variable_prob as (
    select
      fc.blocks_json,
      exp(sum(ln(1.0 / bo.best_odd))) as p
    from final_combos fc
    cross join lateral jsonb_array_elements(fc.blocks_json) b
    join public.template_block_matches tbm
      on tbm.template_id = p_template_id
     and tbm.block_index = (b->>'block')::int
    join best_odds bo
      on bo.match_id  = tbm.match_id
     and bo.market_id = tbm.market_id
     and bo.code      = (b->>'code')::text
    group by fc.blocks_json
  ),

  -- F) fixed část – nejlepší kurz pro konkrétní market_outcome_id
  fixed_best as (
    select
      tfp.match_id,
      tfp.market_outcome_id,
      max(o.odd_value) as best_odd
    from public.template_fixed_picks tfp
    join public.odds o
      on o.match_id = tfp.match_id
     and o.market_outcome_id = tfp.market_outcome_id
    where tfp.template_id = p_template_id
      and o.odd_value is not null
      and o.odd_value > 0
    group by tfp.match_id, tfp.market_outcome_id
  ),

  fixed_prob as (
    select coalesce(exp(sum(ln(1.0 / fb.best_odd))), 1) as p
    from fixed_best fb
  ),

  ranked as (
    select
      vp.blocks_json,
      (vp.p * fp.p) as probability
    from variable_prob vp
    cross join fixed_prob fp
    where p_min_probability is null or (vp.p * fp.p) >= p_min_probability
    order by (vp.p * fp.p) desc, vp.blocks_json::text asc
    limit case
      when p_max_tickets is null then 2147483647
      when p_max_tickets <= 0 then 0
      else p_max_tickets
    end
  )

  -- G) uložit tickets
  insert into public.generated_tickets(run_id, ticket_index, probability, snapshot)
  select
    p_run_id,
    row_number() over(order by probability desc, blocks_json::text asc) as ticket_index,
    probability,
    jsonb_build_object(
      'blocks', blocks_json,
      'fixed',
      (
        select coalesce(
          jsonb_agg(
            jsonb_build_object('match_id', tfp.match_id, 'market_outcome_id', tfp.market_outcome_id)
            order by tfp.match_id
          ),
          '[]'::jsonb
        )
        from public.template_fixed_picks tfp
        where tfp.template_id = p_template_id
      )
    ) as snapshot
  from ranked;

  get diagnostics v_inserted = row_count;

  -- H) uložit fixed picks (1× na run)
  insert into public.generated_ticket_fixed(run_id, match_id, market_outcome_id)
  select p_run_id, tfp.match_id, tfp.market_outcome_id
  from public.template_fixed_picks tfp
  where tfp.template_id = p_template_id
  on conflict do nothing;

  -- I) uložit blokové volby jako market_outcome_id (market-level), 1 řádek na blok
insert into public.generated_ticket_blocks(run_id, ticket_index, block_index, market_outcome_id)
select
  gt.run_id,
  gt.ticket_index,
  (b->>'block')::int as block_index,
  mo.id as market_outcome_id
from public.generated_tickets gt
cross join lateral jsonb_array_elements(gt.snapshot->'blocks') b
join (
  select
    tbm.block_index,
    min(tbm.market_id) as market_id
  from public.template_block_matches tbm
  where tbm.template_id = p_template_id
  group by tbm.block_index
) bm
  on bm.block_index = (b->>'block')::int
join public.market_outcomes mo
  on mo.market_id = bm.market_id
 and mo.code = (b->>'code')::text
where gt.run_id = p_run_id
on conflict do nothing;

  if v_inserted = 0 then
    raise exception
      'No tickets generated (V2 uniform blocks) for template %. Zkontroluj odds pokrytí v blocích.',
      p_template_id;
  end if;

end;
$$;
