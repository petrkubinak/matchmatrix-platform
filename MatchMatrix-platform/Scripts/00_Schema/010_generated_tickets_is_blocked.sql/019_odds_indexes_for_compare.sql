create index if not exists idx_odds_match_outcome
  on public.odds(match_id, market_outcome_id);

create index if not exists idx_odds_match_outcome_bookmaker
  on public.odds(match_id, market_outcome_id, bookmaker_id);
