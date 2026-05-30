/*
MATCHMATRIX BK MATCH STATUS AUDIT V1

Co to je:
- Zjistí reálné hodnoty statusů u BK zápasů.

K čemu to je:
- Potřebujeme vědět, jak BK označuje dokončené zápasy.

Kde výsledek uvidíme:
- V DBeaveru jako seznam statusů a počtů.

Jak se využije na webu:
- Správné statusy rozhodují, co je hotový zápas, live zápas, plánovaný zápas a co může vstoupit do statistik / AI výpočtů.
*/

SELECT
    status,
    COUNT(*) AS matches_count
FROM public.matches
WHERE sport_id = 3
GROUP BY status
ORDER BY matches_count DESC, status;