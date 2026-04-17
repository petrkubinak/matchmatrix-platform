-- =====================================================================================
-- SOUBOR: 334_update_ticket_history_from_generated_run.sql
-- KAM ULOŽIT: C:\MatchMatrix-platform\db\sql\334_update_ticket_history_from_generated_run.sql
-- ÚČEL:
--   Doplní existující řádky v public.ticket_history_base pro jeden generated run:
--   - total_odd
--   - odd_band
--   - notes
-- =====================================================================================

do
$$
declare
    v_run_id bigint := 97;   -- <<< ZDE NASTAV RUN ID
begin
    if not exists (
        select 1
        from public.ticket_history_base th
        where th.run_id = v_run_id
    ) then
        raise exception 'HISTORY UPDATE: v ticket_history_base neexistují řádky pro run_id=%', v_run_id;
    end if;

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
    from public.mm_ui_run_tickets(v_run_id) u
    where th.run_id = u.run_id
      and th.ticket_index = u.ticket_index
      and th.run_id = v_run_id;

    raise notice 'HISTORY UPDATE HOTOVO | run_id=%', v_run_id;
end
$$;