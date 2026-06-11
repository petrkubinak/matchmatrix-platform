/*
MATCHMATRIX SQL 19_2_L
Register PC2 Harvest Roadmap Runtime V1 - FIXED STATE

CO TO JE:
- Registruje dokončenou etapu 19_2 do ops.runtime_entity_audit.

OPRAVA:
- current_state nepovoluje READY.
- Používáme CONFIRMED.
*/

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'PC2 harvest preparation milestone completed.',
    panel_runner_exists = false,
    planner_target_exists = true,
    batch_target_exists = true,
    pull_confirmed = false,
    raw_confirmed = false,
    staging_confirmed = false,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = true,
    last_run_group = '19_2_B_TO_19_2_K',
    last_check_at = now(),
    last_log_summary = '19_2 PC2 Harvest Roadmap registered as CONFIRMED.',
    db_evidence_summary = 'Views created: v_pc2_master_harvest_roadmap_v1, v_pc2_master_next_action_queue_v1, v_pc2_master_harvest_kpi_v1.',
    next_action = 'Napojit PC2 roadmapu do OPS Panel V18 / PC2 Command Center.',
    audit_note = 'Missing Provider Matrix, Photo Provider Research, Dependency Planner and PC2 Master Roadmap are confirmed.',
    updated_at = now()
WHERE provider = 'matchmatrix_pc2'
  AND sport_code = 'ALL'
  AND entity IN (
      'missing_provider_matrix',
      'photo_provider_research',
      'dependency_harvest_planner',
      'pc2_master_harvest_roadmap'
  );

INSERT INTO ops.runtime_entity_audit
(
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    last_check_at,
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note
)
SELECT *
FROM (
    VALUES
    (
        'matchmatrix_pc2','ALL','missing_provider_matrix','CONFIRMED',
        'Missing Provider Matrix dokončena.',
        false,true,true,false,false,false,true,true,true,
        '19_2_B_TO_19_2_C',
        now(),
        'Missing Provider Matrix registered as CONFIRMED.',
        'Tables/views: ops.provider_missing_matrix, v_provider_missing_dashboard_v1.',
        'Napojit Missing Provider Matrix do OPS Panel V18.',
        'Provider gaps are mapped by sport/entity/provider/access type.'
    ),
    (
        'matchmatrix_pc2','ALL','photo_provider_research','CONFIRMED',
        'Photo Provider Research dokončen.',
        false,true,true,false,false,false,true,true,true,
        '19_2_D_TO_19_2_G',
        now(),
        'Photo Provider Research registered as CONFIRMED.',
        'Views: v_photo_provider_research_v1, v_photo_license_review_action_plan_v2, v_pc2_photo_harvest_readiness_v1.',
        'Napojit Photo Provider Research do OPS Panel V18.',
        'Photo/logo/stadium candidates are split into LICENSE_REVIEW and WAIT_FOR_PAID.'
    ),
    (
        'matchmatrix_pc2','ALL','dependency_harvest_planner','CONFIRMED',
        'Dependency Harvest Planner dokončen.',
        false,true,true,false,false,false,true,true,true,
        '19_2_H_TO_19_2_J',
        now(),
        'Dependency Harvest Planner registered as CONFIRMED.',
        'Views: v_sport_coverage_harvest_planner_v1, v_sport_detail_harvest_queue_v1.',
        'Použít jako základ pro CORE -> PEOPLE -> MEDIA -> ODDS pořadí.',
        'Harvest order is dependency based and no longer blind.'
    ),
    (
        'matchmatrix_pc2','ALL','pc2_master_harvest_roadmap','CONFIRMED',
        'PC2 Master Harvest Roadmap připravena.',
        false,true,true,false,false,false,true,true,true,
        '19_2_K',
        now(),
        'PC2 Master Harvest Roadmap registered as CONFIRMED.',
        'Views: v_pc2_master_harvest_roadmap_v1, v_pc2_master_next_action_queue_v1, v_pc2_master_harvest_kpi_v1.',
        'Napojit roadmapu do PC2 Command Center.',
        'PC2 roadmap shows CORE=2, PEOPLE=6, MEDIA=1 according to latest queue.'
    )
) AS v(
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    last_check_at,
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note
)
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.runtime_entity_audit r
    WHERE r.provider = v.provider
      AND r.sport_code = v.sport_code
      AND r.entity = v.entity
);

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    last_check_at
FROM ops.runtime_entity_audit
WHERE provider = 'matchmatrix_pc2'
  AND sport_code = 'ALL'
ORDER BY entity;