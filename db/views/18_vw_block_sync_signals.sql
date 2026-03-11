-- =====================================================
-- VIEW: 18_vw_block_sync_signals
-- V1 synchronizační signály pro bloky 1 / X / 2
--
-- Cíl:
--   nepoužívat jen čistý outcome score,
--   ale i "důvodový profil" zápasu:
--   - favorit vs outsider
--   - vyrovnanost zápasu
--   - možný upset
--   - domácí křehkost
--   - hostující křehkost
--
-- Poznámka:
--   Tohle je V1 a běží jen nad tím, co už teď máme:
--   - mm_value_bets
--   - block outcome kandidáty
--
--   Až doplníme další ingest vrstvy, nahradíme / rozšíříme:
--   - injury signals
--   - suspensions
--   - recent form
--   - lineup absences
--   - congested schedule
-- =====================================================

create or replace view public.vw_block_sync_signals as
with base as (
    select
        b.match_id,
        b.league_id,
        b.match_date,
        b.home_team,
        b.away_team,

        b.odds_1,
        b.odds_x,
        b.odds_2,

        b.model_p_1,
        b.model_p_x,
        b.model_p_2,

        b.book_p_1,
        b.book_p_x,
        b.book_p_2,

        b.edge_1,
        b.edge_x,
        b.edge_2,

        b.ev_1,
        b.ev_x,
        b.ev_2,

        b.block_score_1,
        b.block_score_x,
        b.block_score_2,
        b.best_block_outcome,

        -- rozdíl modelu mezi 1 a 2 = míra náklonu zápasu
        abs(coalesce(b.model_p_1, 0) - coalesce(b.model_p_2, 0)) as model_12_gap,

        -- rozdíl kurzů 1 a 2 = jak moc je trh vychýlený
        abs(coalesce(b.odds_1, 0) - coalesce(b.odds_2, 0)) as odds_12_gap,

        -- celková vyrovnanost trhu
        greatest(coalesce(b.odds_1, 0), coalesce(b.odds_x, 0), coalesce(b.odds_2, 0))
        - least(coalesce(b.odds_1, 9999), coalesce(b.odds_x, 9999), coalesce(b.odds_2, 9999)) as odds_spread_1x2

    from public.vw_block_outcome_candidates b
),

signals as (
    select
        x.*,

        -- -------------------------------------------------
        -- 1) DRAW PROFILE
        -- vyšší, pokud:
        -- - model připouští remízu
        -- - trh je relativně vyrovnaný
        -- - draw edge / EV nejsou špatné
        -- -------------------------------------------------
        (
            coalesce(x.model_p_x, 0) * 0.45
            +
            coalesce(x.edge_x, 0) * 0.25
            +
            coalesce(x.ev_x, 0) * 0.15
            +
            case
                when x.odds_spread_1x2 <= 1.20 then 0.10
                when x.odds_spread_1x2 <= 1.80 then 0.05
                else 0
            end
            +
            case
                when x.odds_x between 2.80 and 4.20 then 0.05
                else 0
            end
        ) as draw_sync_score,

        -- -------------------------------------------------
        -- 2) HOME UPSET / HOME SURGE
        -- vhodné pro blok 1:
        -- - buď je domácí favorit
        -- - nebo je tam zajímavý edge/EV na 1
        -- - nebo jde o solidní domácí překvapení
        -- -------------------------------------------------
        (
            coalesce(x.model_p_1, 0) * 0.40
            +
            coalesce(x.edge_1, 0) * 0.25
            +
            coalesce(x.ev_1, 0) * 0.20
            +
            case
                when x.odds_1 between 1.70 and 3.40 then 0.10
                when x.odds_1 > 3.40 and x.edge_1 > 0 then 0.06
                else 0
            end
            +
            case
                when x.model_p_1 > x.model_p_2 then 0.05
                else 0
            end
        ) as home_sync_score,

        -- -------------------------------------------------
        -- 3) AWAY UPSET / AWAY PRESSURE
        -- vhodné pro blok 2:
        -- - host má value
        -- - nebo je domácí přeceněný
        -- - nebo kurz 2 je zajímavý pro blok
        -- -------------------------------------------------
        (
            coalesce(x.model_p_2, 0) * 0.40
            +
            coalesce(x.edge_2, 0) * 0.25
            +
            coalesce(x.ev_2, 0) * 0.20
            +
            case
                when x.odds_2 between 1.90 and 3.80 then 0.10
                when x.odds_2 > 3.80 and x.edge_2 > 0 then 0.06
                else 0
            end
            +
            case
                when x.model_p_2 > x.model_p_1 then 0.05
                else 0
            end
        ) as away_sync_score,

        -- -------------------------------------------------
        -- 4) DOMÁCÍ KŘEHKOST
        -- pomocný signál:
        -- vysoký, pokud:
        -- - edge na 2 je kladný
        -- - EV na 2 je kladné
        -- - domácí nejsou modelem silní
        -- -------------------------------------------------
        (
            case when coalesce(x.edge_2, 0) > 0 then coalesce(x.edge_2, 0) else 0 end * 0.40
            +
            case when coalesce(x.ev_2, 0) > 0 then coalesce(x.ev_2, 0) else 0 end * 0.30
            +
            case when coalesce(x.model_p_1, 0) < 0.42 then 0.15 else 0 end
            +
            case when x.odds_1 < x.odds_2 then 0.15 else 0 end
        ) as home_fragility_score,

        -- -------------------------------------------------
        -- 5) HOSTUJÍCÍ KŘEHKOST
        -- pomocný signál pro blok 1
        -- -------------------------------------------------
        (
            case when coalesce(x.edge_1, 0) > 0 then coalesce(x.edge_1, 0) else 0 end * 0.40
            +
            case when coalesce(x.ev_1, 0) > 0 then coalesce(x.ev_1, 0) else 0 end * 0.30
            +
            case when coalesce(x.model_p_2, 0) < 0.42 then 0.15 else 0 end
            +
            case when x.odds_2 < x.odds_1 then 0.15 else 0 end
        ) as away_fragility_score,

        -- -------------------------------------------------
        -- 6) OPEN MATCH SCORE
        -- zápas je otevřený / "scénářový"
        -- vhodný pro blokovou práci obecně
        -- -------------------------------------------------
        (
            case when x.odds_spread_1x2 <= 1.20 then 0.35
                 when x.odds_spread_1x2 <= 1.80 then 0.20
                 else 0
            end
            +
            case when x.odds_1 >= 2.20 then 0.10 else 0 end
            +
            case when x.odds_x >= 3.00 then 0.10 else 0 end
            +
            case when x.odds_2 >= 2.20 then 0.10 else 0 end
            +
            case when x.model_p_x >= 0.25 then 0.10 else 0 end
            +
            case when x.model_12_gap <= 0.12 then 0.25
                 when x.model_12_gap <= 0.20 then 0.10
                 else 0
            end
        ) as open_match_score

    from base x
)

select
    s.match_id,
    s.league_id,
    s.match_date,
    s.home_team,
    s.away_team,

    s.odds_1,
    s.odds_x,
    s.odds_2,

    s.model_p_1,
    s.model_p_x,
    s.model_p_2,

    s.edge_1,
    s.edge_x,
    s.edge_2,

    s.ev_1,
    s.ev_x,
    s.ev_2,

    s.block_score_1,
    s.block_score_x,
    s.block_score_2,
    s.best_block_outcome,

    -- synchronizační signály
    s.home_sync_score,
    s.draw_sync_score,
    s.away_sync_score,
    s.home_fragility_score,
    s.away_fragility_score,
    s.open_match_score,

    -- textové důvody pro pozdější analýzu
    case
        when s.away_sync_score >= greatest(s.home_sync_score, s.draw_sync_score, s.away_sync_score)
             and s.home_fragility_score >= 0.18
        then 'HOME_FRAGILITY'

        when s.home_sync_score >= greatest(s.home_sync_score, s.draw_sync_score, s.away_sync_score)
             and s.away_fragility_score >= 0.18
        then 'AWAY_FRAGILITY'

        when s.draw_sync_score >= greatest(s.home_sync_score, s.draw_sync_score, s.away_sync_score)
             and s.open_match_score >= 0.35
        then 'OPEN_BALANCED_MATCH'

        when s.away_sync_score >= greatest(s.home_sync_score, s.draw_sync_score, s.away_sync_score)
        then 'AWAY_SCENARIO'

        when s.home_sync_score >= greatest(s.home_sync_score, s.draw_sync_score, s.away_sync_score)
        then 'HOME_SCENARIO'

        else 'DRAW_SCENARIO'
    end as sync_reason_code,

    -- doporučený synchronizační outcome
    case
        when s.home_sync_score >= greatest(s.home_sync_score, s.draw_sync_score, s.away_sync_score) then '1'
        when s.draw_sync_score >= greatest(s.home_sync_score, s.draw_sync_score, s.away_sync_score) then 'X'
        else '2'
    end as sync_outcome,

    -- finální sync score podle doporučeného scénáře
    greatest(s.home_sync_score, s.draw_sync_score, s.away_sync_score) as final_sync_score,

    -- -------------------------------------------------
    -- Placeholder sloupce pro budoucí rozšíření
    -- -------------------------------------------------
    null::numeric as injury_pressure_home,
    null::numeric as injury_pressure_away,
    null::numeric as recent_form_home,
    null::numeric as recent_form_away,
    null::numeric as schedule_fatigue_home,
    null::numeric as schedule_fatigue_away

from signals s;