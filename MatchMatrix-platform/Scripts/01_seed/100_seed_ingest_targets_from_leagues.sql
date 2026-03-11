INSERT INTO public.sports (code, name)
VALUES
('FB',  'Football'),
('HK',  'Hockey'),
('BK',  'Basketball'),
('TN',  'Tennis'),
('MMA', 'MMA'),
('VB',  'Volleyball'),
('HB',  'Handball'),
('BSB', 'Baseball'),
('RGB', 'Rugby'),
('CK',  'Cricket'),
('FH',  'Field Hockey'),
('AFB', 'American Football'),
('ESP', 'Esports')
ON CONFLICT (code) DO NOTHING;