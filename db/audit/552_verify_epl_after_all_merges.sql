-- 554_world_cup_false_pairing_notes.sql
-- Účel:
-- dokumentační zápis pro false pairing případy World Cup
-- NEPROVÁDÍ změny v datech, jen ukládá rozhodnutí pro audit / ruční evidenci

-- Australia vs Jordan
-- TheOdds hlásí:
--   2026-06-16 04:00
--   2026-06-17 04:00
--
-- DB realita v okolí:
--   61667 = Australia vs Turkey   (2026-06-14 04:00)
--   61682 = Austria   vs Jordan   (2026-06-17 04:00)
--
-- Rozhodnutí:
--   klasifikace = SOURCE MISALIGNMENT / WRONG PAIRING
--   neprovádět merge Australia/Austria
--   nevytvářet alias
--   neřešit jako missing fixture
--   při další validaci ignorovat jako false candidate

SELECT
    'FIFA World Cup' AS league_name,
    'Australia' AS theodds_home,
    'Jordan' AS theodds_away,
    TIMESTAMP '2026-06-16 04:00:00' AS theodds_time,
    'SOURCE MISALIGNMENT / WRONG PAIRING' AS decision,
    'Do not merge Australia/Austria. Ignore as false candidate.' AS notes

UNION ALL

SELECT
    'FIFA World Cup' AS league_name,
    'Australia' AS theodds_home,
    'Jordan' AS theodds_away,
    TIMESTAMP '2026-06-17 04:00:00' AS theodds_time,
    'SOURCE MISALIGNMENT / WRONG PAIRING' AS decision,
    'Do not merge Australia/Austria. Ignore as false candidate.' AS notes;