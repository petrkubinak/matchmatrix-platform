-- 511_batch_merge_remaining_duplicates.sql
-- Cíl:
-- sloučit zbývající duplicitní týmy (api_football → football_data)

-- =========================================================
-- PSG
-- =========================================================
SELECT public.merge_team(12109, 89, 'batch merge PSG', 'batch_511', true, true);

-- Atlético Madrid
SELECT public.merge_team(12083, 79, 'batch merge Atletico', 'batch_511', true, true);

-- Villarreal
SELECT public.merge_team(12086, 82, 'batch merge Villarreal', 'batch_511', true, true);

-- Real Betis
SELECT public.merge_team(12094, 618, 'batch merge Betis', 'batch_511', true, true);

-- Getafe
SELECT public.merge_team(27486, 613, 'batch merge Getafe', 'batch_511', true, true);

-- Valencia
SELECT public.merge_team(12085, 621, 'batch merge Valencia', 'batch_511', true, true);

-- Real Sociedad
SELECT public.merge_team(12097, 619, 'batch merge Sociedad', 'batch_511', true, true);

-- Mallorca
SELECT public.merge_team(12101, 617, 'batch merge Mallorca', 'batch_511', true, true);

-- Rayo Vallecano
SELECT public.merge_team(12100, 615, 'batch merge Rayo', 'batch_511', true, true);

-- Girona
SELECT public.merge_team(12096, 624, 'batch merge Girona', 'batch_511', true, true);

-- Espanyol
SELECT public.merge_team(25884, 611, 'batch merge Espanyol', 'batch_511', true, true);

-- Celta Vigo
SELECT public.merge_team(12090, 625, 'batch merge Celta', 'batch_511', true, true);

-- Osasuna
SELECT public.merge_team(12093, 622, 'batch merge Osasuna', 'batch_511', true, true);