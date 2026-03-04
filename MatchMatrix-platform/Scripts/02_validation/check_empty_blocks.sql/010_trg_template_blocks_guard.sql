create or replace function trg_template_blocks_guard()
returns trigger
language plpgsql
as $$
declare
  v_cnt int;
begin
  -- povolujeme jen VARIABLE bloky v template_blocks
  if new.block_type <> 'VARIABLE' then
    raise exception 'template_blocks supports only VARIABLE blocks. FIXED belong to template_fixed_picks.';
  end if;

  -- block_index 1..3 (redundantní k CHECK, ale hezčí hláška)
  if new.block_index < 1 or new.block_index > 3 then
    raise exception 'block_index must be 1..3 (got %).', new.block_index;
  end if;

  -- max 3 VARIABLE bloky: když se snaží vložit nový řádek, a ještě neexistuje
  if tg_op = 'INSERT' then
    select count(*)
      into v_cnt
    from template_blocks
    where template_id = new.template_id;

    if v_cnt >= 3 then
      raise exception 'Template % already has 3 VARIABLE blocks (max).', new.template_id;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_template_blocks_guard on template_blocks;

create trigger trg_template_blocks_guard
before insert or update on template_blocks
for each row
execute function trg_template_blocks_guard();
