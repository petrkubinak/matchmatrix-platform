INSERT INTO public.data_providers
(
    code,
    name
)
VALUES
('transfermarkt','Transfermarkt'),
('betfair','Betfair Exchange API'),
('pinnacle','Pinnacle Odds API'),
('sportmonks','SportMonks Football API'),
('opta','Opta Sports Data'),
('internal','MatchMatrix Internal Data')

ON CONFLICT (code) DO UPDATE
SET
name = EXCLUDED.name;