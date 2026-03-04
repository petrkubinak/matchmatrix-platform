--1) PREVIEW: co se bude mazat (doporučeno)
--Ukáže ti konkrétní řádky, které půjdou pryč (vždy necháme nejmenší id).

SELECT *
FROM ops.ingest_targets t
WHERE t.id IN (
  SELECT id
  FROM (
    SELECT
      id,
      ROW_NUMBER() OVER (
        PARTITION BY provider, provider_league_id
        ORDER BY id
      ) AS rn
    FROM ops.ingest_targets
    WHERE provider='api_football'
  ) x
  WHERE x.rn > 1
)
ORDER BY provider_league_id::int, id;

--2)DELETE: smaž duplicity (ponech 1 řádek na ligu)
--✅ Tohle je finální čistící krok:

BEGIN;

DELETE FROM ops.ingest_targets t
USING (
  SELECT id
  FROM (
    SELECT
      id,
      ROW_NUMBER() OVER (
        PARTITION BY provider, provider_league_id
        ORDER BY id
      ) AS rn
    FROM ops.ingest_targets
    WHERE provider='api_football'
  ) x
  WHERE x.rn > 1
) d
WHERE t.id = d.id;

COMMIT;

--3)Ověření po smazání

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT provider_league_id) AS distinct_leagues
FROM ops.ingest_targets
WHERE provider='api_football';

SELECT provider_league_id, COUNT(*) cnt
FROM ops.ingest_targets
WHERE provider='api_football'
GROUP BY provider_league_id
HAVING COUNT(*) > 1;

--4) Zabránění návratu duplicit (UNIQUE constraint)
--Až bude 100% čisté:

ALTER TABLE ops.ingest_targets
ADD CONSTRAINT uq_ingest_targets_provider_league
UNIQUE (provider, provider_league_id);