/*
==============================================================================
MATCHMATRIX SQL 111_A
UPDATE SPORTS IMPORT PLAN - HISTORICAL MODE V1
==============================================================================

CO TO JE:
- Přepíná existující sports_import_plan na režim historického harvestu.

K ČEMU TO JE:
- Aby systém primárně budoval historickou databázi pro všechny sporty.
- Aby se fotbal nebral jako jediný hlavní sport.

KDE TO UVIDÍME:
- OPS panel
- planner
- budoucí smart core quota
- historický backfill dashboard

JAK SE TO VYUŽIJE:
- plánovač bude vědět, že teď chceme hlavně historii
- další krok přidá quota pravidla FB 50 %, HK 15 %, BK 15 %, ostatní 20 %
*/

UPDATE ops.sports_import_plan
SET
    mode = 'historical_backfill',
    history_days_back = 36500,
    updated_at = NOW()
WHERE enabled = TRUE;

UPDATE ops.sports_import_plan
SET
    daily_request_budget = 50,
    priority = 100,
    notes = 'Historical mode: football hlavní sport, ale omezený na cca 50 % kapacity.'
WHERE sport_code = 'football';

UPDATE ops.sports_import_plan
SET
    daily_request_budget = 15,
    priority = 90,
    notes = 'Historical mode: hockey pevný podíl cca 15 %.'
WHERE sport_code = 'hockey';

UPDATE ops.sports_import_plan
SET
    daily_request_budget = 15,
    priority = 85,
    notes = 'Historical mode: basketball pevný podíl cca 15 %.'
WHERE sport_code = 'basketball';

UPDATE ops.sports_import_plan
SET
    daily_request_budget = 5,
    priority = 70,
    notes = 'Historical mode: ostatní sporty sdílený multisport harvest.'
WHERE sport_code NOT IN ('football', 'hockey', 'basketball')
  AND enabled = TRUE;