/*
MATCHMATRIX BK PUBLIC SOURCES AUDIT V1

Co to je:
- Zjistí ext_source a statusy u BK zápasů v public.matches.

K čemu to je:
- Potřebujeme určit, z jakého zdroje BK zápasy přišly,
  když nejsou v staging.stg_provider_fixtures.

Kde výsledek uvidíme:
- V DBeaveru jako přehled zdrojů a statusů.

Jak se využije na webu:
- Určíme správnou cestu pro doplnění BK výsledků a statistik.
*/

SELECT
    ext_source,
    status,
    COUNT(*) AS matches_count,
    MIN(kickoff) AS first_kickoff,
    MAX(kickoff) AS last_kickoff
FROM public.matches
WHERE sport_id = 3
GROUP BY ext_source, status
ORDER BY matches_count DESC, ext_source, status;