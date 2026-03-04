-- 1) Základ – jsou duplicity podle provider + provider_league_id?
-- Tohle je nejdůležitější kontrola.
SELECT
    provider,
    provider_league_id,
    COUNT(*) AS cnt
FROM ops.ingest_targets
GROUP BY provider, provider_league_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC, provider_league_id::int;


-- 2) Kontrola duplicit jen pro API Football
SELECT
    provider_league_id,
    STRING_AGG(run_group, ', ') AS groups,
    COUNT(*) AS cnt
FROM ops.ingest_targets
WHERE provider = 'api_football'
GROUP BY provider_league_id
HAVING COUNT(*) > 1
ORDER BY provider_league_id::int;


--3) Zobrazit konkrétní duplicitní řádky (detail)
SELECT *
FROM ops.ingest_targets t
WHERE (provider, provider_league_id) IN (
    SELECT provider, provider_league_id
    FROM ops.ingest_targets
    GROUP BY provider, provider_league_id
    HAVING COUNT(*) > 1
)
ORDER BY provider, provider_league_id::int, id;


--4) Jsou duplicity jen kvůli různému run_group?
--Tohle nám řekne, jestli máš stejnou ligu ve více bucketech.
SELECT
    provider_league_id,
    COUNT(*) AS enabled_cnt
FROM ops.ingest_targets
WHERE provider = 'api_football'
  AND enabled = true
GROUP BY provider_league_id
HAVING COUNT(*) > 1
ORDER BY provider_league_id::int;


--5) Máš víc enabled řádků pro stejnou ligu?
--Tohle je častý problém.
SELECT
    provider_league_id,
    COUNT(*) AS enabled_cnt
FROM ops.ingest_targets
WHERE provider = 'api_football'
  AND enabled = true
GROUP BY provider_league_id
HAVING COUNT(*) > 1
ORDER BY provider_league_id::int;


--6) Kolik je reálně unikátních lig?
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT provider_league_id) AS distinct_leagues
FROM ops.ingest_targets
WHERE provider = 'api_football'
  AND enabled = true;


