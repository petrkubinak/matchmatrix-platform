/*
MATCHMATRIX SQL 18_1_A Match Duplicate Governance Audit V1

CO TO JE:
- Základní audit duplicitních zápasů.

K ČEMU TO JE:
- Vytvoří první governance pohled pro Match Duplicate Prevention.

KDE TO UVIDÍME:
- OPS vrstva
- budoucí panel Governance

JAK SE TO VYUŽIJE:
- identifikace SAFE_MERGE
- identifikace REVIEW_REQUIRED
- identifikace LEAGUE_MAPPING_ERROR
*/

DROP VIEW IF EXISTS ops.v_match_duplicate_governance_audit_v1;

CREATE OR REPLACE VIEW ops.v_match_duplicate_governance_audit_v1 AS

WITH match_base AS (
    SELECT
        m.id,
        m.sport_id,
        m.league_id,
        l.name AS league_name,
        m.kickoff::date AS match_date,
        m.kickoff,
        m.ext_source,
        m.ext_match_id,
        m.status,
        m.home_team_id,
        m.away_team_id,
        ht.name AS home_team,
        at.name AS away_team,
        m.home_score,
        m.away_score,
        LEAST(m.home_team_id, m.away_team_id) AS team_low,
        GREATEST(m.home_team_id, m.away_team_id) AS team_high
    FROM public.matches m
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
    LEFT JOIN public.leagues l ON l.id = m.league_id
),

dup_groups AS (
    SELECT
        sport_id,
        match_date,
        team_low,
        team_high,
        COUNT(*) AS duplicate_count,
        COUNT(DISTINCT league_id) AS distinct_league_count,
        COUNT(DISTINCT ext_source) AS distinct_source_count,
        COUNT(DISTINCT COALESCE(home_score::text, '?') || ':' || COALESCE(away_score::text, '?')) AS distinct_score_count
    FROM match_base
    GROUP BY
        sport_id,
        match_date,
        team_low,
        team_high
    HAVING COUNT(*) > 1
)

SELECT
    mb.*,
    dg.duplicate_count,
    dg.distinct_league_count,
    dg.distinct_source_count,
    dg.distinct_score_count,

    CASE
        WHEN dg.distinct_league_count > 1
            THEN 'LEAGUE_MAPPING_ERROR'

        WHEN dg.distinct_score_count > 1
            THEN 'SCORE_CONFLICT_REVIEW'

        WHEN dg.distinct_source_count > 1
            THEN 'PROVIDER_DUPLICATE'

        ELSE 'REVIEW_REQUIRED'
    END AS governance_status

FROM match_base mb
JOIN dup_groups dg
    ON dg.sport_id = mb.sport_id
   AND dg.match_date = mb.match_date
   AND dg.team_low = mb.team_low
   AND dg.team_high = mb.team_high;