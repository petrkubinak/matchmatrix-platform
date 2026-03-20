# ============================================================
# MatchMatrix
# PLAYER SEASON STATISTICS -> PUBLIC MERGE V1
# ============================================================

import os
from collections import defaultdict
from contextlib import closing
from decimal import Decimal, InvalidOperation
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


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


def load_player_map(cur) -> dict[tuple[str, str], int]:
    cur.execute(
        """
        SELECT provider, provider_player_id, player_id
        FROM public.player_provider_map
        WHERE provider IS NOT NULL
          AND provider_player_id IS NOT NULL
          AND player_id IS NOT NULL
        """
    )
    mapping = {}
    for row in cur.fetchall():
        mapping[(row["provider"], str(row["provider_player_id"]))] = int(row["player_id"])
    return mapping


def load_team_map(cur) -> dict[tuple[str, str], int]:
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


def load_league_map(cur) -> dict[tuple[str, str], int]:
    cur.execute(
        """
        SELECT ext_source, ext_league_id, id
        FROM public.leagues
        WHERE ext_source IS NOT NULL
          AND ext_league_id IS NOT NULL
        """
    )
    mapping = {}
    for row in cur.fetchall():
        mapping[(row["ext_source"], str(row["ext_league_id"]))] = int(row["id"])
    return mapping


def load_sport_map(cur) -> dict[str, int]:
    cur.execute("SELECT code, id FROM public.sports")
    return {row["code"]: int(row["id"]) for row in cur.fetchall()}


def fetch_staging_rows(cur):
    cur.execute(
        """
        SELECT
            provider,
            sport_code,
            external_league_id,
            season,
            player_external_id,
            team_external_id,
            stat_name,
            stat_value
        FROM staging.stg_provider_player_season_stats
        ORDER BY provider, external_league_id, season, player_external_id, team_external_id, stat_name
        """
    )
    return cur.fetchall()


def parse_int(value):
    if value is None:
        return None
    s = str(value).strip()
    if s == "" or s.lower() in {"null", "none", "n/a", "na", "-"}:
        return None
    try:
        return int(float(s.replace(",", ".")))
    except ValueError:
        return None


def parse_decimal(value, scale=2):
    if value is None:
        return None
    s = str(value).strip()
    if s == "" or s.lower() in {"null", "none", "n/a", "na", "-"}:
        return None
    try:
        d = Decimal(s.replace(",", "."))
        quant = Decimal("1").scaleb(-scale)
        return d.quantize(quant)
    except (InvalidOperation, ValueError):
        return None


def build_groups(rows):
    grouped = {}

    for row in rows:
        key = (
            row["provider"],
            str(row["external_league_id"]) if row["external_league_id"] is not None else None,
            str(row["season"]) if row["season"] is not None else None,
            str(row["player_external_id"]) if row["player_external_id"] is not None else None,
            str(row["team_external_id"]) if row["team_external_id"] is not None else None,
            row["sport_code"],
        )

        if key not in grouped:
            grouped[key] = {
                "provider": row["provider"],
                "external_league_id": key[1],
                "season": key[2],
                "player_external_id": key[3],
                "team_external_id": key[4],
                "sport_code": row["sport_code"],
                "stat_map": {},
            }

        grouped[key]["stat_map"][row["stat_name"]] = row["stat_value"]

    return list(grouped.values())


def choose_payload(group, player_id, team_id, sport_id, league_id):
    stat_map = group["stat_map"]

    return {
        "player_id": player_id,
        "team_id": team_id,
        "sport_id": sport_id,
        "league_id": league_id,
        "season": group["season"],
        "appearances": parse_int(stat_map.get("appearances")),
        "lineups": parse_int(stat_map.get("lineups")),
        "minutes_played": parse_int(stat_map.get("minutes_played")),
        "rating": parse_decimal(stat_map.get("rating"), 2),
        "goals": parse_int(stat_map.get("goals")),
        "assists": parse_int(stat_map.get("assists")),
        "shots_total": parse_int(stat_map.get("shots_total")),
        "shots_on_target": parse_int(stat_map.get("shots_on_target")),
        "passes_total": parse_int(stat_map.get("passes_total")),
        "passes_key": parse_int(stat_map.get("passes_key")),
        "passes_accuracy": parse_decimal(stat_map.get("passes_accuracy"), 2),
        "tackles_total": parse_int(stat_map.get("tackles_total")),
        "tackles_blocks": parse_int(stat_map.get("tackles_blocks")),
        "tackles_interceptions": parse_int(stat_map.get("tackles_interceptions")),
        "duels_total": parse_int(stat_map.get("duels_total")),
        "duels_won": parse_int(stat_map.get("duels_won")),
        "dribbles_attempts": parse_int(stat_map.get("dribbles_attempts")),
        "dribbles_success": parse_int(stat_map.get("dribbles_success")),
        "fouls_drawn": parse_int(stat_map.get("fouls_drawn")),
        "fouls_committed": parse_int(stat_map.get("fouls_committed")),
        "yellow_cards": parse_int(stat_map.get("yellow_cards")),
        "red_cards": parse_int(stat_map.get("red_cards")),
        "penalty_won": parse_int(stat_map.get("penalty_won")),
        "penalty_committed": parse_int(stat_map.get("penalty_committed")),
        "penalty_scored": parse_int(stat_map.get("penalty_scored")),
        "penalty_missed": parse_int(stat_map.get("penalty_missed")),
        "penalty_saved": parse_int(stat_map.get("penalty_saved")),
    }


def upsert_public_player_season_statistics(cur, payload):
    insert_cols = list(payload.keys())
    insert_vals = [payload[c] for c in insert_cols]

    update_cols = [c for c in insert_cols if c not in {"player_id", "league_id", "season"}]
    update_sql = ",\n                ".join([f"{c} = EXCLUDED.{c}" for c in update_cols])

    sql = f"""
        INSERT INTO public.player_season_statistics (
            {", ".join(insert_cols)}
        )
        VALUES (
            {", ".join(["%s"] * len(insert_cols))}
        )
        ON CONFLICT (player_id, league_id, season)
        DO UPDATE SET
            {update_sql},
            updated_at = now()
    """
    cur.execute(sql, insert_vals)


def main():
    print("=== MATCHMATRIX: PLAYER SEASON STATISTICS PUBLIC MERGE V1 ===")
    print("Zdroj : staging.stg_provider_player_season_stats")
    print("Cíl   : public.player_season_statistics")
    print()

    processed_groups = 0
    merged_rows = 0
    skipped_missing_player = 0
    skipped_missing_team = 0
    skipped_missing_league = 0

    try:
        with closing(get_db_connection()) as conn:
            conn.autocommit = False

            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                print("[1/6] Nastavuji timeouty...")
                cur.execute("SET lock_timeout = '5s';")
                cur.execute("SET statement_timeout = '10min';")
                print("      OK")

                print("[2/6] Načítám mapování...")
                player_map = load_player_map(cur)
                team_map = load_team_map(cur)
                league_map = load_league_map(cur)
                sport_map = load_sport_map(cur)
                print(f"      players mapped: {len(player_map)}")
                print(f"      teams mapped  : {len(team_map)}")
                print(f"      leagues mapped: {len(league_map)}")

                print("[3/6] Načítám staging...")
                rows = fetch_staging_rows(cur)
                print(f"      staging rows: {len(rows)}")

                print("[4/6] Skupinuji stats...")
                groups = build_groups(rows)
                print(f"      grouped rows: {len(groups)}")

                print("[5/6] Merge do public...")
                for group in groups:
                    processed_groups += 1

                    provider = group["provider"]
                    external_league_id = group["external_league_id"]
                    season = group["season"]
                    player_external_id = group["player_external_id"]
                    team_external_id = group["team_external_id"]
                    sport_code = group["sport_code"]

                    player_id = player_map.get((provider, player_external_id))
                    if player_id is None:
                        skipped_missing_player += 1
                        continue

                    team_id = None
                    if team_external_id is not None:
                        team_id = team_map.get((provider, team_external_id))
                        if team_id is None:
                            skipped_missing_team += 1

                    league_id = None
                    if external_league_id is not None:
                        league_id = league_map.get((provider, external_league_id))
                    if league_id is None:
                        skipped_missing_league += 1
                        continue

                    sport_id = sport_map.get(sport_code)

                    payload = choose_payload(
                        group=group,
                        player_id=player_id,
                        team_id=team_id,
                        sport_id=sport_id,
                        league_id=league_id,
                    )

                    upsert_public_player_season_statistics(cur, payload)
                    merged_rows += 1

                print("      merge OK")

                print("[6/6] COMMIT + kontrola...")
                conn.commit()

                cur.execute("SELECT COUNT(*) AS cnt FROM public.player_season_statistics;")
                cnt = cur.fetchone()["cnt"]

                print(f"      public.player_season_statistics: {cnt}")
                print()
                print("SUMMARY")
                print("--------------------------------------------------")
                print(f"processed grouped rows : {processed_groups}")
                print(f"merged rows            : {merged_rows}")
                print(f"skipped missing player : {skipped_missing_player}")
                print(f"skipped missing team   : {skipped_missing_team}")
                print(f"skipped missing league : {skipped_missing_league}")

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