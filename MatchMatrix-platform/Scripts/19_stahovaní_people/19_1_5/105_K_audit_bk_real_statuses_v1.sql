/*
MATCHMATRIX BK REAL STATUS AUDIT V1

Co to je:
- Audit reálných statusů BK fixture dat ve staging vrstvě.

K čemu to je:
- Zjistíme, zda provider vrací FINISHED zápasy
  a kde se ztrácí při merge do public.matches.

Kde výsledek uvidíme:
- V DBeaveru jako přehled statusů.

Jak se využije na webu:
- Správné statusy jsou základ:
  - výsledků
  - live zápasů
  - statistik
  - AI modelů
  - tabulek
*/

SELECT
    provider,
    sport_code,
    status_text,
    COUNT(*) AS rows_count,
    COUNT(home_score) AS home_scores,
    COUNT(away_score) AS away_scores
FROM staging.stg_provider_fixtures
WHERE sport_code = 'BK'
GROUP BY
    provider,
    sport_code,
    status_text
ORDER BY rows_count DESC;