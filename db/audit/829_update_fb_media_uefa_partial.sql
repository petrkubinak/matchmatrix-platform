-- 829_update_fb_media_uefa_partial.sql
-- UEFA / FB media audit after official site inspect

UPDATE ops.runtime_entity_audit
SET
    current_state = 'PARTIAL',
    pull_confirmed = true,
    raw_confirmed = false,
    staging_confirmed = false,
    public_merge_confirmed = false,
    downstream_confirmed = false,
    last_check_at = now(),
    db_evidence_summary =
        'UEFA official_site HTTP 200, but inspected page returns navigation links only; no article URLs found by static scraper.',
    next_action =
        'Create UEFA-specific scraper or use alternate source/API. Current generic official_site worker is not enough.',
    audit_note =
        'FB MEDIA source validation partial; source reachable but requires special worker.'
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'articles';

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    staging_confirmed,
    public_merge_confirmed,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'articles';