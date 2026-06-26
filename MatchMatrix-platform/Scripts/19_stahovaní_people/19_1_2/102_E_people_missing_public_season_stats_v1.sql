/*
===============================================================================
MATCHMATRIX – PEOPLE MISSING PUBLIC SEASON STATS V1
===============================================================================

CO TO DĚLÁ
-----------
Najde unikátní hráč/sezóna/tým/liga kombinace ze staging,
které nejsou v public.player_season_statistics.

K ČEMU TO JE
-------------
Zjistíme přesně, kterých 293 kombinací chybí v public.

JAK TO VYUŽIJEME
----------------
Podle výsledku opravíme merge worker nebo zjistíme,
jestli jde o chybějící team/league mapping.
===============================================================================
*/

WITH staging_grain AS (
    SELECT DISTINCT
        s.provider,
        s.sport_code,
        s.player_external_id,
        s.team_external_id,
        s.external_league_id,
        s.season,
        ppm.player_id
    FROM staging.stg_provider_player_season_stats s
    LEFT JOIN public.player_provider_map ppm
        ON ppm.provider = s.provider
       AND ppm.provider_player_id = s.player_external_id
)
SELECT
    sg.provider,
    sg.sport_code,
    sg.player_external_id,
    sg.player_id,
    sg.team_external_id,
    sg.external_league_id,
    sg.season
FROM staging_grain sg
LEFT JOIN public.player_season_statistics pss
    ON pss.player_id = sg.player_id
   AND pss.season = sg.season
   AND COALESCE(pss.league_id::text, '') = COALESCE(sg.external_league_id::text, '')
WHERE pss.id IS NULL
ORDER BY
    sg.external_league_id,
    sg.season,
    sg.player_external_id
LIMIT 500;