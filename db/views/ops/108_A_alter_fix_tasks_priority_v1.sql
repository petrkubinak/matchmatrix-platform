/*
MATCHMATRIX SQL 108_A
ALTER FIX TASKS PRIORITY V1

CO TO JE:
- Rozšíření ops.fix_tasks o priority a recommendation engine.

K ČEMU TO JE:
- Operations center začne rozlišovat závažnost problémů.
- Scheduler bude vědět co opravovat jako první.
- Panel zvýrazní kritické problémy.

KDE TO UVIDÍME:
- FIX TASKS panel
- ALERT ENGINE
- Scheduler recommendation

JAK SE TO VYUŽIJE:
- automatické priority
- retry strategie
- blokace providerů
- auto escalation
*/

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS priority_score numeric(12,2);

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS priority_level text;

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS recommended_action text;

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS last_reviewed_at timestamptz;

ALTER TABLE ops.fix_tasks
ADD COLUMN IF NOT EXISTS reviewed_by text;