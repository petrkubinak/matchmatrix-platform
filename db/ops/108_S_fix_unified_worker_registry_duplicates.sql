/*
MATCHMATRIX SQL 108_S
Fix Unified Worker Registry Duplicates

CO TO JE:
- Odstranění duplicit v unified worker registry.

K ČEMU TO JE:
- Jeden provider/sport/entity = jeden orchestration záznam.

KDE TO UVIDÍME:
- ops.unified_worker_registry
- panel V18+

JAK SE TO VYUŽIJE:
- scheduler governance
- runtime intelligence
- orchestration mapping
*/

DELETE FROM ops.unified_worker_registry a
USING ops.unified_worker_registry b
WHERE a.id > b.id
  AND a.provider = b.provider
  AND a.sport_code = b.sport_code
  AND a.entity = b.entity;

ALTER TABLE ops.unified_worker_registry
ADD CONSTRAINT uq_unified_worker_registry
UNIQUE
(
    provider,
    sport_code,
    entity
);