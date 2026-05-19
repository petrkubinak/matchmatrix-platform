-- 809_update_hk_media_runtime_audit.sql
-- NHL/HK MEDIA runtime audit update

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
        'official_site scraper OK | NHL official_site HTTP 200 | staging.stg_media_articles=65 | public.articles=65',
    next_action =
        'Expand official_site media scraper to other providers/sports and add article mapping layer.',
    audit_note =
        'MEDIA layer first successful official_site ingest confirmed for NHL.'
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
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
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'highlights';