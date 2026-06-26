/*
MATCHMATRIX SQL 17_8_F
TEAM SAFE MERGE EXECUTION PLAN V2

CO TO JE:
- Finální bezpečnostní plán před odstraněním low-usage duplicitních týmů.
- Nic nemaže ani neupravuje.
- Kontroluje nejen zápasy, články a provider mapy, ale i hráče, sezónní statistiky a aliasy.

K ČEMU TO JE:
- Zabrání odstranění týmu, na který je ještě navázaný hráč, statistika nebo alias.
- Připraví pouze opravdu bezpečné kandidáty pro budoucí DELETE.
- Oddělí bezpečné kandidáty od ruční kontroly.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> TEAM DEDUP
- DBeaver bezpečnostní audit před DELETE

JAK SE TO VYUŽIJE:
- 17_8_G smaže pouze řádky s execution_status = READY_FOR_DELETE.
- Řádky s HOLD_DEPENDENCY zůstanou na ruční kontrolu.
- Tím snížíme duplicity bez zásahu do navázaných dat.
*/

CREATE OR REPLACE VIEW ops.v_team_safe_merge_execution_plan_v1 AS
WITH base AS (
    SELECT
        p.*
    FROM ops.v_team_safe_merge_plan_v1 p
    WHERE p.merge_status = 'SAFE_LOW_USAGE_MERGE'
),
dependency_counts AS (
    SELECT
        b.old_team_id,

        COUNT(DISTINCT pl.id) AS players_count,
        COUNT(DISTINCT pss.id) AS player_stats_count,
        COUNT(DISTINCT ta.id) AS team_aliases_count

    FROM base b

    LEFT JOIN public.players pl
        ON pl.team_id = b.old_team_id

    LEFT JOIN public.player_season_statistics pss
        ON pss.team_id = b.old_team_id

    LEFT JOIN public.team_aliases ta
        ON ta.team_id = b.old_team_id

    GROUP BY
        b.old_team_id
)
SELECT
    b.team_name,
    b.sport_id,

    b.old_team_id,
    b.master_team_id,

    b.ext_source,
    b.ext_team_id,

    b.matches_count,
    b.article_links_count,
    b.provider_maps_count,

    COALESCE(d.players_count,0) AS players_count,
    COALESCE(d.player_stats_count,0) AS player_stats_count,
    COALESCE(d.team_aliases_count,0) AS team_aliases_count,

    b.master_candidate_score,

    CASE
        WHEN COALESCE(d.players_count,0) = 0
         AND COALESCE(d.player_stats_count,0) = 0
         AND COALESCE(d.team_aliases_count,0) = 0
            THEN 'READY_FOR_DELETE'
        ELSE 'HOLD_DEPENDENCY'
    END AS execution_status,

    CASE
        WHEN COALESCE(d.players_count,0) = 0
         AND COALESCE(d.player_stats_count,0) = 0
         AND COALESCE(d.team_aliases_count,0) = 0
            THEN 'Tým nemá zápasy, články, provider mapy, hráče, statistiky ani aliasy. Bezpečný kandidát na odstranění.'
        ELSE 'Nesmazat automaticky. Tým má navázané hráče, statistiky nebo aliasy.'
    END AS recommendation_cz,

    now() AS generated_at

FROM base b
LEFT JOIN dependency_counts d
    ON d.old_team_id = b.old_team_id

ORDER BY
    execution_status,
    team_name,
    sport_id;