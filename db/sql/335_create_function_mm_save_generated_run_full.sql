-- =====================================================================================
-- SOUBOR: 335_create_function_mm_save_generated_run_full.sql
-- KAM ULOŽIT: C:\MatchMatrix-platform\db\sql\335_create_function_mm_save_generated_run_full.sql
-- ÚČEL:
--   Finální save pipeline pro jeden generated run:
--   1) tickets
--   2) ticket_blocks
--   3) ticket_block_matches
--   4) ticket_history_base INSERT
--   5) ticket_history_base UPDATE (total_odd, odd_band, notes)
--
-- VOLÁNÍ:
--   select * from public.mm_save_generated_run_full(97);
-- =====================================================================================

create or replace function public.mm_save_generated_run_full(
    p_run_id bigint
)
returns table (
    run_id bigint,
    ticket_id bigint,
    tickets_rows integer,
    ticket_blocks_rows integer,
    ticket_block_matches_rows integer,
    history_inserted_rows integer,
    history_updated_rows integer,
    status_text text
)
language plpgsql
as
$$
declare
    v_template_id bigint;
    v_ticket_id bigint;

    v_tickets_before int;
    v_tickets_after int;

    v_blocks_before int;
    v_blocks_after int;

    v_block_matches_before int;
    v_block_matches_after int;

    v_history_before int;
    v_history_after int;

    v_history_updated int := 0;
begin
    -- -------------------------------------------------------------------------
    -- 0) Kontrola runu
    -- -------------------------------------------------------------------------
    select gr.template_id
      into v_template_id
    from public.generated_runs gr
    where gr.id = p_run_id;

    if v_template_id is null then
        raise exception 'mm_save_generated_run_full: run_id=% neexistuje.', p_run_id;
    end if;

    -- -------------------------------------------------------------------------
    -- 1) TICKETS
    -- -------------------------------------------------------------------------
    select count(*) into v_tickets_before
    from public.tickets
    where note = 'generated_run_id=' || p_run_id;

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
    where gr.id = p_run_id
      and not exists (
          select 1
          from public.tickets t
          where t.note = 'generated_run_id=' || gr.id
      )
    group by gr.id;

    select count(*) into v_tickets_after
    from public.tickets
    where note = 'generated_run_id=' || p_run_id;

    select t.id
      into v_ticket_id
    from public.tickets t
    where t.note = 'generated_run_id=' || p_run_id
    order by t.id desc
    limit 1;

    if v_ticket_id is null then
        raise exception 'mm_save_generated_run_full: ticket pro run_id=% nebyl vytvořen ani nalezen.', p_run_id;
    end if;

    -- -------------------------------------------------------------------------
    -- 2) TICKET_BLOCKS
    -- -------------------------------------------------------------------------
    select count(*) into v_blocks_before
    from public.ticket_blocks
    where ticket_id = v_ticket_id;

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
        select distinct block_index
        from public.generated_ticket_blocks
        where run_id = p_run_id
    ) gtb
    left join public.ticket_blocks tb
      on tb.ticket_id = v_ticket_id
     and tb.sort_order = gtb.block_index
    where tb.id is null
      and gtb.block_index between 1 and 3
    order by gtb.block_index;

    select count(*) into v_blocks_after
    from public.ticket_blocks
    where ticket_id = v_ticket_id;

    -- -------------------------------------------------------------------------
    -- 3) TICKET_BLOCK_MATCHES
    -- -------------------------------------------------------------------------
    select count(*) into v_block_matches_before
    from public.ticket_block_matches tbm
    join public.ticket_blocks tb
      on tb.id = tbm.block_id
    where tb.ticket_id = v_ticket_id;

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

    select count(*) into v_block_matches_after
    from public.ticket_block_matches tbm
    join public.ticket_blocks tb
      on tb.id = tbm.block_id
    where tb.ticket_id = v_ticket_id;

    -- -------------------------------------------------------------------------
    -- 4) HISTORY INSERT
    -- -------------------------------------------------------------------------
    select count(*) into v_history_before
    from public.ticket_history_base
    where run_id = p_run_id;

    insert into public.ticket_history_base (
        run_id,
        ticket_index,
        created_at,
        settled_at,
        source_system,
        ticket_size,
        total_odd,
        stake,
        possible_win,
        probability,
        cnt_home,
        cnt_draw,
        cnt_away,
        outcome_signature,
        odd_band,
        is_hit,
        profit_amount,
        roi_percent,
        ticket_payload,
        notes,
        sport_count,
        sport_signature,
        league_count,
        league_signature
    )
    with run_base as (
        select
            gr.id as run_id,
            gr.created_at,
            gr.template_id
        from public.generated_runs gr
        where gr.id = p_run_id
    ),
    gt as (
        select
            g.run_id,
            g.ticket_index,
            g.probability,
            g.snapshot
        from public.generated_tickets g
        where g.run_id = p_run_id
    ),
    ui as (
        select
            u.run_id,
            u.ticket_index,
            u.total_odd,
            u.items
        from public.mm_ui_run_tickets(p_run_id) u
    ),
    block_codes as (
        select
            gt.run_id,
            gt.ticket_index,
            (b->>'block')::int as block_index,
            (b->>'code')::text as outcome_code
        from gt
        cross join lateral jsonb_array_elements(gt.snapshot->'blocks') b
    ),
    outcome_agg as (
        select
            bc.run_id,
            bc.ticket_index,
            count(*)::int as ticket_size,
            count(*) filter (where bc.outcome_code = '1')::int as cnt_home,
            count(*) filter (where bc.outcome_code = 'X')::int as cnt_draw,
            count(*) filter (where bc.outcome_code = '2')::int as cnt_away,
            string_agg(bc.outcome_code, '' order by bc.block_index) as outcome_signature
        from block_codes bc
        group by bc.run_id, bc.ticket_index
    ),
    ticket_matches as (
        select
            bc.run_id,
            bc.ticket_index,
            tbm.match_id
        from block_codes bc
        join run_base rb
          on rb.run_id = bc.run_id
        join public.template_block_matches tbm
          on tbm.template_id = rb.template_id
         and tbm.block_index = bc.block_index

        union

        select
            gt.run_id,
            gt.ticket_index,
            gtf.match_id
        from gt
        join public.generated_ticket_fixed gtf
          on gtf.run_id = gt.run_id
    ),
    league_agg as (
        select
            tm.run_id,
            tm.ticket_index,
            count(distinct m.league_id)::int as league_count,
            string_agg(distinct l.name, ' | ' order by l.name) as league_signature
        from ticket_matches tm
        join public.matches m
          on m.id = tm.match_id
        join public.leagues l
          on l.id = m.league_id
        group by tm.run_id, tm.ticket_index
    ),
    final_rows as (
        select
            gt.run_id,
            gt.ticket_index,
            rb.created_at,
            'ticket_studio'::text as source_system,
            oa.ticket_size,
            ui.total_odd,
            null::numeric as stake,
            null::numeric as possible_win,
            gt.probability,
            oa.cnt_home,
            oa.cnt_draw,
            oa.cnt_away,
            oa.outcome_signature,
            case
                when ui.total_odd is null then null
                when ui.total_odd < 3 then 'LOW'
                when ui.total_odd < 6 then 'MEDIUM'
                when ui.total_odd < 10 then 'HIGH'
                else 'VERY_HIGH'
            end as odd_band,
            gt.snapshot as ticket_payload,
            'seed from generated_tickets.snapshot + mm_ui_run_tickets'::text as notes,
            1::int as sport_count,
            'UNK'::text as sport_signature,
            coalesce(la.league_count, 0) as league_count,
            la.league_signature
        from gt
        join run_base rb
          on rb.run_id = gt.run_id
        left join ui
          on ui.run_id = gt.run_id
         and ui.ticket_index = gt.ticket_index
        left join outcome_agg oa
          on oa.run_id = gt.run_id
         and oa.ticket_index = gt.ticket_index
        left join league_agg la
          on la.run_id = gt.run_id
         and la.ticket_index = gt.ticket_index
    )
    select
        fr.run_id,
        fr.ticket_index,
        fr.created_at,
        null::timestamptz,
        fr.source_system,
        fr.ticket_size,
        fr.total_odd,
        fr.stake,
        fr.possible_win,
        fr.probability,
        fr.cnt_home,
        fr.cnt_draw,
        fr.cnt_away,
        fr.outcome_signature,
        fr.odd_band,
        null::boolean,
        null::numeric,
        null::numeric,
        fr.ticket_payload,
        fr.notes,
        fr.sport_count,
        fr.sport_signature,
        fr.league_count,
        fr.league_signature
    from final_rows fr
    where not exists (
        select 1
        from public.ticket_history_base th
        where th.run_id = fr.run_id
          and th.ticket_index = fr.ticket_index
    )
    order by fr.ticket_index;

    select count(*) into v_history_after
    from public.ticket_history_base
    where run_id = p_run_id;

    -- -------------------------------------------------------------------------
    -- 5) HISTORY UPDATE
    -- -------------------------------------------------------------------------
    update public.ticket_history_base th
    set
        total_odd = u.total_odd,
        odd_band = case
            when u.total_odd is null then null
            when u.total_odd < 3 then 'LOW'
            when u.total_odd < 6 then 'MEDIUM'
            when u.total_odd < 10 then 'HIGH'
            else 'VERY_HIGH'
        end,
        notes = case
            when coalesce(th.notes, '') like '%mm_ui_run_tickets%' then th.notes
            when th.notes is null then 'seed from generated_tickets.snapshot + mm_ui_run_tickets'
            else th.notes || ' + mm_ui_run_tickets'
        end
    from public.mm_ui_run_tickets(p_run_id) u
    where th.run_id = u.run_id
      and th.ticket_index = u.ticket_index
      and th.run_id = p_run_id;

    get diagnostics v_history_updated = row_count;

    -- -------------------------------------------------------------------------
    -- 6) UPDATE HEADER TIMESTAMP
    -- -------------------------------------------------------------------------
    update public.tickets
    set updated_at = now()
    where id = v_ticket_id;

    -- -------------------------------------------------------------------------
    -- 7) RETURN
    -- -------------------------------------------------------------------------
    run_id := p_run_id;
    ticket_id := v_ticket_id;
    tickets_rows := greatest(v_tickets_after - v_tickets_before, 0);
    ticket_blocks_rows := greatest(v_blocks_after - v_blocks_before, 0);
    ticket_block_matches_rows := greatest(v_block_matches_after - v_block_matches_before, 0);
    history_inserted_rows := greatest(v_history_after - v_history_before, 0);
    history_updated_rows := coalesce(v_history_updated, 0);
    status_text := 'OK';

    return next;
end;
$$;