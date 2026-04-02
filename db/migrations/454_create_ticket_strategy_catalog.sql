-- 454_create_ticket_strategy_catalog.sql
-- Katalog strategií pro budoucí škálování více typů tiketů

CREATE TABLE IF NOT EXISTS public.ticket_strategy_catalog (
    id bigserial PRIMARY KEY,
    strategy_code text NOT NULL UNIQUE,
    strategy_family text NOT NULL,
    strategy_variant text NOT NULL,
    ticket_type text NOT NULL,
    risk_profile text NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    is_test_only boolean NOT NULL DEFAULT false,
    worker_script text,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO public.ticket_strategy_catalog (
    strategy_code,
    strategy_family,
    strategy_variant,
    ticket_type,
    risk_profile,
    is_active,
    is_test_only,
    worker_script,
    notes
)
VALUES
(
    'AUTO_SAFE_01',
    'SAFE',
    '01',
    'PREMATCH_1X2',
    'LOW',
    true,
    false,
    'workers/436_auto_safe_seeder_v3.py',
    'Konzervativní safe varianta'
),
(
    'AUTO_SAFE_02',
    'SAFE',
    '02',
    'PREMATCH_1X2',
    'HIGH',
    true,
    true,
    'workers/436_auto_safe_seeder_v3.py',
    'Agresivní testovací safe varianta'
),
(
    'AUTO_SAFE_03',
    'SAFE',
    '03',
    'PREMATCH_1X2',
    'MID',
    true,
    false,
    'workers/436_auto_safe_seeder_v3.py',
    'Střední safe varianta'
)
ON CONFLICT (strategy_code) DO UPDATE
SET
    strategy_family = EXCLUDED.strategy_family,
    strategy_variant = EXCLUDED.strategy_variant,
    ticket_type = EXCLUDED.ticket_type,
    risk_profile = EXCLUDED.risk_profile,
    is_active = EXCLUDED.is_active,
    is_test_only = EXCLUDED.is_test_only,
    worker_script = EXCLUDED.worker_script,
    notes = EXCLUDED.notes,
    updated_at = now();