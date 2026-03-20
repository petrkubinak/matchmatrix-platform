import os
from contextlib import closing
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


# ==========================================================
# LOAD .ENV
# ==========================================================

ENV_PATH = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(dotenv_path=ENV_PATH)

SPORT_CODE = "football"
DEFAULT_EXT_SOURCE = "api_football"


def get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", ""),
    )
    conn.set_client_encoding("UTF8")
    return conn


def get_table_columns(cur, schema_name: str, table_name: str) -> set[str]:
    cur.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
        """,
        (schema_name, table_name),
    )
    return {row["column_name"] for row in cur.fetchall()}


def table_exists(cur, schema_name: str, table_name: str) -> bool:
    cur.execute(
        """
        SELECT EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = %s
              AND table_name = %s
        ) AS exists_flag
        """,
        (schema_name, table_name),
    )
    return bool(cur.fetchone()["exists_flag"])


def fetch_staging_players(cur):
    cur.execute(
        """
        SELECT
            p.provider,
            p.sport_code,
            p.external_player_id,
            p.player_name,
            p.first_name,
            p.last_name,
            p.short_name,
            p.birth_date,
            p.nationality,
            p.position_code,
            p.height_cm,
            p.weight_kg,
            p.preferred_foot,
            p.external_team_id,
            p.external_league_id,
            p.team_name,
            p.league_name,
            p.season,
            p.raw_payload_id,
            p.source_endpoint,
            p.is_active
        FROM staging.stg_provider_players p
        WHERE p.sport_code = %s
        ORDER BY p.provider, p.external_player_id
        """,
        (SPORT_CODE,),
    )
    return cur.fetchall()


def load_team_provider_map(cur) -> dict[tuple[str, str], int]:
    if not table_exists(cur, "public", "team_provider_map"):
        return {}

    cols = get_table_columns(cur, "public", "team_provider_map")
    required = {"provider", "provider_team_id", "team_id"}
    if not required.issubset(cols):
        return {}

    cur.execute(
        """
        SELECT provider, provider_team_id, team_id
        FROM public.team_provider_map
        WHERE provider IS NOT NULL
          AND provider_team_id IS NOT NULL
          AND team_id IS NOT NULL
        """
    )

    mapping = {}
    for row in cur.fetchall():
        mapping[(row["provider"], str(row["provider_team_id"]))] = int(row["team_id"])
    return mapping


def choose_player_payload(row: dict, team_id: int | None, public_players_cols: set[str]) -> dict:
    payload = {}

    if "name" in public_players_cols:
        payload["name"] = row.get("player_name")

    if "first_name" in public_players_cols:
        payload["first_name"] = row.get("first_name")

    if "last_name" in public_players_cols:
        payload["last_name"] = row.get("last_name")

    if "short_name" in public_players_cols:
        payload["short_name"] = row.get("short_name")

    if "birth_date" in public_players_cols:
        payload["birth_date"] = row.get("birth_date")

    if "nationality" in public_players_cols:
        payload["nationality"] = row.get("nationality")

    if "position" in public_players_cols:
        payload["position"] = row.get("position_code")

    if "height_cm" in public_players_cols:
        payload["height_cm"] = row.get("height_cm")
    elif "height" in public_players_cols:
        payload["height"] = row.get("height_cm")

    if "weight_kg" in public_players_cols:
        payload["weight_kg"] = row.get("weight_kg")
    elif "weight" in public_players_cols:
        payload["weight"] = row.get("weight_kg")

    if "preferred_foot" in public_players_cols:
        payload["preferred_foot"] = row.get("preferred_foot")

    if "team_id" in public_players_cols:
        payload["team_id"] = team_id

    if "is_active" in public_players_cols:
        payload["is_active"] = row.get("is_active", True)

    if "ext_source" in public_players_cols:
        payload["ext_source"] = row.get("provider") or DEFAULT_EXT_SOURCE

    if "ext_player_id" in public_players_cols:
        payload["ext_player_id"] = row.get("external_player_id")

    return payload


def find_existing_player_id(cur, payload: dict, public_players_cols: set[str]) -> int | None:
    """
    Bez ON CONFLICT:
    1) ext_source + ext_player_id
    2) name + birth_date
    3) name
    """
    if {"ext_source", "ext_player_id"}.issubset(public_players_cols):
        ext_source = payload.get("ext_source")
        ext_player_id = payload.get("ext_player_id")
        if ext_source and ext_player_id:
            cur.execute(
                """
                SELECT id
                FROM public.players
                WHERE ext_source = %s
                  AND ext_player_id = %s
                LIMIT 1
                """,
                (ext_source, ext_player_id),
            )
            row = cur.fetchone()
            if row:
                return int(row["id"])

    if "name" in payload and "birth_date" in public_players_cols and payload.get("birth_date") is not None:
        cur.execute(
            """
            SELECT id
            FROM public.players
            WHERE name = %s
              AND birth_date = %s
            LIMIT 1
            """,
            (payload["name"], payload["birth_date"]),
        )
        row = cur.fetchone()
        if row:
            return int(row["id"])

    if "name" in payload:
        cur.execute(
            """
            SELECT id
            FROM public.players
            WHERE name = %s
            LIMIT 1
            """,
            (payload["name"],),
        )
        row = cur.fetchone()
        if row:
            return int(row["id"])

    return None


def insert_player(cur, payload: dict) -> int:
    cols = list(payload.keys())
    vals = [payload[c] for c in cols]

    cur.execute(
        f"""
        INSERT INTO public.players (
            {", ".join(cols)}
        )
        VALUES (
            {", ".join(["%s"] * len(cols))}
        )
        RETURNING id
        """,
        vals,
    )
    return int(cur.fetchone()["id"])


def update_player(cur, player_id: int, payload: dict):
    cols = [c for c in payload.keys() if c != "name"]
    if not cols:
        return

    set_sql = ", ".join([f"{c} = %s" for c in cols])
    vals = [payload[c] for c in cols] + [player_id]

    cur.execute(
        f"""
        UPDATE public.players
        SET {set_sql}
        WHERE id = %s
        """,
        vals,
    )


def merge_public_player(cur, payload: dict, public_players_cols: set[str]) -> tuple[int, str]:
    existing_id = find_existing_player_id(cur, payload, public_players_cols)

    if existing_id is None:
        player_id = insert_player(cur, payload)
        return player_id, "inserted"

    update_player(cur, existing_id, payload)
    return existing_id, "updated"


def find_existing_provider_map(cur, provider: str, provider_player_id: str) -> int | None:
    cur.execute(
        """
        SELECT id
        FROM public.player_provider_map
        WHERE provider = %s
          AND provider_player_id = %s
        LIMIT 1
        """,
        (provider, provider_player_id),
    )
    row = cur.fetchone()
    if row:
        return int(row["id"])
    return None


def merge_player_provider_map(cur, row: dict, player_id: int, ppm_cols: set[str]) -> str:
    required = {"provider", "provider_player_id", "player_id"}
    if not required.issubset(ppm_cols):
        return "skipped"

    payload = {
        "provider": row.get("provider"),
        "provider_player_id": row.get("external_player_id"),
        "player_id": player_id,
    }

    if "player_name" in ppm_cols:
        payload["player_name"] = row.get("player_name")

    if "birth_date" in ppm_cols:
        payload["birth_date"] = row.get("birth_date")

    if "nationality" in ppm_cols:
        payload["nationality"] = row.get("nationality")

    if "is_active" in ppm_cols:
        payload["is_active"] = row.get("is_active", True)

    existing_id = find_existing_provider_map(
        cur=cur,
        provider=payload["provider"],
        provider_player_id=payload["provider_player_id"],
    )

    if existing_id is None:
        cols = list(payload.keys())
        vals = [payload[c] for c in cols]

        cur.execute(
            f"""
            INSERT INTO public.player_provider_map (
                {", ".join(cols)}
            )
            VALUES (
                {", ".join(["%s"] * len(cols))}
            )
            """,
            vals,
        )
        return "inserted"

    update_cols = [c for c in payload.keys() if c not in {"provider", "provider_player_id"}]
    if update_cols:
        set_sql = ", ".join([f"{c} = %s" for c in update_cols])
        vals = [payload[c] for c in update_cols] + [existing_id]

        cur.execute(
            f"""
            UPDATE public.player_provider_map
            SET {set_sql}
            WHERE id = %s
            """,
            vals,
        )

    return "updated"


def main():
    print("=== MATCHMATRIX: PLAYERS PUBLIC MERGE V2 ===")
    print("Zdroj : staging.stg_provider_players")
    print("Cíl   : public.players + public.player_provider_map")
    print()

    processed_rows = 0
    inserted_players = 0
    updated_players = 0
    inserted_maps = 0
    updated_maps = 0
    skipped_maps = 0
    mapped_team_count = 0

    try:
        with closing(get_db_connection()) as conn:
            conn.autocommit = False

            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                print("[1/7] Nastavuji timeouty...")
                cur.execute("SET lock_timeout = '5s';")
                cur.execute("SET statement_timeout = '10min';")
                print("      OK")

                print("[2/7] Načítám metadata schématu...")
                public_players_cols = get_table_columns(cur, "public", "players")
                ppm_cols = get_table_columns(cur, "public", "player_provider_map")
                print(f"      public.players columns: {len(public_players_cols)}")
                print(f"      public.player_provider_map columns: {len(ppm_cols)}")

                print("[3/7] Načítám team provider map...")
                team_map = load_team_provider_map(cur)
                print(f"      team mappings: {len(team_map)}")

                print("[4/7] Načítám staging hráče...")
                rows = fetch_staging_players(cur)
                print(f"      staging.stg_provider_players: {len(rows)}")

                print("[5/7] Merge do public...")
                for row in rows:
                    team_id = None
                    external_team_id = row.get("external_team_id")
                    provider = row.get("provider")

                    if provider and external_team_id:
                        team_id = team_map.get((provider, str(external_team_id)))
                        if team_id is not None:
                            mapped_team_count += 1

                    player_payload = choose_player_payload(
                        row=row,
                        team_id=team_id,
                        public_players_cols=public_players_cols,
                    )

                    player_id, player_action = merge_public_player(
                        cur=cur,
                        payload=player_payload,
                        public_players_cols=public_players_cols,
                    )

                    if player_action == "inserted":
                        inserted_players += 1
                    else:
                        updated_players += 1

                    map_action = merge_player_provider_map(
                        cur=cur,
                        row=row,
                        player_id=player_id,
                        ppm_cols=ppm_cols,
                    )

                    if map_action == "inserted":
                        inserted_maps += 1
                    elif map_action == "updated":
                        updated_maps += 1
                    else:
                        skipped_maps += 1

                    processed_rows += 1

                print("      merge OK")

                print("[6/7] COMMIT...")
                conn.commit()
                print("      COMMIT OK")

                print("[7/7] Kontrola cílového stavu...")
                cur.execute("SELECT COUNT(*) AS cnt FROM public.players;")
                players_cnt = cur.fetchone()["cnt"]

                cur.execute("SELECT COUNT(*) AS cnt FROM public.player_provider_map;")
                ppm_cnt = cur.fetchone()["cnt"]

                print(f"      public.players: {players_cnt}")
                print(f"      public.player_provider_map: {ppm_cnt}")
                print(f"      processed rows: {processed_rows}")
                print(f"      inserted players: {inserted_players}")
                print(f"      updated players: {updated_players}")
                print(f"      inserted provider maps: {inserted_maps}")
                print(f"      updated provider maps: {updated_maps}")
                print(f"      skipped provider maps: {skipped_maps}")
                print(f"      team mapped rows: {mapped_team_count}")

        print()
        print("Hotovo.")
        return 0

    except psycopg2.Error as e:
        print()
        print("CHYBA PSYCOPG2:")
        print(str(e))
        return 1
    except Exception as e:
        print()
        print("CHYBA OBECNÁ:")
        print(str(e))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())