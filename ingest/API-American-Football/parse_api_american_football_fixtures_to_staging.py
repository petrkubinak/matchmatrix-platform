import json
import psycopg2
from psycopg2.extras import Json
from pathlib import Path
from datetime import datetime

RAW_FILE = Path(
    r"C:\MatchMatrix-platform\data\raw\api_american_football\fixtures\api_american_football_fixtures_league_1_season_2024_20260410_231121.json"
)

LEAGUE_ID = "1"
SEASON = "2024"
PROVIDER = "api_american_football"

DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"


def safe_scalar(value):
    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False)
    return value


def extract_game_datetime(game_date_obj):
    """
    Provider vraci game.date jako objekt:
    {
      "timezone": "UTC",
      "date": "2024-08-02",
      "time": "00:00",
      "timestamp": 1722556800
    }

    Do DB chceme ulozit normalni Python datetime.
    """
    if not game_date_obj:
        return None

    if isinstance(game_date_obj, str):
        # kdyby provider nekdy vratil string
        try:
            return datetime.fromisoformat(game_date_obj.replace("Z", "+00:00"))
        except Exception:
            return None

    if isinstance(game_date_obj, dict):
        date_part = game_date_obj.get("date")
        time_part = game_date_obj.get("time")

        if date_part and time_part:
            try:
                return datetime.strptime(f"{date_part} {time_part}", "%Y-%m-%d %H:%M")
            except Exception:
                pass

        ts = game_date_obj.get("timestamp")
        if ts is not None:
            try:
                return datetime.utcfromtimestamp(int(ts))
            except Exception:
                return None

    return None


def main():
    print("=" * 70)
    print("MATCHMATRIX - PARSE AFB FIXTURES -> STAGING")
    print("=" * 70)

    if not RAW_FILE.exists():
        raise FileNotFoundError(f"Soubor neexistuje: {RAW_FILE}")

    with RAW_FILE.open("r", encoding="utf-8-sig") as f:
        data = json.load(f)

    response = data.get("response", [])
    print(f"Items in response: {len(response)}")

    conn = psycopg2.connect(DB_DSN)
    cur = conn.cursor()

    insert_sql = """
        insert into staging.stg_api_american_football_fixtures (
            provider,
            league_id,
            season,
            provider_game_id,
            provider_league_id,
            provider_league_name,
            game_date,
            game_status_short,
            game_status_long,
            home_team_id,
            home_team_name,
            away_team_id,
            away_team_name,
            home_score,
            away_score,
            raw_json
        )
        values (
            %s, %s, %s,
            %s, %s, %s,
            %s, %s, %s,
            %s, %s, %s, %s,
            %s, %s,
            %s
        )
    """

    inserted = 0

    for item in response:
        game = item.get("game", {}) or {}
        league = item.get("league", {}) or {}
        teams = item.get("teams", {}) or {}
        scores = item.get("scores", {}) or {}

        home = teams.get("home", {}) or {}
        away = teams.get("away", {}) or {}

        home_score = (scores.get("home") or {}).get("total")
        away_score = (scores.get("away") or {}).get("total")

        game_dt = extract_game_datetime(game.get("date"))

        cur.execute(
            insert_sql,
            (
                PROVIDER,
                LEAGUE_ID,
                SEASON,
                safe_scalar(game.get("id")),
                safe_scalar(league.get("id")),
                safe_scalar(league.get("name")),
                game_dt,
                safe_scalar((game.get("status") or {}).get("short")),
                safe_scalar((game.get("status") or {}).get("long")),
                safe_scalar(home.get("id")),
                safe_scalar(home.get("name")),
                safe_scalar(away.get("id")),
                safe_scalar(away.get("name")),
                home_score,
                away_score,
                Json(item)
            )
        )

        inserted += 1

    conn.commit()
    cur.close()
    conn.close()

    print("-" * 70)
    print(f"INSERTED ROWS: {inserted}")
    print("DONE")
    print("=" * 70)


if __name__ == "__main__":
    main()