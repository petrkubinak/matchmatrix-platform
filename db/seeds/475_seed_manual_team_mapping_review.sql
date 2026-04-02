-- 475_seed_manual_team_mapping_review.sql
-- Ruční seed pro známé naming rozdíly

INSERT INTO public.canonical_team_map (
    canonical_team_id,
    provider,
    provider_team_id,
    status,
    note
)
VALUES

-- England
(55, 'api_football', 50, 'review', 'Manchester United FC ↔ Manchester United'),
(29, 'api_football', 60, 'review', 'West Bromwich Albion FC ↔ West Brom'),
(26, 'api_football', 63, 'review', 'Queens Park Rangers FC ↔ QPR'),
(41, 'api_football', 70, 'review', 'Sheffield United FC ↔ Sheffield Utd'),

-- France
(89, 'api_football', 85, 'review', 'Paris Saint-Germain FC ↔ Paris Saint Germain'),

-- Italy
(84, 'api_football', 75, 'review', 'FC Internazionale Milano ↔ Inter Milan'),

-- Portugal
(99, 'api_football', 90, 'review', 'Sport Lisboa e Benfica ↔ Benfica'),
(87, 'api_football', 91, 'review', 'Sporting Clube de Portugal ↔ Sporting CP')

ON CONFLICT (canonical_team_id, provider, provider_team_id) DO NOTHING;