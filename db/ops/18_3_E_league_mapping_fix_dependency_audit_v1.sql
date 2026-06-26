/*
MATCHMATRIX SQL 18_3_E League Mapping Fix Dependency Audit V1

CO TO JE:
- Kontrola před aktualizací league_id u zápasů.

K ČEMU TO JE:
- Ověří, jestli zápasy určené k UPDATE_TO_MASTER_LEAGUE
  nejsou ve vazbách, které by vyžadovaly zvláštní přesun.

KDE TO UVIDÍME:
- OPS Governance.

JAK SE TO VYUŽIJE:
- Pokud je SAFE_LEAGUE_UPDATE_READY, můžeme provést update league_id.
*/

CREATE OR REPLACE VIEW ops.v_league_mapping_fix_dependency_audit_v1 AS

SELECT
    p.match_id,
    p.current_league_id,
    p.current_league_name,
    p.master_league_id,
    p.master_league_name,
    p.ext_source,
    p.ext_match_id,
    p.home_team,
    p.away_team,
    p.match_date,

    (
        SELECT COUNT(*)
        FROM public.odds o
        WHERE o.match_id = p.match_id
    ) AS odds_rows,

    (
        SELECT COUNT(*)
        FROM public.player_match_statistics pms
        WHERE pms.match_id = p.match_id
    ) AS player_match_statistics_rows,

    (
        SELECT COUNT(*)
        FROM public.team_match_statistics tms
        WHERE tms.match_id = p.match_id
    ) AS team_match_statistics_rows,

    (
        SELECT COUNT(*)
        FROM public.article_match_map amm
        WHERE amm.match_id = p.match_id
    ) AS article_match_map_rows,

    CASE
        WHEN
            (
                SELECT COUNT(*)
                FROM public.odds o
                WHERE o.match_id = p.match_id
            )
            +
            (
                SELECT COUNT(*)
                FROM public.player_match_statistics pms
                WHERE pms.match_id = p.match_id
            )
            +
            (
                SELECT COUNT(*)
                FROM public.team_match_statistics tms
                WHERE tms.match_id = p.match_id
            )
            +
            (
                SELECT COUNT(*)
                FROM public.article_match_map amm
                WHERE amm.match_id = p.match_id
            ) = 0
        THEN 'SAFE_LEAGUE_UPDATE_READY'
        ELSE 'DEPENDENCY_REVIEW'
    END AS dependency_status

FROM ops.v_league_mapping_safe_fix_plan_v1 p
WHERE p.proposed_action = 'UPDATE_TO_MASTER_LEAGUE';