BEGIN;

-- A) team_aliases.team_id musí být vyplněné
ALTER TABLE team_aliases
  ALTER COLUMN team_id SET NOT NULL;

-- B) alias nesmí být prázdný (idempotentně)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'team_aliases_alias_not_blank'
  ) THEN
    ALTER TABLE team_aliases
      ADD CONSTRAINT team_aliases_alias_not_blank
      CHECK (btrim(alias) <> '');
  END IF;
END $$;

-- C) FK alias -> teams (idempotentně)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'team_aliases_team_id_fkey'
  ) THEN
    ALTER TABLE team_aliases
      ADD CONSTRAINT team_aliases_team_id_fkey
      FOREIGN KEY (team_id) REFERENCES teams(id)
      ON DELETE CASCADE;
  END IF;
END $$;

-- D) UNIQUE index (team_id, normalized alias) (idempotentně)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND indexname = 'ux_team_aliases_teamid_aliasnorm'
  ) THEN
    CREATE UNIQUE INDEX ux_team_aliases_teamid_aliasnorm
      ON team_aliases (team_id, lower(btrim(alias)));
  END IF;
END $$;

-- E) FK pro league_teams (idempotentně)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'league_teams_team_id_fkey') THEN
    ALTER TABLE league_teams
      ADD CONSTRAINT league_teams_team_id_fkey
      FOREIGN KEY (team_id) REFERENCES teams(id)
      ON DELETE RESTRICT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'league_teams_league_id_fkey') THEN
    ALTER TABLE league_teams
      ADD CONSTRAINT league_teams_league_id_fkey
      FOREIGN KEY (league_id) REFERENCES leagues(id)
      ON DELETE RESTRICT;
  END IF;
END $$;

COMMIT;