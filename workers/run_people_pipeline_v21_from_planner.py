"""
run_people_pipeline_v21_from_planner.py

PEOPLE PIPELINE V2.1
- planner-driven
- RAW -> staging
- players -> public.players + public.player_provider_map
- coaches -> staging only
- planner status update
- audit update
"""

import os
import json
import hashlib
import urllib.request
import urllib.error

import psycopg
from psycopg.rows import dict_row


DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"

API_KEY = (
    os.getenv("APISPORTS_KEY")
    or os.getenv("API_SPORTS_KEY")
    or os.getenv("RAPIDAPI_KEY")
)


def safe_int(value):
    try:
        return int(value) if value not in (None, "") else None
    except Exception:
        return None


def payload_hash(payload: dict) -> str:
    text = json.dumps(payload, sort_keys=True, ensure_ascii=False)
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def fetch_payload(url: str) -> dict:
    if not API_KEY:
        raise RuntimeError("Missing API key APISPORTS_KEY / API_SPORTS_KEY / RAPIDAPI_KEY")

    req = urllib.request.Request(url)
    req.add_header("x-apisports-key", API_KEY)

    with urllib.request.urlopen(req, timeout=45) as response:
        raw = response.read().decode("utf-8", errors="replace")
        return json.loads(raw)


def build_url(job: dict) -> str | None:
    provider = job["provider"]
    entity = job["entity"]
    scope_id = job["provider_league_id"]
    season = job["season"]

    if provider == "api_football":
        if entity == "players":
            if str(job["run_group"]).startswith("FB_PEOPLE_TEAM_SCALE"):
                return f"https://v3.football.api-sports.io/players?team={scope_id}&season={season}&page=1"
            return f"https://v3.football.api-sports.io/players?league={scope_id}&season={season}&page=1"
        if entity == "coaches":
            # API-Football coaches endpoint je team-based.
            return "https://v3.football.api-sports.io/coachs?team=33"

    if provider == "api_american_football":
        if entity == "players":
            # U AFB zatím provider_league_id používáme jako team scope.
            return f"https://v1.american-football.api-sports.io/players?team={scope_id}&season={season}"

    return None


def save_raw(cur, job: dict, payload: dict) -> int:
    endpoint_name = "coachs" if job["entity"] == "coaches" else job["entity"]

    cur.execute(
        """
        INSERT INTO staging.stg_api_payloads (
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            fetched_at,
            payload_json,
            payload_hash,
            parse_status,
            parse_message,
            created_at
        )
        VALUES (
            %s, %s, %s, %s, %s, %s,
            now(),
            %s::jsonb,
            %s,
            'pending',
            'people pipeline v2.1 raw saved',
            now()
        )
        RETURNING id;
        """,
        (
            job["provider"],
            job["sport_code"],
            job["entity"],
            endpoint_name,
            job["provider_league_id"],
            job["season"],
            json.dumps(payload, ensure_ascii=False),
            payload_hash(payload),
        ),
    )
    return cur.fetchone()["id"]


def parse_fb_players(cur, raw_id: int, payload: dict) -> int:
    rows = payload.get("response", [])

    for item in rows:
        player = item.get("player") or {}
        stats = item.get("statistics") or []
        stat0 = stats[0] if stats else {}

        team = stat0.get("team") or {}
        league = stat0.get("league") or {}
        games = stat0.get("games") or {}

        external_player_id = str(player.get("id")) if player.get("id") is not None else None

        cur.execute(
            """
            INSERT INTO staging.stg_provider_players (
                provider,
                sport_code,
                external_player_id,
                player_name,
                first_name,
                last_name,
                birth_date,
                nationality,
                height_cm,
                weight_kg,
                external_team_id,
                team_name,
                external_league_id,
                league_name,
                season,
                position_code,
                raw_payload_id,
                source_endpoint,
                created_at
            )
            VALUES (
                'api_football',
                'FB',
                %s, %s, %s, %s, %s, %s,
                %s, %s,
                %s, %s,
                %s, %s,
                %s, %s,
                %s,
                'players',
                now()
            )
            ON CONFLICT DO NOTHING;
            """,
            (
                external_player_id,
                player.get("name"),
                player.get("firstname"),
                player.get("lastname"),
                player.get("birth", {}).get("date"),
                player.get("nationality"),
                safe_int(player.get("height")),
                safe_int(player.get("weight")),
                str(team.get("id")) if team.get("id") is not None else None,
                team.get("name"),
                str(league.get("id")) if league.get("id") is not None else None,
                league.get("name"),
                str(league.get("season")) if league.get("season") is not None else None,
                games.get("position"),
                raw_id,
            ),
        )

        # existující starší FB záznamy doplníme / normalizujeme
        cur.execute(
            """
            UPDATE staging.stg_provider_players
            SET
                sport_code = 'FB',
                external_team_id = %s,
                team_name = %s,
                external_league_id = %s,
                league_name = %s,
                season = %s,
                position_code = COALESCE(position_code, %s),
                raw_payload_id = %s,
                source_endpoint = 'players'
            WHERE provider = 'api_football'
              AND external_player_id::text = %s;
            """,
            (
                str(team.get("id")) if team.get("id") is not None else None,
                team.get("name"),
                str(league.get("id")) if league.get("id") is not None else None,
                league.get("name"),
                str(league.get("season")) if league.get("season") is not None else None,
                games.get("position"),
                raw_id,
                external_player_id,
            ),
        )

    return len(rows)


def parse_simple_players(cur, raw_id: int, job: dict, payload: dict) -> int:
    rows = payload.get("response", [])
    team_scope = job["provider_league_id"]

    for p in rows:
        external_player_id = str(p.get("id")) if p.get("id") is not None else None

        cur.execute(
            """
            INSERT INTO staging.stg_provider_players (
                provider,
                sport_code,
                external_player_id,
                player_name,
                nationality,
                height_cm,
                weight_kg,
                external_team_id,
                team_name,
                season,
                position_code,
                raw_payload_id,
                source_endpoint,
                created_at
            )
            VALUES (
                %s, %s,
                %s, %s,
                %s,
                NULL,
                NULL,
                %s,
                %s,
                %s,
                %s,
                %s,
                'players',
                now()
            )
            ON CONFLICT DO NOTHING;
            """,
            (
                job["provider"],
                job["sport_code"],
                external_player_id,
                p.get("name"),
                p.get("country"),
                str(team_scope),
                f"Team {team_scope}",
                job["season"],
                p.get("position"),
                raw_id,
            ),
        )

        cur.execute(
            """
            UPDATE staging.stg_provider_players
            SET
                sport_code = %s,
                external_team_id = COALESCE(NULLIF(external_team_id, ''), %s),
                team_name = COALESCE(team_name, %s),
                season = COALESCE(season, %s),
                position_code = COALESCE(position_code, %s),
                raw_payload_id = %s,
                source_endpoint = 'players'
            WHERE provider = %s
              AND external_player_id::text = %s;
            """,
            (
                job["sport_code"],
                str(team_scope),
                f"Team {team_scope}",
                job["season"],
                p.get("position"),
                raw_id,
                job["provider"],
                external_player_id,
            ),
        )

    return len(rows)


def parse_fb_coaches(cur, raw_id: int, payload: dict) -> int:
    rows = payload.get("response", [])

    for c in rows:
        team = c.get("team") or {}

        cur.execute(
            """
            INSERT INTO staging.stg_provider_coaches (
                provider,
                sport_code,
                external_coach_id,
                coach_name,
                first_name,
                last_name,
                birth_date,
                nationality,
                team_external_id,
                team_name,
                raw_payload_id,
                source_endpoint,
                created_at
            )
            VALUES (
                'api_football',
                'FB',
                %s, %s, %s, %s, %s, %s,
                %s, %s,
                %s,
                'coachs',
                now()
            )
            ON CONFLICT DO NOTHING;
            """,
            (
                str(c.get("id")) if c.get("id") is not None else None,
                c.get("name"),
                c.get("firstname"),
                c.get("lastname"),
                c.get("birth", {}).get("date"),
                c.get("nationality"),
                str(team.get("id")) if team.get("id") is not None else None,
                team.get("name"),
                raw_id,
            ),
        )

    return len(rows)


def merge_players_to_public(cur, job: dict, raw_id: int) -> tuple[int, int]:
    cur.execute(
        """
        INSERT INTO public.players (
            name,
            team_id,
            nationality,
            birth_date,
            position,
            ext_source,
            ext_player_id,
            created_at,
            updated_at
        )
        SELECT
            p.player_name,
            tpm.team_id,
            p.nationality,
            p.birth_date,
            p.position_code,
            p.provider,
            p.external_player_id::text,
            now(),
            now()
        FROM staging.stg_provider_players p
        JOIN public.team_provider_map tpm
            ON tpm.provider = p.provider
           AND tpm.provider_team_id = p.external_team_id::text
        LEFT JOIN public.player_provider_map ppm
            ON ppm.provider = p.provider
           AND ppm.provider_player_id = p.external_player_id::text
        WHERE p.raw_payload_id = %s
          AND p.provider = %s
          AND p.sport_code = %s
          AND ppm.player_id IS NULL
          AND p.player_name IS NOT NULL;
        """,
        (raw_id, job["provider"], job["sport_code"]),
    )
    players_inserted = cur.rowcount

    cur.execute(
        """
        INSERT INTO public.player_provider_map (
            provider,
            provider_player_id,
            player_id,
            provider_team_id,
            provider_team_name,
            provider_player_name,
            is_active,
            created_at,
            updated_at
        )
        SELECT
            p.provider,
            p.external_player_id::text,
            pl.id,
            p.external_team_id::text,
            p.team_name,
            p.player_name,
            true,
            now(),
            now()
        FROM staging.stg_provider_players p
        JOIN public.players pl
            ON pl.ext_source = p.provider
           AND pl.ext_player_id = p.external_player_id::text
        LEFT JOIN public.player_provider_map ppm
            ON ppm.provider = p.provider
           AND ppm.provider_player_id = p.external_player_id::text
        WHERE p.raw_payload_id = %s
          AND p.provider = %s
          AND p.sport_code = %s
          AND ppm.player_id IS NULL;
        """,
        (raw_id, job["provider"], job["sport_code"]),
    )
    maps_inserted = cur.rowcount

    return players_inserted, maps_inserted


def mark_raw_parsed(cur, raw_id: int, parsed_rows: int) -> None:
    cur.execute(
        """
        UPDATE staging.stg_api_payloads
        SET parse_status = 'parsed',
            parse_message = %s
        WHERE id = %s;
        """,
        (f"people pipeline v2.1 parsed rows={parsed_rows}", raw_id),
    )


def mark_job_done(cur, job_id: int) -> None:
    cur.execute(
        """
        UPDATE ops.ingest_planner
        SET status = 'done',
            attempts = attempts + 1,
            last_attempt = now(),
            updated_at = now()
        WHERE id = %s;
        """,
        (job_id,),
    )


def mark_job_error(cur, job_id: int, message: str) -> None:
    cur.execute(
        """
        UPDATE ops.ingest_planner
        SET status = 'error',
            attempts = attempts + 1,
            last_attempt = now(),
            updated_at = now()
        WHERE id = %s;
        """,
        (job_id,),
    )


def update_people_audit(cur, job: dict, final_status: str, note: str) -> None:
    cur.execute(
        """
        UPDATE ops.provider_people_audit
        SET
            technical_status = %s,
            final_verdict = %s,
            data_quality_status = 'BASIC_OK',
            alternative_provider_needed = false,
            evidence_note = %s,
            next_step = 'PEOPLE V2.1 hotovo. Další krok: rozšířit targets/planner scope na další ligy/týmy.',
            updated_at = now()
        WHERE provider = %s
          AND sport_code = %s
          AND entity = %s;
        """,
        (
            final_status,
            final_status,
            note,
            job["provider"],
            job["sport_code"],
            job["entity"],
        ),
    )


def process_job(conn, job: dict) -> None:
    label = f"JOB {job['id']} | {job['provider']} | {job['sport_code']} | {job['entity']}"
    print(f"\n--- {label} ---")

    url = build_url(job)
    if not url:
        raise RuntimeError("No URL mapping for this people job")

    payload = fetch_payload(url)
    response = payload.get("response", [])
    response_count = len(response) if isinstance(response, list) else 0
    print(f"HTTP OK; response_count={response_count}")

    with conn.cursor() as cur:
        raw_id = save_raw(cur, job, payload)
        print(f"RAW saved id={raw_id}")

        if job["provider"] == "api_football" and job["entity"] == "players":
            parsed_rows = parse_fb_players(cur, raw_id, payload)
        elif job["provider"] == "api_football" and job["entity"] == "coaches":
            parsed_rows = parse_fb_coaches(cur, raw_id, payload)
        elif job["entity"] == "players":
            parsed_rows = parse_simple_players(cur, raw_id, job, payload)
        else:
            parsed_rows = 0

        mark_raw_parsed(cur, raw_id, parsed_rows)
        print(f"Parsed rows={parsed_rows}")

        if job["entity"] == "players":
            players_inserted, maps_inserted = merge_players_to_public(cur, job, raw_id)
            print(f"Public merge: players_inserted={players_inserted}; maps_inserted={maps_inserted}")

            final_status = "PUBLIC_CONFIRMED"
            note = (
                f"PEOPLE V2.1 OK | raw_id={raw_id} | parsed={parsed_rows} | "
                f"players_inserted={players_inserted} | maps_inserted={maps_inserted}"
            )
        else:
            print("Coaches public merge skipped: public coaches model not confirmed.")
            final_status = "STAGING_CONFIRMED"
            note = f"PEOPLE V2.1 coaches staging OK | raw_id={raw_id} | parsed={parsed_rows}"

        update_people_audit(cur, job, final_status, note)
        mark_job_done(cur, job["id"])


def main() -> None:
    print("=== MATCHMATRIX PEOPLE PIPELINE V2.1 FROM PLANNER ===")

    with psycopg.connect(DB_DSN, row_factory=dict_row) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT *
                FROM ops.ingest_planner
                WHERE status = 'pending'
                  AND run_group IN ('AFB_PEOPLE_V2')
                  AND entity IN ('players', 'coaches')
                ORDER BY priority, id
                LIMIT 10;
                """
            )
            jobs = cur.fetchall()

        if not jobs:
            print("No pending PEOPLE V2 jobs found.")
            return

        for job in jobs:
            try:
                process_job(conn, job)
                conn.commit()
            except Exception as e:
                conn.rollback()
                print(f"ERROR job_id={job['id']}: {type(e).__name__}: {e}")
                with conn.cursor() as cur:
                    mark_job_error(cur, job["id"], str(e))
                conn.commit()

    print("\nDONE")


if __name__ == "__main__":
    main()