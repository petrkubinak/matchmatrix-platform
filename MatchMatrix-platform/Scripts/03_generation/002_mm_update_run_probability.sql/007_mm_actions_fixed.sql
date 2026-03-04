-- Přidat FIXED tip
insert into template_fixed_picks(template_id, match_id, market_outcome_id)
values (1, 123, 456) -- <<< template_id, match_id, market_outcome_id
on conflict do nothing;

-- Odebrat FIXED tip
delete from template_fixed_picks
where template_id = 1
  and match_id = 1
  and market_outcome_id = 456;
