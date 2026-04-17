-- ============================================================================
-- 093_check_sports_mapping.sql
-- Cíl:
--   Ověřit, jaké kódy jsou v public.sports vs staging sport_code
-- ============================================================================

SELECT 'public_sports' AS section, id::text, code, name
FROM public.sports

UNION ALL

SELECT 'staging_sport_codes', NULL::text, sport_code, COUNT(*)::text
FROM staging.stg_provider_player_season_stats
GROUP BY sport_code
ORDER BY section, code;