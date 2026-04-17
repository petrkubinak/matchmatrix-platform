-- =====================================================================
-- 217_fb_team_merge_batch_1_current.sql
-- MatchMatrix - aktuální merge batch #1
-- Bez Vitesse, jen existující kandidáti
-- =====================================================================

-- =========================
-- Almeria -> keep 1158
-- =========================
SELECT public.merge_team(12871, 1158, 'merge Almeria dup', 'FB_MULTI_MATCH', true, true);
SELECT public.merge_team(25856, 1158, 'merge Almeria dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- Cambuur -> keep 1114
-- =========================
SELECT public.merge_team(12180, 1114, 'merge Cambuur dup', 'FB_MULTI_MATCH', true, true);
SELECT public.merge_team(27530, 1114, 'merge Cambuur dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- Crotone -> keep 1090
-- =========================
SELECT public.merge_team(14302, 1090, 'merge Crotone dup', 'FB_MULTI_MATCH', true, true);
SELECT public.merge_team(26935, 1090, 'merge Crotone dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- Eibar -> keep 1161
-- =========================
SELECT public.merge_team(12429, 1161, 'merge Eibar dup', 'FB_MULTI_MATCH', true, true);
SELECT public.merge_team(27752, 1161, 'merge Eibar dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- Empoli -> keep 1083
-- =========================
SELECT public.merge_team(12135, 1083, 'merge Empoli dup', 'FB_MULTI_MATCH', true, true);
SELECT public.merge_team(27097, 1083, 'merge Empoli dup', 'FB_MULTI_MATCH', true, true);