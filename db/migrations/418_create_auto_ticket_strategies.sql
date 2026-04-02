-- 418_create_auto_ticket_strategies.sql
-- První tabulka pro definici AUTO ticket strategií
-- SAFE_01 / SAFE_02 / SAFE_03

CREATE TABLE IF NOT EXISTS public.auto_ticket_strategies (
    id BIGSERIAL PRIMARY KEY,
    strategy_code TEXT NOT NULL UNIQUE,
    strategy_name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    sport_code TEXT NULL,
    bookmaker_id INTEGER NULL,

    fix_count INTEGER NOT NULL,
    block_a_count INTEGER NOT NULL DEFAULT 0,
    block_b_count INTEGER NOT NULL DEFAULT 0,
    block_c_count INTEGER NOT NULL DEFAULT 0,

    fix_min_odd NUMERIC(10,4) NULL,
    fix_max_odd NUMERIC(10,4) NULL,

    block_mode TEXT NOT NULL DEFAULT 'balanced_high',
    block_similarity_mode TEXT NOT NULL DEFAULT 'same_profile',

    selection_rules_json JSONB NULL,
    notes TEXT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- updated_at trigger
DROP TRIGGER IF EXISTS trg_auto_ticket_strategies_updated_at ON public.auto_ticket_strategies;

CREATE TRIGGER trg_auto_ticket_strategies_updated_at
BEFORE UPDATE ON public.auto_ticket_strategies
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- seed SAFE strategie
INSERT INTO public.auto_ticket_strategies (
    strategy_code,
    strategy_name,
    is_active,
    sport_code,
    bookmaker_id,
    fix_count,
    block_a_count,
    block_b_count,
    block_c_count,
    fix_min_odd,
    fix_max_odd,
    block_mode,
    block_similarity_mode,
    selection_rules_json,
    notes
)
VALUES
(
    'SAFE_01',
    'SAFE 01 | 4 fix + A1 + B1',
    TRUE,
    'FB',
    NULL,
    4,
    1,
    1,
    0,
    1.20,
    1.50,
    'balanced_high',
    'same_profile',
    jsonb_build_object(
        'fix_pick_mode', 'favorite_only',
        'fix_odds_band', jsonb_build_object('min', 1.20, 'max', 1.50),
        'block_pick_mode', 'balanced_matches_highest_odds',
        'block_similarity', 'same_criteria',
        'require_1x2_odds', true
    ),
    'SAFE strategie: 4 fixy v pásmu 1.20-1.50, blok A 1 zápas, blok B 1 zápas, blokové zápasy vyrovnané s co nejvyššími kurzy.'
),
(
    'SAFE_02',
    'SAFE 02 | 5 fix + A2 + B2',
    TRUE,
    'FB',
    NULL,
    5,
    2,
    2,
    0,
    1.20,
    1.50,
    'balanced_high',
    'same_profile',
    jsonb_build_object(
        'fix_pick_mode', 'favorite_only',
        'fix_odds_band', jsonb_build_object('min', 1.20, 'max', 1.50),
        'block_pick_mode', 'balanced_matches_highest_odds',
        'block_similarity', 'same_criteria',
        'require_1x2_odds', true
    ),
    'SAFE strategie: 5 fixů v pásmu 1.20-1.50, blok A 2 zápasy, blok B 2 zápasy, v blocích podobné zápasy se stejnými kritérii.'
),
(
    'SAFE_03',
    'SAFE 03 | 3 fix + A1 + B1',
    TRUE,
    'FB',
    NULL,
    3,
    1,
    1,
    0,
    1.50,
    1.80,
    'balanced_high',
    'same_profile',
    jsonb_build_object(
        'fix_pick_mode', 'favorite_only',
        'fix_odds_band', jsonb_build_object('min', 1.50, 'max', 1.80),
        'block_pick_mode', 'balanced_matches_highest_odds',
        'block_similarity', 'same_criteria',
        'require_1x2_odds', true
    ),
    'SAFE strategie: 3 fixy v pásmu 1.50-1.80, blok A 1 zápas, blok B 1 zápas, blokové zápasy vyrovnané s co nejvyššími kurzy.'
)
ON CONFLICT (strategy_code) DO UPDATE
SET
    strategy_name = EXCLUDED.strategy_name,
    is_active = EXCLUDED.is_active,
    sport_code = EXCLUDED.sport_code,
    bookmaker_id = EXCLUDED.bookmaker_id,
    fix_count = EXCLUDED.fix_count,
    block_a_count = EXCLUDED.block_a_count,
    block_b_count = EXCLUDED.block_b_count,
    block_c_count = EXCLUDED.block_c_count,
    fix_min_odd = EXCLUDED.fix_min_odd,
    fix_max_odd = EXCLUDED.fix_max_odd,
    block_mode = EXCLUDED.block_mode,
    block_similarity_mode = EXCLUDED.block_similarity_mode,
    selection_rules_json = EXCLUDED.selection_rules_json,
    notes = EXCLUDED.notes,
    updated_at = NOW();

-- kontrola
SELECT
    id,
    strategy_code,
    strategy_name,
    sport_code,
    bookmaker_id,
    fix_count,
    block_a_count,
    block_b_count,
    block_c_count,
    fix_min_odd,
    fix_max_odd,
    block_mode,
    block_similarity_mode,
    is_active
FROM public.auto_ticket_strategies
ORDER BY id;