/*
===============================================================================
MATCHMATRIX – STG_API_PAYLOADS COLUMNS AUDIT V1
===============================================================================

Zjistí skutečné sloupce tabulky:
staging.stg_api_payloads
===============================================================================
*/

SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'stg_api_payloads'
ORDER BY ordinal_position;