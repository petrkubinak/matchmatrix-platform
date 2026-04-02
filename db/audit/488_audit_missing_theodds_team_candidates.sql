-- 488_audit_missing_theodds_team_candidates.sql
-- Cíl:
-- pro 11 chybějících názvů z TheOdds najít kandidáty v public.teams

WITH missing_names AS (
    SELECT 'Czech Republic' AS team_name
    UNION ALL SELECT 'Deportes Tolima'
    UNION ALL SELECT 'DR Congo'
    UNION ALL SELECT 'Estudiantes La Plata'
    UNION ALL SELECT 'FC Zwolle'
    UNION ALL SELECT 'Iraq'
    UNION ALL SELECT 'Junior FC'
    UNION ALL SELECT 'Lanus'
    UNION ALL SELECT 'Peñarol Montevideo'
    UNION ALL SELECT 'Rosario Central'
    UNION ALL SELECT 'Sporting Cristal'
)
SELECT
    mn.team_name AS missing_theodds_name,
    t.id AS candidate_team_id,
    t.name AS candidate_team_name,
    t.ext_source,
    t.ext_team_id
FROM missing_names mn
LEFT JOIN public.teams t
  ON lower(t.name) LIKE '%' || lower(mn.team_name) || '%'
   OR lower(mn.team_name) LIKE '%' || lower(t.name) || '%'
ORDER BY
    mn.team_name,
    t.name,
    t.id;