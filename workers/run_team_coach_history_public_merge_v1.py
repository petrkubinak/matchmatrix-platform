# ============================================================
# MatchMatrix
# TEAM COACH HISTORY -> PUBLIC MERGE V1
#
# Source:
#   staging.stg_provider_coaches
#
# Target:
#   public.team_coach_history
#
# Purpose:
#   Merge provider coach-team-season rows into canonical
#   public.team_coach_history.
# ============================================================

import os
from contextlib import closing
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
        select column_name
        from information_schema.columns
        where table_schema = %s
          and table_name = %s
        """,
        (schema_name, table_name),
    )
    return {row["column_name"] for row in cur.fetchall()}


def load_coach_map(cur) -> dict[tuple[str, str], int]:
    cur.execute(
        """
        select provider, provider_coach_id, coach_id
        from public.coach_provider_map
        where provider is not null
          and provider_coach_id is not null
          and coach_id is not null
        """
    )
    mapping = {}
    for row in cur.fetchall():
        mapping[(row["provider"], str(row["provider_coach_id"]))] = int(row["coach_id"])
    return mapping


def load_team_map(cur) -> dict[tuple[str, str], int]:
    cur.execute(
        """
        select provider, provider_team_id, team_id
        from public.team_provider_map
        where provider is not null
          and provider_team_id is not null
          and team_id is not null
        """
    )
    mapping = {}
    for row in cur.fetchall():
        mapping[(row["provider"], str(row["provider_team_id"]))] = int(row["team_id"])
    return mapping


def load_league_map(cur) -> dict[tuple[str, str], int]:
    cur.execute(
        """
        select ext_source, ext_league_id, id
        from public.leagues
        where ext_source is not null
          and ext_league_id is not null
        """
    )
    mapping = {}
    for row in cur.fetchall():
        mapping[(row["ext_source"], str(row["ext_league_id"]))] = int(row["id"])
    return mapping


def load_sport_map(cur) -> dict[str, int]:
    cur.execute("select code, id from public.sports")
    return {row["code"]: int(row["id"]) for row in cur.fetchall()}


def fetch_staging_rows(cur):
    cur.execute(
        """
        select
            id,
            provider,
            sport_code,
            external_coach_id,
            coach_name,
            team_external_id,
            team_name,
            league_external_id,
            league_name,
            season,
            source_endpoint,
            raw_payload_id,
            fetched_at,
            is_active
        from staging.stg_provider_coaches
        order by provider, team_external_id, external_coach_id, season, id
        """
    )
    return cur.fetchall()


def build_groups(rows):
    grouped = {}

    for row in rows:
        key = (
            row["provider"],
            str(row["external_coach_id"]) if row["external_coach_id"] is not None else None,
            str(row["team_external_id"]) if row["team_external_id"] is not None else None,
            str(row["league_external_id"]) if row["league_external_id"] is not None else None,
            str(row["season"]) if row["season"] is not None else None,
        )

        if key not in grouped:
            grouped[key] = row

    return list(grouped.values())


def upsert_team_coach_history(cur, payload: dict):
    insert_cols = list(payload.keys())
    insert_vals = [payload[c] for c in insert_cols]

    update_cols = [c for c in insert_cols if c not in {"team_id", "coach_id", "provider", "provider_team_id", "provider_coach_id", "start_date", "end_date", "role_code"}]
    update_sql = ",\n                ".join([f"{c} = EXCLUDED.{c}" for c in update_cols])

    sql = f"""
        insert into public.team_coach_history (
            {", ".join(insert_cols)}
        )
        values (
            {", ".join(["%s"] * len(insert_cols))}
        )
        on conflict (
            team_id,
            coach_id,
            coalesce(start_date, date '1900-01-01'),
            coalesce(end_date, date '2999-12-31'),
            coalesce(role_code, ''),
            coalesce(provider, ''),
            coalesce(provider_team_id, ''),
            coalesce(provider_coach_id, '')
        )
        do update set
            {update_sql},
            updated_at = now()
    """
    cur.execute(sql, insert_vals)


def main():
    print("=== MATCHMATRIX: TEAM COACH HISTORY PUBLIC MERGE V1 ===")
    print("Zdroj : staging.stg_provider_coaches")
    print("Cíl   : public.team_coach_history")
    print()

    processed_groups = 0
    merged_rows = 0
    skipped_missing_coach = 0
    skipped_missing_team = 0
    skipped_missing_league = 0

    try:
        with closing(get_db_connection()) as conn:
            conn.autocommit = False

            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                print("[1/6] Nastavuji timeouty...")
                cur.execute("set lock_timeout = '5s';")
                cur.execute("set statement_timeout = '10min';")
                print("      OK")

                print("[2/6] Načítám mapování...")
                coach_map = load_coach_map(cur)
                team_map = load_team_map(cur)
                league_map = load_league_map(cur)
                sport_map = load_sport_map(cur)
                print(f"      coaches mapped: {len(coach_map)}")
                print(f"      teams mapped  : {len(team_map)}")
                print(f"      leagues mapped: {len(league_map)}")

                print("[3/6] Načítám staging...")
                rows = fetch_staging_rows(cur)
                print(f"      staging rows: {len(rows)}")

                print("[4/6] Skupinuji rows...")
                groups = build_groups(rows)
                print(f"      grouped rows: {len(groups)}")

                print("[5/6] Merge do public...")
                for row in groups:
                    processed_groups += 1

                    provider = row["provider"]
                    external_coach_id = str(row["external_coach_id"]) if row["external_coach_id"] is not None else None
                    team_external_id = str(row["team_external_id"]) if row["team_external_id"] is not None else None
                    league_external_id = str(row["league_external_id"]) if row["league_external_id"] is not None else None
                    season = row["season"]
                    sport_code = row["sport_code"]

                    if not provider or not external_coach_id:
                        skipped_missing_coach += 1
                        continue

                    coach_id = coach_map.get((provider, external_coach_id))
                    if coach_id is None:
                        skipped_missing_coach += 1
                        continue

                    if not team_external_id:
                        skipped_missing_team += 1
                        continue

                    team_id = team_map.get((provider, team_external_id))
                    if team_id is None:
                        skipped_missing_team += 1
                        continue

                    league_id = None
                    if league_external_id is not None:
                        league_id = league_map.get((provider, league_external_id))
                    if league_external_id is not None and league_id is None:
                        skipped_missing_league += 1
                        continue

                    sport_id = sport_map.get(sport_code)

                    payload = {
                        "team_id": team_id,
                        "coach_id": coach_id,
                        "sport_id": sport_id,
                        "league_id": league_id,
                        "season": season,
                        "role_code": "head_coach",
                        "role_name": "Head Coach",
                        "start_date": None,
                        "end_date": None,
                        "is_current": bool(row["is_active"]) if row["is_active"] is not None else False,
                        "source_type": "provider",
                        "source_note": row["source_endpoint"],
                        "provider": provider,
                        "provider_coach_id": external_coach_id,
                        "provider_team_id": team_external_id,
                        "provider_league_id": league_external_id,
                        "confidence_score": 90.00,
                        "raw_payload_id": row["raw_payload_id"],
                    }

                    upsert_team_coach_history(cur, payload)
                    merged_rows += 1

                print("      merge OK")

                print("[6/6] COMMIT + kontrola...")
                conn.commit()

                cur.execute("select count(*) as cnt from public.team_coach_history;")
                cnt = cur.fetchone()["cnt"]

                print(f"      public.team_coach_history: {cnt}")
                print()
                print("SUMMARY")
                print("--------------------------------------------------")
                print(f"processed grouped rows : {processed_groups}")
                print(f"merged rows            : {merged_rows}")
                print(f"skipped missing coach  : {skipped_missing_coach}")
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