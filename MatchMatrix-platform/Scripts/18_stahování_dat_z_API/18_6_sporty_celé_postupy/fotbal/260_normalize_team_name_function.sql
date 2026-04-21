-- =====================================================================
-- 260_normalize_team_name_function.sql
-- Robustni normalizace nazvu tymu (diakritika + encoding)
-- =====================================================================

CREATE OR REPLACE FUNCTION public.normalize_team_name(input TEXT)
RETURNS TEXT
LANGUAGE SQL
AS $$
SELECT
LOWER(
    REGEXP_REPLACE(
        TRANSLATE(
            input,

            -- zdroj znaky
            'áäčďéěëíïľĺňñóöřŕšťúůüýžÁÄČĎÉĚËÍÏĽĹŇÑÓÖŘŔŠŤÚŮÜÝŽçÇ',

            -- cil
            'aacdeeeiillnnoorrstuuuyzaacdeeeiillnnoorrstuuuyzcc'
        ),

        -- odstraneni vseho krom a-z0-9
        '[^a-z0-9 ]',
        '',
        'g'
    )
);
$$;