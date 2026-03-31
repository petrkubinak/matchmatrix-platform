-- =====================================================================================
-- SOUBOR: 329_save_generated_run_into_tickets.sql
-- KAM ULOŽIT: C:\MatchMatrix-platform\db\sql\329_save_generated_run_into_tickets.sql
-- ÚČEL:
--   Uloží jeden generated run z runtime vrstvy do produktové vrstvy:
--   generated_runs / generated_tickets / generated_ticket_blocks
--       ->
--   tickets / ticket_blocks / ticket_block_matches
--
-- JAK POUŽÍT:
--   1) níže uprav v_run_id
--   2) spusť celý skript v DBeaveru
--   3) skript je idempotentní pro stejný run:
--      - nevloží znovu stejný ticket header
--      - nevloží duplicitní blocky
--      - nevloží duplicitní block matches
-- =====================================================================================

do
$$
declare
    v_run_id bigint := 97;      -- <<< ZDE VŽDY NASTAV RUN ID
    v_template_id bigint;
    v_ticket_id bigint;
begin
    -- -------------------------------------------------------------------------
    -- 1) Kontrola existence runu
    -- -------------------------------------------------------------------------
    select gr.template_id
      into v_template_id
    from public.generated_runs gr
    where gr.id = v_run_id;

    if v_template_id is null then
        raise exception 'SAVE PIPELINE: generated_run_id=% neexistuje.', v_run_id;
    end if;

    -- -------------------------------------------------------------------------
    -- 2) Vložení / dohledání headeru v tickets
    -- -------------------------------------------------------------------------
    insert into public.tickets (
        ticket_code,
        strategy_code,
        constants_count,
        blocks_count,
        variants_generated,
        source_type,
        status,
        note,
        created_at,
        updated_at
    )
    select
        'T-' || gr.id || '-' || to_char(now(), 'YYYY-MM-DD') as ticket_code,
        'AUTO_V1' as strategy_code,
        0 as constants_count,
        count(distinct gtb.block_index) as blocks_count,
        count(distinct gt.ticket_index) as variants_generated,
        'generated' as source_type,
        'draft' as status,
        'generated_run_id=' || gr.id as note,
        now() as created_at,
        now() as updated_at
    from public.generated_runs gr
    join public.generated_tickets gt
      on gt.run_id = gr.id
    left join public.generated_ticket_blocks gtb
      on gtb.run_id = gr.id
    where gr.id = v_run_id
      and not exists (
          select 1
          from public.tickets t
          where t.note = 'generated_run_id=' || gr.id
      )
    group by gr.id;

    -- najdi ticket_id (nově vložený nebo již existující)
    select t.id
      into v_ticket_id
    from public.tickets t
    where t.note = 'generated_run_id=' || v_run_id
    order by t.id desc
    limit 1;

    if v_ticket_id is null then
        raise exception 'SAVE PIPELINE: nepodařilo se dohledat ticket pro generated_run_id=%', v_run_id;
    end if;

    -- -------------------------------------------------------------------------
    -- 3) Vložení ticket_blocks
    --    block_code smí být jen A / B / C
    -- -------------------------------------------------------------------------
    insert into public.ticket_blocks (
        ticket_id,
        block_code,
        sort_order,
        created_at
    )
    select
        v_ticket_id as ticket_id,
        case gtb.block_index
            when 1 then 'A'
            when 2 then 'B'
            when 3 then 'C'
        end as block_code,
        gtb.block_index as sort_order,
        now() as created_at
    from (
        select distinct
            block_index
        from public.generated_ticket_blocks
        where run_id = v_run_id
    ) gtb
    left join public.ticket_blocks tb
      on tb.ticket_id = v_ticket_id
     and tb.sort_order = gtb.block_index
    where tb.id is null
      and gtb.block_index between 1 and 3
    order by gtb.block_index;

    -- -------------------------------------------------------------------------
    -- 4) Vložení ticket_block_matches
    --    Přenos skutečných matchů z template_block_matches
    -- -------------------------------------------------------------------------
    insert into public.ticket_block_matches (
        block_id,
        match_id,
        market_id,
        bookmaker_id,
        bookmaker_odds,
        prob_1,
        prob_0,
        prob_2,
        sort_order,
        created_at
    )
    select
        q.block_id,
        q.match_id,
        q.market_id,
        null::bigint as bookmaker_id,
        null::numeric as bookmaker_odds,
        null::numeric as prob_1,
        null::numeric as prob_0,
        null::numeric as prob_2,
        q.sort_order,
        now() as created_at
    from (
        select
            tb.id as block_id,
            tbm.match_id,
            tbm.market_id,
            row_number() over (
                partition by tb.id
                order by tbm.match_id
            ) as sort_order
        from public.ticket_blocks tb
        join public.template_block_matches tbm
          on tbm.template_id = v_template_id
         and tbm.block_index = tb.sort_order
        where tb.ticket_id = v_ticket_id
    ) q
    left join public.ticket_block_matches x
      on x.block_id = q.block_id
     and x.match_id = q.match_id
    where x.id is null
    order by q.block_id, q.sort_order;

    -- -------------------------------------------------------------------------
    -- 5) Aktualizace updated_at na ticket headeru
    -- -------------------------------------------------------------------------
    update public.tickets
    set updated_at = now()
    where id = v_ticket_id;

    raise notice 'SAVE PIPELINE HOTOVO | run_id=% | template_id=% | ticket_id=%',
        v_run_id, v_template_id, v_ticket_id;
end
$$;