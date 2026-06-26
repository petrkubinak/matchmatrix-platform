/*
MATCHMATRIX SQL 108_C
ALTER FIX TASKS AUTO REVIEW V1

CO TO JE:
- Rozšíření fix tasků o automatickou klasifikaci problému.

K ČEMU TO JE:
- Panel pozná, jestli jde o parser chybu, provider problém,
  bezpečný retry nebo blokující problém.

KDE TO UVIDÍME:
- FIX TASKS
- budoucí AUTO REVIEW / AI OPS panel

JAK SE TO VYUŽIJE:
- priorita oprav
- doporučené akce
- safe retry
- blokace scheduleru
*/

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS issue_type text;

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS auto_review_status text;

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS auto_fixable boolean DEFAULT false;

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS safe_retry boolean DEFAULT false;

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS blocks_scheduler boolean DEFAULT false;

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS review_confidence numeric(12,2);