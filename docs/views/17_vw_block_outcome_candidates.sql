-- =====================================================
-- VIEW: 17_vw_block_outcome_candidates
-- Kandidáti zápasů pro bloky 1 / X / 2
--
-- Cíl:
--   pro každý zápas spočítat vhodnost do bloku:
--   - blok 1
--   - blok X
--   - blok 2
--
-- Logika:
--   block_score_* kombinuje:
--   - model probability
--   - edge
--   - EV
--   - odd bonus (vyšší kurz je zajímavý pro blok)
--
-- Poznámka:
--   tohle není finální tiket.
--   je to vrstva pro další skládání blokových trojic.
-- =====================================================

create or replace view public.vw_block_outcome_candidates as
select
    v.match_id,
    v.league_id,
    v.match_date,
    v.home_team,
    v.away_team,

    -- Odds 1X2
    v.odds_home as odds_1,
    v.odds_draw as odds_x,
    v.odds_away as odds_2,

    -- Model probabilities
    v.model_p_home as model_p_1,
    v.model_p_draw as model_p_x,
    v.model_p_away as model_p_2,

    -- Bookmaker implied probabilities
    v.book_p_home as book_p_1,
    v.book_p_draw as book_p_x,
    v.book_p_away as book_p_2,

    -- Edge
    v.edge_home as edge_1,
    v.edge_draw as edge_x,
    v.edge_away as edge_2,

    -- EV
    case
        when v.odds_home > 0 then (v.model_p_home * v.odds_home) - 1
        else null
    end as ev_1,

    case
        when v.odds_draw > 0 then (v.model_p_draw * v.odds_draw) - 1
        else null
    end as ev_x,

    case
        when v.odds_away > 0 then (v.model_p_away * v.odds_away) - 1
        else null
    end as ev_2,

    -- -------------------------------------------------
    -- BLOCK SCORE 1
    -- Váhy:
    --   45 % model probability
    --   30 % edge
    --   20 % EV
    --   05 % odd bonus
    --
    -- odd bonus:
    --   pro blok chceme rozumně vyšší kurz,
    --   ale ne extrémní nesmysly
    -- -------------------------------------------------
    (
        coalesce(v.model_p_home, 0) * 0.45
        +
        coalesce(v.edge_home, 0) * 0.30
        +
        coalesce(
            case when v.odds_home > 0 then (v.model_p_home * v.odds_home) - 1 else 0 end,
            0
        ) * 0.20
        +
        coalesce(
            case
                when v.odds_home between 2.10 and 4.20 then (v.odds_home - 2.10) / 10.0
                else 0
            end,
            0
        ) * 0.05
    ) as block_score_1,

    -- BLOCK SCORE X
    (
        coalesce(v.model_p_draw, 0) * 0.45
        +
        coalesce(v.edge_draw, 0) * 0.30
        +
        coalesce(
            case when v.odds_draw > 0 then (v.model_p_draw * v.odds_draw) - 1 else 0 end,
            0
        ) * 0.20
        +
        coalesce(
            case
                when v.odds_draw between 2.40 and 5.50 then (v.odds_draw - 2.40) / 10.0
                else 0
            end,
            0
        ) * 0.05
    ) as block_score_x,

    -- BLOCK SCORE 2
    (
        coalesce(v.model_p_away, 0) * 0.45
        +
        coalesce(v.edge_away, 0) * 0.30
        +
        coalesce(
            case when v.odds_away > 0 then (v.model_p_away * v.odds_away) - 1 else 0 end,
            0
        ) * 0.20
        +
        coalesce(
            case
                when v.odds_away between 2.10 and 4.20 then (v.odds_away - 2.10) / 10.0
                else 0
            end,
            0
        ) * 0.05
    ) as block_score_2,

    -- Nejlepší outcome pro blokové použití
    case
        when coalesce(
                 (
                     coalesce(v.model_p_home, 0) * 0.45
                     + coalesce(v.edge_home, 0) * 0.30
                     + coalesce(case when v.odds_home > 0 then (v.model_p_home * v.odds_home) - 1 else 0 end, 0) * 0.20
                     + coalesce(case when v.odds_home between 2.10 and 4.20 then (v.odds_home - 2.10) / 10.0 else 0 end, 0) * 0.05
                 ),
                 -999
             )
             >= greatest(
                 coalesce(
                     (
                         coalesce(v.model_p_home, 0) * 0.45
                         + coalesce(v.edge_home, 0) * 0.30
                         + coalesce(case when v.odds_home > 0 then (v.model_p_home * v.odds_home) - 1 else 0 end, 0) * 0.20
                         + coalesce(case when v.odds_home between 2.10 and 4.20 then (v.odds_home - 2.10) / 10.0 else 0 end, 0) * 0.05
                     ),
                     -999
                 ),
                 coalesce(
                     (
                         coalesce(v.model_p_draw, 0) * 0.45
                         + coalesce(v.edge_draw, 0) * 0.30
                         + coalesce(case when v.odds_draw > 0 then (v.model_p_draw * v.odds_draw) - 1 else 0 end, 0) * 0.20
                         + coalesce(case when v.odds_draw between 2.40 and 5.50 then (v.odds_draw - 2.40) / 10.0 else 0 end, 0) * 0.05
                     ),
                     -999
                 ),
                 coalesce(
                     (
                         coalesce(v.model_p_away, 0) * 0.45
                         + coalesce(v.edge_away, 0) * 0.30
                         + coalesce(case when v.odds_away > 0 then (v.model_p_away * v.odds_away) - 1 else 0 end, 0) * 0.20
                         + coalesce(case when v.odds_away between 2.10 and 4.20 then (v.odds_away - 2.10) / 10.0 else 0 end, 0) * 0.05
                     ),
                     -999
                 )
             )
        then '1'

        when coalesce(
                 (
                     coalesce(v.model_p_draw, 0) * 0.45
                     + coalesce(v.edge_draw, 0) * 0.30
                     + coalesce(case when v.odds_draw > 0 then (v.model_p_draw * v.odds_draw) - 1 else 0 end, 0) * 0.20
                     + coalesce(case when v.odds_draw between 2.40 and 5.50 then (v.odds_draw - 2.40) / 10.0 else 0 end, 0) * 0.05
                 ),
                 -999
             )
             >= greatest(
                 coalesce(
                     (
                         coalesce(v.model_p_home, 0) * 0.45
                         + coalesce(v.edge_home, 0) * 0.30
                         + coalesce(case when v.odds_home > 0 then (v.model_p_home * v.odds_home) - 1 else 0 end, 0) * 0.20
                         + coalesce(case when v.odds_home between 2.10 and 4.20 then (v.odds_home - 2.10) / 10.0 else 0 end, 0) * 0.05
                     ),
                     -999
                 ),
                 coalesce(
                     (
                         coalesce(v.model_p_draw, 0) * 0.45
                         + coalesce(v.edge_draw, 0) * 0.30
                         + coalesce(case when v.odds_draw > 0 then (v.model_p_draw * v.odds_draw) - 1 else 0 end, 0) * 0.20
                         + coalesce(case when v.odds_draw between 2.40 and 5.50 then (v.odds_draw - 2.40) / 10.0 else 0 end, 0) * 0.05
                     ),
                     -999
                 ),
                 coalesce(
                     (
                         coalesce(v.model_p_away, 0) * 0.45
                         + coalesce(v.edge_away, 0) * 0.30
                         + coalesce(case when v.odds_away > 0 then (v.model_p_away * v.odds_away) - 1 else 0 end, 0) * 0.20
                         + coalesce(case when v.odds_away between 2.10 and 4.20 then (v.odds_away - 2.10) / 10.0 else 0 end, 0) * 0.05
                     ),
                     -999
                 )
             )
        then 'X'

        else '2'
    end as best_block_outcome

from public.mm_value_bets v
where v.match_date >= now()
  and v.match_date < now() + interval '7 day'
  and v.odds_home is not null
  and v.odds_draw is not null
  and v.odds_away is not null;