-- 490_insert_missing_theodds_teams.sql
-- vytvoření chybějících týmů

INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id
)
VALUES
    ('Deportes Tolima', 'theodds', NULL),
    ('DR Congo', 'theodds', NULL),
    ('Estudiantes La Plata', 'theodds', NULL),
    ('FC Zwolle', 'theodds', NULL),
    ('Iraq', 'theodds', NULL),
    ('Lanus', 'theodds', NULL),
    ('Peñarol Montevideo', 'theodds', NULL)
ON CONFLICT DO NOTHING;

-- kontrola
SELECT id, name, ext_source
FROM public.teams
WHERE name IN (
    'Deportes Tolima',
    'DR Congo',
    'Estudiantes La Plata',
    'FC Zwolle',
    'Iraq',
    'Lanus',
    'Peñarol Montevideo'
)
ORDER BY name;