/*
MATCHMATRIX SQL 120_N Match Context Candidate Classification V1

CO TO JE:
- Univerzální klasifikace media článků pro Match Context Engine.

K ČEMU TO JE:
- Oddělí články na:
  1) konkrétní zápas
  2) celé kolo / matchday
  3) lineup/news kontext
  4) obecný media kontext

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Další resolver nebude všechno tlačit do article_match_map.
- Některé články patří na ligu/kolo, ne na jeden zápas.
*/

CREATE OR REPLACE VIEW ops.v_match_context_candidate_classification_v1 AS
SELECT
    article_id,
    title,
    article_league_name,
    match_signal,
    published_at,
    content_source_id,

    CASE
        WHEN title ILIKE '% vs %'
          OR title ILIKE '% v %'
        THEN 'DIRECT_MATCH_CONTEXT'

        WHEN title ILIKE '%matchday%'
          OR title ILIKE '%final day%'
          OR title ILIKE '%probable teams%'
        THEN 'ROUND_CONTEXT'

        WHEN title ILIKE '%lineup%'
          OR title ILIKE '%lineups%'
          OR title ILIKE '%starting goalies%'
        THEN 'LINEUP_CONTEXT'

        ELSE 'GENERAL_CONTEXT'
    END AS context_type,

    CASE
        WHEN title ILIKE '% vs %'
          OR title ILIKE '% v %'
        THEN 'RESOLVE_TO_SINGLE_MATCH'

        WHEN title ILIKE '%matchday%'
          OR title ILIKE '%final day%'
          OR title ILIKE '%probable teams%'
        THEN 'RESOLVE_TO_ROUND_OR_MULTIPLE_MATCHES'

        WHEN title ILIKE '%lineup%'
          OR title ILIKE '%lineups%'
          OR title ILIKE '%starting goalies%'
        THEN 'RESOLVE_TO_TEAM_OR_DAILY_MATCHES'

        ELSE 'KEEP_AS_ARTICLE_CONTEXT'
    END AS recommended_resolution,

    now() AS audited_at

FROM ops.v_universal_match_context_candidates_v1;