/*
MATCHMATRIX SQL 111_S
AUTONOMOUS OPS BRAIN SOURCE AUDIT V1

CO TO JE:
- Audit všech zdrojů, ze kterých bude Autonomous OPS Brain rozhodovat.

K ČEMU TO JE:
- Ověříme, že máme všechny potřebné vstupy:
  - Sport Completion
  - AI Recommendations
  - Candidate Ranking
  - Autonomous Queue
  - Execution History

KDE TO UVIDÍME:
- Výsledek v DBeaveru.

JAK SE TO VYUŽIJE:
- Na základě výsledku navrhneme finální Brain Score.
- Brain bude rozhodovat RUN / WAIT / HOLD / SKIP.
*/

SELECT
    'SPORT_COMPLETION' AS source_type,
    COUNT(*) AS row_count
FROM ops.v_sport_completion_dashboard_v2

UNION ALL

SELECT
    'AI_RECOMMENDATIONS',
    COUNT(*)
FROM ops.v_panel_ai_recommendations_v1

UNION ALL

SELECT
    'AUTONOMOUS_RANKING',
    COUNT(*)
FROM ops.v_autonomous_candidate_ranking_v1

UNION ALL

SELECT
    'AUTONOMOUS_QUEUE',
    COUNT(*)
FROM ops.v_autonomous_execution_queue_v1

UNION ALL

SELECT
    'ACTION_HISTORY',
    COUNT(*)
FROM ops.ai_action_execution_log

ORDER BY 1;