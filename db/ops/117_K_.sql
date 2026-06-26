INSERT INTO ops.odds_provider_roadmap
(
provider_code,
provider_name,
sport_code,
free_available,
paid_available,
historical_odds,
live_odds,
pre_match_odds,
implementation_priority,
provider_status,
next_action
)
VALUES

('api_football','API Football','FB',true,true,true,true,true,10,'REVIEW','Ověřit odds endpointy'),
('theodds','The Odds API','FB',true,true,true,true,true,20,'PARTIAL','Rozšířit coverage'),

('api_hockey','API Hockey','HK',false,true,false,false,false,30,'RESEARCH','Prověřit odds dostupnost'),
('api_sport','API Basketball','BK',false,true,false,false,false,30,'RESEARCH','Prověřit odds dostupnost'),

('oddspapi','OddsPapi','FB',true,true,true,true,true,40,'RESEARCH','Otestovat free tier'),
('oddspapi','OddsPapi','HK',true,true,true,true,true,40,'RESEARCH','Otestovat free tier'),
('oddspapi','OddsPapi','BK',true,true,true,true,true,40,'RESEARCH','Otestovat free tier'),
('oddspapi','OddsPapi','TN',true,true,true,true,true,40,'RESEARCH','Otestovat free tier'),
('oddspapi','OddsPapi','HB',true,true,true,true,true,40,'RESEARCH','Otestovat free tier'),
('oddspapi','OddsPapi','VB',true,true,true,true,true,40,'RESEARCH','Otestovat free tier'),

('sportsgameodds','SportsGameOdds','AFB',true,true,true,true,true,50,'RESEARCH','Otestovat NFL odds'),
('sportsgameodds','SportsGameOdds','BK',true,true,true,true,true,50,'RESEARCH','Otestovat NBA odds'),

('goalserve','GoalServe','FB',false,true,true,true,true,60,'RESEARCH','Vyhodnotit cenu'),
('sportsdataio','SportsDataIO','AFB',false,true,true,true,true,70,'RESEARCH','Vyhodnotit cenu'),
('lsports','LSports','FB',false,true,true,true,true,80,'RESEARCH','Enterprise varianta');