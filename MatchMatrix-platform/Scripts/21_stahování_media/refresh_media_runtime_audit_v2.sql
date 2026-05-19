-- refresh_media_runtime_audit_v2.sql
-- Refresh MEDIA OPS audit po opravě coverage view.

UPDATE ops.runtime_entity_audit rea
SET
    current_state = 'PARTIAL',
    state_reason =
        'MEDIA layer production-ready pro league/team/player feeds. Match linking čeká na canonical NBA/NHL fixtures coverage.',

    db_evidence_summary =
        'articles=' || c.total_articles ||
        ' | quality_70_plus=' || c.quality_70_plus ||
        ' | feed_eligible=' || c.feed_eligible ||
        ' | published_at=' || c.with_published_at ||
        ' | league_linked=' || c.league_linked_articles ||
        ' | team_linked=' || c.team_linked_articles ||
        ' | player_linked=' || c.player_linked_articles ||
        ' | match_linked=' || c.match_linked_articles,

    next_action =
        'Doplnit canonical NBA/NHL fixtures coverage do public.matches a následně aktivovat article_match_map matcher.',

    audit_note =
        'Coverage view opraven proti JOIN row multiplication. SAFE alias engine potvrzen.',

    updated_at = now(),
    last_check_at = now()

FROM public.v_media_layer_coverage c

WHERE rea.provider = 'multi_source_media'
  AND rea.sport_code = 'MULTI'
  AND rea.entity = 'articles';


-- kontrola
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'multi_source_media'
  AND sport_code = 'MULTI'
  AND entity = 'articles';