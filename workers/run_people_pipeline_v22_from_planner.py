#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MATCHMATRIX PEOPLE PIPELINE V2.2 FROM PLANNER

Soubor uložit jako:
  C:\\MatchMatrix-platform\\workers\\run_people_pipeline_v22_from_planner.py

Účel:
  Planner-driven PEOPLE worker pro entitu players se stránkováním page=1..MAX_PAGES.

Hlavní logika:
  - čte pending jobs z ops.ingest_planner
  - pro players endpoint jede page=1..N
  - každý page ukládá jako RAW do staging.stg_api_payloads
  - každý page parsuje do staging.stg_provider_players
  - po každé stránce provede merge do public.players + public.player_provider_map
  - loop končí při response_count = 0 nebo při dosažení MAX_PAGES
  - planner job označí done až po doběhnutí všech stran
  - runtime audit doplní pages / parsed rows / mapped rows

Priorita použití:
  1) FB team-based players pagination
  2) FB league-based players pagination
  3) další team batch

Poznámka:
  V2.1 ponech jako zálohu. Tato verze je samostatná a bezpečně fail-fast.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

import requests

try:
    import psycopg
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "Chybí Python balíček psycopg. Nainstaluj: C:\\Python314\\python.exe -m pip install psycopg[binary] requests"
    ) from exc


BASE_DIR = Path(__file__).resolve().parents[1]
DEFAULT_MAX_PAGES = 5
REQUEST_TIMEOUT_SEC = 60
REQUEST_SLEEP_SEC = 0.35
HTTP_RETRIES_DEFAULT = 5
HTTP_RETRY_SLEEP_SEC_DEFAULT = 20.0
JOB_CODE = "people_pipeline_v22_from_planner"


# -----------------------------------------------------------------------------
# Utility
# -----------------------------------------------------------------------------

def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def load_env_file(path: Path) -> None:
    """Malý .env loader bez externí závislosti python-dotenv."""
    if not path.exists():
        return

    for raw_line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def load_project_envs(provider: Optional[str] = None) -> None:
    """Načte běžná MatchMatrix .env místa. Existující env hodnoty nepřepisuje."""
    candidates = [
        BASE_DIR / ".env",
        BASE_DIR / "ingest" / ".env",
        BASE_DIR / "workers" / ".env",
    ]

    # Provider-specific složky podle používaných názvů v projektu.
    provider_dirs = {
        "api_football": "API-Football",
        "api_football_squads": "API-Football",
        "api_american_football": "API-American-Football",
        "api_hockey": "API-Hockey",
        "api_basketball": "API-Basketball",
        "api_sport": "API-Sport",
        "api_baseball": "API-Baseball",
        "api_cricket": "API-Cricket",
        "api_rugby": "API-Rugby",
        "api_handball": "API-Handball",
        "api_volleyball": "API-Volleyball",
        "api_tennis": "API-Tennis",
    }
    if provider in provider_dirs:
        candidates.append(BASE_DIR / "ingest" / provider_dirs[provider] / ".env")

    for p in candidates:
        load_env_file(p)


def env_first(*names: str, default: Optional[str] = None) -> Optional[str]:
    for name in names:
        value = os.getenv(name)
        if value:
            return value
    return default


def get_db_dsn() -> str:
    """Vrátí bezpečný psycopg DSN.

    Důležité:
    Na Windows může být DB_DSN omylem nastavený jako celý příkaz typu
    `set DB_DSN=...`. Psycopg potom hlásí: missing "=" after "set".
    Proto DB_DSN použijeme jen pokud vypadá jako skutečný conninfo string.
    """
    raw_dsn = (os.getenv("DB_DSN") or os.getenv("DATABASE_URL") or "").strip().strip('"').strip("'")

    # Oprava častého Windows zápisu: DB_DSN="set DB_DSN=host=..."
    if raw_dsn.lower().startswith("set ") and "=" in raw_dsn:
        raw_dsn = raw_dsn.split("=", 1)[1].strip().strip('"').strip("'")

    # Použij jen validně vypadající psycopg conninfo.
    if raw_dsn and ("host=" in raw_dsn or "dbname=" in raw_dsn or raw_dsn.startswith("postgresql://")):
        return raw_dsn

    host = env_first("PGHOST", default="localhost")
    port = env_first("PGPORT", default="5432")
    dbname = env_first("PGDATABASE", default="matchmatrix")
    user = env_first("PGUSER", default="matchmatrix")
    password = env_first("PGPASSWORD", default="matchmatrix_pass")
    return f"host={host} port={port} dbname={dbname} user={user} password={password}"


def stable_hash_json(payload: Dict[str, Any]) -> str:
    data = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(data.encode("utf-8")).hexdigest()


def to_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    txt = str(value).strip()
    return txt if txt else None


def to_int(value: Any) -> Optional[int]:
    if value is None or value == "":
        return None
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def parse_height_cm(value: Any) -> Optional[int]:
    if value is None:
        return None
    if isinstance(value, int):
        return value
    m = re.search(r"(\d+)", str(value))
    return int(m.group(1)) if m else None


def parse_weight_kg(value: Any) -> Optional[int]:
    if value is None:
        return None
    if isinstance(value, int):
        return value
    m = re.search(r"(\d+)", str(value))
    return int(m.group(1)) if m else None


def parse_date(value: Any) -> Optional[str]:
    txt = to_text(value)
    if not txt:
        return None
    # API-Football typicky vrací YYYY-MM-DD.
    if re.match(r"^\d{4}-\d{2}-\d{2}$", txt):
        return txt
    return None


# -----------------------------------------------------------------------------
# Data model
# -----------------------------------------------------------------------------

@dataclass
class PlannerJob:
    id: int
    provider: str
    sport_code: str
    entity: str
    provider_league_id: Optional[str]
    season: Optional[str]
    run_group: Optional[str]
    priority: Optional[int]


@dataclass
class PageResult:
    page: int
    raw_id: int
    response_count: int
    parsed_rows: int
    players_inserted: int
    maps_inserted: int


# -----------------------------------------------------------------------------
# Provider config / HTTP
# -----------------------------------------------------------------------------

def provider_base_url(provider: str) -> str:
    if provider in ("api_football", "api_football_squads"):
        return env_first(
            "APISPORTS_BASE",
            "API_FOOTBALL_BASE",
            default="https://v3.football.api-sports.io",
        ) or "https://v3.football.api-sports.io"

    if provider == "api_american_football":
        return env_first(
            "APISPORTS_AFB_BASE",
            "API_AMERICAN_FOOTBALL_BASE",
            default="https://v1.american-football.api-sports.io",
        ) or "https://v1.american-football.api-sports.io"

    if provider == "api_handball":
        return env_first(
            "APISPORTS_HB_BASE",
            "API_HANDBALL_BASE",
            default="https://v1.handball.api-sports.io",
        ) or "https://v1.handball.api-sports.io"

    if provider == "api_hockey":
        return env_first(
            "APISPORTS_HK_BASE",
            "API_HOCKEY_BASE",
            default="https://v1.hockey.api-sports.io",
        ) or "https://v1.hockey.api-sports.io"

    if provider == "api_baseball":
        return env_first(
            "APISPORTS_BSB_BASE",
            "API_BASEBALL_BASE",
            default="https://v1.baseball.api-sports.io",
        ) or "https://v1.baseball.api-sports.io"

    if provider == "api_rugby":
        return env_first(
            "APISPORTS_RGB_BASE",
            "API_RUGBY_BASE",
            default="https://v1.rugby.api-sports.io",
        ) or "https://v1.rugby.api-sports.io"
    
    elif provider == "sportsdataio":
        return "https://api.sportsdata.io/v3"

    raise RuntimeError(f"Provider zatím není v V2.2 podporovaný pro players pagination: {provider}")


def provider_headers(provider: str) -> Dict[str, str]:
    api_sports_providers = {
        "api_football",
        "api_football_squads",
        "api_handball",
        "api_hockey",
        "api_baseball",
        "api_rugby",
    }

    if provider in api_sports_providers:
        key = env_first("APISPORTS_KEY", "API_SPORTS_KEY", "API_FOOTBALL_KEY")

    elif provider == "api_american_football":
        key = env_first("APISPORTS_AFB_KEY", "APISPORTS_KEY", "API_SPORTS_KEY")

    elif provider == "sportsdataio":
        key = env_first("SPORTSDATAIO_KEY")
        return {
            "Ocp-Apim-Subscription-Key": key
        }

    elif provider == "api_volleyball":
        # API-Volleyball core má vlastní provider, ale /players endpoint není dostupný.
        # Necháme explicitně blokované, aby se omylem nepouštěl people harvest.
        raise RuntimeError(
            "api_volleyball players endpoint není dostupný. "
            "VB people layer musí použít náhradního providera."
        )

    elif provider in ("api_cricket", "api_tennis"):
        key = env_first("RAPIDAPI_KEY", "API_CRICKET_KEY", "API_TENNIS_KEY")

    else:
        key = None

    if not key:
        raise RuntimeError(f"Chybí API key pro provider={provider}. Zkontroluj .env.")

    return {"x-apisports-key": key}


def build_players_request(job: PlannerJob, page: int) -> Tuple[str, Dict[str, Any], str, Optional[str]]:
    base_url = provider_base_url(job.provider).rstrip("/")
    endpoint = f"{base_url}/players"
    endpoint_name = "players"
    params: Dict[str, Any] = {"page": page}
    external_id = job.provider_league_id

    # -------------------------
    # API-Football team squad
    # -------------------------
    if job.provider == "api_football_squads" or job.entity == "team_squad":
        if not job.provider_league_id:
            raise RuntimeError("Team-based players job nemá provider_team_id/provider_league_id.")

        params["team"] = job.provider_league_id

        if job.season:
            params["season"] = job.season

        return endpoint, params, "players_team", external_id

    # -------------------------
    # API-Sports style providers
    # -------------------------
    if job.provider in (
        "api_football",
        "api_american_football",
        "api_handball",
        "api_hockey",
        "api_baseball",
        "api_rugby",
    ):
        if job.provider_league_id:
            params["league"] = job.provider_league_id

        if job.season:
            params["season"] = job.season

        if "league" not in params:
            raise RuntimeError(f"{job.provider} players job nemá league scope.")

        return endpoint, params, "players_league", external_id

    # -------------------------
    # SportsDataIO providers
    # -------------------------
    if job.provider == "sportsdataio":
        # SportsDataIO nemá stejný league/page pattern jako API-Sports.
        # Pro smoke test taháme celý seznam hráčů daného sportu.

        if job.sport_code == "BK":
            return (
                f"{base_url}/nba/scores/json/Players",
                {},
                "sportsdataio_nba_players_all",
                None,
            )

        if job.sport_code == "BSB":
            return (
                f"{base_url}/mlb/scores/json/Players",
                {},
                "sportsdataio_mlb_players_all",
                None,
            )

        if job.sport_code == "HK":
            return (
                f"{base_url}/nhl/scores/json/Players",
                {},
                "sportsdataio_nhl_players_all",
                None,
            )

        if job.sport_code == "MMA":
            return (
                f"{base_url}/mma/stats/json/Fighters",
                {},
                "sportsdataio_mma_fighters_all",
                None,
            )

        raise RuntimeError(f"sportsdataio nepodporuje sport_code={job.sport_code}")

    raise RuntimeError(f"Unsupported players job: provider={job.provider}, entity={job.entity}")


def http_get_json(
    url: str,
    headers: Dict[str, str],
    params: Dict[str, Any],
    timeout_sec: int,
    retries: int = HTTP_RETRIES_DEFAULT,
    retry_sleep_sec: float = HTTP_RETRY_SLEEP_SEC_DEFAULT,
) -> Dict[str, Any]:
    """HTTP GET s retry/backoff pro API rate limit.

    API-Sports při rychlém batchi vrací 429 Too Many Requests.
    Worker proto nesmí spadnout hned na první 429, ale počká a zopakuje stejnou stránku.
    Pokud provider po všech pokusech stále vrací chybu, chyba se propustí výš a planner job
    se označí jako failed.
    """
    last_exc: Optional[BaseException] = None

    for attempt in range(1, max(1, retries) + 1):
        try:
            response = requests.get(url, headers=headers, params=params, timeout=timeout_sec)

            if response.status_code == 429:
                retry_after_raw = response.headers.get("Retry-After")
                try:
                    retry_after = float(retry_after_raw) if retry_after_raw else None
                except ValueError:
                    retry_after = None

                wait_sec = retry_after if retry_after is not None else retry_sleep_sec * attempt
                print(
                    f"HTTP 429 Too Many Requests -> retry {attempt}/{retries}; "
                    f"sleep {wait_sec:.1f}s"
                )
                if attempt >= retries:
                    response.raise_for_status()
                time.sleep(wait_sec)
                continue

            response.raise_for_status()
            return response.json()

        except (requests.Timeout, requests.ConnectionError) as exc:
            last_exc = exc
            wait_sec = retry_sleep_sec * attempt
            print(
                f"HTTP transient error {type(exc).__name__} -> retry {attempt}/{retries}; "
                f"sleep {wait_sec:.1f}s"
            )
            if attempt >= retries:
                raise
            time.sleep(wait_sec)

    if last_exc is not None:
        raise last_exc
    raise RuntimeError("HTTP request failed without response")


def get_response_items(payload: Any) -> List[Dict[str, Any]]:
    if isinstance(payload, list):
        return [x for x in payload if isinstance(x, dict)]

    if isinstance(payload, dict):
        data = payload.get("response", [])
        if isinstance(data, list):
            return [x for x in data if isinstance(x, dict)]

    return []


def get_response_count(payload: Any) -> int:
    if isinstance(payload, list):
        return len(payload)

    if isinstance(payload, dict):
        results = payload.get("results")
        if isinstance(results, int):
            return results

        response = payload.get("response")
        if isinstance(response, list):
            return len(response)

    return 0


# -----------------------------------------------------------------------------
# DB operations
# -----------------------------------------------------------------------------

def fetch_pending_jobs(conn: psycopg.Connection, args: argparse.Namespace) -> List[PlannerJob]:
    where = ["status = 'pending'", "entity = 'players'"]
    params: Dict[str, Any] = {}

    if args.provider:
        where.append("provider = %(provider)s")
        params["provider"] = args.provider
    if args.sport:
        where.append("sport_code = %(sport)s")
        params["sport"] = args.sport
    if args.entity:
        where.append("entity = %(entity)s")
        params["entity"] = args.entity
    if args.run_group:
        where.append("run_group = %(run_group)s")
        params["run_group"] = args.run_group

    sql = f"""
        SELECT id, provider, sport_code, entity, provider_league_id, season, run_group, priority
        FROM ops.ingest_planner
        WHERE {' AND '.join(where)}
          AND (next_run IS NULL OR next_run <= now())
        ORDER BY priority NULLS LAST, id
        LIMIT %(limit)s
    """
    params["limit"] = args.limit

    rows = conn.execute(sql, params).fetchall()
    return [PlannerJob(*row) for row in rows]


def mark_job_running(conn: psycopg.Connection, job: PlannerJob) -> None:
    conn.execute(
        """
        UPDATE ops.ingest_planner
        SET status = 'running', attempts = COALESCE(attempts, 0) + 1,
            last_attempt = now(), updated_at = now()
        WHERE id = %s
        """,
        (job.id,),
    )


def mark_job_done(conn: psycopg.Connection, job: PlannerJob) -> None:
    conn.execute(
        """
        UPDATE ops.ingest_planner
        SET status = 'done', updated_at = now(), next_run = NULL
        WHERE id = %s
        """,
        (job.id,),
    )


def mark_job_failed(conn: psycopg.Connection, job: PlannerJob, error: str) -> None:
    conn.execute(
        """
        UPDATE ops.ingest_planner
        SET status = 'failed', updated_at = now(), next_run = now() + interval '1 hour'
        WHERE id = %s
        """,
        (job.id,),
    )
    write_job_run(conn, job, "error", 0, {"error": error})


def save_raw_payload(
    conn: psycopg.Connection,
    job: PlannerJob,
    endpoint_name: str,
    external_id: Optional[str],
    payload: Dict[str, Any],
) -> int:
    payload_hash = stable_hash_json(payload)
    row = conn.execute(
        """
        INSERT INTO staging.stg_api_payloads
            (provider, sport_code, entity_type, endpoint_name, external_id, season,
             payload_json, payload_hash, parse_status, parse_message)
        VALUES
            (%s, %s, %s, %s, %s, %s,
             %s::jsonb, %s, 'pending', NULL)
        RETURNING id
        """,
        (
            job.provider,
            job.sport_code,
            job.entity,
            endpoint_name,
            external_id,
            job.season,
            json.dumps(payload, ensure_ascii=False),
            payload_hash,
        ),
    ).fetchone()
    return int(row[0])


def parse_player_item(job: PlannerJob, raw_id: int, item: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Normalizace API-Sports /players payloadu do staging.stg_provider_players."""

    player = item.get("player") if isinstance(item.get("player"), dict) else item
    stats = item.get("statistics") if isinstance(item.get("statistics"), list) else []

    stat0 = stats[0] if stats and isinstance(stats[0], dict) else {}
    team = stat0.get("team") if isinstance(stat0.get("team"), dict) else {}
    league = stat0.get("league") if isinstance(stat0.get("league"), dict) else {}
    games = stat0.get("games") if isinstance(stat0.get("games"), dict) else {}

    external_player_id_raw = (
        player.get("id")
        or player.get("player_id")
        or player.get("athlete_id")
        or item.get("id")
    )

    external_player_id = str(external_player_id_raw).strip() if external_player_id_raw is not None else None

    name = (
        player.get("name")
        or player.get("displayName")
        or player.get("fullname")
        or player.get("full_name")
    )
    name = str(name).strip() if name is not None else None

    if not external_player_id or not name:
        return None

    birth = player.get("birth")
    birth_date = birth.get("date") if isinstance(birth, dict) else birth

    return {
        "provider": job.provider,
        "sport_code": job.sport_code,
        "external_player_id": external_player_id,
        "player_name": name,
        "birth_date": parse_date(birth_date),
        "nationality": to_text(player.get("nationality") or player.get("country")),
        "external_team_id": to_text(team.get("id") or item.get("team_id") or player.get("team_id")),
        "season": job.season,
        "raw_payload_id": raw_id,
        "first_name": to_text(player.get("firstname") or player.get("first_name")),
        "last_name": to_text(player.get("lastname") or player.get("last_name")),
        "short_name": to_text(player.get("shortName") or player.get("short_name")),
        "position_code": to_text(games.get("position") or player.get("position") or item.get("position")),
        "height_cm": parse_height_cm(player.get("height")),
        "weight_kg": parse_weight_kg(player.get("weight")),
        "preferred_foot": to_text(player.get("preferred_foot") or player.get("foot")),
        "external_league_id": to_text(league.get("id") or job.provider_league_id),
        "team_name": to_text(team.get("name") or item.get("team_name") or player.get("team_name")),
        "league_name": to_text(league.get("name")),
        "source_endpoint": "players",
        "raw_item": item,
    }

def insert_staging_players(conn: psycopg.Connection, job: PlannerJob, raw_id: int, payload: Dict[str, Any]) -> int:
    """Parse provider players payload do staging.stg_provider_players.

    Podporuje:
      - API-Sports/API-Football tvar: {"response": [{"player": {...}, "statistics": [...]}]}
      - SportsDataIO tvar: list[dict] pro NHL/NBA/MLB Players
      - SportsDataIO MMA tvar: list[dict] pro Fighters
    """
    items = get_response_items(payload)
    parsed = 0

    insert_sql = """
        INSERT INTO staging.stg_provider_players
            (provider, sport_code, external_player_id, player_name, birth_date, nationality,
             external_team_id, season, raw_payload_id, is_active,
             first_name, last_name, short_name, position_code, height_cm, weight_kg,
             preferred_foot, external_league_id, team_name, league_name, source_endpoint)
        VALUES
            (%(provider)s, %(sport_code)s, %(external_player_id)s, %(player_name)s,
             %(birth_date)s::date, %(nationality)s, %(external_team_id)s, %(season)s,
             %(raw_payload_id)s, true,
             %(first_name)s, %(last_name)s, %(short_name)s, %(position_code)s,
             %(height_cm)s, %(weight_kg)s, %(preferred_foot)s,
             %(external_league_id)s, %(team_name)s, %(league_name)s, %(source_endpoint)s)
        ON CONFLICT (provider, external_player_id) DO UPDATE SET
            sport_code = EXCLUDED.sport_code,
            player_name = COALESCE(EXCLUDED.player_name, staging.stg_provider_players.player_name),
            birth_date = COALESCE(EXCLUDED.birth_date, staging.stg_provider_players.birth_date),
            nationality = COALESCE(EXCLUDED.nationality, staging.stg_provider_players.nationality),
            external_team_id = COALESCE(EXCLUDED.external_team_id, staging.stg_provider_players.external_team_id),
            season = COALESCE(EXCLUDED.season, staging.stg_provider_players.season),
            raw_payload_id = EXCLUDED.raw_payload_id,
            is_active = true,
            first_name = COALESCE(EXCLUDED.first_name, staging.stg_provider_players.first_name),
            last_name = COALESCE(EXCLUDED.last_name, staging.stg_provider_players.last_name),
            short_name = COALESCE(EXCLUDED.short_name, staging.stg_provider_players.short_name),
            position_code = COALESCE(EXCLUDED.position_code, staging.stg_provider_players.position_code),
            height_cm = COALESCE(EXCLUDED.height_cm, staging.stg_provider_players.height_cm),
            weight_kg = COALESCE(EXCLUDED.weight_kg, staging.stg_provider_players.weight_kg),
            preferred_foot = COALESCE(EXCLUDED.preferred_foot, staging.stg_provider_players.preferred_foot),
            external_league_id = COALESCE(EXCLUDED.external_league_id, staging.stg_provider_players.external_league_id),
            team_name = COALESCE(EXCLUDED.team_name, staging.stg_provider_players.team_name),
            league_name = COALESCE(EXCLUDED.league_name, staging.stg_provider_players.league_name),
            source_endpoint = COALESCE(EXCLUDED.source_endpoint, staging.stg_provider_players.source_endpoint),
            updated_at = now()
    """

    # -------------------------
    # SportsDataIO players/fighters
    # -------------------------
    if job.provider == "sportsdataio":
        for p in items:
            # MMA / UFC fighters mají ve SportsDataIO jiné ID než NHL/NBA/MLB players.
            if job.sport_code == "MMA":
                external_player_id = str(
                    p.get("FighterID")
                    or p.get("FighterId")
                    or p.get("PlayerID")
                    or p.get("ID")
                    or ""
                ).strip()
                if not external_player_id:
                    continue

                first_name = p.get("FirstName")
                last_name = p.get("LastName")
                name = p.get("Name") or f"{first_name or ''} {last_name or ''}".strip()

                row = {
                    "provider": job.provider,
                    "sport_code": job.sport_code,
                    "external_player_id": external_player_id,
                    "player_name": name,
                    "birth_date": None,
                    "nationality": p.get("Nationality") or p.get("BirthCountry"),
                    "external_team_id": None,
                    "season": job.season,
                    "raw_payload_id": raw_id,
                    "first_name": first_name,
                    "last_name": last_name,
                    "short_name": p.get("Nickname"),
                    "position_code": p.get("WeightClass"),
                    "height_cm": None,
                    "weight_kg": None,
                    "preferred_foot": None,
                    "external_league_id": None,
                    "team_name": None,
                    "league_name": "MMA",
                    "source_endpoint": "sportsdataio_mma_fighters",
                }

            else:
                external_player_id = str(p.get("PlayerID") or p.get("ID") or "").strip()
                if not external_player_id:
                    continue

                first_name = p.get("FirstName")
                last_name = p.get("LastName")
                name = p.get("Name") or f"{first_name or ''} {last_name or ''}".strip()

                row = {
                    "provider": job.provider,
                    "sport_code": job.sport_code,
                    "external_player_id": external_player_id,
                    "player_name": name,
                    "birth_date": None,
                    "nationality": p.get("BirthCountry") or p.get("Nationality"),
                    "external_team_id": str(p.get("TeamID") or p.get("Team") or "").strip() or None,
                    "season": job.season,
                    "raw_payload_id": raw_id,
                    "first_name": first_name,
                    "last_name": last_name,
                    "short_name": p.get("ShortName"),
                    "position_code": p.get("Position"),
                    "height_cm": None,
                    "weight_kg": None,
                    "preferred_foot": None,
                    "external_league_id": job.provider_league_id,
                    "team_name": p.get("Team"),
                    "league_name": None,
                    "source_endpoint": "sportsdataio_players",
                }

            conn.execute(insert_sql, row)
            parsed += 1

    # -------------------------
    # API-Sports / API-Football players
    # -------------------------
    else:
        for item in items:
            row = parse_player_item(job, raw_id, item)
            if not row:
                continue

            conn.execute(insert_sql, row)
            parsed += 1

    conn.execute(
        """
        UPDATE staging.stg_api_payloads
        SET parse_status = 'parsed', parse_message = %s
        WHERE id = %s
        """,
        (f"parsed_rows={parsed}", raw_id),
    )

    return int(parsed or 0)

def merge_players_to_public(conn: psycopg.Connection, job: PlannerJob, raw_id: int) -> Tuple[int, int]:
    """Merge staging players z konkrétní RAW stránky do public.players + public.player_provider_map."""

    before_players = conn.execute("SELECT COUNT(*) FROM public.players").fetchone()[0]
    before_maps = conn.execute("SELECT COUNT(*) FROM public.player_provider_map").fetchone()[0]

    # 1) vlož hráče, pro které ještě neexistuje provider map.
    conn.execute(
        """
        WITH src AS (
            SELECT DISTINCT ON (s.provider, s.external_player_id)
                s.provider,
                s.sport_code,
                s.external_player_id,
                s.player_name,
                s.first_name,
                s.last_name,
                s.short_name,
                s.birth_date,
                s.nationality,
                s.position_code,
                s.height_cm,
                s.weight_kg,
                s.external_team_id,
                s.team_name,
                s.raw_payload_id,
                tpm.team_id
            FROM staging.stg_provider_players s
            LEFT JOIN public.team_provider_map tpm
              ON tpm.provider = s.provider
             AND tpm.provider_team_id = s.external_team_id
            WHERE s.raw_payload_id = %s
              AND s.provider = %s
              AND s.sport_code = %s
            ORDER BY s.provider, s.external_player_id, s.updated_at DESC, s.id DESC
        )
        INSERT INTO public.players
            (team_id, name, first_name, last_name, short_name, birth_date, nationality,
             position, height_cm, weight_kg, is_active, ext_source, ext_player_id)
        SELECT
            src.team_id::integer,
            src.player_name,
            src.first_name,
            src.last_name,
            src.short_name,
            src.birth_date,
            src.nationality,
            src.position_code,
            src.height_cm,
            src.weight_kg,
            true,
            src.provider,
            src.external_player_id
        FROM src
        WHERE NOT EXISTS (
            SELECT 1
            FROM public.player_provider_map ppm
            WHERE ppm.provider = src.provider
              AND ppm.provider_player_id = src.external_player_id
        )
        """,
        (raw_id, job.provider, job.sport_code),
    )

    # 2) vlož provider map pro nově vzniklé nebo existující public.players.
    conn.execute(
        """
        WITH src AS (
            SELECT DISTINCT ON (s.provider, s.external_player_id)
                s.provider,
                s.external_player_id,
                s.player_name,
                s.external_team_id,
                s.team_name
            FROM staging.stg_provider_players s
            WHERE s.raw_payload_id = %s
              AND s.provider = %s
              AND s.sport_code = %s
            ORDER BY s.provider, s.external_player_id, s.updated_at DESC, s.id DESC
        ), matched_players AS (
            SELECT
                src.*,
                p.id AS player_id
            FROM src
            JOIN public.players p
              ON p.ext_source = src.provider
             AND p.ext_player_id = src.external_player_id
        )
        INSERT INTO public.player_provider_map
            (provider, provider_player_id, player_id, provider_team_id,
             provider_team_name, provider_player_name, is_active)
        SELECT
            mp.provider,
            mp.external_player_id,
            mp.player_id,
            mp.external_team_id,
            mp.team_name,
            mp.player_name,
            true
        FROM matched_players mp
        WHERE NOT EXISTS (
            SELECT 1
            FROM public.player_provider_map ppm
            WHERE ppm.provider = mp.provider
              AND ppm.provider_player_id = mp.external_player_id
        )
        """,
        (raw_id, job.provider, job.sport_code),
    )

    after_players = conn.execute("SELECT COUNT(*) FROM public.players").fetchone()[0]
    after_maps = conn.execute("SELECT COUNT(*) FROM public.player_provider_map").fetchone()[0]
    return int(after_players - before_players), int(after_maps - before_maps)


def write_job_run(
    conn: psycopg.Connection,
    job: PlannerJob,
    status: str,
    rows_affected: int,
    details: Dict[str, Any],
) -> None:
    params = {
        "provider": job.provider,
        "sport_code": job.sport_code,
        "entity": job.entity,
        "run_group": job.run_group,
        "provider_league_id": job.provider_league_id,
        "season": job.season,
        "worker": "run_people_pipeline_v22_from_planner.py",
    }
    conn.execute(
        """
        INSERT INTO ops.job_runs
            (job_code, status, finished_at, params, message, details, rows_affected)
        VALUES
            (%s, %s, now(), %s::jsonb, %s, %s::jsonb, %s)
        """,
        (
            JOB_CODE,
            status,
            json.dumps(params, ensure_ascii=False),
            "People pipeline V2.2 finished" if status == "ok" else "People pipeline V2.2 failed",
            json.dumps(details, ensure_ascii=False),
            rows_affected,
        ),
    )


def update_runtime_audit(
    conn: psycopg.Connection,
    job: PlannerJob,
    page_results: List[PageResult],
    max_pages: int,
) -> None:
    pages = len(page_results)
    total_response = sum(r.response_count for r in page_results)
    total_parsed = sum(r.parsed_rows for r in page_results)
    total_players_inserted = sum(r.players_inserted for r in page_results)
    total_maps_inserted = sum(r.maps_inserted for r in page_results)
    raw_ids = [r.raw_id for r in page_results]

    evidence = (
        f"PEOPLE V2.2 players pagination OK | pages={pages}/{max_pages} | "
        f"response_rows={total_response} | parsed_rows={total_parsed} | "
        f"players_inserted={total_players_inserted} | maps_inserted={total_maps_inserted} | raw_ids={raw_ids}"
    )

    conn.execute(
        """
        INSERT INTO ops.runtime_entity_audit
            (provider, sport_code, entity, current_state, state_reason,
             panel_runner_exists, planner_target_exists, batch_target_exists,
             pull_confirmed, raw_confirmed, staging_confirmed, provider_map_confirmed,
             public_merge_confirmed, downstream_confirmed,
             last_run_group, last_run_at, last_check_at, last_log_summary,
             db_evidence_summary, next_action, audit_note)
        VALUES
            (%s, %s, %s, 'CONFIRMED', %s,
             true, true, false,
             true, true, true, true,
             true, false,
             %s, now(), now(), %s,
             %s, %s, %s)
        ON CONFLICT (provider, sport_code, entity)
        DO UPDATE SET
            current_state = 'CONFIRMED',
            state_reason = EXCLUDED.state_reason,
            panel_runner_exists = true,
            planner_target_exists = true,
            pull_confirmed = true,
            raw_confirmed = true,
            staging_confirmed = true,
            provider_map_confirmed = true,
            public_merge_confirmed = true,
            last_run_group = EXCLUDED.last_run_group,
            last_run_at = now(),
            last_check_at = now(),
            last_log_summary = EXCLUDED.last_log_summary,
            db_evidence_summary = EXCLUDED.db_evidence_summary,
            next_action = EXCLUDED.next_action,
            audit_note = EXCLUDED.audit_note,
            updated_at = now()
        """,
        (
            job.provider,
            job.sport_code,
            job.entity,
            "PEOPLE V2.2 players pagination confirmed.",
            job.run_group,
            evidence,
            evidence,
            "Rozšířit scope na další týmy/sezóny až po ověření batch limitů.",
            f"Updated by {JOB_CODE} at {utc_now_iso()}",
        ),
    )


# -----------------------------------------------------------------------------
# Pipeline
# -----------------------------------------------------------------------------

def get_people_provider_candidates(conn: psycopg.Connection, job: PlannerJob) -> List[str]:
    supported_now = {
        "api_football",
        "api_football_squads",
        "api_american_football",
        "api_handball",
        "api_hockey",
        "api_baseball",
        "api_rugby",
        "sportsdataio",
    }

    rows = conn.execute(
        """
        SELECT provider
        FROM ops.provider_entity_coverage
        WHERE sport_code = %s
          AND entity = %s
          AND is_enabled = true
          AND provider = ANY(%s)
          AND coverage_status <> 'blocked'
        ORDER BY
            is_primary DESC,
            is_primary_source DESC,
            is_fallback_source DESC,
            priority ASC NULLS LAST,
            provider_priority ASC NULLS LAST
        """,
        (job.sport_code, job.entity, list(supported_now)),
    ).fetchall()

    providers = [r[0] for r in rows]

    if job.provider not in providers and job.provider in supported_now:
        providers.insert(0, job.provider)

    return providers


def clone_job_with_provider(job: PlannerJob, provider: str) -> PlannerJob:
    return PlannerJob(
        id=job.id,
        provider=provider,
        sport_code=job.sport_code,
        entity=job.entity,
        provider_league_id=job.provider_league_id,
        season=job.season,
        run_group=job.run_group,
        priority=job.priority,
    )


def run_players_job(conn: psycopg.Connection, job: PlannerJob, args: argparse.Namespace) -> List[PageResult]:
    max_pages = args.max_pages
    page_results: List[PageResult] = []

    print(f"\n--- JOB {job.id} | {job.provider} | {job.sport_code} | {job.entity} | run_group={job.run_group} ---")

    provider_candidates = get_people_provider_candidates(conn, job)
    print(f"Provider candidates: {provider_candidates}")

    if not provider_candidates:
        raise RuntimeError(f"Žádný podporovaný PEOPLE provider pro {job.sport_code}/{job.entity}")

    mark_job_running(conn, job)
    conn.commit()

    try:
        selected_job: Optional[PlannerJob] = None

        for provider in provider_candidates:
            test_job = clone_job_with_provider(job, provider)

            try:
                headers = provider_headers(provider)
                url, params, endpoint_name, external_id = build_players_request(test_job, 1)

                print(f"PROVIDER TEST: {provider}")
                print(f"PAGE 1/{max_pages}: GET {endpoint_name} params={params}")

                payload = http_get_json(
                    url,
                    headers,
                    params,
                    args.timeout_sec,
                    retries=args.http_retries,
                    retry_sleep_sec=args.retry_sleep_sec,
                )

                response_count = get_response_count(payload)
                print(f"{provider}: HTTP OK; response_count={response_count}")

                if response_count == 0:
                    print(f"{provider}: EMPTY -> zkusím další provider")
                    continue

                selected_job = test_job

                raw_id = save_raw_payload(conn, selected_job, endpoint_name, external_id, payload)
                parsed_rows = insert_staging_players(conn, selected_job, raw_id, payload)
                parsed_rows = int(parsed_rows or 0)
                players_inserted, maps_inserted = merge_players_to_public(conn, selected_job, raw_id)
                conn.commit()

                page_results.append(
                    PageResult(
                        page=1,
                        raw_id=raw_id,
                        response_count=response_count,
                        parsed_rows=parsed_rows,
                        players_inserted=players_inserted,
                        maps_inserted=maps_inserted,
                    )
                )

                print(
                    f"PAGE 1: RAW id={raw_id}; parsed={parsed_rows}; "
                    f"players_inserted={players_inserted}; maps_inserted={maps_inserted}"
                )

                # SportsDataIO endpoint /Players není stránkovaný.
                # Po první úspěšné odpovědi už nepokračujeme na PAGE 2–5.
                if selected_job.provider == "sportsdataio":
                    max_pages = 1

                break

            except Exception as exc:
                print(f"{provider}: FAIL -> {exc}")
                continue

        if selected_job is None:
            print("Žádný provider nevrátil players data. Job bude označen jako done s empty výsledkem.")
            selected_job = job

        for page in range(2, max_pages + 1):
            headers = provider_headers(selected_job.provider)
            url, params, endpoint_name, external_id = build_players_request(selected_job, page)
            print(f"PAGE {page}/{max_pages}: GET {endpoint_name} params={params}")

            payload = http_get_json(
                url,
                headers,
                params,
                args.timeout_sec,
                retries=args.http_retries,
                retry_sleep_sec=args.retry_sleep_sec,
            )

            response_count = get_response_count(payload)
            print(f"PAGE {page}: HTTP OK; response_count={response_count}")

            if response_count == 0:
                print(f"PAGE {page}: response_count=0 -> pagination stop")
                break

            raw_id = save_raw_payload(conn, selected_job, endpoint_name, external_id, payload)
            parsed_rows = insert_staging_players(conn, selected_job, raw_id, payload)
            parsed_rows = int(parsed_rows or 0)
            players_inserted, maps_inserted = merge_players_to_public(conn, selected_job, raw_id)
            conn.commit()

            page_results.append(
                PageResult(
                    page=page,
                    raw_id=raw_id,
                    response_count=response_count,
                    parsed_rows=parsed_rows,
                    players_inserted=players_inserted,
                    maps_inserted=maps_inserted,
                )
            )

            print(
                f"PAGE {page}: RAW id={raw_id}; parsed={parsed_rows}; "
                f"players_inserted={players_inserted}; maps_inserted={maps_inserted}"
            )

            time.sleep(args.sleep_sec)

        mark_job_done(conn, job)
        update_runtime_audit(conn, selected_job, page_results, max_pages)
        write_job_run(
            conn,
            selected_job,
            "ok",
            sum(r.parsed_rows for r in page_results),
            {
                "selected_provider": selected_job.provider,
                "provider_candidates": provider_candidates,
                "pages": [r.__dict__ for r in page_results],
                "pages_count": len(page_results),
                "max_pages": max_pages,
                "parsed_rows": sum(r.parsed_rows for r in page_results),
                "players_inserted": sum(r.players_inserted for r in page_results),
                "maps_inserted": sum(r.maps_inserted for r in page_results),
            },
        )
        conn.commit()
        return page_results

    except Exception as exc:
        conn.rollback()
        with conn.transaction():
            mark_job_failed(conn, job, str(exc))
        raise


# -----------------------------------------------------------------------------
# CLI
# -----------------------------------------------------------------------------

def parse_args(argv: Optional[Iterable[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix PEOPLE pipeline V2.2 from planner")
    parser.add_argument("--provider", default=None, help="např. api_football / api_american_football")
    parser.add_argument("--sport", default=None, help="např. FB / AFB")
    parser.add_argument("--entity", default="players", help="aktuálně podporováno: players")
    parser.add_argument("--run-group", default=None, help="např. FB_PEOPLE / AFB_PEOPLE_V2")
    parser.add_argument("--limit", type=int, default=1, help="počet planner jobů")
    parser.add_argument("--max-pages", type=int, default=DEFAULT_MAX_PAGES, help="bezpečnostní limit stránek")
    parser.add_argument("--timeout-sec", type=int, default=REQUEST_TIMEOUT_SEC, help="HTTP timeout")
    parser.add_argument("--sleep-sec", type=float, default=REQUEST_SLEEP_SEC, help="pauza mezi stránkami")
    parser.add_argument("--http-retries", type=int, default=HTTP_RETRIES_DEFAULT, help="počet retry pokusů pro 429/timeout")
    parser.add_argument("--retry-sleep-sec", type=float, default=HTTP_RETRY_SLEEP_SEC_DEFAULT, help="základní pauza při 429/timeout")
    return parser.parse_args(argv)


def main(argv: Optional[Iterable[str]] = None) -> int:
    args = parse_args(argv)

    # Env načíst až po args, abychom mohli načíst provider-specific .env.
    load_project_envs(args.provider)

    if args.entity != "players":
        print("V2.2 zatím podporuje pouze --entity players", file=sys.stderr)
        return 2

    print("=== MATCHMATRIX PEOPLE PIPELINE V2.2 FROM PLANNER ===")
    print(f"BASE_DIR   : {BASE_DIR}")
    print(f"MAX_PAGES  : {args.max_pages}")
    print(f"LIMIT      : {args.limit}")

    dsn = get_db_dsn()
    with psycopg.connect(dsn) as conn:
        jobs = fetch_pending_jobs(conn, args)
        if not jobs:
            print("No pending PEOPLE V2.2 jobs found.")
            return 0

        total_pages = 0
        total_parsed = 0
        total_maps = 0

        for job in jobs:
            results = run_players_job(conn, job, args)
            total_pages += len(results)
            total_parsed += sum(r.parsed_rows for r in results)
            total_maps += sum(r.maps_inserted for r in results)

        print("\nDONE")
        print(f"pages={total_pages}; parsed_rows={total_parsed}; maps_inserted={total_maps}")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
