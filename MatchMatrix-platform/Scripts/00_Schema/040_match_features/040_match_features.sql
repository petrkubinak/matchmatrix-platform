create table if not exists match_features (
  match_id bigint primary key references matches(id) on delete cascade,

  -- team form
  home_last5_points integer,
  away_last5_points integer,

  home_last5_gf numeric,
  home_last5_ga numeric,
  away_last5_gf numeric,
  away_last5_ga numeric,

  -- rest
  home_rest_days integer,
  away_rest_days integer,

  -- h2h
  h2h_last5_goal_diff integer,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_match_features_updated_at
on match_features(updated_at);
