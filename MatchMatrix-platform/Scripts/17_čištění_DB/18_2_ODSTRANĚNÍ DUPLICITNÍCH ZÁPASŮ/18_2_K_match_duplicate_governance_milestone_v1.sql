/*
MATCHMATRIX SQL 18_2_K Match Duplicate Governance Milestone V1
*/

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
    'MATCH_DUPLICATE_GOVERNANCE',
    'Match Duplicate Governance',
    'GOVERNANCE',
    CURRENT_DATE,
    'CONTROLLED_HOLD',
    80,
    75,
    'SAFE provider duplicates removed: 1629. Remaining: LEAGUE_MAPPING_ERROR 564 groups, REVIEW_REQUIRED 322 groups, SCORE_CONFLICT_REVIEW 101 groups.'
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