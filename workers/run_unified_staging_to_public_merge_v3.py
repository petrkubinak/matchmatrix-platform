# ==========================================================
# MATCHMATRIX
# UNIFIED STAGING -> PUBLIC CORE MERGE V3
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_unified_staging_to_public_merge_v3.py
#
# Spuštění:
# python C:\MatchMatrix-platform\workers\run_unified_staging_to_public_merge_v3.py
# ==========================================================

import json
import psycopg2


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def create_job_run(conn) -> int:
    sql = """
        INSERT INTO ops.job_runs
        (
            job_code,
            started_at,
            status,
            params,
            message,
            details,
            rows_affected
        )
        VALUES
        (
            %s,
            NOW(),
            %s,
            %s::jsonb,
            %s,
            %s::jsonb,
            %s
        )
        RETURNING id
    """

    params = {
        "worker": "run_unified_staging_to_public_merge_v2.py"
    }

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                "unified_staging_to_public_merge",
                "running",
                json.dumps(params),
                "Unified staging to public merge started.",
                json.dumps({}),
                0,
            ),
        )
        job_run_id = cur.fetchone()[0]

    conn.commit()
    return job_run_id


def finish_job_run(conn, job_run_id: int, status: str, message: str, details: dict, rows_affected: int) -> None:
    sql = """
        UPDATE ops.job_runs
        SET
            finished_at = NOW(),
            status = %s,
            message = %s,
            details = %s::jsonb,
            rows_affected = %s
        WHERE id = %s
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                status,
                message,
                json.dumps(details),
                rows_affected,
                job_run_id,
            ),
        )

    conn.commit()


def to_int_sql(expr: str) -> str:
    """
    Bezpečný převod text -> integer.
    """
    return f"""
    CASE
        WHEN {expr} IS NULL THEN NULL
        WHEN btrim({expr}::text) = '' THEN NULL
        WHEN {expr}::text ~ '^-?\\d+$' THEN ({expr})::integer
        ELSE NULL
    END
    """


def normalize_status_sql(expr: str) -> str:
    """
    Převod provider statusů do canonical hodnot v public.matches.
    """
    return f"""
    CASE
        WHEN {expr} IS NULL OR btrim({expr}) = '' THEN 'SCHEDULED'
        WHEN upper(btrim({expr})) IN ('FT', 'AET', 'PEN', 'FINISHED') THEN 'FINISHED'
        WHEN upper(btrim({expr})) IN ('NS', 'TBD', 'SCHEDULED') THEN 'SCHEDULED'
        WHEN upper(btrim({expr})) IN ('1H', '2H', 'HT', 'ET', 'BT', 'LIVE', 'IN_PLAY') THEN 'LIVE'
        WHEN upper(btrim({expr})) IN ('PST', 'POSTPONED') THEN 'POSTPONED'
        WHEN upper(btrim({expr})) IN ('CANC', 'CANCELLED', 'ABD', 'AWD', 'WO') THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END
    """


def score_if_finished_sql(score_expr: str, status_expr: str) -> str:
    """
    Score zapisovat jen pokud je canonical status FINISHED,
    jinak kvůli check constraintu musí být NULL.
    """
    return f"""
    CASE
        WHEN ({normalize_status_sql(status_expr)}) = 'FINISHED'
        THEN {to_int_sql(score_expr)}
        ELSE NULL
    END
    """


def main() -> None:
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False
    cur = conn.cursor()
    job_run_id = None

    stats = {
        "leagues_updated": 0,
        "leagues_inserted": 0,
        "league_teams_inserted": 0,
        "league_provider_map_inserted": 0,
        "teams_updated": 0,
        "teams_inserted": 0,
        "team_provider_map_inserted": 0,
        "players_updated": 0,
        "players_inserted": 0,
        "player_provider_map_inserted": 0,
        "matches_updated": 0,
        "matches_inserted": 0,
    }

    final_counts = {}

    try:
        job_run_id = create_job_run(conn)

        print("=== UNIFIED STAGING -> PUBLIC CORE MERGE V3 ===")

        # --------------------------------------------------
        # 0) sport map
        # --------------------------------------------------
        cur.execute("""
            SELECT lower(code), id
            FROM public.sports
        """)
        sports = {code: sport_id for code, sport_id in cur.fetchall()}
        football_id = sports.get("fb") or sports.get("football")
        hockey_id = sports.get("hk") or sports.get("hockey")

        print("Detected sports map:", sports)

        # --------------------------------------------------
        # 1) LEAGUES - update existing
        # --------------------------------------------------
        cur.execute("""
            UPDATE public.leagues l
            SET
                name = src.league_name,
                country = src.country_name,
                updated_at = now()
            FROM (
                SELECT DISTINCT
                    provider,
                    sport_code,
                    external_league_id,
                    league_name,
                    country_name
                FROM staging.stg_provider_leagues
                WHERE external_league_id IS NOT NULL
            ) src
            WHERE l.ext_source = src.provider
              AND l.ext_league_id = src.external_league_id
        """)
        stats["leagues_updated"] = cur.rowcount
        print("leagues updated:", cur.rowcount)

        # --------------------------------------------------
        # 2) LEAGUES - insert new
        # --------------------------------------------------
        cur.execute(f"""
            INSERT INTO public.leagues
            (
                sport_id,
                name,
                country,
                ext_source,
                ext_league_id
            )
            SELECT
                CASE
                    WHEN lower(src.sport_code) = 'football' THEN {football_id if football_id is not None else 'NULL'}
                    WHEN lower(src.sport_code) = 'hockey'   THEN {hockey_id if hockey_id is not None else 'NULL'}
                    ELSE NULL
                END AS sport_id,
                src.league_name,
                src.country_name,
                src.provider,
                src.external_league_id
            FROM (
                SELECT DISTINCT
                    provider,
                    sport_code,
                    external_league_id,
                    league_name,
                    country_name
                FROM staging.stg_provider_leagues
                WHERE external_league_id IS NOT NULL
            ) src
            WHERE
                CASE
                    WHEN lower(src.sport_code) = 'football' THEN {football_id if football_id is not None else 'NULL'}
                    WHEN lower(src.sport_code) = 'hockey'   THEN {hockey_id if hockey_id is not None else 'NULL'}
                    ELSE NULL
                END IS NOT NULL
              AND NOT EXISTS (
                  SELECT 1
                  FROM public.leagues l
                  WHERE l.ext_source = src.provider
                    AND l.ext_league_id = src.external_league_id
              )
        """)
        stats["leagues_inserted"] = cur.rowcount
        print("leagues inserted:", cur.rowcount)

        # --------------------------------------------------
        # 3) LEAGUE PROVIDER MAP
        # --------------------------------------------------
        cur.execute("""
            INSERT INTO public.league_provider_map
            (
                league_id,
                provider,
                provider_league_id
            )
            SELECT
                l.id,
                src.provider,
                src.external_league_id
            FROM (
                SELECT DISTINCT
                    provider,
                    external_league_id
                FROM staging.stg_provider_leagues
                WHERE external_league_id IS NOT NULL
            ) src
            JOIN public.leagues l
              ON l.ext_source = src.provider
             AND l.ext_league_id = src.external_league_id
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.league_provider_map m
                WHERE m.provider = src.provider
                  AND m.provider_league_id = src.external_league_id
            )
        """)
        stats["league_provider_map_inserted"] = cur.rowcount
        print("league_provider_map inserted:", cur.rowcount)

        # --------------------------------------------------
        # 4) TEAMS - update existing
        # --------------------------------------------------
        cur.execute("""
            UPDATE public.teams t
            SET
                name = src.team_name,
                updated_at = now()
            FROM (
                SELECT DISTINCT ON (provider, external_team_id)
                    provider,
                    external_team_id,
                    team_name
                FROM staging.stg_provider_teams
                WHERE external_team_id IS NOT NULL
                  AND team_name IS NOT NULL
                  AND btrim(team_name) <> ''
                ORDER BY provider, external_team_id, updated_at DESC, id DESC
            ) src
            WHERE t.ext_source = src.provider
              AND t.ext_team_id = src.external_team_id
              AND t.name IS DISTINCT FROM src.team_name
        """)
        stats["teams_updated"] = cur.rowcount
        print("teams updated:", cur.rowcount)

                # --------------------------------------------------
        # 5) TEAMS - insert new
        # --------------------------------------------------
        cur.execute("""
            INSERT INTO public.teams
            (
                name,
                ext_source,
                ext_team_id
            )
            SELECT
                src.team_name,
                src.provider,
                src.external_team_id
            FROM (
                SELECT DISTINCT ON (provider, external_team_id)
                    provider,
                    external_team_id,
                    team_name
                FROM staging.stg_provider_teams
                WHERE external_team_id IS NOT NULL
                  AND team_name IS NOT NULL
                  AND btrim(team_name) <> ''
                ORDER BY provider, external_team_id, updated_at DESC, id DESC
            ) src
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.teams t
                WHERE t.ext_source = src.provider
                  AND t.ext_team_id = src.external_team_id
            )
        """)
        stats["teams_inserted"] = cur.rowcount
        print("teams inserted:", cur.rowcount)

        # --------------------------------------------------
        # 6) TEAM PROVIDER MAP
        # --------------------------------------------------
        cur.execute("""
            INSERT INTO public.team_provider_map
            (
                team_id,
                provider,
                provider_team_id
            )
            SELECT
                t.id,
                src.provider,
                src.external_team_id
            FROM (
                SELECT DISTINCT
                    provider,
                    external_team_id
                FROM staging.stg_provider_teams
                WHERE external_team_id IS NOT NULL
            ) src
            JOIN public.teams t
              ON t.ext_source = src.provider
             AND t.ext_team_id = src.external_team_id
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.team_provider_map m
                WHERE m.provider = src.provider
                  AND m.provider_team_id = src.external_team_id
            )
        """)
        stats["team_provider_map_inserted"] = cur.rowcount
        print("team_provider_map inserted:", cur.rowcount)

                # --------------------------------------------------
        # 6B) LEAGUE_TEAMS
        # --------------------------------------------------
        cur.execute("""
            INSERT INTO public.league_teams
            (
                league_id,
                team_id,
                season,
                created_at,
                updated_at
            )
            SELECT DISTINCT ON (lpm.league_id, tpm.team_id)
                lpm.league_id,
                tpm.team_id,
                spt.season,
                now(),
                now()
            FROM staging.stg_provider_teams spt
            JOIN public.league_provider_map lpm
              ON lpm.provider = spt.provider
             AND lpm.provider_league_id = spt.external_league_id
            JOIN public.team_provider_map tpm
              ON tpm.provider = spt.provider
             AND tpm.provider_team_id = spt.external_team_id
            WHERE spt.external_league_id IS NOT NULL
              AND spt.external_team_id IS NOT NULL
              AND NOT EXISTS (
                  SELECT 1
                  FROM public.league_teams lt
                  WHERE lt.league_id = lpm.league_id
                    AND lt.team_id = tpm.team_id
              )
            ORDER BY lpm.league_id, tpm.team_id, spt.updated_at DESC, spt.id DESC
        """)
        stats["league_teams_inserted"] = cur.rowcount
        print("league_teams inserted:", cur.rowcount)

        # --------------------------------------------------
        # 7) PLAYERS - update existing
        # --------------------------------------------------
        cur.execute("""
            UPDATE public.players p
            SET
                team_id = tp.team_id,
                name = src.player_name,
                birth_date = src.birth_date,
                nationality = src.nationality,
                is_active = coalesce(src.is_active, true),
                updated_at = now()
            FROM (
                SELECT DISTINCT
                    sp.provider,
                    sp.external_player_id,
                    sp.player_name,
                    sp.birth_date,
                    sp.nationality,
                    sp.external_team_id,
                    sp.is_active
                FROM staging.stg_provider_players sp
                WHERE sp.external_player_id IS NOT NULL
            ) src
            LEFT JOIN public.team_provider_map tp
              ON tp.provider = src.provider
             AND tp.provider_team_id = src.external_team_id
            WHERE p.ext_source = src.provider
              AND p.ext_player_id = src.external_player_id
        """)
        stats["players_updated"] = cur.rowcount
        print("players updated:", cur.rowcount)

        # --------------------------------------------------
        # 8) PLAYERS - insert new
        # --------------------------------------------------
        cur.execute("""
            INSERT INTO public.players
            (
                team_id,
                name,
                birth_date,
                nationality,
                is_active,
                ext_source,
                ext_player_id
            )
            SELECT
                tp.team_id,
                src.player_name,
                src.birth_date,
                src.nationality,
                coalesce(src.is_active, true),
                src.provider,
                src.external_player_id
            FROM (
                SELECT DISTINCT
                    sp.provider,
                    sp.external_player_id,
                    sp.player_name,
                    sp.birth_date,
                    sp.nationality,
                    sp.external_team_id,
                    sp.is_active
                FROM staging.stg_provider_players sp
                WHERE sp.external_player_id IS NOT NULL
            ) src
            LEFT JOIN public.team_provider_map tp
              ON tp.provider = src.provider
             AND tp.provider_team_id = src.external_team_id
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.players p
                WHERE p.ext_source = src.provider
                  AND p.ext_player_id = src.external_player_id
            )
        """)
        stats["players_inserted"] = cur.rowcount
        print("players inserted:", cur.rowcount)

        # --------------------------------------------------
        # 9) PLAYER PROVIDER MAP
        # --------------------------------------------------
        cur.execute("""
            INSERT INTO public.player_provider_map
            (
                provider,
                provider_player_id,
                player_id,
                provider_team_id,
                provider_player_name,
                is_active
            )
            SELECT
                src.provider,
                src.external_player_id,
                p.id,
                src.external_team_id,
                src.player_name,
                coalesce(src.is_active, true)
            FROM (
                SELECT DISTINCT
                    provider,
                    external_player_id,
                    external_team_id,
                    player_name,
                    is_active
                FROM staging.stg_provider_players
                WHERE external_player_id IS NOT NULL
            ) src
            JOIN public.players p
              ON p.ext_source = src.provider
             AND p.ext_player_id = src.external_player_id
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.player_provider_map m
                WHERE m.provider = src.provider
                  AND m.provider_player_id = src.external_player_id
            )
        """)
        stats["player_provider_map_inserted"] = cur.rowcount
        print("player_provider_map inserted:", cur.rowcount)

        # --------------------------------------------------
        # 10) MATCHES - update existing
        # --------------------------------------------------
        cur.execute(f"""
            UPDATE public.matches m
            SET
                league_id = src.league_id,
                home_team_id = src.home_team_id,
                away_team_id = src.away_team_id,
                kickoff = src.kickoff_ts,
                status = src.status_text_norm,
                home_score = src.home_score_int,
                away_score = src.away_score_int,
                season = src.season,
                sport_id = src.sport_id,
                updated_at = now()
            FROM (
                SELECT
                    sf.provider,
                    sf.external_fixture_id,
                    lpm.league_id,
                    htp.team_id AS home_team_id,
                    atp.team_id AS away_team_id,
                    sf.fixture_date::timestamp without time zone AS kickoff_ts,
                    {normalize_status_sql('sf.status_text')} AS status_text_norm,
                    {score_if_finished_sql('sf.home_score', 'sf.status_text')} AS home_score_int,
                    {score_if_finished_sql('sf.away_score', 'sf.status_text')} AS away_score_int,
                    sf.season,
                    CASE
                        WHEN lower(sf.sport_code) = 'football' THEN {football_id if football_id is not None else 'NULL'}
                        WHEN lower(sf.sport_code) = 'hockey'   THEN {hockey_id if hockey_id is not None else 'NULL'}
                        ELSE NULL
                    END AS sport_id
                FROM staging.stg_provider_fixtures sf
                LEFT JOIN public.league_provider_map lpm
                  ON lpm.provider = sf.provider
                 AND lpm.provider_league_id = sf.external_league_id
                LEFT JOIN public.team_provider_map htp
                  ON htp.provider = sf.provider
                 AND htp.provider_team_id = sf.home_team_external_id
                LEFT JOIN public.team_provider_map atp
                  ON atp.provider = sf.provider
                 AND atp.provider_team_id = sf.away_team_external_id
                WHERE sf.external_fixture_id IS NOT NULL
            ) src
            WHERE m.ext_source = src.provider
              AND m.ext_match_id = src.external_fixture_id
        """)
        stats["matches_updated"] = cur.rowcount
        print("matches updated:", cur.rowcount)

        # --------------------------------------------------
        # 11) MATCHES - insert new
        # --------------------------------------------------
        cur.execute(f"""
            INSERT INTO public.matches
            (
                league_id,
                home_team_id,
                away_team_id,
                kickoff,
                ext_source,
                ext_match_id,
                status,
                home_score,
                away_score,
                season,
                sport_id
            )
            SELECT
                src.league_id,
                src.home_team_id,
                src.away_team_id,
                src.kickoff_ts,
                src.provider,
                src.external_fixture_id,
                src.status_text_norm,
                src.home_score_int,
                src.away_score_int,
                src.season,
                src.sport_id
            FROM (
                SELECT
                    sf.provider,
                    sf.external_fixture_id,
                    lpm.league_id,
                    htp.team_id AS home_team_id,
                    atp.team_id AS away_team_id,
                    sf.fixture_date::timestamp without time zone AS kickoff_ts,
                    {normalize_status_sql('sf.status_text')} AS status_text_norm,
                    {score_if_finished_sql('sf.home_score', 'sf.status_text')} AS home_score_int,
                    {score_if_finished_sql('sf.away_score', 'sf.status_text')} AS away_score_int,
                    sf.season,
                    CASE
                        WHEN lower(sf.sport_code) = 'football' THEN {football_id if football_id is not None else 'NULL'}
                        WHEN lower(sf.sport_code) = 'hockey'   THEN {hockey_id if hockey_id is not None else 'NULL'}
                        ELSE NULL
                    END AS sport_id
                FROM staging.stg_provider_fixtures sf
                LEFT JOIN public.league_provider_map lpm
                  ON lpm.provider = sf.provider
                 AND lpm.provider_league_id = sf.external_league_id
                LEFT JOIN public.team_provider_map htp
                  ON htp.provider = sf.provider
                 AND htp.provider_team_id = sf.home_team_external_id
                LEFT JOIN public.team_provider_map atp
                  ON atp.provider = sf.provider
                 AND atp.provider_team_id = sf.away_team_external_id
                WHERE sf.external_fixture_id IS NOT NULL
            ) src
            WHERE src.home_team_id IS NOT NULL
              AND src.away_team_id IS NOT NULL
              AND src.sport_id IS NOT NULL
              AND NOT EXISTS (
                  SELECT 1
                  FROM public.matches m
                  WHERE m.ext_source = src.provider
                    AND m.ext_match_id = src.external_fixture_id
              )
        """)
        stats["matches_inserted"] = cur.rowcount
        print("matches inserted:", cur.rowcount)

        # --------------------------------------------------
        # 12) FINAL COUNTS
        # --------------------------------------------------
        conn.commit()

        checks = [
            ("public.leagues", "SELECT count(*) FROM public.leagues"),
            ("public.league_provider_map", "SELECT count(*) FROM public.league_provider_map"),
            ("public.teams", "SELECT count(*) FROM public.teams"),
            ("public.team_provider_map", "SELECT count(*) FROM public.team_provider_map"),
            ("public.players", "SELECT count(*) FROM public.players"),
            ("public.player_provider_map", "SELECT count(*) FROM public.player_provider_map"),
            ("public.matches", "SELECT count(*) FROM public.matches"),
        ]

        print("\n=== FINAL COUNTS ===")
        for label, sql_text in checks:
            cur.execute(sql_text)
            final_counts[label] = cur.fetchone()[0]
            print(f"{label}: {final_counts[label]}")

        print("\nHotovo.")

        total_rows_affected = (
            stats["leagues_updated"]
            + stats["leagues_inserted"]
            + stats["league_teams_inserted"]
            + stats["league_provider_map_inserted"]
            + stats["teams_updated"]
            + stats["teams_inserted"]
            + stats["team_provider_map_inserted"]
            + stats["players_updated"]
            + stats["players_inserted"]
            + stats["player_provider_map_inserted"]
            + stats["matches_updated"]
            + stats["matches_inserted"]
        )

        details = {
            "stats": stats,
            "final_counts": final_counts,
            "sports_detected": sports,
        }

        finish_job_run(
            conn=conn,
            job_run_id=job_run_id,
            status="ok",
            message="Unified staging to public merge finished OK.",
            details=details,
            rows_affected=total_rows_affected,
        )

    except Exception as exc:
        conn.rollback()

        if job_run_id is not None:
            try:
                finish_job_run(
                    conn=conn,
                    job_run_id=job_run_id,
                    status="error",
                    message=f"Unified staging to public merge failed: {exc}",
                    details={
                        "stats": stats,
                        "final_counts": final_counts,
                        "error": str(exc),
                    },
                    rows_affected=0,
                )
            except Exception:
                pass

        raise

    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()