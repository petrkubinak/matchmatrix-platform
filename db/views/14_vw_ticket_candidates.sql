-- =====================================================
-- VIEW: 14_vw_ticket_candidates
-- První verze kandidátů pro Ticket Optimizer
-- Zdroj: public.mm_value_bets
-- Logika:
--   - vezme doporučený pick
--   - přiřadí správný kurz / probability / edge
--   - spočítá EV
--   - připraví score pro řazení kandidátů
-- =====================================================

create or replace view public.vw_ticket_candidates as
select
    v.match_id,
    v.league_id,
    v.match_date,
    v.home_team,
    v.away_team,
    v.recommended_pick,

    -- model probability podle doporučeného picku
    case v.recommended_pick
        when '1' then v.model_p_home
        when 'X' then v.model_p_draw
        when '2' then v.model_p_away
    end as model_probability,

    -- bookmaker probability podle doporučeného picku
    case v.recommended_pick
        when '1' then v.book_p_home
        when 'X' then v.book_p_draw
        when '2' then v.book_p_away
    end as bookmaker_probability,

    -- kurz podle doporučeného picku
    case v.recommended_pick
        when '1' then v.odds_home
        when 'X' then v.odds_draw
        when '2' then v.odds_away
    end as selected_odd,

    -- edge podle doporučeného picku
    case v.recommended_pick
        when '1' then v.edge_home
        when 'X' then v.edge_draw
        when '2' then v.edge_away
    end as selected_edge,

    -- expected value
    case v.recommended_pick
        when '1' then (v.model_p_home * v.odds_home) - 1
        when 'X' then (v.model_p_draw * v.odds_draw) - 1
        when '2' then (v.model_p_away * v.odds_away) - 1
    end as selected_ev,

    -- jednoduché skóre kandidáta pro první MVP
    (
        coalesce(
            case v.recommended_pick
                when '1' then v.edge_home
                when 'X' then v.edge_draw
                when '2' then v.edge_away
            end,
            0
        ) * 0.60
        +
        coalesce(
            case v.recommended_pick
                when '1' then (v.model_p_home * v.odds_home) - 1
                when 'X' then (v.model_p_draw * v.odds_draw) - 1
                when '2' then (v.model_p_away * v.odds_away) - 1
            end,
            0
        ) * 0.40
    ) as candidate_score

from public.mm_value_bets v
where v.recommended_pick is not null;