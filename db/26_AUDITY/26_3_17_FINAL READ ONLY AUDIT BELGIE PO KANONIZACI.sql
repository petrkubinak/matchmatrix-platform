-- MATCHMATRIX
-- 26_3_17_FINAL READ ONLY AUDIT BELGIE PO KANONIZACI

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SET LOCAL TIME ZONE 'UTC';

WITH last_group AS (
    SELECT m.id, m.league_id, m.home_team_id, m.away_team_id, m.kickoff
    FROM public.matches m
    WHERE m.sport_id = 1
      AND m.league_id = 20853
      AND m.ext_source = 'football_data_uk'
      AND (m.home_team_id IN (986,988) OR m.away_team_id IN (986,988))
)
SELECT 'BELGIUM_FINAL' AS sekce,
       'LEGACY_MATCHES_REMAINING' AS kontrola,
       CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'REVIEW_REQUIRED' END AS stav,
       0::bigint AS ocekavano,
       COUNT(*)::bigint AS skutecnost
FROM public.matches
WHERE sport_id = 1 AND league_id = 4 AND ext_source = 'football_data_uk'

UNION ALL
SELECT 'BELGIUM_FINAL','CANONICAL_LAST_121',
       CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
       121, COUNT(*)::bigint
FROM last_group

UNION ALL
SELECT 'BELGIUM_FINAL','API_IDENTITIES_737_743',
       CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
       2, COUNT(*)::bigint
FROM public.team_provider_map
WHERE provider='api_football'
  AND ((team_id=986 AND provider_team_id='743')
    OR (team_id=988 AND provider_team_id='737'))

UNION ALL
SELECT 'BELGIUM_FINAL','LOKEREN_TEMSE_SEPARATE_IDENTITY',
       CASE WHEN COUNT(*) = 1 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
       1, COUNT(*)::bigint
FROM public.team_provider_map
WHERE team_id=12819 AND provider='api_football' AND provider_team_id='14128'

UNION ALL
SELECT 'DOWNSTREAM','LAST_GROUP_MATCH_FEATURE_ROWS',
       CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
       121, COUNT(*)::bigint
FROM public.match_features f
JOIN last_group g ON g.id=f.match_id

UNION ALL
SELECT 'DOWNSTREAM','LAST_GROUP_RATING_DIMENSIONS_ALIGNED',
       CASE WHEN COUNT(*) = 121 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
       121, COUNT(*)::bigint
FROM public.mm_match_ratings r
JOIN last_group g ON g.id=r.match_id
WHERE r.league_id=g.league_id
  AND r.home_team_id=g.home_team_id
  AND r.away_team_id=g.away_team_id
  AND r.kickoff IS NOT DISTINCT FROM g.kickoff

UNION ALL
SELECT 'GLOBAL','MATCH_COUNT',
       CASE WHEN COUNT(*) = 120981 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
       120981, COUNT(*)::bigint
FROM public.matches

UNION ALL
SELECT 'GLOBAL','MATCH_PROVIDER_MAP_COUNT',
       CASE WHEN COUNT(*) = 121908 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
       121908, COUNT(*)::bigint
FROM public.match_provider_map

UNION ALL
SELECT 'GLOBAL','GLOBAL_RATING_ORPHANS',
       CASE WHEN COUNT(*) = 78794 THEN 'OK' ELSE 'REVIEW_REQUIRED' END,
       78794, COUNT(*)::bigint
FROM public.mm_match_ratings r
LEFT JOIN public.matches m ON m.id=r.match_id
WHERE m.id IS NULL;

WITH final_state AS (
    SELECT
      (SELECT COUNT(*) FROM public.matches
       WHERE sport_id=1 AND league_id=4 AND ext_source='football_data_uk') AS legacy_remaining,
      (SELECT COUNT(*) FROM public.matches
       WHERE sport_id=1 AND league_id=20853 AND ext_source='football_data_uk'
         AND (home_team_id IN (986,988) OR away_team_id IN (986,988))) AS final_121,
      (SELECT COUNT(*) FROM public.team_provider_map
       WHERE provider='api_football'
         AND ((team_id=986 AND provider_team_id='743')
           OR (team_id=988 AND provider_team_id='737'))) AS api_ids,
      (SELECT COUNT(*) FROM public.team_provider_map
       WHERE team_id=12819 AND provider='api_football' AND provider_team_id='14128') AS lokeren_temse
)
SELECT 'ZAVER' AS sekce,
       'BELGIUM_CANONICALIZATION_FINAL_STATUS' AS kontrola,
       CASE WHEN legacy_remaining=0 AND final_121=121 AND api_ids=2 AND lokeren_temse=1
            THEN 'BELGIUM_CANONICALIZATION_COMPLETE'
            ELSE 'BELGIUM_CANONICALIZATION_REVIEW_REQUIRED' END AS stav,
       121::bigint AS ocekavano,
       final_121::bigint AS skutecnost
FROM final_state;

ROLLBACK;