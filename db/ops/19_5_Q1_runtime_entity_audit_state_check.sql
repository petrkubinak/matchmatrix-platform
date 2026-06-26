/*
MATCHMATRIX SQL 19_5_Q1

CO TO JE:
- Kontrola povolených hodnot current_state v ops.runtime_entity_audit.

K ČEMU TO JE:
- Insert pro wikimedia / FB / PLAYER_PHOTOS spadl na check constraintu.

KDE TO UVIDÍME:
- definice constraintu chk_runtime_entity_audit_state

JAK SE TO VYUŽIJE:
- Podle povolených hodnot opravíme 19_5_Q.
*/

SELECT
    conname,
    pg_get_constraintdef(c.oid) AS constraint_definition
FROM pg_constraint c
JOIN pg_class t ON t.oid = c.conrelid
JOIN pg_namespace n ON n.oid = t.relnamespace
WHERE n.nspname = 'ops'
  AND t.relname = 'runtime_entity_audit'
  AND conname = 'chk_runtime_entity_audit_state';