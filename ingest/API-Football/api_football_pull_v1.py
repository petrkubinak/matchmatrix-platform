import os
import argparse
import requests
from datetime import datetime

def load_env(path: str) -> None:
    if not os.path.exists(path):
        return
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())

def api_get(base: str, key: str, endpoint: str, params: dict) -> dict:
    url = f"{base.rstrip('/')}/{endpoint.lstrip('/')}"
    r = requests.get(url, headers={"x-apisports-key": key}, params=params, timeout=30)
    r.raise_for_status()
    return r.json()

def parse_yyyy_mm_dd(s: str) -> str:
    # validate only
    datetime.strptime(s, "%Y-%m-%d")
    return s

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--league-id", type=int, required=False, help="API-Football league id (preferred)")
    parser.add_argument("--league-search", required=False, help="Text search for league (bootstrap/debug)")
    parser.add_argument("--season", type=int, required=True)
    parser.add_argument("--mode", choices=["bootstrap", "fixtures", "odds"], default="bootstrap")
    parser.add_argument("--from", dest="date_from", required=False, help="YYYY-MM-DD (for fixtures/odds modes)")
    parser.add_argument("--to", dest="date_to", required=False, help="YYYY-MM-DD (for fixtures/odds modes)")
    parser.add_argument("--print-run-id", action="store_true")
    args = parser.parse_args()

    quiet = args.print_run_id

    if args.league_id is None and not args.league_search:
        parser.error("Provide either --league-id or --league-search.")

    if args.mode in ("fixtures", "odds"):
        if not args.date_from or not args.date_to:
            parser.error("Modes fixtures/odds require --from YYYY-MM-DD and --to YYYY-MM-DD.")
        args.date_from = parse_yyyy_mm_dd(args.date_from)
        args.date_to   = parse_yyyy_mm_dd(args.date_to)

    load_env(os.path.join(os.path.dirname(__file__), ".env"))
    key  = os.environ.get("APISPORTS_KEY")
    base = os.environ.get("APISPORTS_BASE", "https://v3.football.api-sports.io")

    if not key:
        raise SystemExit("Missing APISPORTS_KEY in ingest/.env")

    # 1) Resolve league_id
    league_id = None
    league_name = None
    country = None
    seasons = []

    if args.league_id is not None:
        league_id = args.league_id
        if not quiet:
            print(f"[LEAGUE] id={league_id} (passed via --league-id)")
    else:
        leagues = api_get(base, key, "/leagues", {"search": args.league_search})
        resp = leagues.get("response", [])
        if not resp:
            raise SystemExit(f"No results for league search: {args.league_search}")

        item = resp[0]
        league_id = item["league"]["id"]
        league_name = item["league"]["name"]
        country = item["country"]["name"]
        seasons = [s["year"] for s in item.get("seasons", [])]

        if not quiet:
            print(f"[LEAGUE] id={league_id} name={league_name} country={country} seasons={seasons[:10]}...")

    # 2) Minimal API calls per mode
    if args.mode == "bootstrap":
        teams = api_get(base, key, "/teams", {"league": league_id, "season": args.season})
        teams_resp = teams.get("response", [])
        if not quiet:
            print(f"[TEAMS] league_id={league_id} season={args.season} teams={len(teams_resp)}")

    elif args.mode == "fixtures":
        fixtures = api_get(base, key, "/fixtures", {
            "league": league_id,
            "season": args.season,
            "from": args.date_from,
            "to": args.date_to
        })
        resp = fixtures.get("response", [])
        if not quiet:
            print(f"[FIXTURES] league_id={league_id} season={args.season} from={args.date_from} to={args.date_to} count={len(resp)}")

    elif args.mode == "odds":
        odds = api_get(base, key, "/odds", {
            "league": league_id,
            "season": args.season,
            "from": args.date_from,
            "to": args.date_to
        })
        resp = odds.get("response", [])
        if not quiet:
            print(f"[ODDS] league_id={league_id} season={args.season} from={args.date_from} to={args.date_to} count={len(resp)}")

    # For now: return a dummy numeric run_id (pipeline expects a number).
    # Later we will replace this with a real run_id from staging insert.
    if args.print_run_id:
        print(1)

if __name__ == "__main__":
    main()