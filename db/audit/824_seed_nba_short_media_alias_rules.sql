-- 824_seed_nba_short_media_alias_rules.sql
-- NBA short MEDIA alias rules

INSERT INTO public.media_team_alias_rules (
    sport_code,
    provider,
    team_name,
    alias_slug
)
VALUES
('BK', 'nba_official_site', 'Los Angeles Lakers', 'lakers'),
('BK', 'nba_official_site', 'Oklahoma City Thunder', 'thunder'),
('BK', 'nba_official_site', 'New York Knicks', 'knicks'),
('BK', 'nba_official_site', 'Cleveland Cavaliers', 'cavaliers'),
('BK', 'nba_official_site', 'Minnesota Timberwolves', 'timberwolves'),
('BK', 'nba_official_site', 'San Antonio Spurs', 'spurs'),
('BK', 'nba_official_site', 'Philadelphia 76ers', '76ers'),
('BK', 'nba_official_site', 'Denver Nuggets', 'nuggets'),
('BK', 'nba_official_site', 'Golden State Warriors', 'warriors')
ON CONFLICT (sport_code, provider, alias_slug)
DO UPDATE SET
    team_name = EXCLUDED.team_name,
    is_active = true,
    updated_at = now();

SELECT
    sport_code,
    provider,
    team_name,
    alias_slug,
    is_active
FROM public.media_team_alias_rules
WHERE sport_code = 'BK'
  AND provider = 'nba_official_site'
ORDER BY team_name, alias_slug;