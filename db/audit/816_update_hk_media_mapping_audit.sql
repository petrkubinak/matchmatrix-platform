-- 816_update_hk_media_mapping_audit.sql

UPDATE ops.runtime_entity_audit
SET
    downstream_confirmed = true,
    last_check_at = now(),
    db_evidence_summary =
        'official_site scraper OK | NHL HTTP 200 | staging=65 | public.articles=65 | article_media_team_alias_map OK',
    next_action =
        'Expand NHL alias rules and later connect aliases to canonical public.teams when NHL core team coverage is complete.',
    audit_note =
        'MEDIA layer PARTIAL confirmed including article -> media team alias mapping.'
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'highlights';

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    staging_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    db_evidence_summary
FROM ops.runtime_entity_audit
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'highlights';