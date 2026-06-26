-- ============================================
-- 230a_seed_multisport_leagues.sql
-- Minimal multisport leagues pro FK do ops.ingest_targets
-- ============================================

BEGIN;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (10001, 'ATP Tour', 'Global', 4)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (10002, 'WTA Tour', 'Global', 4)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (11001, 'UFC', 'Global', 9)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (12001, 'FIVB', 'Global', 10)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (13001, 'EHF', 'Europe', 11)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (14001, 'MLB', 'USA', 12)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (15001, 'Six Nations', 'Europe', 13)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (16001, 'IPL', 'India', 14)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (17001, 'FIH', 'Global', 15)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (18001, 'NFL', 'USA', 16)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (19001, 'CSGO', 'Global', 17)
ON CONFLICT DO NOTHING;

INSERT INTO public.leagues (id, name, country, sport_id)
VALUES (20001, 'PDC', 'Global', 23)
ON CONFLICT DO NOTHING;

COMMIT;

SELECT id, name, sport_id
FROM public.leagues
WHERE id >= 10000
ORDER BY id;