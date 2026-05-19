-- jen logika, ne ALTER (sloupce už máš)

UPDATE ops.provider_people_audit
SET
    next_step = CASE
        WHEN final_verdict = 'PUBLIC_CONFIRMED'
            THEN 'Rozšířit ingest_targets na další league/team scope + batch ingest.'
        WHEN final_verdict = 'STAGING_CONFIRMED'
            THEN 'Čeká na public model (coaches) nebo mapping.'
        WHEN final_verdict LIKE 'ENDPOINT%'
            THEN 'Čeká na implementaci parser + merge.'
        ELSE next_step
    END,
    updated_at = now()
WHERE provider IN ('api_football','api_american_football')
  AND sport_code IN ('FB','AFB')
  AND entity IN ('players','coaches');