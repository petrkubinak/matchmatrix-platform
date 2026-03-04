create or replace function trg_template_block_matches_not_empty()
returns trigger
language plpgsql
as $$
declare
  v_remaining int;
begin
  -- Povolíme INSERT vždy (vkládání zápasů je OK)
  if tg_op = 'INSERT' then
    return new;
  end if;

  -- Při DELETE/UPDATE hlídáme, že po operaci nezůstane blok prázdný,
  -- pokud ten blok existuje v template_blocks (VARIABLE blok definovaný).
  if tg_op = 'DELETE' then
    select count(*)
      into v_remaining
    from template_block_matches tbm
    where tbm.template_id = old.template_id
      and tbm.block_index = old.block_index
      and not (tbm.match_id = old.match_id);

    -- existuje vůbec ten VARIABLE blok?
    if exists (
      select 1
      from template_blocks tb
      where tb.template_id = old.template_id
        and tb.block_index = old.block_index
        and tb.block_type = 'VARIABLE'
    ) then
      if v_remaining = 0 then
        raise exception 'Cannot remove last match from VARIABLE block %.% (empty blocks are not allowed).',
          old.template_id, old.block_index;
      end if;
    end if;

    return old;
  end if;

  -- UPDATE: pokud měníš block_index/template_id/match_id, je to kombinace DELETE+INSERT => zjednodušíme:
  return new;
end;
$$;

drop trigger if exists trg_template_block_matches_not_empty on template_block_matches;

create trigger trg_template_block_matches_not_empty
before delete on template_block_matches
for each row
execute function trg_template_block_matches_not_empty();
