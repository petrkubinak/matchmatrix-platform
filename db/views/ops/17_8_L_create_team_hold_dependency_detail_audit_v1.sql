/*
MATCHMATRIX SQL 17_8_L
TEAM HOLD DEPENDENCY DETAIL AUDIT V2

CO TO JE:
- Detailní audit týmů, které zůstaly v HOLD_DEPENDENCY.
- Ukazuje přesně, co blokuje jejich odstranění.
- Verze V2 používá skutečný sloupec public.players.name.

K ČEMU TO JE:
- Zjistí konkrétní hráče navázané na duplicitní tým.
- Zjistí league standings navázané na duplicitní tým.
- Připraví podklad pro případný bezpečný přesun hráčů na master tým.
- Připraví podklad pro ruční kontrolu.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> TEAM DEDUP
- DBeaver HOLD DEPENDENCY audit

JAK SE TO VYUŽIJE:
- Pokud jsou hráči skutečně duplicita / špatně navázaní, vytvoříme PLAYER MOVE PLAN.
- Pokud jsou standings navázané na špatný tým, vytvoříme STANDINGS MOVE PLAN.
- Teprve potom může být duplicitní tým odstraněn.

VÝSLEDEK:
- Jeden řádek = jedna konkrétní závislost.
*/

CREATE OR REPLACE VIEW ops.v_team_hold_dependency_detail_audit_v1 AS

/* ---------------------------------------------------------------------------
   PLAYERS
--------------------------------------------------------------------------- */
SELECT
    e.team_name,
    e.old_team_id,
    e.master_team_id,

    'PLAYER' AS dependency_type,

    p.id::text AS dependency_id,
    p.name AS dependency_name,

    concat_ws(
        ' | ',
        'ext_source=' || COALESCE(p.ext_source,''),
        'ext_player_id=' || COALESCE(p.ext_player_id,''),
        'sport_id=' || COALESCE(p.sport_id::text,'')
    ) AS extra_info,

    now() AS generated_at

FROM ops.v_team_safe_merge_execution_plan_v1 e

JOIN public.players p
    ON p.team_id = e.old_team_id

WHERE e.execution_status = 'HOLD_DEPENDENCY'

UNION ALL

/* ---------------------------------------------------------------------------
   LEAGUE STANDINGS
--------------------------------------------------------------------------- */
SELECT
    e.team_name,
    e.old_team_id,
    e.master_team_id,

    'LEAGUE_STANDING' AS dependency_type,

    ls.id::text AS dependency_id,

    COALESCE(
        'League ID ' || ls.league_id::text,
        'League Standing'
    ) AS dependency_name,

    'team_id=' || ls.team_id::text AS extra_info,

    now() AS generated_at

FROM ops.v_team_safe_merge_execution_plan_v1 e

JOIN public.league_standings ls
    ON ls.team_id = e.old_team_id

WHERE e.execution_status = 'HOLD_DEPENDENCY';