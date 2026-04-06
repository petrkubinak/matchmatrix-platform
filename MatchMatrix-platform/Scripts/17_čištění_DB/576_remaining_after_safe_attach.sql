SELECT
    provider,
    league_name,
    event_name,
    home_raw,
    away_raw,
    best_home_candidate,
    best_away_candidate,
    best_home_score,
    best_away_score,
    match_id,
    issue_code
FROM public.unmatched_theodds
WHERE COALESCE(match_id, '') = ''
ORDER BY league_name, event_name;