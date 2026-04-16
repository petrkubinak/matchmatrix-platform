-- 496_d_seed_missing_team_aliases_FIX2.sql
-- FIX2:
-- 1) kontrola existence jen podle alias
-- 2) deduplikace teams -> 1 team_id na team_name

WITH alias_seed(team_name, alias) AS (
    VALUES
        ('Grêmio', 'gremio'),
        ('1. FC Heidenheim', '1 heidenheim'),
        ('FC St. Pauli', 'saint pauli'),
        ('Club Always Ready', 'always ready'),
        ('Club Bolívar', 'bolivar'),
        ('Cerro Porteño', 'cerro porteno'),
        ('Cusco FC', 'cusco'),
        ('Peñarol Montevideo', 'penarol montevideo'),
        ('UCV FC', 'ucv'),
        ('Universidad Católica (CHI)', 'universidad catolica chi'),
        ('Corinthians-SP', 'corinthians sp'),
        ('Flamengo-RJ', 'flamengo rj'),
        ('Independiente Medellín', 'independiente medellin'),
        ('Junior FC', 'junior'),
        ('Deportivo La Guaira', 'la guaira'),
        ('Palmeiras-SP', 'palmeiras sp'),
        ('Club Universitario de Deportes', 'universitario de deportes')
),
team_pick AS (
    SELECT
        LOWER(t.name) AS team_name_key,
        MIN(t.id) AS team_id
    FROM public.teams t
    GROUP BY LOWER(t.name)
)
INSERT INTO public.team_aliases (team_id, alias, source)
SELECT
    tp.team_id,
    s.alias,
    'audit_496_missing_team_alias'
FROM alias_seed s
JOIN team_pick tp
  ON tp.team_name_key = LOWER(s.team_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE LOWER(a.alias) = LOWER(s.alias)
);