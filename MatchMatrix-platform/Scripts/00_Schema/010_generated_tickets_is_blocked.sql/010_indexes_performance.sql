-- odds: hledáme podle (match_id, market_outcome_id) a bereme max(odd_value)
create index if not exists ix_odds_match_outcome_odd
  on public.odds(match_id, market_outcome_id, odd_value desc);

-- template_block_matches: filtr template + block, pak match
create index if not exists ix_tbm_template_block_match
  on public.template_block_matches(template_id, block_index, match_id);

-- fixed picks: filtr template + join na match/outcome
create index if not exists ix_tfp_template_match_outcome
  on public.template_fixed_picks(template_id, match_id, market_outcome_id);

-- generated_tickets: sum(probability) per run
create index if not exists ix_gt_run_prob
  on public.generated_tickets(run_id, probability);
