-- 819_update_bk_media_runtime_audit.sql
-- NBA/BK MEDIA runtime audit update

UPDATE ops.runtime_entity_audit
SET
    current_state = 'PARTIAL',
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_check_at = now(),
    db_evidence_summary =
        'official_site scraper OK | NBA official_site HTTP 200 | public.articles merged successfully',
    next_action =
        'Create NBA alias rules and downstream media mappings.',
    audit_note =
        'MEDIA layer first successful official_site ingest confirmed for NBA.'
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'highlights';

-- kontrola
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    staging_confirmed,
    public_merge_confirmed,
    db_evidence_summary
FROM ops.runtime_entity_audit
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'highlights';