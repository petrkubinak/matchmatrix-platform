# ============================================================
# MatchMatrix
# PLAYER MATCH STATISTICS -> PUBLIC MERGE V1
#
# Source:
#   staging.stg_provider_player_stats
#
# Target:
#   public.player_match_statistics
#
# Purpose:
#   Merge EAV-style provider player stats into canonical
#   match-level player statistics.
#
# Notes:
#   - expects match-level rows already parsed into staging
#   - uses:
#       public.matches            via (ext_source, ext_match_id)
#       public.player_provider_map via (provider, provider_player_id)
#       public.team_provider_map   via (provider, provider_team_id)
#   - upsert target key:
#       (match_id, player_id)
# ============================================================

import os
from collections import defaultdict
from contextlib import closing
from decimal import Decimal, InvalidOperation
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
    if provider is None:
        return None

    mapping = {
        "api_football_squads": "api_football",
        "api_football_players": "api_football",
        "api_football_odds": "api_football",
        "api_football_statistics": "api_football",
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


def fetch_staging_rows(cur):
    cur.execute(
        """
        SELECT
            id,
            provider,
            sport_code,
            external_fixture_id,
            player_external_id,
            stat_name,
            stat_value,
            raw_payload_id,
            team_external_id,
            external_league_id,
            season,
            source_endpoint,
            created_at,
            updated_at
        FROM staging.stg_provider_player_stats
        WHERE sport_code = 'football'
        ORDER BY provider, external_fixture_id, player_external_id, team_external_id, stat_name, id
        """
    )
    return cur.fetchall()


def load_match_map(cur) -> dict[tuple[str, str], int]:
    cur.execute(
        """
        SELECT id, ext_source, ext_match_id
        FROM public.matches
        WHERE ext_source IS NOT NULL
          AND ext_match_id IS NOT NULL
        """
    )

    mapping = {}
    for row in cur.fetchall():
        mapping[(row["ext_source"], str(row["ext_match_id"]))] = int(row["id"])
    return mapping


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


def normalize_stat_name(name: str | None) -> str:
    if not name:
        return ""

    x = name.strip().lower()
    x = x.replace("%", " pct ")
    x = x.replace("/", " ")
    x = x.replace("-", " ")
    x = x.replace("_", " ")
    x = " ".join(x.split())
    return x


STAT_ALIASES = {
    "minutes_played": {
        "minutes played", "minutes", "min", "mins", "time played"
    },
    "goals": {
        "goals", "goals total", "goal", "total goals"
    },
    "assists": {
        "assists", "assist"
    },
    "shots_total": {
        "shots total", "total shots", "shots", "shots attempted"
    },
    "shots_on_target": {
        "shots on target", "on target", "shots on goal"
    },
    "passes_total": {
        "passes total", "total passes", "passes"
    },
    "passes_accurate": {
        "passes accurate", "accurate passes", "passes success", "successful passes"
    },
    "key_passes": {
        "key passes", "key pass"
    },
    "dribbles_attempted": {
        "dribbles attempts", "dribbles attempted", "dribbles", "dribble attempts"
    },
    "dribbles_successful": {
        "dribbles success", "dribbles successful", "successful dribbles"
    },
    "tackles": {
        "tackles", "total tackles"
    },
    "interceptions": {
        "interceptions", "intercept"
    },
    "clearances": {
        "clearances", "clearance"
    },
    "blocks": {
        "blocks", "blocked shots", "blocked"
    },
    "fouls_committed": {
        "fouls committed", "fouls", "fouls commited", "faults committed"
    },
    "fouls_drawn": {
        "fouls drawn", "was fouled", "drawn fouls"
    },
    "yellow_cards": {
        "yellow cards", "yellow", "yellow card"
    },
    "red_cards": {
        "red cards", "red", "red card"
    },
    "offsides": {
        "offsides", "offsides won", "offside"
    },
    "saves": {
        "saves", "goalkeeper saves", "save"
    },
    "rating": {
        "rating", "match rating"
    },
    "xg": {
        "xg", "expected goals"
    },
    "xa": {
        "xa", "expected assists"
    },
}


def canonical_stat_name(raw_name: str | None) -> str | None:
    normalized = normalize_stat_name(raw_name)
    if not normalized:
        return None

    for canonical, aliases in STAT_ALIASES.items():
        if normalized in aliases:
            return canonical

    return None


def parse_int(value) -> int | None:
    if value is None:
        return None

    s = str(value).strip()
    if s == "" or s.lower() in {"null", "none", "n/a", "na", "-"}:
        return None

    s = s.replace(",", ".")
    try:
        return int(float(s))
    except ValueError:
        return None


def parse_decimal(value, scale: int | None = None) -> Decimal | None:
    if value is None:
        return None

    s = str(value).strip()
    if s == "" or s.lower() in {"null", "none", "n/a", "na", "-"}:
        return None

    s = s.replace(",", ".")
    try:
        d = Decimal(s)
        if scale is not None:
            quant = Decimal("1").scaleb(-scale)
            d = d.quantize(quant)
        return d
    except (InvalidOperation, ValueError):
        return None


def build_stat_groups(rows):
    """
    EAV rows -> 1 grouped object per
    (provider, external_fixture_id, player_external_id, team_external_id)
    """
    grouped = {}

    for row in rows:
        provider = normalize_provider(row["provider"])
        external_fixture_id = str(row["external_fixture_id"]) if row["external_fixture_id"] is not None else None
        player_external_id = str(row["player_external_id"]) if row["player_external_id"] is not None else None
        team_external_id = str(row["team_external_id"]) if row["team_external_id"] is not None else None

        if not provider or not external_fixture_id or not player_external_id:
            continue

        key = (provider, external_fixture_id, player_external_id, team_external_id)

        if key not in grouped:
            grouped[key] = {
                "provider": provider,
                "external_fixture_id": external_fixture_id,
                "player_external_id": player_external_id,
                "team_external_id": team_external_id,
                "external_league_id": row.get("external_league_id"),
                "season": row.get("season"),
                "source_endpoint": row.get("source_endpoint"),
                "stat_map": {},
            }

        canonical = canonical_stat_name(row.get("stat_name"))
        if canonical:
            grouped[key]["stat_map"][canonical] = row.get("stat_value")

    return list(grouped.values())


def choose_public_payload(group, match_id: int, team_id: int, player_id: int) -> dict:
    stat_map = group["stat_map"]

    payload = {
        "match_id": match_id,
        "team_id": team_id,
        "player_id": player_id,
        "minutes_played": parse_int(stat_map.get("minutes_played")),
        "goals": parse_int(stat_map.get("goals")) or 0,
        "assists": parse_int(stat_map.get("assists")) or 0,
        "shots_total": parse_int(stat_map.get("shots_total")) or 0,
        "shots_on_target": parse_int(stat_map.get("shots_on_target")) or 0,
        "passes_total": parse_int(stat_map.get("passes_total")) or 0,
        "passes_accurate": parse_int(stat_map.get("passes_accurate")) or 0,
        "key_passes": parse_int(stat_map.get("key_passes")) or 0,
        "dribbles_attempted": parse_int(stat_map.get("dribbles_attempted")) or 0,
        "dribbles_successful": parse_int(stat_map.get("dribbles_successful")) or 0,
        "tackles": parse_int(stat_map.get("tackles")) or 0,
        "interceptions": parse_int(stat_map.get("interceptions")) or 0,
        "clearances": parse_int(stat_map.get("clearances")) or 0,
        "blocks": parse_int(stat_map.get("blocks")) or 0,
        "fouls_committed": parse_int(stat_map.get("fouls_committed")) or 0,
        "fouls_drawn": parse_int(stat_map.get("fouls_drawn")) or 0,
        "yellow_cards": parse_int(stat_map.get("yellow_cards")) or 0,
        "red_cards": parse_int(stat_map.get("red_cards")) or 0,
        "offsides": parse_int(stat_map.get("offsides")) or 0,
        "saves": parse_int(stat_map.get("saves")) or 0,
        "rating": parse_decimal(stat_map.get("rating"), scale=2),
        "xg": parse_decimal(stat_map.get("xg"), scale=4),
        "xa": parse_decimal(stat_map.get("xa"), scale=4),
    }

    return payload


def upsert_public_player_match_statistics(cur, payload: dict):
    insert_cols = list(payload.keys())
    insert_vals = [payload[c] for c in insert_cols]

    update_cols = [c for c in insert_cols if c not in {"match_id", "player_id"}]
    update_sql = ",\n                ".join([f"{c} = EXCLUDED.{c}" for c in update_cols])

    sql = f"""
        INSERT INTO public.player_match_statistics (
            {", ".join(insert_cols)}
        )
        VALUES (
            {", ".join(["%s"] * len(insert_cols))}
        )
        ON CONFLICT (match_id, player_id)
        DO UPDATE SET
            {update_sql},
            updated_at = now()
    """
    cur.execute(sql, insert_vals)


def main():
    print("=== MATCHMATRIX: PLAYER MATCH STATISTICS PUBLIC MERGE V1 ===")
    print("Zdroj : staging.stg_provider_player_stats")
    print("Cíl   : public.player_match_statistics")
    print()

    processed_groups = 0
    merged_rows = 0
    skipped_missing_match = 0
    skipped_missing_player = 0
    skipped_missing_team = 0
    skipped_empty_stats = 0

    try:
        with closing(get_db_connection()) as conn:
            conn.autocommit = False

            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                print("[1/7] Nastavuji timeouty...")
                cur.execute("SET lock_timeout = '5s';")
                cur.execute("SET statement_timeout = '10min';")
                print("      OK")

                print("[2/7] Kontrola schématu...")
                public_cols = get_table_columns(cur, "public", "player_match_statistics")
                required_public = {
                    "match_id", "team_id", "player_id",
                    "minutes_played", "goals", "assists",
                    "shots_total", "shots_on_target", "passes_total",
                    "passes_accurate", "key_passes",
                    "dribbles_attempted", "dribbles_successful",
                    "tackles", "interceptions", "clearances", "blocks",
                    "fouls_committed", "fouls_drawn",
                    "yellow_cards", "red_cards", "offsides", "saves",
                    "rating", "xg", "xa"
                }
                missing_public = sorted(required_public - public_cols)
                if missing_public:
                    raise RuntimeError(
                        "V public.player_match_statistics chybí sloupce: "
                        + ", ".join(missing_public)
                    )
                print("      OK")

                print("[3/7] Načítám mapování...")
                match_map = load_match_map(cur)
                player_map = load_player_map(cur)
                team_map = load_team_map(cur)
                print(f"      matches mapped: {len(match_map)}")
                print(f"      players mapped: {len(player_map)}")
                print(f"      teams mapped  : {len(team_map)}")

                print("[4/7] Načítám staging rows...")
                rows = fetch_staging_rows(cur)
                print(f"      staging rows: {len(rows)}")

                print("[5/7] Skupinuji EAV stats...")
                groups = build_stat_groups(rows)
                print(f"      grouped player-match rows: {len(groups)}")

                print("[6/7] Merge do public...")
                for group in groups:
                    processed_groups += 1

                    provider = group["provider"]
                    external_fixture_id = group["external_fixture_id"]
                    player_external_id = group["player_external_id"]
                    team_external_id = group["team_external_id"]

                    match_id = match_map.get((provider, external_fixture_id))
                    if match_id is None:
                        skipped_missing_match += 1
                        continue

                    player_id = player_map.get((provider, player_external_id))
                    if player_id is None:
                        skipped_missing_player += 1
                        continue

                    if not team_external_id:
                        skipped_missing_team += 1
                        continue

                    team_id = team_map.get((provider, team_external_id))
                    if team_id is None:
                        skipped_missing_team += 1
                        continue

                    payload = choose_public_payload(
                        group=group,
                        match_id=match_id,
                        team_id=team_id,
                        player_id=player_id,
                    )

                    # Pokud opravdu není ani jedna metrika, nemá smysl řádek ukládat.
                    metric_values = [
                        payload["minutes_played"],
                        payload["goals"],
                        payload["assists"],
                        payload["shots_total"],
                        payload["shots_on_target"],
                        payload["passes_total"],
                        payload["passes_accurate"],
                        payload["key_passes"],
                        payload["dribbles_attempted"],
                        payload["dribbles_successful"],
                        payload["tackles"],
                        payload["interceptions"],
                        payload["clearances"],
                        payload["blocks"],
                        payload["fouls_committed"],
                        payload["fouls_drawn"],
                        payload["yellow_cards"],
                        payload["red_cards"],
                        payload["offsides"],
                        payload["saves"],
                        payload["rating"],
                        payload["xg"],
                        payload["xa"],
                    ]
                    if all(v is None or v == 0 for v in metric_values):
                        skipped_empty_stats += 1
                        continue

                    upsert_public_player_match_statistics(cur, payload)
                    merged_rows += 1

                print("      merge OK")

                print("[7/7] COMMIT + kontrola...")
                conn.commit()

                cur.execute("SELECT COUNT(*) AS cnt FROM public.player_match_statistics;")
                target_cnt = cur.fetchone()["cnt"]

                print(f"      public.player_match_statistics: {target_cnt}")
                print()
                print("SUMMARY")
                print("--------------------------------------------------")
                print(f"processed grouped rows : {processed_groups}")
                print(f"merged rows            : {merged_rows}")
                print(f"skipped missing match  : {skipped_missing_match}")
                print(f"skipped missing player : {skipped_missing_player}")
                print(f"skipped missing team   : {skipped_missing_team}")
                print(f"skipped empty stats    : {skipped_empty_stats}")

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