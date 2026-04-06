-- 496_q_merge_union_berlin.sql
-- Cíl:
-- sloučit duplicitní tým Union Berlin:
-- OLD  = 27654 (Union Berlin)
-- NEW  = 533   (1. FC Union Berlin)

BEGIN;

SELECT public.merge_team(
    27654,                         -- old team_id
    533,                           -- new team_id
    'Audit 496: Bundesliga duplicate cleanup',
    'audit_496_merge_union_berlin',
    true,                          -- delete old
    true                           -- create alias
);

COMMIT;