-- =====================================================
-- VIEW: 19_vw_block_candidate_groups
--
-- Kandidátní bloky (2 zápasy v bloku)
-- Zápasy musí mít stejný synchronizační outcome
--
-- Výstup:
--   block_outcome (1/X/2)
--   match_a
--   match_b
--   combined_odds
--   combined_score
--
-- Později:
--   z těchto bloků budeme stavět 3 bloky → 27 tiketů
-- =====================================================

create or replace view public.vw_block_candidate_groups as

select
    a.sync_outcome as block_outcome,

    a.match_id as match_a_id,
    a.home_team as match_a_home,
    a.away_team as match_a_away,

    b.match_id as match_b_id,
    b.home_team as match_b_home,
    b.away_team as match_b_away,

    -- odds podle outcome
    case
        when a.sync_outcome = '1' then a.odds_1
        when a.sync_outcome = 'X' then a.odds_x
        else a.odds_2
    end as odds_a,

    case
        when b.sync_outcome = '1' then b.odds_1
        when b.sync_outcome = 'X' then b.odds_x
        else b.odds_2
    end as odds_b,

    -- kombinovaný kurz
    (
        case
            when a.sync_outcome = '1' then a.odds_1
            when a.sync_outcome = 'X' then a.odds_x
            else a.odds_2
        end
        *
        case
            when b.sync_outcome = '1' then b.odds_1
            when b.sync_outcome = 'X' then b.odds_x
            else b.odds_2
        end
    ) as combined_odds,

    -- synchronizační skóre
    a.final_sync_score as score_a,
    b.final_sync_score as score_b,

    -- celkové skóre bloku
    (a.final_sync_score + b.final_sync_score) as combined_score,

    a.sync_reason_code as reason_a,
    b.sync_reason_code as reason_b,

    a.match_date as match_a_date,
    b.match_date as match_b_date

from public.vw_block_sync_signals a
join public.vw_block_sync_signals b
    on a.sync_outcome = b.sync_outcome
   and a.match_id < b.match_id

where

    -- nechceme stejnou ligu
    a.league_id <> b.league_id

    -- chceme rozumné skóre synchronizace
    and a.final_sync_score > 0.25
    and b.final_sync_score > 0.25

    -- nechceme extrémní kurzy
    and (
        case
            when a.sync_outcome = '1' then a.odds_1
            when a.sync_outcome = 'X' then a.odds_x
            else a.odds_2
        end
    ) between 1.6 and 6.0

    and (
        case
            when b.sync_outcome = '1' then b.odds_1
            when b.sync_outcome = 'X' then b.odds_x
            else b.odds_2
        end
    ) between 1.6 and 6.0;