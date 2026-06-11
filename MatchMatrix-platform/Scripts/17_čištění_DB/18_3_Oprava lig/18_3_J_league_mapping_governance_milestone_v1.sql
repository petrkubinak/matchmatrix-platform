INSERT INTO ops.project_milestones (
    milestone_code,
    milestone_name,
    category,
    completed_date,
    status,
    priority,
    progress_percent,
    description
)
VALUES (
    'LEAGUE_MAPPING_GOVERNANCE',
    'League Mapping Governance',
    'GOVERNANCE',
    CURRENT_DATE,
    'CONTROLLED_HOLD',
    80,
    99,
    'SAFE league mapping conflicts updated: 562. Remaining HOLD: HOLD_SCORE_CONFLICT 1, LEAGUE_CANONICAL_CONFLICT 1.'
)
ON CONFLICT (milestone_code)
DO UPDATE SET
    milestone_name = EXCLUDED.milestone_name,
    category = EXCLUDED.category,
    completed_date = EXCLUDED.completed_date,
    status = EXCLUDED.status,
    priority = EXCLUDED.priority,
    progress_percent = EXCLUDED.progress_percent,
    description = EXCLUDED.description,
    updated_at = now();