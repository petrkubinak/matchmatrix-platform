-- =========================================================
-- MatchMatrix
-- Soubor: 2026-03-29_02_seed_standings_rules.sql
-- Účel: seed pravidel bodování pro standings
-- =========================================================

-- Football (3-1-0)
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    3, 1, 0,
    true,
    'Football standard 3-1-0',
    true
FROM public.sports
WHERE code = 'FB'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- Hockey (základní varianta, později doladíme OT/SO)
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    3, 0, 0,
    false,
    'Hockey basic',
    true
FROM public.sports
WHERE code = 'HK'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- Basketball
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    2, 0, 0,
    false,
    'Basketball standard',
    true
FROM public.sports
WHERE code = 'BK'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- Volleyball
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    3, 0, 0,
    false,
    'Volleyball basic',
    true
FROM public.sports
WHERE code = 'VB'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- Handball
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    2, 1, 0,
    true,
    'Handball standard',
    true
FROM public.sports
WHERE code = 'HB'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- Baseball
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    1, 0, 0,
    false,
    'Baseball win-loss',
    true
FROM public.sports
WHERE code = 'BSB'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- Rugby
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    4, 2, 0,
    true,
    'Rugby standard without bonus points',
    true
FROM public.sports
WHERE code = 'RGB'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- Cricket
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    2, 1, 0,
    true,
    'Cricket basic',
    true
FROM public.sports
WHERE code = 'CK'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- Field Hockey
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    3, 1, 0,
    true,
    'Field Hockey standard',
    true
FROM public.sports
WHERE code = 'FH'
ON CONFLICT (sport_id, league_id) DO NOTHING;

-- American Football
INSERT INTO public.standings_rules (
    sport_id,
    league_id,
    win_points,
    draw_points,
    loss_points,
    allow_draws,
    rules_name,
    is_default
)
SELECT
    id,
    NULL,
    1, 0, 0,
    false,
    'American Football win-loss',
    true
FROM public.sports
WHERE code = 'AFB'
ON CONFLICT (sport_id, league_id) DO NOTHING;