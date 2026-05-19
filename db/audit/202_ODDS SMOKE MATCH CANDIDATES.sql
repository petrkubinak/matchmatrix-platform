-- 99_playground / ODDS SMOKE MATCH CANDIDATES

SELECT
    m.id AS match_id,
    m.sport_id,
    s.code AS sport_code,
    m.ext_source,
    m.ext_match_id,
    m.kickoff,
    m.status
FROM public.matches m
JOIN public.sports s ON s.id = m.sport_id
WHERE s.code IN ('FB','HK','BK','HB','BSB','RGB','AFB','CK','VB')
  AND m.status IN ('SCHEDULED','LIVE','FINISHED')
ORDER BY m.kickoff DESC
LIMIT 50;