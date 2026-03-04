-- 1) Ratingy na úrovni zápasu (abychom měli pre-match rating pro trénink i predikce)
CREATE TABLE IF NOT EXISTS mm_match_ratings (
  match_id       BIGINT PRIMARY KEY,
  league_id      BIGINT NOT NULL,
  kickoff        TIMESTAMPTZ NOT NULL,
  home_team_id   BIGINT NOT NULL,
  away_team_id   BIGINT NOT NULL,

  home_rating    DOUBLE PRECISION NOT NULL,
  away_rating    DOUBLE PRECISION NOT NULL,
  rating_diff    DOUBLE PRECISION NOT NULL,

  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_mm_match_ratings_league_kickoff
  ON mm_match_ratings(league_id, kickoff);

CREATE INDEX IF NOT EXISTS ix_mm_match_ratings_home_team
  ON mm_match_ratings(home_team_id);

CREATE INDEX IF NOT EXISTS ix_mm_match_ratings_away_team
  ON mm_match_ratings(away_team_id);


-- 2) Aktuální ratingy týmů v lize (latest snapshot)
CREATE TABLE IF NOT EXISTS mm_team_ratings (
  league_id      BIGINT NOT NULL,
  team_id        BIGINT NOT NULL,
  rating         DOUBLE PRECISION NOT NULL,
  last_match_id  BIGINT,
  last_kickoff   TIMESTAMPTZ,

  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (league_id, team_id)
);

CREATE INDEX IF NOT EXISTS ix_mm_team_ratings_league
  ON mm_team_ratings(league_id);
