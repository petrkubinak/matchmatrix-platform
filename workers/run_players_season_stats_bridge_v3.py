import json
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

PROVIDER_CODE = "api_football"
SPORT_CODE = "football"
SOURCE_ENDPOINT = "/players"
TARGET_SCHEMA = "staging"
TARGET_TABLE = "stg_provider_player_season_stats"
SOURCE_SCHEMA = "staging"
SOURCE_TABLE = "players_import"


# ==========================================================
# MAPOVANI STATISTIK Z API-FOOTBALL
# ==========================================================
# V3:
# - uklada jen NEPRAZDNE hodnoty
# - uklada jen kanonicke nazvy statistik
# - pred insertem smaze stare radky pro daneho hrace/tym/ligu/sezonu,
#   aby v cili nezustavaly stare aliasy ani NULL kostra z V1/V2
# ==========================================================

STAT_FIELDS = [
    ("games", "appearences", "appearances"),
    ("games", "lineups", "lineups"),
    ("games", "minutes", "minutes_played"),
    ("games", "rating", "rating"),
    ("games", "captain", "captain"),
    ("games", "position", "position"),

    ("substitutes", "in", "substitutes_in"),
    ("substitutes", "out", "substitutes_out"),
    ("substitutes", "bench", "substitutes_bench"),

    ("shots", "total", "shots_total"),
    ("shots", "on", "shots_on"),

    ("goals", "total", "goals_total"),
    ("goals", "conceded", "goals_conceded"),
    ("goals", "assists", "assists"),
    ("goals", "saves", "saves"),

    ("passes", "total", "passes_total"),
    ("passes", "key", "passes_key"),
    ("passes", "accuracy", "passes_accuracy"),

    ("tackles", "total", "tackles_total"),
    ("tackles", "blocks", "tackles_blocks"),
    ("tackles", "interceptions", "tackles_interceptions"),

    ("duels", "total", "duels_total"),
    ("duels", "won", "duels_won"),

    ("dribbles", "attempts", "dribbles_attempts"),
    ("dribbles", "success", "dribbles_success"),
    ("dribbles", "past", "dribbles_past"),

    ("fouls", "drawn", "fouls_drawn"),
    ("fouls", "committed", "fouls_committed"),

    ("cards", "yellow", "cards_yellow"),
    ("cards", "yellowred", "cards_yellowred"),
    ("cards", "red", "cards_red"),

    ("penalty", "won", "penalty_won"),
    ("penalty", "commited", "penalty_committed"),
    ("penalty", "committed", "penalty_committed"),
    ("penalty", "scored", "penalty_scored"),
    ("penalty", "missed", "penalty_missed"),
    ("penalty", "saved", "penalty_saved"),
]


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


def get_table_columns(cur, schema_name: str, table_name: str) -> list[str]:
    cur.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
        ORDER BY ordinal_position
        """,
        (schema_name, table_name),
    )
    return [row["column_name"] for row in cur.fetchall()]


def _is_non_empty_stat_value(value) -> bool:
    if value is None:
        return False
    if isinstance(value, str):
        return value.strip() != ""
    return True


def _count_filled_stats(stat_row: dict) -> int:
    score = 0
    for parent_key, child_key, _ in STAT_FIELDS:
        parent = stat_row.get(parent_key, {}) or {}
        if not isinstance(parent, dict):
            continue
        value = parent.get(child_key)
        if _is_non_empty_stat_value(value):
            score += 1
    return score


def _select_best_statistics_block(statistics: list, expected_league_id: str, expected_season: str):
    valid_stats = [s for s in (statistics or []) if isinstance(s, dict)]
    if not valid_stats:
        return {}

    expected_league_id = str(expected_league_id) if expected_league_id is not None else None
    expected_season = str(expected_season) if expected_season is not None else None

    scored = []
    for s in valid_stats:
        league_obj = s.get("league", {}) or {}
        league_id = league_obj.get("id")
        season = league_obj.get("season")
        scored.append(
            {
                "row": s,
                "league_id": str(league_id) if league_id is not None else None,
                "season": str(season) if season is not None else None,
                "score": _count_filled_stats(s),
            }
        )

    exact = [x for x in scored if x["league_id"] == expected_league_id and x["season"] == expected_season]
    if exact:
        exact.sort(key=lambda x: x["score"], reverse=True)
        return exact[0]["row"]

    same_league = [x for x in scored if x["league_id"] == expected_league_id]
    if same_league:
        same_league.sort(key=lambda x: x["score"], reverse=True)
        return same_league[0]["row"]

    scored.sort(key=lambda x: x["score"], reverse=True)
    return scored[0]["row"]


def safe_json_load(value):
    if value is None:
        return None
    if isinstance(value, dict):
        return value
    if isinstance(value, str):
        value = value.strip()
        if not value:
            return None
        return json.loads(value)
    return None


def fetch_source_rows(cur):
    cur.execute(
        """
        SELECT
            provider,
            external_player_id,
            player_name,
            first_name,
            last_name,
            external_team_id,
            external_league_id,
            team_name,
            league_name,
            season,
            raw_payload_id,
            source_endpoint,
            is_active,
            raw_json
        FROM (
            SELECT
                COALESCE(provider_code, %s)::text AS provider,
                provider_player_id::text AS external_player_id,
                player_name::text AS player_name,
                first_name::text AS first_name,
                last_name::text AS last_name,
                COALESCE(provider_team_id, team_provider_id)::text AS external_team_id,
                provider_league_id::text AS external_league_id,
                team_name::text AS team_name,
                league_name::text AS league_name,
                season::text AS season,
                run_id::bigint AS raw_payload_id,
                source_endpoint::text AS source_endpoint,
                COALESCE(is_active, TRUE) AS is_active,
                raw_json,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        COALESCE(provider_code, %s),
                        provider_player_id,
                        COALESCE(provider_league_id, ''),
                        COALESCE(season::text, ''),
                        COALESCE(provider_team_id, team_provider_id, '')
                    ORDER BY
                        CASE WHEN source_endpoint = %s THEN 0 ELSE 1 END,
                        CASE WHEN run_id IS NOT NULL THEN 0 ELSE 1 END,
                        run_id DESC NULLS LAST,
                        provider_player_id::text DESC
                ) AS rn
            FROM staging.players_import
            WHERE provider_player_id IS NOT NULL
              AND raw_json IS NOT NULL
        ) q
        WHERE q.rn = 1
        ORDER BY provider, external_league_id, season, external_player_id;
        """,
        (PROVIDER_CODE, PROVIDER_CODE, SOURCE_ENDPOINT),
    )
    return cur.fetchall()


def get_nested_value(source: dict, parent_key: str, child_key: str):
    parent = source.get(parent_key, {}) or {}
    if not isinstance(parent, dict):
        return None
    return parent.get(child_key)


def normalize_stat_value(value):
    if value is None:
        return None
    if isinstance(value, str):
        value = value.strip()
        return value if value != "" else None
    if isinstance(value, bool):
        return value
    return value


def choose_payload_value(column_name: str, row: dict, stat_group: str, stat_name: str, stat_value, stat_block: dict):
    mapping = {
        "provider": row.get("provider"),
        "provider_code": row.get("provider"),
        "source_provider": row.get("provider"),
        "sport_code": SPORT_CODE,
        "external_player_id": row.get("external_player_id"),
        "player_external_id": row.get("external_player_id"),
        "provider_player_id": row.get("external_player_id"),
        "player_name": row.get("player_name"),
        "first_name": row.get("first_name"),
        "last_name": row.get("last_name"),
        "external_team_id": row.get("external_team_id"),
        "team_external_id": row.get("external_team_id"),
        "provider_team_id": row.get("external_team_id"),
        "team_name": row.get("team_name"),
        "external_league_id": row.get("external_league_id"),
        "provider_league_id": row.get("external_league_id"),
        "league_name": row.get("league_name"),
        "season": row.get("season"),
        "season_code": row.get("season"),
        "raw_payload_id": row.get("raw_payload_id"),
        "source_payload_id": row.get("raw_payload_id"),
        "run_id": row.get("raw_payload_id"),
        "source_endpoint": row.get("source_endpoint") or SOURCE_ENDPOINT,
        "is_active": row.get("is_active", True),
        "stat_group": stat_group,
        "stat_category": stat_group,
        "stat_name": stat_name,
        "stat_code": stat_name,
        "metric_name": stat_name,
        "metric_code": stat_name,
        "stat_value": stat_value,
        "metric_value": stat_value,
        "value": stat_value,
        "value_text": None if stat_value is None else str(stat_value),
        "value_num": float(stat_value) if isinstance(stat_value, (int, float)) and not isinstance(stat_value, bool) else None,
        "value_numeric": float(stat_value) if isinstance(stat_value, (int, float)) and not isinstance(stat_value, bool) else None,
        "value_bool": stat_value if isinstance(stat_value, bool) else None,
        "position_code": get_nested_value(stat_block, "games", "position"),
    }

    if column_name in mapping:
        return mapping[column_name]

    if column_name in {"created_at", "updated_at"}:
        return None

    return None


def extract_stat_payloads_from_row(row: dict, target_cols: set[str]) -> tuple[dict, list[dict], dict]:
    payload = safe_json_load(row.get("raw_json"))
    if not isinstance(payload, dict):
        return row, [], {}

    statistics = payload.get("statistics", []) or []
    stat_block = _select_best_statistics_block(
        statistics=statistics,
        expected_league_id=row.get("external_league_id"),
        expected_season=row.get("season"),
    )

    if not isinstance(stat_block, dict) or not stat_block:
        return row, [], {}

    team_obj = stat_block.get("team", {}) or {}
    league_obj = stat_block.get("league", {}) or {}

    row = dict(row)
    if team_obj.get("id") is not None:
        row["external_team_id"] = str(team_obj.get("id"))
    if team_obj.get("name"):
        row["team_name"] = team_obj.get("name")
    if league_obj.get("id") is not None:
        row["external_league_id"] = str(league_obj.get("id"))
    if league_obj.get("name"):
        row["league_name"] = league_obj.get("name")
    if league_obj.get("season") is not None:
        row["season"] = str(league_obj.get("season"))

    payloads = []
    stat_fill_summary = {}

    for stat_group, child_key, stat_name in STAT_FIELDS:
        raw_value = get_nested_value(stat_block, stat_group, child_key)
        stat_value = normalize_stat_value(raw_value)

        # V3: ukladame jen ne-null / ne-empty hodnoty
        if not _is_non_empty_stat_value(stat_value):
            continue

        stat_fill_summary[stat_name] = stat_fill_summary.get(stat_name, 0) + 1

        row_payload = {}
        for col in target_cols:
            if col in {"created_at", "updated_at"}:
                continue
            value = choose_payload_value(
                column_name=col,
                row=row,
                stat_group=stat_group,
                stat_name=stat_name,
                stat_value=stat_value,
                stat_block=stat_block,
            )
            if value is not None:
                row_payload[col] = value

        if row_payload.get("stat_name") or row_payload.get("stat_code") or row_payload.get("metric_name"):
            payloads.append(row_payload)

    return row, payloads, stat_fill_summary


def validate_target_columns(target_cols: set[str]):
    required_any = [
        {"provider", "player_external_id", "external_league_id", "season", "stat_name", "stat_value"},
        {"provider", "external_player_id", "external_league_id", "season", "stat_name", "stat_value"},
        {"provider_code", "provider_player_id", "provider_league_id", "season", "stat_name", "stat_value"},
        {"source_provider", "external_player_id", "external_league_id", "season", "metric_name", "metric_value"},
    ]

    if any(req.issubset(target_cols) for req in required_any):
        return

    raise RuntimeError(
        "Cílová tabulka staging.stg_provider_player_season_stats nemá očekávané sloupce. "
        f"Nalezené sloupce: {sorted(target_cols)}"
    )


def build_scope_conditions(target_cols: set[str], row: dict):
    candidate_pairs = [
        ("provider", row.get("provider")),
        ("provider_code", row.get("provider")),
        ("source_provider", row.get("provider")),
        ("sport_code", SPORT_CODE),
        ("external_player_id", row.get("external_player_id")),
        ("player_external_id", row.get("external_player_id")),
        ("provider_player_id", row.get("external_player_id")),
        ("external_team_id", row.get("external_team_id")),
        ("team_external_id", row.get("external_team_id")),
        ("provider_team_id", row.get("external_team_id")),
        ("external_league_id", row.get("external_league_id")),
        ("provider_league_id", row.get("external_league_id")),
        ("season", row.get("season")),
        ("season_code", row.get("season")),
        ("source_endpoint", row.get("source_endpoint") or SOURCE_ENDPOINT),
    ]

    conditions = []
    params = []
    for col, value in candidate_pairs:
        if col in target_cols and value is not None:
            conditions.append(f"{col} IS NOT DISTINCT FROM %s")
            params.append(value)

    return conditions, params


def delete_existing_scope_rows(cur, target_cols: set[str], row: dict) -> int:
    conditions, params = build_scope_conditions(target_cols, row)
    if len(conditions) < 5:
        raise RuntimeError(
            f"Nelze bezpečně složit DELETE scope pro hráče {row.get('external_player_id')}. "
            f"Podmínky: {conditions}"
        )

    cur.execute(
        f"""
        DELETE FROM {TARGET_SCHEMA}.{TARGET_TABLE}
        WHERE {' AND '.join(conditions)}
        """,
        params,
    )
    return cur.rowcount


def insert_new_row(cur, payload: dict, target_cols: set[str]):
    insert_cols = [c for c in payload.keys() if c in target_cols]
    values = [payload[c] for c in insert_cols]

    extra_cols = []
    extra_sql = []
    if "created_at" in target_cols:
        extra_cols.append("created_at")
        extra_sql.append("NOW()")
    if "updated_at" in target_cols:
        extra_cols.append("updated_at")
        extra_sql.append("NOW()")

    cur.execute(
        f"""
        INSERT INTO {TARGET_SCHEMA}.{TARGET_TABLE} (
            {', '.join(insert_cols + extra_cols)}
        )
        VALUES (
            {', '.join(['%s'] * len(insert_cols) + extra_sql)}
        )
        """,
        values,
    )


def main():
    print("=== MATCHMATRIX: PLAYERS SEASON STATS BRIDGE V3 ===")
    print(f"Zdroj : {SOURCE_SCHEMA}.{SOURCE_TABLE}")
    print(f"Cíl   : {TARGET_SCHEMA}.{TARGET_TABLE}")
    print()

    try:
        with closing(get_db_connection()) as conn:
            conn.autocommit = False

            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                print("[1/8] Nastavuji timeouty...")
                cur.execute("SET lock_timeout = '5s';")
                cur.execute("SET statement_timeout = '20min';")
                print("      OK")

                print("[2/8] Kontrola tabulek...")
                if not table_exists(cur, SOURCE_SCHEMA, SOURCE_TABLE):
                    raise RuntimeError(f"Chybí zdrojová tabulka {SOURCE_SCHEMA}.{SOURCE_TABLE}")
                if not table_exists(cur, TARGET_SCHEMA, TARGET_TABLE):
                    raise RuntimeError(f"Chybí cílová tabulka {TARGET_SCHEMA}.{TARGET_TABLE}")
                print("      OK")

                print("[3/8] Čtu cílové sloupce...")
                target_cols = set(get_table_columns(cur, TARGET_SCHEMA, TARGET_TABLE))
                validate_target_columns(target_cols)
                print(f"      cílové sloupce: {len(target_cols)}")
                print(f"      rozpoznané sloupce: {sorted(target_cols)}")

                print("[4/8] Kontrola zdroje...")
                cur.execute(
                    "SELECT COUNT(*) AS cnt FROM staging.players_import WHERE provider_player_id IS NOT NULL AND raw_json IS NOT NULL;"
                )
                src_count = cur.fetchone()["cnt"]
                print(f"      staging.players_import valid rows: {src_count}")

                print("[5/8] Načítám deduplikovaný zdroj...")
                source_rows = fetch_source_rows(cur)
                print(f"      načteno source rows: {len(source_rows)}")

                if not source_rows:
                    print("[6/8] Zdroj je prázdný, rollback a konec.")
                    conn.rollback()
                    return 0

                print("[6/8] Refreshuji target scope a ukládám jen neprázdné statistiky...")
                processed_source = 0
                players_with_stats = 0
                deleted_rows = 0
                inserted_rows = 0
                parsed_stat_rows = 0
                stat_fill_summary = {}

                for row in source_rows:
                    normalized_row, payloads, per_row_summary = extract_stat_payloads_from_row(row, target_cols)
                    processed_source += 1

                    if payloads:
                        players_with_stats += 1

                    deleted_rows += delete_existing_scope_rows(cur, target_cols, normalized_row)

                    for stat_name, cnt in per_row_summary.items():
                        stat_fill_summary[stat_name] = stat_fill_summary.get(stat_name, 0) + cnt

                    for payload in payloads:
                        parsed_stat_rows += 1
                        insert_new_row(cur, payload, target_cols)
                        inserted_rows += 1

                print("      bridge OK")

                print("[7/8] COMMIT...")
                conn.commit()
                print("      COMMIT OK")

                print("[8/8] Kontrola cíle...")
                cur.execute(f"SELECT COUNT(*) AS cnt FROM {TARGET_SCHEMA}.{TARGET_TABLE};")
                target_count = cur.fetchone()["cnt"]
                print(f"      {TARGET_SCHEMA}.{TARGET_TABLE}: {target_count}")
                print(f"      processed source rows: {processed_source}")
                print(f"      players with non-empty stats: {players_with_stats}")
                print(f"      deleted old rows in source scope: {deleted_rows}")
                print(f"      inserted rows: {inserted_rows}")
                print(f"      parsed non-empty stat rows: {parsed_stat_rows}")

                if stat_fill_summary:
                    print("      stat coverage (non-empty rows):")
                    for stat_name in sorted(stat_fill_summary.keys()):
                        print(f"        - {stat_name}: {stat_fill_summary[stat_name]}")

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
