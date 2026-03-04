-- Speed up common feature queries: last N finished games by team
create index if not exists idx_matches_home_finished_kickoff
on matches(home_team_id, kickoff)
where status = 'FINISHED';

create index if not exists idx_matches_away_finished_kickoff
on matches(away_team_id, kickoff)
where status = 'FINISHED';

create index if not exists idx_matches_league_kickoff
on matches(league_id, kickoff);

create index if not exists idx_matches_sport_kickoff
on matches(sport_id, kickoff);

-- Dedupe/upsert safety: provider match id
create unique index if not exists ux_matches_ext_source_match
on matches(ext_source, ext_match_id);
