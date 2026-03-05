--Teď jen přepnout season na 2023 pro těch 16 lig
BEGIN;

UPDATE ops.ingest_targets
SET season = '2023'
WHERE enabled = true
  AND run_group IN ('EU_major_v4_A');

COMMIT;