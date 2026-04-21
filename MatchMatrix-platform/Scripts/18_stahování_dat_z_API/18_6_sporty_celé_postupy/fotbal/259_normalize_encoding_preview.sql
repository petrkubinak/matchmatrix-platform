-- =====================================================================
-- 259_normalize_encoding_preview.sql
-- Preview normalizace encoding problemu
-- =====================================================================

SELECT
    s.external_team_id,
    s.team_name,

    -- odstraneni bordelu
    LOWER(BTRIM(s.team_name)) AS raw_norm,

    -- nahrazeni typickych znaku
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        LOWER(BTRIM(s.team_name)),
        '?', ''),
        'á', 'a'),
        'é', 'e'),
        'í', 'i'),
        'ó', 'o'
    ) AS simple_normalized

FROM staging.stg_provider_teams s
WHERE s.provider = 'api_football'
  AND s.team_name ~ '\?'
ORDER BY s.team_name;