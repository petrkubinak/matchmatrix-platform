create or replace view ml_match_dataset as
select
    m.id as match_id,
    m.league_id,
    m.kickoff,

    -- ===== RATING FEATURES (NOVÉ) =====
    mr.home_rating,
    mr.away_rating,
    mr.rating_diff,

    -- ===== FORM FEATURES =====
    f.home_last5_points,
    f.away_last5_points,
    f.home_last5_gf,
    f.home_last5_ga,
    f.away_last5_gf,
    f.away_last5_ga,
    f.home_rest_days,
    f.away_rest_days,
    f.h2h_last5_goal_diff,

    -- ===== LABEL =====
    case
        when m.home_score > m.away_score then 1
        when m.home_score < m.away_score then -1
        else 0
    end as result_label

from matches m
join match_features f 
    on f.match_id = m.id

join mm_match_ratings mr
    on mr.match_id = m.id

where m.status = 'FINISHED';

