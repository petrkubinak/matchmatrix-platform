/*
MATCHMATRIX SQL 18_4_H
LEAGUE GOVERNANCE RUNTIME AUDIT V1

CO TO JE:
- Zapíše dokončenou League Governance do ops.runtime_entity_audit.

K ČEMU TO JE:
- Aby OPS vrstva věděla, že ligy mají hotovou canonical governance.
- Aby se v panelu a runtime auditu zobrazilo:
    LEAGUE_CANONICAL_GOVERNANCE = CONFIRMED

KDE TO UVIDÍME:
- ops.runtime_entity_audit
- OPS Panel
- Governance Dashboard
- budoucí League Governance sekce

JAK SE TO VYUŽIJE:
- Při rozhodování AI/OPS, zda lze bezpečně pokračovat v harvestu.
- Při napojení providerů.
- Při Match Context Engine.
- Při Odds/Media/People linkeru.
*/

DELETE FROM ops.runtime_entity_audit
WHERE provider = 'matchmatrix_governance'
  AND sport_code = 'ALL'
  AND entity = 'league_canonical_governance';

INSERT INTO ops.runtime_entity_audit (
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
    last_run_at,
    last_check_at,
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note
)
VALUES (
    'matchmatrix_governance',
    'ALL',
    'league_canonical_governance',
    'CONFIRMED',
    'League Canonical Governance dokončeno. Canonical Master=800, Safe Map=624, Hold=176. Fyzický merge lig je vypnutý.',
    false,
    false,
    false,
    true,
    true,
    true,
    true,
    false,
    true,
    '18_4_A_TO_18_4_H_LEAGUE_GOVERNANCE',
    now(),
    now(),
    '18_4 League Governance completed: canonical registry active, league provider map active, controlled hold for dependency leagues.',
    'CANONICAL_MASTER=800 | SAFE_PROVIDER_MAP=624 | HOLD_DEPENDENCY=176 | LEAGUE_PHYSICAL_MERGE=DISABLED',
    'Napojit League Governance do OPS Panel V18 / Governance Dashboard.',
    'League Governance READY. Nepoužívat fyzický merge lig bez dalšího ručního auditu.'
);