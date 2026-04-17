SELECT
    COUNT(*) AS unmatched_odds_rows
FROM public.odds
WHERE match_id IS NULL;