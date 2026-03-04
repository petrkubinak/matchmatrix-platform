-- MLS - doplníme ext_league_id až ho vytáhne Python (vypíše do konzole)
-- sport_id = 1 (soccer), tier = 1
INSERT INTO leagues (
  sport_id, name, country, ext_source, ext_league_id, tier, is_cup, is_international
)
VALUES
  (1, 'MLS', 'USA', 'api_football', NULL, 1, false, false);

-- Pozn.: ext_league_id pak updatujeme přes UPDATE podle výstupu z Pythonu