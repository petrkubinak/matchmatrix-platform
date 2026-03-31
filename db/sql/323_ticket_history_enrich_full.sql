-- 323_ticket_history_enrich_full.sql
-- Enrich ticket_history_base o sporty a ligy
-- připraveno i pro budoucí multisport použití

ALTER TABLE public.ticket_history_base
ADD COLUMN IF NOT EXISTS sport_count integer,
ADD COLUMN IF NOT EXISTS sport_signature text,
ADD COLUMN IF NOT EXISTS league_count integer,
ADD COLUMN IF NOT EXISTS league_signature text;

WITH src AS (
    SELECT
        thb.id,
        COUNT(DISTINCT s.id) AS sport_count,
        STRING_AGG(DISTINCT s.code, '+' ORDER BY s.code) AS sport_signature,
        COUNT(DISTINCT l.id) AS league_count,
        STRING_AGG(DISTINCT l.name, ' | ' ORDER BY l.name) AS league_signature
    FROM public.ticket_history_base thb
    LEFT JOIN public.generated_ticket_fixed gtf
        ON gtf.run_id = thb.run_id
    LEFT JOIN public.matches m
        ON m.id = gtf.match_id
    LEFT JOIN public.leagues l
        ON l.id = m.league_id
    LEFT JOIN public.sports s
        ON s.id = l.sport_id
    GROUP BY thb.id
)
UPDATE public.ticket_history_base thb
SET
    sport_count = src.sport_count,
    sport_signature = src.sport_signature,
    league_count = src.league_count,
    league_signature = src.league_signature
FROM src
WHERE thb.id = src.id;