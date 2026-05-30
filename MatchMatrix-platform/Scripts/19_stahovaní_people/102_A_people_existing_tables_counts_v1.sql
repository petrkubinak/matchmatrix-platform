/*
===============================================================================
MATCHMATRIX – PEOPLE EXISTING TABLES COUNTS V1
===============================================================================

CO TO DĚLÁ
-----------
Zkontroluje reálné počty řádků v PEOPLE tabulkách.

K ČEMU TO JE
-------------
Zjistíme:
- co už je skutečně naplněné
- co je jen připravená struktura
- kde funguje merge
- kde chybí parser
- kde chybí orchestrace

JAK TO VYUŽIJEME
----------------
Výsledek použijeme pro:
- PEOPLE roadmapu
- provider priority
- merge priority
- audit připravenosti před PRO aktivací
===============================================================================
*/

SELECT 'public.players' AS table_name, COUNT(*) AS rows_count
FROM public.players

UNION ALL

SELECT 'public.player_provider_map', COUNT(*)
FROM public.player_provider_map

UNION ALL

SELECT 'public.player_external_identity', COUNT(*)
FROM public.player_external_identity

UNION ALL

SELECT 'public.player_season_statistics', COUNT(*)
FROM public.player_season_statistics

UNION ALL

SELECT 'public.player_match_statistics', COUNT(*)
FROM public.player_match_statistics

UNION ALL

SELECT 'public.player_social_links', COUNT(*)
FROM public.player_social_links

UNION ALL

SELECT 'public.player_team_history', COUNT(*)
FROM public.player_team_history

UNION ALL

SELECT 'public.player_translations', COUNT(*)
FROM public.player_translations

UNION ALL

SELECT 'public.player_trending', COUNT(*)
FROM public.player_trending

UNION ALL

SELECT 'public.coaches', COUNT(*)
FROM public.coaches

UNION ALL

SELECT 'public.coach_provider_map', COUNT(*)
FROM public.coach_provider_map

UNION ALL

SELECT 'public.article_player_map', COUNT(*)
FROM public.article_player_map

UNION ALL

SELECT 'staging.stg_provider_players', COUNT(*)
FROM staging.stg_provider_players

UNION ALL

SELECT 'staging.stg_provider_player_profiles', COUNT(*)
FROM staging.stg_provider_player_profiles

UNION ALL

SELECT 'staging.stg_provider_player_stats', COUNT(*)
FROM staging.stg_provider_player_stats

UNION ALL

SELECT 'staging.stg_provider_player_season_stats', COUNT(*)
FROM staging.stg_provider_player_season_stats

UNION ALL

SELECT 'staging.stg_provider_coaches', COUNT(*)
FROM staging.stg_provider_coaches

ORDER BY table_name;