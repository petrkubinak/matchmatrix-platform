/*
MATCHMATRIX SQL 17_8_G
TEAM SAFE DELETE LOW USAGE DUPLICATE TEAMS V2

CO TO JE:
- První fyzické odstranění nepoužívaných duplicitních týmů.
- Maže pouze kandidáty s execution_status = READY_FOR_DELETE.
- Keshla FC a další HOLD_DEPENDENCY zůstanou zachované.

K ČEMU TO JE:
- Odstraní pouze zcela nepoužívané duplicitní týmy.
- Vyčistí public.teams bez zásahu do zápasů, článků, provider map, hráčů, statistik, aliasů a league standings.
- Sníží počet duplicit před dalšími merge kroky.

KDE TO UVIDÍME:
- public.teams
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> TEAM DEDUP
- OPS Panel -> DATA QUALITY

JAK SE TO VYUŽIJE:
- Po odstranění těchto 361 týmů znovu přepočítáme 17_8_D, 17_8_E a 17_8_F.
- Potom budeme řešit SAFE_PROVIDER_MAP_MERGE.
- Nakonec zůstanou pouze rizikové duplicity k ruční kontrole.

BEZPEČNOST:
- DELETE znovu ověřuje všechny závislosti.
- Nemaže týmy se zápasy.
- Nemaže týmy s články.
- Nemaže týmy s provider mapami.
- Nemaže týmy s hráči.
- Nemaže týmy s hráčskými statistikami.
- Nemaže týmy s aliasy.
- Nemaže týmy s league standings.
*/

BEGIN;

WITH safe_delete_candidates AS (
    SELECT
        old_team_id
    FROM ops.v_team_safe_merge_execution_plan_v1
    WHERE execution_status = 'READY_FOR_DELETE'
),

verified AS (
    SELECT
        t.id
    FROM public.teams t
    JOIN safe_delete_candidates s
        ON s.old_team_id = t.id

    WHERE NOT EXISTS (
        SELECT 1
        FROM public.matches m
        WHERE m.home_team_id = t.id
           OR m.away_team_id = t.id
    )

    AND NOT EXISTS (
        SELECT 1
        FROM public.article_team_map atm
        WHERE atm.team_id = t.id
    )

    AND NOT EXISTS (
        SELECT 1
        FROM public.team_provider_map tpm
        WHERE tpm.team_id = t.id
    )

    AND NOT EXISTS (
        SELECT 1
        FROM public.players p
        WHERE p.team_id = t.id
    )

    AND NOT EXISTS (
        SELECT 1
        FROM public.player_season_statistics pss
        WHERE pss.team_id = t.id
    )

    AND NOT EXISTS (
        SELECT 1
        FROM public.team_aliases ta
        WHERE ta.team_id = t.id
    )

    AND NOT EXISTS (
        SELECT 1
        FROM public.league_standings ls
        WHERE ls.team_id = t.id
    )
)

DELETE FROM public.teams t
USING verified v
WHERE t.id = v.id;

COMMIT;