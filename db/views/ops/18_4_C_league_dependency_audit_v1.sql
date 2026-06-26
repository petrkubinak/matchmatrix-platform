/*
MATCHMATRIX SQL 18_4_C
LEAGUE DEPENDENCY AUDIT V1

CO TO JE:
- Audit vazeb na duplicitní ligy z League Canonical Governance.

K ČEMU TO JE:
- Zjistí, jestli na MASTER / MERGE ligách visí zápasy, odds, player stats nebo jiné důležité vazby.

KDE TO UVIDÍME:
- ops.v_league_dependency_audit_v1
- ops.v_league_dependency_summary_v1

JAK SE TO VYUŽIJE:
- Rozhodne, zda půjdeme cestou SAFE_LEAGUE_MERGE nebo jen LEAGUE_PROVIDER_MAP_ONLY.
*/

DROP VIEW IF EXISTS ops.v_league_dependency_summary_v1;
DROP VIEW IF EXISTS ops.v_league_dependency_audit_v1;

CREATE OR REPLACE VIEW ops.v_league_dependency_audit_v1 AS
WITH league_base AS (
    SELECT
        a.audit_group_key,
        a.league_id,
        a.sport_id,
        a.league_name,
        a.country,
        a.ext_source,
        a.ext_league_id,
        a.canonical_role,
        a.governance_issue
    FROM ops.v_league_canonical_governance_audit_v1 a
    WHERE a.governance_issue <> 'OK'
),
match_counts AS (
    SELECT
        m.league_id,
        count(*) AS match_rows,
        count(*) FILTER (WHERE m.status IN ('FINISHED', 'FT', 'AET', 'PEN')) AS finished_match_rows,
        count(*) FILTER (WHERE m.status NOT IN ('FINISHED', 'FT', 'AET', 'PEN')) AS non_finished_match_rows
    FROM public.matches m
    GROUP BY m.league_id
),
odds_counts AS (
    SELECT
        m.league_id,
        count(o.id) AS odds_rows
    FROM public.matches m
    JOIN public.odds o
      ON o.match_id = m.id
    GROUP BY m.league_id
),
player_stats_counts AS (
    SELECT
        pss.league_id,
        count(*) AS player_season_stats_rows
    FROM public.player_season_statistics pss
    GROUP BY pss.league_id
)
SELECT
    lb.audit_group_key,
    lb.league_id,
    lb.sport_id,
    lb.league_name,
    lb.country,
    lb.ext_source,
    lb.ext_league_id,
    lb.canonical_role,
    lb.governance_issue,

    coalesce(mc.match_rows, 0) AS match_rows,
    coalesce(mc.finished_match_rows, 0) AS finished_match_rows,
    coalesce(mc.non_finished_match_rows, 0) AS non_finished_match_rows,
    coalesce(oc.odds_rows, 0) AS odds_rows,
    coalesce(psc.player_season_stats_rows, 0) AS player_season_stats_rows,

    (
        coalesce(mc.match_rows, 0)
        + coalesce(oc.odds_rows, 0)
        + coalesce(psc.player_season_stats_rows, 0)
    ) AS total_dependency_rows,

    CASE
        WHEN coalesce(mc.match_rows, 0) = 0
         AND coalesce(oc.odds_rows, 0) = 0
         AND coalesce(psc.player_season_stats_rows, 0) = 0
            THEN 'NO_DEPENDENCIES'
        WHEN lb.canonical_role = 'MASTER_CANDIDATE'
            THEN 'MASTER_HAS_DEPENDENCIES_OK'
        WHEN coalesce(mc.match_rows, 0) > 0
          OR coalesce(oc.odds_rows, 0) > 0
          OR coalesce(psc.player_season_stats_rows, 0) > 0
            THEN 'MERGE_CANDIDATE_HAS_DEPENDENCIES'
        ELSE 'REVIEW'
    END AS dependency_status,

    CASE
        WHEN lb.canonical_role = 'CANONICAL_MERGE_CANDIDATE'
         AND (
            coalesce(mc.match_rows, 0) > 0
            OR coalesce(oc.odds_rows, 0) > 0
            OR coalesce(psc.player_season_stats_rows, 0) > 0
         )
            THEN 'HOLD_DEPENDENCY_REVIEW'
        WHEN lb.canonical_role = 'CANONICAL_MERGE_CANDIDATE'
            THEN 'SAFE_PROVIDER_MAP_CANDIDATE'
        WHEN lb.canonical_role = 'MASTER_CANDIDATE'
            THEN 'KEEP_MASTER'
        ELSE 'REVIEW'
    END AS recommended_action,

    now() AS audited_at
FROM league_base lb
LEFT JOIN match_counts mc
       ON mc.league_id = lb.league_id
LEFT JOIN odds_counts oc
       ON oc.league_id = lb.league_id
LEFT JOIN player_stats_counts psc
       ON psc.league_id = lb.league_id;

CREATE OR REPLACE VIEW ops.v_league_dependency_summary_v1 AS
SELECT
    canonical_role,
    dependency_status,
    recommended_action,
    count(*) AS league_rows,
    sum(match_rows) AS total_matches,
    sum(odds_rows) AS total_odds,
    sum(player_season_stats_rows) AS total_player_stats
FROM ops.v_league_dependency_audit_v1
GROUP BY
    canonical_role,
    dependency_status,
    recommended_action
ORDER BY league_rows DESC;