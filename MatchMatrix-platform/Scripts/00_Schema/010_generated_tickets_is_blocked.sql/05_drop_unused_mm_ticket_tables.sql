-- =====================================================
-- MatchMatrix
-- DROP nepoužívaných experimentálních mm_* ticket tabulek
--
-- Důvod:
--   V projektu zůstane jen jedna canonical ticket architektura:
--   tickets / ticket_blocks / ticket_variants / ...
--
-- Poznámka:
--   Tabulky jsou zatím bez dat, proto je bezpečné je odstranit.
-- =====================================================

drop table if exists public.mm_ticket_scenario_block_matches cascade;
drop table if exists public.mm_ticket_scenario_blocks cascade;
drop table if exists public.mm_ticket_scenario_variants cascade;
drop table if exists public.mm_ticket_scenarios cascade;