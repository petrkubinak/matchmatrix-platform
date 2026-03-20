# ============================================================
# MatchMatrix
# PLAYER PROFILES -> PUBLIC PLAYERS MERGE V1
#
# Source:
#   staging.stg_provider_player_profiles
#
# Target:
#   public.players
#   public.player_provider_map
#   public.player_external_identity
#
# Purpose:
#   Enrich canonical players with profile data.
#   If player mapping does not exist yet, create the player
#   in public.players and create provider mapping automatically.
# ============================================================

import os
from contextlib import closing
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


# ============================================================
# LOAD .ENV
# ============================================================

ENV_PATH = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(dotenv_path=ENV_PATH)


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


def normalize_provider(provider: str | None) -> str | None:
    """
    Normalizace endpoint-specific providerů na canonical provider.
    """
    if provider is None:
        return None

    mapping = {
        "api_football_squads": "api_football",
        "api_football_players": "api_football",
        "api_football_odds": "api_football",
    }
    return mapping.get(provider, provider)


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


def fetch_profile_rows(cur):
    cur.execute(
        """
        SELECT
            id,
            provider,
            sport_code,
            external_player_id,
            player_name,
            first_name,
            last_name,
            display_name,
            short_name,
            birth_date,
            birth_place,
            birth_country,
            nationality,
            height_cm,
            weight_kg,
            preferred_foot,
            shirt_number,
            position_code,
            position_name,
            photo_url,
            is_injured,
            is_active,
            external_team_id,
            team_name,
            external_league_id,
            league_name,
            season,
            source_payload_id,
            source_endpoint,
            created_at,
            updated_at
        FROM staging.stg_provider_player_profiles
        ORDER BY id
        """
    )
    return cur.fetchall()


def load_team_provider_map(cur) -> dict[tuple[str, str], int]:
    """
    (provider, provider_team_id) -> team_id
    """
    cur.execute(
        """
        SELECT EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = 'team_provider_map'
        ) AS exists_flag
        """
    )
    if not cur.fetchone()["exists_flag"]:
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


def find_player_by_provider_map(cur, provider: str, ext_player_id: str):
    cur.execute(
        """
        SELECT player_id
        FROM public.player_provider_map
        WHERE provider = %s
          AND provider_player_id = %s
        """,
        (provider, ext_player_id),
    )
    return cur.fetchone()


def find_player_by_public_players(cur, provider: str, ext_player_id: str):
    cur.execute(
        """
        SELECT id AS player_id
        FROM public.players
        WHERE ext_source = %s
          AND ext_player_id = %s
        """,
        (provider, ext_player_id),
    )
    return cur.fetchone()


def choose_player_payload(
    row: dict,
    public_players_cols: set[str],
    provider: str,
    ext_player_id: str,
    team_id: int | None,
) -> dict:
    """
    Připraví payload jen do sloupců, které v public.players opravdu existují.
    """
    payload = {}

    canonical_name = row.get("display_name") or row.get("player_name")
    canonical_position = row.get("position_name") or row.get("position_code")

    if "name" in public_players_cols:
        payload["name"] = canonical_name

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
        payload["position"] = canonical_position

    if "shirt_number" in public_players_cols:
        payload["shirt_number"] = row.get("shirt_number")

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

    if "photo_url" in public_players_cols:
        payload["photo_url"] = row.get("photo_url")

    if "is_active" in public_players_cols:
        payload["is_active"] = row.get("is_active", True)

    if "team_id" in public_players_cols:
        payload["team_id"] = team_id

    if "ext_source" in public_players_cols:
        payload["ext_source"] = provider

    if "ext_player_id" in public_players_cols:
        payload["ext_player_id"] = ext_player_id

    return payload


def upsert_public_player(cur, payload: dict, public_players_cols: set[str]) -> int:
    """
    UPSERT do public.players přes (ext_source, ext_player_id), pokud existují.
    Jinak fallback na name + birth_date.
    """
    if not payload:
        raise RuntimeError("Prázdný payload pro public.players")

    has_ext_keys = {"ext_source", "ext_player_id"}.issubset(public_players_cols)

    if has_ext_keys:
        insert_cols = list(payload.keys())
        insert_vals = [payload[c] for c in insert_cols]

        update_cols = [c for c in insert_cols if c not in {"ext_source", "ext_player_id"}]

        # Pro photo_url nechceme přepsat existující hodnotu prázdným stringem.
        update_parts = []
        for c in update_cols:
            if c == "photo_url":
                update_parts.append("photo_url = COALESCE(NULLIF(EXCLUDED.photo_url, ''), public.players.photo_url)")
            else:
                update_parts.append(f"{c} = EXCLUDED.{c}")

        update_sql = ",\n                ".join(update_parts)

        sql = f"""
            INSERT INTO public.players (
                {", ".join(insert_cols)}
            )
            VALUES (
                {", ".join(["%s"] * len(insert_cols))}
            )
            ON CONFLICT (ext_source, ext_player_id)
            WHERE ext_source IS NOT NULL AND ext_player_id IS NOT NULL
            DO UPDATE SET
                {update_sql}
            RETURNING id;
        """
        cur.execute(sql, insert_vals)
        return int(cur.fetchone()["id"])

    # fallback branch
    if "name" not in payload:
        raise RuntimeError("Fallback merge bez ext klíčů vyžaduje sloupec public.players.name")

    if "birth_date" in public_players_cols and payload.get("birth_date") is not None:
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
    else:
        cur.execute(
            """
            SELECT id
            FROM public.players
            WHERE name = %s
            LIMIT 1
            """,
            (payload["name"],),
        )

    found = cur.fetchone()
    if found:
        player_id = int(found["id"])

        update_cols = [c for c in payload.keys() if c != "name"]
        if update_cols:
            set_sql = ", ".join([f"{c} = %s" for c in update_cols])
            vals = [payload[c] for c in update_cols] + [player_id]
            cur.execute(
                f"""
                UPDATE public.players
                SET {set_sql}
                WHERE id = %s
                """,
                vals,
            )
        return player_id

    insert_cols = list(payload.keys())
    insert_vals = [payload[c] for c in insert_cols]
    cur.execute(
        f"""
        INSERT INTO public.players (
            {", ".join(insert_cols)}
        )
        VALUES (
            {", ".join(["%s"] * len(insert_cols))}
        )
        RETURNING id
        """,
        insert_vals,
    )
    return int(cur.fetchone()["id"])


def upsert_player_provider_map(cur, row: dict, player_id: int, ppm_cols: set[str], provider: str, ext_player_id: str):
    """
    UPSERT do public.player_provider_map jen přes existující sloupce.
    """
    required = {"provider", "provider_player_id", "player_id"}
    if not required.issubset(ppm_cols):
        return

    payload = {
        "provider": provider,
        "provider_player_id": ext_player_id,
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

    insert_cols = list(payload.keys())
    insert_vals = [payload[c] for c in insert_cols]

    update_cols = [c for c in insert_cols if c not in {"provider", "provider_player_id"}]
    update_sql = ",\n                ".join([f"{c} = EXCLUDED.{c}" for c in update_cols])

    sql = f"""
        INSERT INTO public.player_provider_map (
            {", ".join(insert_cols)}
        )
        VALUES (
            {", ".join(["%s"] * len(insert_cols))}
        )
        ON CONFLICT (provider, provider_player_id)
        DO UPDATE SET
            {update_sql}
    """
    cur.execute(sql, insert_vals)


def upsert_player_external_identity(cur, row: dict, player_id: int, pei_cols: set[str], provider: str, ext_player_id: str):
    """
    UPSERT do public.player_external_identity.
    Použije jen existující sloupce.
    """
    required = {"provider", "external_player_id"}
    if not required.issubset(pei_cols):
        return False

    payload = {
        "provider": provider,
        "external_player_id": ext_player_id,
    }

    if "player_id" in pei_cols:
        payload["player_id"] = player_id

    if "external_team_id" in pei_cols:
        payload["external_team_id"] = row.get("external_team_id")

    if "external_league_id" in pei_cols:
        payload["external_league_id"] = row.get("external_league_id")

    if "season" in pei_cols:
        payload["season"] = row.get("season")

    insert_cols = list(payload.keys())
    insert_vals = [payload[c] for c in insert_cols]

    conflict_cols = ["provider", "external_player_id"]

    update_cols = [c for c in insert_cols if c not in conflict_cols]
    if not update_cols:
        return False

    update_sql = ",\n                ".join([f"{c} = EXCLUDED.{c}" for c in update_cols])

    sql = f"""
        INSERT INTO public.player_external_identity (
            {", ".join(insert_cols)}
        )
        VALUES (
            {", ".join(["%s"] * len(insert_cols))}
        )
        ON CONFLICT ({", ".join(conflict_cols)})
        DO UPDATE SET
            {update_sql}
    """
    cur.execute(sql, insert_vals)
    return True


def main():
    print("=== MATCHMATRIX PLAYER PROFILES MERGE V1 ===")
    print("Zdroj : staging.stg_provider_player_profiles")
    print("Cíl   : public.players + public.player_provider_map + public.player_external_identity")
    print()

    processed = 0
    created_or_updated_players = 0
    provider_map_upserts = 0
    external_identity_upserts = 0
    created_missing_players = 0
    team_mapped_rows = 0
    skipped_missing_keys = 0

    try:
        with closing(get_db_connection()) as conn:
            conn.autocommit = False

            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                print("[1/8] Nastavuji timeouty...")
                cur.execute("SET lock_timeout = '5s';")
                cur.execute("SET statement_timeout = '10min';")
                print("      OK")

                print("[2/8] Načítám metadata schématu...")
                public_players_cols = get_table_columns(cur, "public", "players")
                ppm_cols = get_table_columns(cur, "public", "player_provider_map")
                pei_cols = get_table_columns(cur, "public", "player_external_identity")
                print(f"      public.players columns: {len(public_players_cols)}")
                print(f"      public.player_provider_map columns: {len(ppm_cols)}")
                print(f"      public.player_external_identity columns: {len(pei_cols)}")

                print("[3/8] Načítám team provider map...")
                team_map = load_team_provider_map(cur)
                print(f"      team mappings: {len(team_map)}")

                print("[4/8] Načítám staging player profiles...")
                rows = fetch_profile_rows(cur)
                print(f"      staging.stg_provider_player_profiles: {len(rows)}")

                print("[5/8] Merge do public...")
                for row in rows:
                    processed += 1

                    raw_provider = row.get("provider")
                    provider = normalize_provider(raw_provider)
                    ext_player_id_raw = row.get("external_player_id")
                    ext_player_id = str(ext_player_id_raw) if ext_player_id_raw is not None else None

                    if not provider or not ext_player_id:
                        skipped_missing_keys += 1
                        print(
                            f"      SKIP missing key data | staging_id={row.get('id')} | "
                            f"provider={raw_provider} | external_player_id={ext_player_id_raw}"
                        )
                        continue

                    # team mapping
                    team_id = None
                    external_team_id = row.get("external_team_id")
                    if external_team_id is not None:
                        team_id = team_map.get((provider, str(external_team_id)))
                        if team_id is not None:
                            team_mapped_rows += 1

                    # 1) lookup via player_provider_map
                    map_row = find_player_by_provider_map(cur, provider, ext_player_id)

                    # 2) fallback via public.players(ext_source, ext_player_id)
                    if not map_row:
                        map_row = find_player_by_public_players(cur, provider, ext_player_id)

                    # 3) create/update player
                    player_payload = choose_player_payload(
                        row=row,
                        public_players_cols=public_players_cols,
                        provider=provider,
                        ext_player_id=ext_player_id,
                        team_id=team_id,
                    )

                    if map_row:
                        player_id = int(map_row["player_id"])
                        # Update existing row explicitly přes upsert_public_player
                        player_id = upsert_public_player(
                            cur=cur,
                            payload=player_payload,
                            public_players_cols=public_players_cols,
                        )
                    else:
                        player_id = upsert_public_player(
                            cur=cur,
                            payload=player_payload,
                            public_players_cols=public_players_cols,
                        )
                        created_missing_players += 1
                        print(
                            f"      CREATE missing player | staging_id={row.get('id')} | "
                            f"provider={provider} | external_player_id={ext_player_id} | "
                            f"player_name={row.get('player_name')}"
                        )

                    created_or_updated_players += 1

                    # 4) ensure provider map exists
                    upsert_player_provider_map(
                        cur=cur,
                        row=row,
                        player_id=player_id,
                        ppm_cols=ppm_cols,
                        provider=provider,
                        ext_player_id=ext_player_id,
                    )
                    provider_map_upserts += 1

                    # 5) external identity
                    did_upsert_identity = upsert_player_external_identity(
                        cur=cur,
                        row=row,
                        player_id=player_id,
                        pei_cols=pei_cols,
                        provider=provider,
                        ext_player_id=ext_player_id,
                    )
                    if did_upsert_identity:
                        external_identity_upserts += 1

                print("      merge OK")

                print("[6/8] COMMIT...")
                conn.commit()
                print("      COMMIT OK")

                print("[7/8] Kontrola cílového stavu...")
                cur.execute("SELECT COUNT(*) AS cnt FROM public.players;")
                players_cnt = cur.fetchone()["cnt"]

                cur.execute("SELECT COUNT(*) AS cnt FROM public.player_provider_map;")
                ppm_cnt = cur.fetchone()["cnt"]

                cur.execute("SELECT COUNT(*) AS cnt FROM public.player_external_identity;")
                pei_cnt = cur.fetchone()["cnt"]

                print(f"      public.players: {players_cnt}")
                print(f"      public.player_provider_map: {ppm_cnt}")
                print(f"      public.player_external_identity: {pei_cnt}")

                print("[8/8] Summary...")
                print(f"      processed rows: {processed}")
                print(f"      players created/updated: {created_or_updated_players}")
                print(f"      newly created missing players: {created_missing_players}")
                print(f"      provider map upserts: {provider_map_upserts}")
                print(f"      external identity upserts: {external_identity_upserts}")
                print(f"      team mapped rows: {team_mapped_rows}")
                print(f"      skipped missing keys: {skipped_missing_keys}")

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