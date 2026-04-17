-- ============================================================================
-- 073_create_missing_player_profile_batches.sql
-- Cíl:
--   Rozdělit chybějící player IDs do batchů pro další ingest.
--   Batch size = 20
-- ============================================================================

DROP TABLE IF EXISTS work.missing_player_profile_batches;

CREATE TABLE work.missing_player_profile_batches AS
WITH numbered AS (
    SELECT
        provider,
        sport_code,
        player_external_id,
        ROW_NUMBER() OVER (ORDER BY player_external_id) AS rn
    FROM work.missing_player_profile_ids
    WHERE provider = 'api_football'
      AND sport_code = 'football'
)
SELECT
    provider,
    sport_code,
    player_external_id,
    rn,
    ((rn - 1) / 20) + 1 AS batch_no
FROM numbered
ORDER BY rn;

-- kontrola
SELECT
    batch_no,
    COUNT(*) AS ids_in_batch
FROM work.missing_player_profile_batches
GROUP BY batch_no
ORDER BY batch_no;