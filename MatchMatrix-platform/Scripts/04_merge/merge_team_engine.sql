-- /sql/engine/merge_team_engine.sql
-- Postgres: merge old team -> canonical team
-- team_aliases columns: (id, team_id, alias, source)

CREATE OR REPLACE FUNCTION public.merge_team(
    p_old_team_id INT,
    p_new_team_id INT,
    p_notes TEXT DEFAULT NULL,
    p_source TEXT DEFAULT 'merge_engine',
    p_delete_old BOOLEAN DEFAULT TRUE,
    p_create_alias BOOLEAN DEFAULT TRUE
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_name TEXT;
    v_new_name TEXT;
BEGIN
    IF p_old_team_id IS NULL OR p_new_team_id IS NULL THEN
        RAISE EXCEPTION 'merge_team: old_team_id or new_team_id is NULL.';
    END IF;

    IF p_old_team_id = p_new_team_id THEN
        RAISE EXCEPTION 'merge_team: old_team_id = new_team_id (%).', p_old_team_id;
    END IF;

    SELECT name INTO v_old_name FROM teams WHERE id = p_old_team_id;
    SELECT name INTO v_new_name FROM teams WHERE id = p_new_team_id;

    IF v_old_name IS NULL THEN
        RAISE EXCEPTION 'merge_team: old team not found: %', p_old_team_id;
    END IF;
    IF v_new_name IS NULL THEN
        RAISE EXCEPTION 'merge_team: new team not found: %', p_new_team_id;
    END IF;

    -- 1) smazat PK konflikty v league_teams (league_id, team_id)
    DELETE FROM league_teams lt
    WHERE lt.team_id = p_old_team_id
      AND EXISTS (
        SELECT 1
        FROM league_teams lt2
        WHERE lt2.league_id = lt.league_id
          AND lt2.team_id = p_new_team_id
      );

    -- 2) update league_teams
    UPDATE league_teams
    SET team_id = p_new_team_id
    WHERE team_id = p_old_team_id;

    -- 3) update matches
    UPDATE matches
    SET home_team_id = p_new_team_id
    WHERE home_team_id = p_old_team_id;

    UPDATE matches
    SET away_team_id = p_new_team_id
    WHERE away_team_id = p_old_team_id;

    -- 4) přenést existující aliasy ze starého team_id na nový (aby se nic neztratilo)
    UPDATE team_aliases
    SET team_id = p_new_team_id
    WHERE team_id = p_old_team_id;

    -- 5) vytvořit alias z původního názvu týmu (pokud chceš)
    IF p_create_alias THEN
        INSERT INTO team_aliases (team_id, alias, source)
        SELECT p_new_team_id, v_old_name, p_source
        WHERE NOT EXISTS (
            SELECT 1
            FROM team_aliases a
            WHERE a.team_id = p_new_team_id
              AND lower(a.alias) = lower(v_old_name)
        );
    END IF;

    -- 6) smazat starý tým
    IF p_delete_old THEN
        DELETE FROM teams WHERE id = p_old_team_id;
    END IF;

    -- Poznámky (p_notes) zatím neukládám – pokud chceš audit log, doplníme tabulku team_merge_log.
END;
$$;