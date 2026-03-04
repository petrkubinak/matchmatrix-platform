create or replace function public.mm_preview_run(p_template_id bigint)
returns table (
  template_id bigint,
  variable_blocks int,
  fixed_picks int,
  estimated_tickets bigint,
  preview_blocks_detail jsonb,
  preview_warnings text[]
)
language plpgsql
as $$
declare
  v_max_tickets int := public.mm_get_max_tickets();
begin
  return query
  with
  -- jen VARIABLE bloky
  var_blocks as (
    select tb.template_id, tb.block_index
    from public.template_blocks tb
    where tb.template_id = p_template_id
      and tb.block_type = 'VARIABLE'
  ),

  -- market_id pro každý VARIABLE blok (musí být přesně 1)
  block_market as (
    select
      tbm.block_index,
      count(distinct tbm.market_id) as distinct_markets,
      min(tbm.market_id) as market_id,
      count(*) as matches_in_block
    from public.template_block_matches tbm
    join var_blocks vb
      on vb.template_id = tbm.template_id
     and vb.block_index = tbm.block_index
    where tbm.template_id = p_template_id
    group by tbm.block_index
  ),

  -- nejlepší kurz per (match_id, market_id, code) jen pro zápasy v blocích
  best_odds as (
    select
      tbm.block_index,
      tbm.match_id,
      tbm.market_id,
      mo.code,
      max(o.odd_value) as best_odd
    from public.template_block_matches tbm
    join var_blocks vb
      on vb.template_id = tbm.template_id
     and vb.block_index = tbm.block_index
    join public.market_outcomes mo
      on mo.market_id = tbm.market_id
    join public.odds o
      on o.match_id = tbm.match_id
     and o.market_outcome_id = mo.id
    where tbm.template_id = p_template_id
      and o.odd_value is not null
      and o.odd_value > 0
      and tbm.market_id is not null
    group by tbm.block_index, tbm.match_id, tbm.market_id, mo.code
  ),

  -- kolik code je validních pro blok = musí existovat pro všechny zápasy v bloku
  codes_per_block as (
    select
      bm.block_index,
      bm.market_id,
      bm.distinct_markets,
      bm.matches_in_block,
      count(*) filter (where covered_matches = bm.matches_in_block) as valid_codes
    from block_market bm
    left join (
      select
        bo.block_index,
        bo.code,
        count(distinct bo.match_id) as covered_matches
      from best_odds bo
      group by bo.block_index, bo.code
    ) x
      on x.block_index = bm.block_index
    group by bm.block_index, bm.market_id, bm.distinct_markets, bm.matches_in_block
  ),

  fixed_cnt as (
    select count(*)::int as cnt
    from public.template_fixed_picks tfp
    where tfp.template_id = p_template_id
  ),

  valid_codes_list as (
    select
      bm.block_index,
      jsonb_agg(
        x.code
        order by
          case x.code
            when '1' then 1
            when 'X' then 2
            when '2' then 3
            else 99
          end,
          x.code
      ) as valid_codes_list
    from block_market bm
    left join (
      select
        bo.block_index,
        bo.code,
        count(distinct bo.match_id) as covered_matches
      from best_odds bo
      group by bo.block_index, bo.code
    ) x
      on x.block_index = bm.block_index
     and x.covered_matches = bm.matches_in_block
    group by bm.block_index
  ),

  d0 as (
    select
      jsonb_agg(
        jsonb_build_object(
          'block_index', cpb.block_index,
          'market_id', cpb.market_id,
          'matches_in_block', cpb.matches_in_block,
          'distinct_markets', cpb.distinct_markets,
          'valid_codes', cpb.valid_codes,
          'valid_codes_list', vcl.valid_codes_list
        )
        order by cpb.block_index
      ) as blocks_detail,
      array_remove(array[
        case when exists (select 1 from codes_per_block where distinct_markets <> 1) then
          'Některý VARIABLE blok nemá přesně 1 market_id (je prázdný nebo má mix marketů).'
        end,
        case when exists (select 1 from codes_per_block where matches_in_block = 0) then
          'Některý VARIABLE blok nemá žádné zápasy (template_block_matches je prázdné).'
        end,
        case when exists (select 1 from codes_per_block where valid_codes = 0) then
          'Některý VARIABLE blok má 0 validních možností (chybí odds pro některé zápasy/kódy).'
        end
      ], null) as warnings
    from codes_per_block cpb
    left join valid_codes_list vcl
      on vcl.block_index = cpb.block_index
  ),

  calc as (
    select
      p_template_id as template_id,
      (select count(*)::int from var_blocks) as variable_blocks,
      (select cnt from fixed_cnt) as fixed_picks,
      coalesce(
        (select exp(sum(ln(nullif(valid_codes,0)::numeric)))::bigint from codes_per_block),
        0
      ) as estimated_tickets,
      d0.blocks_detail as preview_blocks_detail,
      d0.warnings as base_warnings
    from d0
  )

  select
    c.template_id,
    c.variable_blocks,
    c.fixed_picks,
    c.estimated_tickets,
    c.preview_blocks_detail,
    (
      c.base_warnings
      || case
           when c.estimated_tickets > v_max_tickets then
             array[format(
               'LIMIT: estimated_tickets=%s exceeds max_tickets=%s (template_id=%s).',
               c.estimated_tickets, v_max_tickets, c.template_id
             )]
           else array[]::text[]
         end
    ) as preview_warnings
  from calc c;

end;
$$;
