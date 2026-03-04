create or replace function mm_validate_template(p_template_id bigint)
returns void
language plpgsql
as $$
declare
  v_variable_blocks int;
  v_empty_blocks int;
begin
  -- Počítáme jen VARIABLE bloky (max 3)
  select count(*)
    into v_variable_blocks
  from template_blocks tb
  where tb.template_id = p_template_id
    and tb.block_type = 'VARIABLE';

  if v_variable_blocks > 3 then
    raise exception 'Template % has % VARIABLE blocks, max is 3.',
      p_template_id, v_variable_blocks;
  end if;

  -- Prázdný VARIABLE blok = zakázáno
  select count(*)
    into v_empty_blocks
  from template_blocks tb
  left join template_block_matches tbm
    on tbm.template_id = tb.template_id
   and tbm.block_index = tb.block_index
  where tb.template_id = p_template_id
    and tb.block_type = 'VARIABLE'
  group by tb.template_id, tb.block_index
  having count(tbm.match_id) = 0;

  if coalesce(v_empty_blocks, 0) > 0 then
    raise exception
      'Template % contains empty VARIABLE block.',
      p_template_id;
  end if;

end;
$$;
