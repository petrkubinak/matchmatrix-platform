-- 1. Seznam aktivních lig (pro levé menu / hamburger)
CREATE OR REPLACE VIEW public.v_web_active_leagues AS
SELECT 
    l.id,
    l.name,
    l.country,
    l.is_cup,
    (SELECT count(*) FROM public.matches m WHERE m.league_id = l.id AND m.kickoff > now()) as upcoming_matches_count
FROM public.leagues l
JOIN ops.ingest_targets it ON l.id = it.canonical_league_id
WHERE it.enabled = true
ORDER BY l.tier ASC, l.name ASC;

-- 2. Dnešní a zítřejší zápasy (hlavní zeď ve stylu Livesport)
CREATE OR REPLACE VIEW public.v_web_fixtures AS
SELECT 
    m.id as match_id,
    m.kickoff,
    l.name as league_name,
    t1.name as home_team,
    t2.name as away_team,
    o.back_1, o.back_x, o.back_2, -- kurzy
    m.status
FROM public.matches m
JOIN public.leagues l ON m.league_id = l.id
JOIN public.teams t1 ON m.home_team_id = t1.id
JOIN public.teams t2 ON m.away_team_id = t2.id
LEFT JOIN public.odds o ON m.id = o.match_id
WHERE m.kickoff BETWEEN now() - interval '2 hours' AND now() + interval '48 hours'
ORDER BY m.kickoff ASC;

-- 3. Náhled Ticket Builderu (volá Vaši novou logiku 27 variant)
CREATE OR REPLACE VIEW public.v_web_ticket_calculation AS
SELECT 
    t.id as template_id,
    t.name as ticket_name,
    public.generate_run(t.id) as calculation_results -- tady voláme Váš "mozek"
FROM public.templates t;