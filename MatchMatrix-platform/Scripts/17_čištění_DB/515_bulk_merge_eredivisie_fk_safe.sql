-- 515_bulk_merge_eredivisie_fk_safe.sql
-- FULL SAFE BULK (řeší alias + FK)

DO $$
DECLARE
    r RECORD;
BEGIN

    FOR r IN (
        SELECT * FROM (VALUES
            (12167, 563, 'groningen'),
            (12169, 572, 'fortuna'),
            (12161, 95,  'ajax'),
            (13365, 557, 'excelsior')
        ) AS t(old_id, new_id, label)
    )
    LOOP

        IF EXISTS (SELECT 1 FROM public.teams WHERE id = r.old_id) THEN

            -- 🔥 FK FIX (tohle chybělo!)
            UPDATE public.player_season_statistics
            SET team_id = r.new_id
            WHERE team_id = r.old_id;

            UPDATE public.league_standings
            SET team_id = r.new_id
            WHERE team_id = r.old_id;

            -- alias cleanup
            DELETE FROM public.team_aliases a_old
            WHERE a_old.team_id = r.old_id
              AND EXISTS (
                  SELECT 1
                  FROM public.team_aliases a_new
                  WHERE a_new.team_id = r.new_id
                    AND LOWER(BTRIM(a_new.alias)) = LOWER(BTRIM(a_old.alias))
              );

            -- merge
            PERFORM public.merge_team(
                r.old_id,
                r.new_id,
                'bulk eredivisie fk safe',
                'bulk_' || r.label,
                true,
                true
            );

        END IF;

    END LOOP;

END $$;
