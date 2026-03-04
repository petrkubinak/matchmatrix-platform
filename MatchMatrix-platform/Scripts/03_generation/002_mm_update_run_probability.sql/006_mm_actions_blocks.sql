-- Přidat zápas do VARIABLE bloku
insert into template_block_matches(template_id, block_index, match_id)
values (1, 1, 2)  -- <<< template_id, block_index, match_id
on conflict do nothing;

-- Odebrat zápas z bloku
delete from template_block_matches
where template_id = 1
  and block_index = 1
  and match_id = 2;
