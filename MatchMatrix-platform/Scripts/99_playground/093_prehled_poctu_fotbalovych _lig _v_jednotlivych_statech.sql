SELECT
  country,
  COUNT(*) AS leagues
FROM staging.api_football_leagues
GROUP BY country
ORDER BY leagues DESC;

SELECT league_id, name, country, type, is_cup, is_international
FROM staging.api_football_leagues
WHERE country IN ('England','Spain','Italy','Germany','France','Portugal','Netherlands','Belgium','Scotland',
                 'Austria','Switzerland','Czech Republic','Poland','Turkey','Greece','Denmark','Sweden','Norway',
                 'Serbia','Croatia','Ukraine','Romania','Bulgaria','Slovakia','Hungary','Slovenia','Finland','Ireland',
                 'Wales','Iceland')
ORDER BY country, name;


CREATE SCHEMA IF NOT EXISTS work;

CREATE TABLE IF NOT EXISTS work.leagues_to_add (
  provider text NOT NULL,
  provider_league_id int NOT NULL,
  sport_code text NOT NULL DEFAULT 'football',
  notes text NULL,
  PRIMARY KEY (provider, provider_league_id)
  
INSERT INTO work.leagues_to_add(provider, provider_league_id, notes)
SELECT 'api_football', league_id, 'EU batch 1'
FROM staging.api_football_leagues
WHERE country IN ('England','Spain','Italy','Germany','France','Portugal','Netherlands','Belgium','Scotland')
ON CONFLICT DO NOTHING;

