-- =====================================================
-- VIEW: 15_v_best_ticket_candidates_today
-- Nejlepší kandidáti pro nejbližší dny
-- =====================================================

create or replace view public.v_best_ticket_candidates_today as
select
    c.*
from public.vw_ticket_candidates c
where c.match_date >= now()
  and c.match_date < now() + interval '3 day'
  and c.selected_odd between 1.45 and 3.50
  and c.model_probability >= 0.35
  and c.selected_edge >= 0.05
  and c.selected_ev > 0
order by
    c.candidate_score desc,
    c.selected_edge desc,
    c.selected_ev desc,
    c.model_probability desc;