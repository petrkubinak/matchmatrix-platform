SELECT *
FROM public.vw_match_feed_for_user
WHERE match_date >= NOW()
  AND recommended_pick IS NOT NULL
ORDER BY best_edge DESC, match_date ASC
LIMIT 100;