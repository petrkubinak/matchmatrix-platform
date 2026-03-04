create or replace function public.mm_get_odds_compare(
  p_match_id bigint,
  p_market_outcome_id bigint
)
returns table (
  bookmaker_id int,
  bookmaker_name text,
  odd_value numeric,
  collected_at timestamptz
)
language sql
stable
as $$
  select
    b.id as bookmaker_id,
    b.name as bookmaker_name,
    o.odd_value,
    o.collected_at
  from public.odds o
  join public.bookmakers b on b.id = o.bookmaker_id
  where o.match_id = p_match_id
    and o.market_outcome_id = p_market_outcome_id
  order by o.odd_value desc nulls last, b.id;
$$;
