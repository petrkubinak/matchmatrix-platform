-- =====================================================================
-- 216_fb_merge_candidates_existence_audit.sql
-- MatchMatrix - ověření, které candidate team_id ještě existují
-- =====================================================================

WITH candidates AS (
    SELECT 'Vitesse'::text AS team_name, 1113::bigint AS candidate_team_id UNION ALL
    SELECT 'Vitesse', 13027 UNION ALL
    SELECT 'Vitesse', 25793 UNION ALL
    SELECT 'Vitesse', 26481 UNION ALL

    SELECT 'Almeria', 1158 UNION ALL
    SELECT 'Almeria', 12871 UNION ALL
    SELECT 'Almeria', 25856 UNION ALL

    SELECT 'Cambuur', 1114 UNION ALL
    SELECT 'Cambuur', 12180 UNION ALL
    SELECT 'Cambuur', 27530 UNION ALL

    SELECT 'Crotone', 1090 UNION ALL
    SELECT 'Crotone', 14302 UNION ALL
    SELECT 'Crotone', 26935 UNION ALL

    SELECT 'Eibar', 1161 UNION ALL
    SELECT 'Eibar', 12429 UNION ALL
    SELECT 'Eibar', 27752 UNION ALL

    SELECT 'Empoli', 1083 UNION ALL
    SELECT 'Empoli', 12135 UNION ALL
    SELECT 'Empoli', 27097
)
SELECT
    c.team_name,
    c.candidate_team_id,
    t.id AS existing_team_id,
    t.name AS existing_team_name,
    t.ext_source,
    t.ext_team_id
FROM candidates c
LEFT JOIN public.teams t
  ON t.id = c.candidate_team_id
ORDER BY c.team_name, c.candidate_team_id;

-- =====================================================================
-- KONTROLA 2 - shrnutí po názvech
-- =====================================================================
WITH candidates AS (
    SELECT 'Vitesse'::text AS team_name, 1113::bigint AS candidate_team_id UNION ALL
    SELECT 'Vitesse', 13027 UNION ALL
    SELECT 'Vitesse', 25793 UNION ALL
    SELECT 'Vitesse', 26481 UNION ALL

    SELECT 'Almeria', 1158 UNION ALL
    SELECT 'Almeria', 12871 UNION ALL
    SELECT 'Almeria', 25856 UNION ALL

    SELECT 'Cambuur', 1114 UNION ALL
    SELECT 'Cambuur', 12180 UNION ALL
    SELECT 'Cambuur', 27530 UNION ALL

    SELECT 'Crotone', 1090 UNION ALL
    SELECT 'Crotone', 14302 UNION ALL
    SELECT 'Crotone', 26935 UNION ALL

    SELECT 'Eibar', 1161 UNION ALL
    SELECT 'Eibar', 12429 UNION ALL
    SELECT 'Eibar', 27752 UNION ALL

    SELECT 'Empoli', 1083 UNION ALL
    SELECT 'Empoli', 12135 UNION ALL
    SELECT 'Empoli', 27097
),
resolved AS (
    SELECT
        c.team_name,
        c.candidate_team_id,
        CASE WHEN t.id IS NOT NULL THEN 1 ELSE 0 END AS exists_flag
    FROM candidates c
    LEFT JOIN public.teams t
      ON t.id = c.candidate_team_id
)
SELECT
    team_name,
    COUNT(*) AS candidate_count_from_export,
    SUM(exists_flag) AS candidate_count_existing_now
FROM resolved
GROUP BY team_name
ORDER BY team_name;