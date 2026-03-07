
-- =====================================================
-- MatchMatrix
-- Merge staging.players_import -> public.players
-- File: 009_merge_players.sql
-- =====================================================

WITH src AS (
    SELECT DISTINCT ON (p.provider_code, p.provider_player_id)
        p.provider_code,
        p.provider_player_id,
        p.player_name,
        p.first_name,
        p.last_name,
        p.birth_date,
        p.nationality,
        p.height_cm,
        p.weight_kg,
        p.position_code,
        p.is_active
    FROM staging.players_import p
    WHERE p.provider_code IS NOT NULL
      AND p.provider_player_id IS NOT NULL
      AND p.player_name IS NOT NULL
    ORDER BY
        p.provider_code,
        p.provider_player_id,
        p.imported_at DESC NULLS LAST
)

UPDATE public.players pl
SET
    name        = src.player_name,
    first_name  = src.first_name,
    last_name   = src.last_name,
    short_name  = src.player_name,
    birth_date  = src.birth_date,
    nationality = src.nationality,
    position    = src.position_code,
    height_cm   = src.height_cm,
    weight_kg   = src.weight_kg,
    is_active   = COALESCE(src.is_active, true),
    updated_at  = now()
FROM src
WHERE pl.ext_source = src.provider_code
  AND pl.ext_player_id = src.provider_player_id;

WITH src AS (
    SELECT DISTINCT ON (p.provider_code, p.provider_player_id)
        p.provider_code,
        p.provider_player_id,
        p.player_name,
        p.first_name,
        p.last_name,
        p.birth_date,
        p.nationality,
        p.height_cm,
        p.weight_kg,
        p.position_code,
        p.is_active
    FROM staging.players_import p
    WHERE p.provider_code IS NOT NULL
      AND p.provider_player_id IS NOT NULL
      AND p.player_name IS NOT NULL
    ORDER BY
        p.provider_code,
        p.provider_player_id,
        p.imported_at DESC NULLS LAST
)

INSERT INTO public.players
(
    name,
    first_name,
    last_name,
    short_name,
    birth_date,
    nationality,
    position,
    height_cm,
    weight_kg,
    is_active,
    ext_source,
    ext_player_id
)
SELECT
    src.player_name,
    src.first_name,
    src.last_name,
    src.player_name,
    src.birth_date,
    src.nationality,
    src.position_code,
    src.height_cm,
    src.weight_kg,
    COALESCE(src.is_active, true),
    src.provider_code,
    src.provider_player_id
FROM src
WHERE NOT EXISTS (
    SELECT 1
    FROM public.players pl
    WHERE pl.ext_source = src.provider_code
      AND pl.ext_player_id = src.provider_player_id
);