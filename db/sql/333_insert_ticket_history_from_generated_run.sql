-- =====================================================================================
-- SOUBOR: 330_insert_ticket_history_from_generated_run.sql
-- KAM ULOŽIT: C:\MatchMatrix-platform\db\sql\330_insert_ticket_history_from_generated_run.sql
-- ÚČEL:
--   Naplní public.ticket_history_base z runtime vrstvy pro jeden generated run.
--
-- ZDROJ:
--   - public.generated_runs
--   - public.generated_tickets
--   - public.mm_ui_run_tickets(run_id)
--   - public.template_block_matches
--   - public.generated_ticket_fixed
--   - public.matches / public.leagues
--
-- POZNÁMKA:
--   - skript je idempotentní pro kombinaci (run_id, ticket_index)
--   - neřeší zatím settlement (is_hit / roi / profit) => zůstává NULL
--   - sport_signature zatím nastavuje na 'UNK'
-- =====================================================================================

do
$$
declare
    v_run_id bigint := 97;   -- <<< ZDE VŽDY NASTAV RUN ID
begin
    if not exists (
        select 1
        from public.generated_runs gr
        where gr.id = v_run_id
    ) then
        raise exception 'HISTORY INSERT: generated_run_id=% neexistuje.', v_run_id;
    end if;

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
        where gr.id = v_run_id
    ),

    gt as (
        select
            g.run_id,
            g.ticket_index,
            g.probability,
            g.snapshot
        from public.generated_tickets g
        where g.run_id = v_run_id
    ),

    ui as (
        select
            u.run_id,
            u.ticket_index,
            u.total_odd,
            u.items
        from public.mm_ui_run_tickets(v_run_id) u
    ),

    -- blokové kódy ze snapshotu
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

    -- všechny relevantní match_id pro ticket:
    -- variable bloky + fixed picks
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
        null::timestamptz as settled_at,
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
        null::boolean as is_hit,
        null::numeric as profit_amount,
        null::numeric as roi_percent,
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

    raise notice 'HISTORY INSERT HOTOVO | run_id=%', v_run_id;
end
$$;