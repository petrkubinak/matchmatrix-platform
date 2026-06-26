/*
MATCHMATRIX BK CORE AUDIT V1

Co to je:
- Kontrola basketbalové CORE vrstvy.

K čemu to je:
- Ověříme, zda BK má ligy, týmy a zápasy správně v public vrstvě.

Kde výsledek uvidíme:
- V DBeaveru jako výstup SQL dotazu.

Jak se využije na webu:
- BK zápasy, ligy a týmy budou základ pro výsledky, profily týmů, tabulky, statistiky, odds a AI výpočty.
*/

SELECT
    'BK leagues in public.leagues' AS check_name,
    COUNT(*) AS rows_count
FROM public.leagues
WHERE sport_id = 3

UNION ALL

SELECT
    'BK teams in public.teams' AS check_name,
    COUNT(*) AS rows_count
FROM public.teams
WHERE sport_id = 3

UNION ALL

SELECT
    'BK matches in public.matches' AS check_name,
    COUNT(*) AS rows_count
FROM public.matches
WHERE sport_id = 3

UNION ALL

SELECT
    'BK finished matches' AS check_name,
    COUNT(*) AS rows_count
FROM public.matches
WHERE sport_id = 3
  AND status = 'FINISHED'

UNION ALL

SELECT
    'BK matches missing league' AS check_name,
    COUNT(*) AS rows_count
FROM public.matches m
LEFT JOIN public.leagues l ON l.id = m.league_id
WHERE m.sport_id = 3
  AND l.id IS NULL

UNION ALL

SELECT
    'BK matches missing home team' AS check_name,
    COUNT(*) AS rows_count
FROM public.matches m
LEFT JOIN public.teams t ON t.id = m.home_team_id
WHERE m.sport_id = 3
  AND t.id IS NULL

UNION ALL

SELECT
    'BK matches missing away team' AS check_name,
    COUNT(*) AS rows_count
FROM public.matches m
LEFT JOIN public.teams t ON t.id = m.away_team_id
WHERE m.sport_id = 3
  AND t.id IS NULL;