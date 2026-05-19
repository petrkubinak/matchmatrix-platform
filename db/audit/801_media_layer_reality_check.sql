-- 801_media_layer_reality_check.sql
-- MATCHMATRIX MEDIA LAYER – REALITY CHECK V1

-- 1) Najdi media/content/highlight/news tabulky
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema IN ('public', 'staging', 'ops')
  AND (
      table_name ILIKE '%media%'
      OR table_name ILIKE '%highlight%'
      OR table_name ILIKE '%news%'
      OR table_name ILIKE '%article%'
      OR table_name ILIKE '%rss%'
      OR table_name ILIKE '%comment%'
      OR table_name ILIKE '%content%'
  )
ORDER BY table_schema, table_name;

-- 2) Najdi media/content/highlight/news sloupce
SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema IN ('public', 'staging', 'ops')
  AND (
      column_name ILIKE '%media%'
      OR column_name ILIKE '%highlight%'
      OR column_name ILIKE '%news%'
      OR column_name ILIKE '%article%'
      OR column_name ILIKE '%rss%'
      OR column_name ILIKE '%comment%'
      OR column_name ILIKE '%content%'
      OR column_name ILIKE '%url%'
      OR column_name ILIKE '%source%'
  )
ORDER BY table_schema, table_name, ordinal_position;

-- 3) Ověř, jestli už je media zapsaná v OPS plánech
SELECT *
FROM ops.ingest_entity_plan
WHERE entity ILIKE '%media%'
   OR entity ILIKE '%highlight%'
   OR entity ILIKE '%news%'
   OR entity ILIKE '%article%'
   OR entity ILIKE '%rss%'
   OR entity ILIKE '%comment%'
   OR entity ILIKE '%content%'
ORDER BY provider, sport_code, entity;

-- 4) Ověř runtime audit pro media/entity
SELECT *
FROM ops.runtime_entity_audit
WHERE entity ILIKE '%media%'
   OR entity ILIKE '%highlight%'
   OR entity ILIKE '%news%'
   OR entity ILIKE '%article%'
   OR entity ILIKE '%rss%'
   OR entity ILIKE '%comment%'
   OR entity ILIKE '%content%'
ORDER BY provider, sport_code, entity;