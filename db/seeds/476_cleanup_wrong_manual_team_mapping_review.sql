-- 476_cleanup_wrong_manual_team_mapping_review.sql
-- Smaže jen chybné review páry z prvního batch.
-- Správné páry ponechá.

DELETE FROM public.canonical_team_map
WHERE provider = 'api_football'
  AND status = 'review'
  AND (
       (canonical_team_id = 84 AND provider_team_id = 75)
    OR (canonical_team_id = 55 AND provider_team_id = 50)
    OR (canonical_team_id = 89 AND provider_team_id = 85)
    OR (canonical_team_id = 26 AND provider_team_id = 63)
    OR (canonical_team_id = 41 AND provider_team_id = 70)
    OR (canonical_team_id = 87 AND provider_team_id = 91)
    OR (canonical_team_id = 99 AND provider_team_id = 90)
    OR (canonical_team_id = 29 AND provider_team_id = 60)
  );

-- kontrola: review mapy po cleanupu
SELECT
    ctm.canonical_team_id,
    t1.name AS canonical_team_name,
    ctm.provider,
    ctm.provider_team_id,
    t2.name AS provider_team_name,
    ctm.status,
    ctm.note
FROM public.canonical_team_map ctm
LEFT JOIN public.teams t1
       ON t1.id = ctm.canonical_team_id
LEFT JOIN public.teams t2
       ON t2.id = ctm.provider_team_id
WHERE ctm.provider = 'api_football'
  AND ctm.status = 'review'
ORDER BY t1.name, t2.name;