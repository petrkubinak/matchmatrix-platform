-- 319_ticket_history_sport_features.sql
-- Přidání sport_count a sport_signature do ticket_history_base

-- 1️⃣ přidání sloupců
ALTER TABLE public.ticket_history_base
ADD COLUMN IF NOT EXISTS sport_count integer,
ADD COLUMN IF NOT EXISTS sport_signature text;

-- 2️⃣ update hodnot ze snapshotu
UPDATE public.ticket_history_base thb
SET
    sport_count = s.sport_count,
    sport_signature = s.sport_signature
FROM (
    SELECT
        thb.id,

        COUNT(DISTINCT blk.sport_code) AS sport_count,

        STRING_AGG(DISTINCT blk.sport_code, '+' ORDER BY blk.sport_code) AS sport_signature

    FROM public.ticket_history_base thb

    LEFT JOIN LATERAL (
        SELECT
            COALESCE(b ->> 'sport_code', 'UNK') AS sport_code
        FROM jsonb_array_elements(COALESCE(thb.ticket_payload -> 'blocks', '[]'::jsonb)) b
    ) blk ON TRUE

    GROUP BY thb.id
) s
WHERE thb.id = s.id;