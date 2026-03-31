-- AUTO INSERT THEODDS ALIASES (napojení přes LIKE match)

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Flamengo-RJ', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%flamengo%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Fluminense-RJ', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%fluminense%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Corinthians-SP', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%corinthians%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Palmeiras-SP', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%palmeiras%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Lanus', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%lanus%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Peñarol Montevideo', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%penarol%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Libertad Asuncion', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%libertad%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'LDU Quito', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%quito%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Boca Juniors', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%boca%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Cerro Porteño', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%cerro%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Junior FC', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%junior%'
ON CONFLICT DO NOTHING;

INSERT INTO public.team_aliases (team_id, alias, source)
SELECT t.id, 'Rosario Central', 'theodds'
FROM public.teams t
WHERE lower(t.name) LIKE '%rosario%'
ON CONFLICT DO NOTHING;