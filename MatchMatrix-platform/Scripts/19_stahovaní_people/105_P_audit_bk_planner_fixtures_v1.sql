/*
MATCHMATRIX BK PLANNER FIXTURES AUDIT V1

Co to je:
- Kontrola BK fixtures jobů v ops.ingest_planner.

K čemu to je:
- Zjistíme, jestli už máme připravené řízené BK fixtures joby
  pro nové stažení RAW dat.

Kde výsledek uvidíme:
- V DBeaveru jako přehled statusů planneru.

Jak se využije na webu:
- Planner joby budou zdroj pro dotažení BK výsledků,
  statistik, tabulek a později AI výpočtů.
*/

SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    COUNT(*) AS jobs_count,
    MIN(provider_league_id) AS sample_provider_league_id,
    MIN(season) AS sample_season,
    MIN(last_attempt) AS first_last_attempt,
    MAX(last_attempt) AS last_last_attempt
FROM ops.ingest_planner
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures'
GROUP BY
    provider,
    sport_code,
    entity,
    run_group,
    status
ORDER BY
    run_group,
    status;