/*
===============================================================================
MATCHMATRIX 20_3_A – CORE DATABASE AUDIT BEFORE HARVEST
===============================================================================

CO TO JE:
Audit základních CORE tabulek před velkým harvestem dat.

K ČEMU TO JE:
Ověříme, kolik máme sportů, lig, týmů, zápasů a základních dat.

KDE TO UVIDÍME:
DBeaver / SQL výstup.

JAK SE TO VYUŽIJE:
Podle výsledku určíme READY / PARTIAL / DATA_GAP / BLOCKED pro CORE vrstvu.
===============================================================================
*/

SELECT 'public.sports' AS table_name, COUNT(*) AS row_count FROM public.sports
UNION ALL
SELECT 'public.countries', COUNT(*) FROM public.countries
UNION ALL
SELECT 'public.leagues', COUNT(*) FROM public.leagues
UNION ALL
SELECT 'public.seasons', COUNT(*) FROM public.seasons
UNION ALL
SELECT 'public.teams', COUNT(*) FROM public.teams
UNION ALL
SELECT 'public.stadiums', COUNT(*) FROM public.stadiums
UNION ALL
SELECT 'public.matches', COUNT(*) FROM public.matches
ORDER BY table_name;