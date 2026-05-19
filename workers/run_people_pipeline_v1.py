"""
run_people_pipeline_v1.py

Unified PEOPLE pipeline V1

Umí:
- RAW pull -> staging.stg_api_payloads
- parse -> staging.stg_provider_players / staging.stg_provider_coaches
- merge players -> public.players + public.player_provider_map
- audit update -> ops.provider_people_audit

Poznámka:
- coaches zatím pouze RAW + staging, protože public coaches model není potvrzený.
"""

import os
import json
import hashlib
import urllib.request
import urllib.error
from datetime import datetime, timezone

import psycopg


DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"

API_KEY = (
    os.getenv("APISPORTS_KEY")
    or os.getenv("API_SPORTS_KEY")
    or os.getenv("RAPIDAPI_KEY")
)

TARGETS = [
    {
        "provider": "api_football",
        "sport_code": "FB",
        "entity": "players",
        "endpoint_name": "players",
        "external_id": "league=39",
        "season": "2024",
        "url": "https://v3.football.api-sports.io/players?league=39&season=2024&page=1",
        "mode": "fb_players",
    },
    {
        "provider": "api_football",
        "sport_code": "FB",
        "entity": "coaches",
        "endpoint_name": "coachs",
        "external_id": "team=33",
        "season": None,
        "url": "https://v3.football.api-sports.io/coachs?team=33",
        "mode": "fb_coaches",
    },
    {
        "provider": "api_american_football",
        "sport_code": "AFB",
        "entity": "players",
        "endpoint_name": "players",
        "external_id": "team=1",
        "season": "2024",
        "url": "https://v1.american-football.api-sports.io/players?team=1&season=2024",
        "mode": "simple_players",
    },
]


def safe_int(value):
    try:
        return int(value) if value not in (None, "") else None
    except Exception:
        return None


def normalize_height_cm(value):
    if value is None:
        return None

    text = str(value).strip()

    if text.isdigit():
        return int(text)

    # zatím necháme US height typu 5' 9" jako NULL
    return None


def normalize_weight_kg(value):
    if value is None:
        return None

    text = str(value).strip()

    if text.isdigit():
        return int(text)

    # zatím necháme lbs jako NULL
    return None


def fetch_payload(url: str) -> dict:
    if not API_KEY:
        raise RuntimeError("Missing API key: APISPORTS_KEY / API_SPORTS_KEY / RAPIDAPI_KEY")

    req = urllib.request.Request(url)
    req.add_header("x-apisports-key", API_KEY)

    with urllib.request.urlopen(req, timeout=45) as response:
        raw = response.read().decode("utf-8", errors="replace")
        return json.loads(raw)


def hash_payload(payload: dict) -> str:
    text = json.dumps(payload, sort_keys=True, ensure_ascii=False)
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def save_raw(conn, target: dict, payload: dict) -> int:
    with conn.cursor() as cur:
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
                'people unified pipeline v1 raw saved',
                now()
            )
            RETURNING id;
            """,
            (
                target["provider"],
                target["sport_code"],
                target["entity"],
                target["endpoint_name"],
                target["external_id"],
                target["season"],
                json.dumps(payload, ensure_ascii=False),
                hash_payload(payload),
            ),
        )
        return cur.fetchone()[0]


def parse_fb_players(conn, raw_id: int, payload: dict) -> int:
    inserted_or_updated = 0
    rows = payload.get("response", [])

    with conn.cursor() as cur:
        for item in rows:
            player = item.get("player") or {}
            stats = item.get("statistics") or []
            stat0 = stats[0] if stats else {}

            team = stat0.get("team") or {}
            league = stat0.get("league") or {}
            games = stat0.get("games") or {}

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
                    str(player.get("id")) if player.get("id") is not None else None,
                    player.get("name"),
                    player.get("firstname"),
                    player.get("lastname"),
                    player.get("birth", {}).get("date"),
                    player.get("nationality"),
                    normalize_height_cm(player.get("height")),
                    normalize_weight_kg(player.get("weight")),
                    str(team.get("id")) if team.get("id") is not None else None,
                    team.get("name"),
                    str(league.get("id")) if league.get("id") is not None else None,
                    league.get("name"),
                    str(league.get("season")) if league.get("season") is not None else None,
                    games.get("position"),
                    raw_id,
                ),
            )

            inserted_or_updated += cur.rowcount

            # Pokud hráč už existuje, doplníme aktuální RAW/team/league info.
            cur.execute(
                """
                UPDATE staging.stg_provider_players
                SET
                    sport_code = 'FB',
                    external_team_id = COALESCE(NULLIF(external_team_id, ''), %s),
                    team_name = COALESCE(team_name, %s),
                    external_league_id = COALESCE(NULLIF(external_league_id, ''), %s),
                    league_name = COALESCE(league_name, %s),
                    season = COALESCE(season, %s),
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
                    str(player.get("id")) if player.get("id") is not None else None,
                ),
            )

    return len(rows)


def parse_simple_players(conn, raw_id: int, target: dict, payload: dict) -> int:
    rows = payload.get("response", [])
    team_id_from_target = target["external_id"].replace("team=", "") if target["external_id"].startswith("team=") else None

    with conn.cursor() as cur:
        for p in rows:
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
                    season,
                    position_code,
                    raw_payload_id,
                    source_endpoint,
                    created_at
                )
                VALUES (
                    %s, %s,
                    %s, %s,
                    NULL, NULL,
                    NULL,
                    %s,
                    %s,
                    %s,
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
                    target["provider"],
                    target["sport_code"],
                    str(p.get("id")) if p.get("id") is not None else None,
                    p.get("name"),
                    p.get("country"),
                    normalize_height_cm(p.get("height")),
                    normalize_weight_kg(p.get("weight")),
                    team_id_from_target,
                    f"Team {team_id_from_target}" if team_id_from_target else None,
                    target.get("season"),
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
                    target["sport_code"],
                    team_id_from_target,
                    f"Team {team_id_from_target}" if team_id_from_target else None,
                    target.get("season"),
                    p.get("position"),
                    raw_id,
                    target["provider"],
                    str(p.get("id")) if p.get("id") is not None else None,
                ),
            )

    return len(rows)


def parse_fb_coaches(conn, raw_id: int, payload: dict) -> int:
    rows = payload.get("response", [])

    with conn.cursor() as cur:
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


def mark_raw_parsed(conn, raw_id: int, rows: int) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE staging.stg_api_payloads
            SET parse_status = 'parsed',
                parse_message = %s
            WHERE id = %s;
            """,
            (f"people unified pipeline v1 parsed rows={rows}", raw_id),
        )


def merge_players_to_public(conn, provider: str, sport_code: str, raw_id: int) -> tuple[int, int]:
    with conn.cursor() as cur:
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
            (raw_id, provider, sport_code),
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
            (raw_id, provider, sport_code),
        )
        maps_inserted = cur.rowcount

    return players_inserted, maps_inserted


def update_audit(conn, target: dict, status: str, note: str) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE ops.provider_people_audit
            SET
                technical_status = %s,
                final_verdict = %s,
                data_quality_status = 'BASIC_OK',
                alternative_provider_needed = false,
                evidence_note = %s,
                next_step = %s,
                updated_at = now()
            WHERE provider = %s
              AND sport_code = %s
              AND entity = %s;
            """,
            (
                status,
                status,
                note,
                "People unified pipeline v1 hotová pro tuto větev. Další krok: přidat planner/targets a parametrizovat league/team scope.",
                target["provider"],
                target["sport_code"],
                target["entity"],
            ),
        )


def run_target(conn, target: dict) -> None:
    label = f"{target['provider']} | {target['sport_code']} | {target['entity']}"
    print(f"\n--- {label} ---")

    payload = fetch_payload(target["url"])
    response = payload.get("response", [])
    response_count = len(response) if isinstance(response, list) else 0

    raw_id = save_raw(conn, target, payload)
    print(f"RAW saved id={raw_id}; response_count={response_count}")

    if target["mode"] == "fb_players":
        parsed_rows = parse_fb_players(conn, raw_id, payload)
    elif target["mode"] == "fb_coaches":
        parsed_rows = parse_fb_coaches(conn, raw_id, payload)
    elif target["mode"] == "simple_players":
        parsed_rows = parse_simple_players(conn, raw_id, target, payload)
    else:
        parsed_rows = 0

    mark_raw_parsed(conn, raw_id, parsed_rows)
    print(f"Parsed rows={parsed_rows}")

    if target["entity"] == "players":
        players_inserted, maps_inserted = merge_players_to_public(
            conn,
            target["provider"],
            target["sport_code"],
            raw_id,
        )
        print(f"Public merge: players_inserted={players_inserted}; maps_inserted={maps_inserted}")

        update_audit(
            conn,
            target,
            "PUBLIC_CONFIRMED",
            f"Unified people pipeline v1 OK | raw_id={raw_id} | parsed={parsed_rows} | players_inserted={players_inserted} | maps_inserted={maps_inserted}",
        )
    else:
        print("Coaches: public merge skipped, public coaches model not confirmed.")
        update_audit(
            conn,
            target,
            "STAGING_CONFIRMED",
            f"Unified people pipeline v1 coaches staging OK | raw_id={raw_id} | parsed={parsed_rows}",
        )


def main() -> None:
    print("=== MATCHMATRIX UNIFIED PEOPLE PIPELINE V1 ===")

    with psycopg.connect(DB_DSN) as conn:
        for target in TARGETS:
            try:
                run_target(conn, target)
                conn.commit()
            except urllib.error.HTTPError as e:
                conn.rollback()
                body = e.read().decode("utf-8", errors="replace")
                print(f"HTTP ERROR {e.code}: {body[:500]}")
            except Exception as e:
                conn.rollback()
                print(f"ERROR {type(e).__name__}: {e}")

    print("\nDONE")


if __name__ == "__main__":
    main()