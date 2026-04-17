-- =====================================================================
-- 262_normalize_team_name_function_unaccent.sql
-- Robustni normalizace nazvu tymu pres unaccent
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION public.normalize_team_name(input TEXT)
RETURNS TEXT
LANGUAGE SQL
IMMUTABLE
AS $$
SELECT
    LOWER(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                unaccent(COALESCE(input, '')),
                '[^a-zA-Z0-9 ]',
                '',
                'g'
            ),
            '\s+',
            ' ',
            'g'
        )
    );
$$;