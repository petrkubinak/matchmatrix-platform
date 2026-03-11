INSERT INTO ops.sports_import_plan
(
    sport_code, sport_name, enabled, priority, mode, provider,
    daily_request_budget, max_parallel_jobs,
    history_days_back, fixtures_days_forward, odds_days_forward, notes
)
VALUES
('football',      'Football',      true,  10, 'bootstrap', 'api-sports', 7500, 2, 3650, 14, 3, 'Nejširší coverage, top priorita'),
('hockey',        'Hockey',        true,  20, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Lední hokej'),
('basketball',    'Basketball',    true,  30, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Silný globální sport'),
('tennis',        'Tennis',        true,  40, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Velké množství turnajů'),
('mma',           'MMA',           true,  50, 'bootstrap', 'api-sports', 7500, 1, 3650, 30, 7, 'Eventový sport'),
('volleyball',    'Volleyball',    true,  60, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Ligy + reprezentace'),
('handball',      'Handball',      true,  70, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Evropsky silné'),
('baseball',      'Baseball',      true,  80, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'USA + další ligy'),
('rugby',         'Rugby',         true,  90, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Union / League dle coverage'),
('cricket',       'Cricket',       true, 100, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Velký objem dat'),
('field_hockey',  'Field Hockey',  true, 110, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Pozemní hokej'),
('american_football', 'American Football', true, 120, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'NFL + další'),
('esports',       'Esports',       true, 130, 'bootstrap', 'api-sports', 7500, 1, 3650, 14, 3, 'Jen pokud provider podporuje')
ON CONFLICT (sport_code) DO NOTHING;