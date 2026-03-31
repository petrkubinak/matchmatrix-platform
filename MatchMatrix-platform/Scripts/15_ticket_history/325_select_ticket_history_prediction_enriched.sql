SELECT column_name
FROM information_schema.columns
WHERE table_name = 'ticket_history_base'
ORDER BY ordinal_position;

WITH src AS (
    SELECT
        thb.id,
        COUNT(DISTINCT l.id) AS league_count,
        STRING_AGG(DISTINCT l.name, ' | ' ORDER BY l.name) AS league_signature
    FROM public.ticket_history_base thb
    LEFT JOIN public.generated_ticket_fixed gtf
        ON gtf.run_id = thb.run_id
    LEFT JOIN public.matches m
        ON m.id = gtf.match_id
    LEFT JOIN public.leagues l
        ON l.id = m.league_id
    GROUP BY thb.id
)
UPDATE public.ticket_history_base thb
SET
    league_count = src.league_count,
    league_signature = src.league_signature
FROM src
WHERE thb.id = src.id;