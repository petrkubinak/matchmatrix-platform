/*
MATCHMATRIX SQL 111_R
AUDIT AI RECOMMENDATION COLUMNS V1

CO TO JE:
- Kontrola sloupců existujících AI recommendation / autonomous OPS view.

K ČEMU TO JE:
- Abychom zjistili, jestli už view obsahují sport, vrstvu, worker, důvod, skóre a doporučenou akci.

KDE TO UVIDÍME:
- Výsledek v DBeaveru.

JAK SE TO VYUŽIJE:
- Podle výsledku upravíme 111_R jako nové sjednocující view,
  nebo rozšíříme existující v_panel_ai_recommendations_v1.
*/

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name IN (
      'v_panel_ai_recommendations_v1',
      'v_panel_ai_recommendations_summary_v1',
      'v_ai_ops_actions_queue_v1',
      'v_autonomous_next_ranked_candidate_v1',
      'v_autonomous_candidate_ranking_v1',
      'v_autonomous_execution_queue_v1'
  )
ORDER BY
    table_name,
    ordinal_position;