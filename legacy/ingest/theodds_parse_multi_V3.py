# -*- coding: utf-8 -*-
"""
theodds_parse_multi_V3.py

MatchMatrix – The Odds API ingest (multi-league) – V3

V3:
- zachovává architekturu FINAL parseru
- používá theodds_matching_v3.py
- lepší UTF-8 normalizace
- detailnější issue codes:
    MATCH_OK
    NO_TEAM_MATCH
    NO_MATCH_ID
    LOW_COVERAGE
- zachovává RAW save, api_import_runs, unmatched reporty
- používá canonical lookup vrstvu (v_preferred_team_name_lookup + v_canonical_match_lookup)
- DOPLNĚN fallback resolver přes provider_map / team_map / alias_map
"""

from __future__ import annotations

import csv
import json
import os
import sys
import time
from pathlib import Path
from typing import Any, Iterable

import psycopg2
import requests

# ------------------------------------------------------------
# Přidání PROJECT_ROOT do sys.path kvůli importu worker helperu
# ------------------------------------------------------------
CURRENT_FILE = Path(__file__).resolve()
PROJECT_ROOT = CURRENT_FILE.parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from workers.theodds_matching_v3 import (  # noqa: E402
    best_candidate,
    build_match_debug_payload,
    classify_matching_issue,
    normalize_team_name,
)

# ------------------------------------------------------------
# ENV / KONFIG
# ------------------------------------------------------------
DB_DSN = os.environ["DB_DSN"]
THEODDS_API_KEY = os.environ.get("THEODDS_API_KEY")

THEODDS_BASE_URL = os.environ.get("THEODDS_BASE_URL", "https://api.the-odds-api.com/v4").rstrip("/")
THEODDS_REGIONS = os.environ.get("THEODDS_REGIONS", "eu")
THEODDS_MARKETS = os.environ.get("THEODDS_MARKETS", "h2h")
THEODDS_SLEEP_SEC = float(os.environ.get("THEODDS_SLEEP_SEC", "1.2"))
THEODDS_MAX_LEAGUES = os.environ.get("THEODDS_MAX_LEAGUES")
THEODDS_MIN_TEAMS_PRESENT = int(os.environ.get("THEODDS_MIN_TEAMS_PRESENT", "35"))

TEAM_MATCH_THRESHOLD = float(os.environ.get("THEODDS_TEAM_MATCH_THRESHOLD", "0.78"))
LOW_COVERAGE_THRESHOLD = float(os.environ.get("THEODDS_LOW_COVERAGE_THRESHOLD", "0.75"))

# ------------------------------------------------------------
# DB helpers
# ------------------------------------------------------------
def db():
    return psycopg2.connect(DB_DSN)


def start_import_run(conn, source: str = "theodds") -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into public.api_import_runs(source, status, details)
            values (%s, 'running', %s::jsonb)
            returning id
            """,
            (source, json.dumps({"script": "theodds_parse_multi_V3.py"})),
        )
        run_id = int(cur.fetchone()[0])
    conn.commit()
    return run_id


def finish_import_run(conn, run_id: int, status: str, details: dict[str, Any]):
    with conn.cursor() as cur:
        cur.execute(
            """
            update public.api_import_runs
               set finished_at = now(),
                   status = %s,
                   details = %s::jsonb
             where id = %s
            """,
            (status, json.dumps(details, ensure_ascii=False), run_id),
        )
    conn.commit()


def insert_raw_payload(conn, run_id: int, source: str, endpoint: str, payload: Any):
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into public.api_raw_payloads(run_id, source, endpoint, payload)
            values (%s, %s, %s, %s::jsonb)
            """,
            (run_id, source, endpoint, json.dumps(payload, ensure_ascii=False)),
        )
    conn.commit()


def load_theodds_keys_from_db(conn) -> list[str]:
    with conn.cursor() as cur:
        cur.execute(
            """
            select distinct theodds_key
            from public.leagues
            where theodds_key is not null
              and btrim(theodds_key) <> ''
            order by theodds_key
            """
        )
        keys = [r[0] for r in cur.fetchall() if r and r[0]]

    if THEODDS_MAX_LEAGUES:
        try:
            n = int(THEODDS_MAX_LEAGUES)
            if n > 0:
                keys = keys[:n]
        except Exception:
            pass

    return keys


# ------------------------------------------------------------
# Matching / maps
# ------------------------------------------------------------
def norm_team_key(name: str) -> str:
    """
    V3 už neudržuje vlastní normalizaci,
    používá centrální helper z workers/theodds_matching_v3.py
    """
    return normalize_team_name(name or "")


def load_future_match_team_map(conn, days_ahead: int = 120) -> dict[str, int]:
    future_map: dict[str, int] = {}

    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT DISTINCT t.id, t.name
            FROM public.matches m
            JOIN public.teams t
              ON t.id IN (m.home_team_id, m.away_team_id)
            WHERE m.kickoff >= now() - interval '3 days'
              AND m.kickoff < now() + (%s || ' days')::interval
            """,
            (days_ahead,),
        )
        for tid, name in cur.fetchall():
            k = norm_team_key(name or "")
            if k and k not in future_map:
                future_map[k] = int(tid)

    return future_map


def load_team_maps(conn) -> tuple[dict[str, int], dict[str, int], dict[str, int]]:
    """
    Vrátí:
    - provider_map: team_provider_map(provider='theodds')
    - alias_map:    team_aliases(source='theodds')
    - team_map:     canonical teams
    """
    provider_map: dict[str, int] = {}
    alias_map: dict[str, int] = {}
    team_map: dict[str, int] = {}

    future_match_map = load_future_match_team_map(conn, days_ahead=120)

    # 1) provider map
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT team_id, provider_team_id
            FROM public.team_provider_map
            WHERE provider = 'theodds'
            """
        )
        for tid, provider_team_id in cur.fetchall():
            k = norm_team_key(provider_team_id or "")
            if k and k not in provider_map:
                provider_map[k] = int(tid)

    # 2) canonical teams
    with conn.cursor() as cur:
        cur.execute(
            """
            WITH team_usage AS (
                SELECT home_team_id AS team_id, COUNT(*) AS cnt
                FROM public.matches
                GROUP BY home_team_id

                UNION ALL

                SELECT away_team_id AS team_id, COUNT(*) AS cnt
                FROM public.matches
                GROUP BY away_team_id
            ),
            team_usage_sum AS (
                SELECT team_id, SUM(cnt) AS matches_cnt
                FROM team_usage
                GROUP BY team_id
            )
            SELECT
                t.id,
                t.name,
                t.ext_source,
                t.ext_team_id
            FROM public.teams t
            LEFT JOIN team_usage_sum u
              ON u.team_id = t.id
            ORDER BY
                CASE WHEN COALESCE(u.matches_cnt, 0) > 0 THEN 0 ELSE 1 END,
                COALESCE(u.matches_cnt, 0) DESC,
                CASE
                    WHEN t.ext_source = 'football_data' THEN 1
                    WHEN t.ext_source = 'football_data_uk' THEN 2
                    WHEN t.ext_source = 'api_football' THEN 3
                    WHEN t.ext_source = 'api_sport' THEN 4
                    ELSE 9
                END,
                t.id
            """
        )
        for tid, name, ext_source, ext_team_id in cur.fetchall():
            tid = int(tid)

            k1 = norm_team_key(name or "")
            if k1:
                if k1 in future_match_map:
                    team_map[k1] = future_match_map[k1]
                elif k1 not in team_map:
                    team_map[k1] = tid

            if ext_source == "football_data_uk" and ext_team_id:
                k2 = norm_team_key(ext_team_id or "")
                if k2 and k2 not in team_map:
                    team_map[k2] = tid

    # 3) aliases
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema='public' AND table_name='team_aliases'
            """
        )
        has_aliases = cur.fetchone() is not None

    if has_aliases:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT team_id, alias
                FROM public.team_aliases
                WHERE source = 'theodds'
                """
            )
            for tid, alias in cur.fetchall():
                k = norm_team_key(alias or "")
                if k and k not in alias_map:
                    alias_map[k] = int(tid)

    return provider_map, alias_map, team_map


# ------------------------------------------------------------
# Canonical lookup helpers
# ------------------------------------------------------------
def load_preferred_team_lookup(conn) -> dict[str, int]:
    """
    Načte preferované mapování názvu týmu -> canonical_team_id
    z public.v_preferred_team_name_lookup.
    """
    lookup: dict[str, int] = {}
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT team_name_key, canonical_team_id
            FROM public.v_preferred_team_name_lookup
            """
        )
        for team_name_key, canonical_team_id in cur.fetchall():
            k = norm_team_key(team_name_key or "")
            if k and canonical_team_id is not None and k not in lookup:
                lookup[k] = int(canonical_team_id)
    return lookup


def _insert_theodds_alias_if_missing(conn, team_id: int, alias_raw: str) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.team_aliases(team_id, alias, source)
            SELECT %s, %s, 'theodds'
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.team_aliases ta
                WHERE ta.source = 'theodds'
                  AND lower(ta.alias) = lower(%s)
            )
            """,
            (team_id, alias_raw, alias_raw),
        )


def resolve_team_id_theodds_canonical(
    conn,
    preferred_lookup: dict[str, int],
    team_name_raw: str,
    auto_insert_alias: bool = True,
) -> tuple[int | None, str | None, float]:
    """
    Preferované mapování TheOdds -> canonical_team_id.
    Priorita:
    1) public.v_preferred_team_name_lookup
    2) fuzzy best candidate nad již preferovanými názvy
    """
    key = norm_team_key(team_name_raw or "")
    if not key:
        return None, None, 0.0

    tid = preferred_lookup.get(key)
    if tid is not None:
        if auto_insert_alias:
            try:
                _insert_theodds_alias_if_missing(conn, tid, team_name_raw)
                conn.commit()
            except Exception:
                try:
                    conn.rollback()
                except Exception:
                    pass
        return tid, key, 1.0

    candidate_names = list(preferred_lookup.keys())
    best_name, score = best_candidate(key, candidate_names)
    if best_name and score >= TEAM_MATCH_THRESHOLD:
        resolved_tid = preferred_lookup.get(best_name)
        if resolved_tid is not None:
            if auto_insert_alias:
                try:
                    _insert_theodds_alias_if_missing(conn, resolved_tid, team_name_raw)
                    conn.commit()
                except Exception:
                    try:
                        conn.rollback()
                    except Exception:
                        pass
            preferred_lookup[key] = int(resolved_tid)
            return int(resolved_tid), best_name, score

    return None, best_name, score


def resolve_team_id_theodds(
    conn,
    preferred_lookup: dict[str, int],
    provider_map: dict[str, int],
    alias_map: dict[str, int],
    team_map: dict[str, int],
    team_name_raw: str,
    auto_insert_alias: bool = True,
) -> int | None:
    """
    Fallback resolver:
    1) v_preferred_team_name_lookup
    2) team_provider_map(provider='theodds')
    3) canonical teams
    4) team_aliases(source='theodds')
    """
    key = norm_team_key(team_name_raw or "")
    if not key:
        return None

    tid = preferred_lookup.get(key)
    if tid is not None:
        if auto_insert_alias:
            try:
                _insert_theodds_alias_if_missing(conn, tid, team_name_raw)
                conn.commit()
            except Exception:
                try:
                    conn.rollback()
                except Exception:
                    pass
        return int(tid)

    tid = provider_map.get(key)
    if tid is not None:
        return int(tid)

    tid = team_map.get(key)
    if tid is not None:
        if auto_insert_alias:
            try:
                _insert_theodds_alias_if_missing(conn, tid, team_name_raw)
                conn.commit()
            except Exception:
                try:
                    conn.rollback()
                except Exception:
                    pass
        return int(tid)

    tid = alias_map.get(key)
    if tid is not None:
        return int(tid)

    return None


def find_match_id_canonical(conn, home_team_id: int, away_team_id: int, kickoff_iso: str, sport_key: str | None = None):
    """
    Hledání zápasu přes public.v_canonical_match_lookup.
    Preferuje správný theodds_key league match, ale umí i fallback bez ligy.
    """
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT v.match_id
            FROM public.v_canonical_match_lookup v
            LEFT JOIN public.leagues l
              ON l.id = v.league_id
            WHERE v.canonical_home_team_id = %s
              AND v.canonical_away_team_id = %s
              AND v.kickoff BETWEEN (%s)::timestamptz - interval '72 hours'
                               AND (%s)::timestamptz + interval '72 hours'
              AND (
                    %s IS NULL
                    OR l.theodds_key = %s
                    OR l.theodds_key IS NULL
                  )
            ORDER BY
                CASE WHEN l.theodds_key = %s THEN 0 ELSE 1 END,
                ABS(EXTRACT(EPOCH FROM (v.kickoff - (%s)::timestamptz))) ASC,
                v.match_id
            LIMIT 1
            """,
            (home_team_id, away_team_id, kickoff_iso, kickoff_iso, sport_key, sport_key, sport_key, kickoff_iso),
        )
        r = cur.fetchone()
        return r[0] if r else None


def find_match_id(conn, home_team_id: int, away_team_id: int, kickoff_iso: str, sport_key: str | None = None):
    """
    Backward-compatible public match lookup wrapper.
    Nově deleguje na kanonický lookup přes v_canonical_match_lookup.
    """
    return find_match_id_canonical(
        conn=conn,
        home_team_id=home_team_id,
        away_team_id=away_team_id,
        kickoff_iso=kickoff_iso,
        sport_key=sport_key,
    )


def get_h2h_market_id(conn):
    with conn.cursor() as cur:
        cur.execute("select id from markets where lower(code)=lower('h2h') limit 1")
        r = cur.fetchone()
        if not r:
            raise RuntimeError("Market h2h neexistuje v tabulce markets (code='h2h')")
        return r[0]


def get_market_outcome_map(conn, market_id):
    with conn.cursor() as cur:
        cur.execute(
            "select id, code from market_outcomes where market_id=%s",
            (market_id,),
        )
        return {code: mid for (mid, code) in cur.fetchall()}


def get_or_create_bookmaker(conn, btitle: str, bregion: str | None, bkey: str):
    with conn.cursor() as cur:
        cur.execute(
            """
            select id
            from bookmakers
            where ext_source = 'theodds'
              and ext_bookmaker_key = %s
            limit 1
            """,
            (bkey,),
        )
        row = cur.fetchone()
        if row:
            return row[0]

        try:
            cur.execute(
                """
                insert into bookmakers (name, region, ext_source, ext_bookmaker_key)
                values (%s, %s, 'theodds', %s)
                returning id
                """,
                (btitle, bregion, bkey),
            )
            new_id = cur.fetchone()[0]
            conn.commit()
            return new_id
        except Exception:
            conn.rollback()
            cur.execute(
                """
                select id
                from bookmakers
                where ext_source = 'theodds'
                  and ext_bookmaker_key = %s
                limit 1
                """,
                (bkey,),
            )
            row = cur.fetchone()
            return row[0] if row else None


def odds_exists(conn, match_id: int, bookmaker_id: int, market_outcome_id: int, odd_value: float):
    with conn.cursor() as cur:
        cur.execute(
            """
            select 1
            from odds
            where match_id=%s
              and bookmaker_id=%s
              and market_outcome_id=%s
              and odd_value=%s
            limit 1
            """,
            (match_id, bookmaker_id, market_outcome_id, odd_value),
        )
        return cur.fetchone() is not None


# ------------------------------------------------------------
# The Odds API
# ------------------------------------------------------------
def fetch_odds_for_sport(sport_key: str) -> tuple[int, Any, str]:
    endpoint = f"/sports/{sport_key}/odds"
    url = f"{THEODDS_BASE_URL}{endpoint}"
    params = {
        "apiKey": THEODDS_API_KEY,
        "regions": THEODDS_REGIONS,
        "markets": THEODDS_MARKETS,
        "oddsFormat": "decimal",
        "dateFormat": "iso",
    }

    try:
        resp = requests.get(url, params=params, timeout=30)
        resp.encoding = "utf-8"
    except Exception as e:
        return 0, {"error": "request_failed", "message": str(e), "sport_key": sport_key}, endpoint

    status = int(resp.status_code)

    try:
        payload = resp.json()
    except Exception:
        payload = {"raw_text": resp.text[:2000], "sport_key": sport_key}

    return status, payload, endpoint


# ------------------------------------------------------------
# Parsing
# ------------------------------------------------------------
def iter_events_from_payload(payload: Any) -> Iterable[dict[str, Any]]:
    if payload is None:
        return []
    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict) and isinstance(payload.get("data"), list):
        return payload.get("data") or []
    return []


def add_unmatched_row(unmatched_rows: list[dict[str, Any]], row: dict[str, Any]) -> None:
    unmatched_rows.append(row)


def parse_and_insert_odds(
    conn,
    sport_key: str,
    preferred_lookup: dict[str, int],
    provider_map: dict[str, int],
    alias_map: dict[str, int],
    team_map: dict[str, int],
    outcome_map: dict[str, int],
    payload: Any,
    unmatched_rows: list[dict[str, Any]],
) -> tuple[int, int, int, int]:
    """
    Vrací:
    (inserted, skipped_no_team, skipped_no_match, skipped_low_coverage)
    """
    inserted = 0
    skipped_no_team = 0
    skipped_no_match = 0
    skipped_low_coverage = 0

    events = iter_events_from_payload(payload)

    for event in events:
        home_team_name = event.get("home_team")
        away_team_name = event.get("away_team")
        commence_time = event.get("commence_time")

        if not home_team_name or not away_team_name or not commence_time:
            continue

        home_id, best_home_candidate, best_home_score = resolve_team_id_theodds_canonical(
            conn=conn,
            preferred_lookup=preferred_lookup,
            team_name_raw=home_team_name,
        )
        if home_id is None:
            fallback_home_id = resolve_team_id_theodds(
                conn=conn,
                preferred_lookup=preferred_lookup,
                provider_map=provider_map,
                alias_map=alias_map,
                team_map=team_map,
                team_name_raw=home_team_name,
                auto_insert_alias=True,
            )
            if fallback_home_id is not None:
                home_id = fallback_home_id
                best_home_candidate = norm_team_key(home_team_name)
                best_home_score = 1.0

        away_id, best_away_candidate, best_away_score = resolve_team_id_theodds_canonical(
            conn=conn,
            preferred_lookup=preferred_lookup,
            team_name_raw=away_team_name,
        )
        if away_id is None:
            fallback_away_id = resolve_team_id_theodds(
                conn=conn,
                preferred_lookup=preferred_lookup,
                provider_map=provider_map,
                alias_map=alias_map,
                team_map=team_map,
                team_name_raw=away_team_name,
                auto_insert_alias=True,
            )
            if fallback_away_id is not None:
                away_id = fallback_away_id
                best_away_candidate = norm_team_key(away_team_name)
                best_away_score = 1.0

        similarity_score = min(best_home_score or 0.0, best_away_score or 0.0)

        match_id = None
        attach_reason = None

        if home_id and away_id:

            # --------------------------------------------------
            # 1) STRICT MATCH (±6 hodin)
            # --------------------------------------------------
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT v.match_id, v.kickoff
                    FROM public.v_canonical_match_lookup v
                    WHERE v.canonical_home_team_id = %s
                    AND v.canonical_away_team_id = %s
                    AND v.kickoff BETWEEN (%s)::timestamptz - interval '6 hours'
                                    AND (%s)::timestamptz + interval '6 hours'
                    ORDER BY ABS(EXTRACT(EPOCH FROM (v.kickoff - (%s)::timestamptz))) ASC
                    LIMIT 1
                    """,
                    (home_id, away_id, commence_time, commence_time, commence_time),
                )
                r = cur.fetchone()

            if r:
                match_id = r[0]
                attach_reason = "EXACT_PAIR_EXACT_KICKOFF"

            # --------------------------------------------------
            # 2) TIME TOLERANCE MATCH (±72 hodin)
            # --------------------------------------------------
            if not match_id:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        SELECT v.match_id, v.kickoff
                        FROM public.v_canonical_match_lookup v
                        WHERE v.canonical_home_team_id = %s
                        AND v.canonical_away_team_id = %s
                        AND v.kickoff BETWEEN (%s)::timestamptz - interval '72 hours'
                                        AND (%s)::timestamptz + interval '72 hours'
                        ORDER BY ABS(EXTRACT(EPOCH FROM (v.kickoff - (%s)::timestamptz))) ASC
                        LIMIT 1
                        """,
                        (home_id, away_id, commence_time, commence_time, commence_time),
                    )
                    r = cur.fetchone()

                if r:
                    match_id = r[0]
                    attach_reason = "EXACT_PAIR_TIME_TOLERANCE"

            # --------------------------------------------------
            # 3) FALSE PAIR GUARD
            # --------------------------------------------------
            if not match_id:
                if best_home_score < 0.9 or best_away_score < 0.9:
                    attach_reason = "FALSE_PAIRING_BLACKLIST"

        issue_code = classify_matching_issue(
            home_name=home_team_name,
            away_name=away_team_name,
            matched_home=home_id is not None,
            matched_away=away_id is not None,
            match_id=match_id,
            similarity_score=similarity_score,
        )

        if issue_code == "MATCH_OK":
            pass
        elif issue_code.startswith("NO_TEAM_MATCH"):
            skipped_no_team += 1
            print("NO TEAM MATCH:", home_team_name, "vs", away_team_name)
            add_unmatched_row(
                unmatched_rows,
                build_match_debug_payload(
                    provider_name="theodds",
                    league_name=sport_key,
                    event_name=f"{home_team_name} vs {away_team_name}",
                    home_name_raw=home_team_name,
                    away_name_raw=away_team_name,
                    home_name_normalized=norm_team_key(home_team_name),
                    away_name_normalized=norm_team_key(away_team_name),
                    best_home_candidate=best_home_candidate,
                    best_away_candidate=best_away_candidate,
                    best_home_score=best_home_score,
                    best_away_score=best_away_score,
                    match_id=match_id,
                    issue_code=issue_code,
                ),
            )
            continue
        elif issue_code == "LOW_COVERAGE":
            skipped_low_coverage += 1
            print(
                "LOW COVERAGE:",
                home_team_name, f"(score={best_home_score})",
                "vs",
                away_team_name, f"(score={best_away_score})",
                "| kickoff:", commence_time,
            )
            add_unmatched_row(
                unmatched_rows,
                build_match_debug_payload(
                    provider_name="theodds",
                    league_name=sport_key,
                    event_name=f"{home_team_name} vs {away_team_name}",
                    home_name_raw=home_team_name,
                    away_name_raw=away_team_name,
                    home_name_normalized=norm_team_key(home_team_name),
                    away_name_normalized=norm_team_key(away_team_name),
                    best_home_candidate=best_home_candidate,
                    best_away_candidate=best_away_candidate,
                    best_home_score=best_home_score,
                    best_away_score=best_away_score,
                    match_id=match_id,
                    issue_code=issue_code,
                ),
            )
            continue
        elif issue_code == "NO_MATCH_ID":
            skipped_no_match += 1
            print(
                "NO MATCH ID:",
                home_team_name, f"(id={home_id})",
                "vs",
                away_team_name, f"(id={away_id})",
                "| kickoff:", commence_time
            )
            add_unmatched_row(
                unmatched_rows,
                build_match_debug_payload(
                    provider_name="theodds",
                    league_name=sport_key,
                    event_name=f"{home_team_name} vs {away_team_name}",
                    home_name_raw=home_team_name,
                    away_name_raw=away_team_name,
                    home_name_normalized=norm_team_key(home_team_name),
                    away_name_normalized=norm_team_key(away_team_name),
                    best_home_candidate=best_home_candidate,
                    best_away_candidate=best_away_candidate,
                    best_home_score=best_home_score,
                    best_away_score=best_away_score,
                    match_id=match_id,
                    issue_code=issue_code,
                ),
            )
            continue

        print(
            "ATTACH DEBUG:",
            home_team_name,
            "vs",
            away_team_name,
            "| reason:",
            attach_reason
        )

        # MATCH_OK -> insert odds
        for bookmaker in event.get("bookmakers", []) or []:
            bkey = bookmaker.get("key")
            btitle = bookmaker.get("title")
            bregion = bookmaker.get("region")
            if not bkey or not btitle:
                continue

            bookmaker_id = get_or_create_bookmaker(conn, btitle, bregion, bkey)
            if not bookmaker_id:
                continue

            for market in bookmaker.get("markets", []) or []:
                if market.get("key") != "h2h":
                    continue

                for outcome in market.get("outcomes", []) or []:
                    name = outcome.get("name")
                    price = outcome.get("price")
                    if name is None or price is None:
                        continue

                    if name == home_team_name:
                        mcode = "1"
                    elif name == away_team_name:
                        mcode = "2"
                    else:
                        mcode = "X"

                    market_outcome_id = outcome_map.get(mcode)
                    if not market_outcome_id:
                        continue

                    try:
                        odd_value = float(price)
                    except Exception:
                        continue

                    # DB public.odds.odd_value = numeric(6,3)
                    # => povolený rozsah je přibližně 0.001 až 999.999
                    # extrémní / vadné hodnoty raději přeskočíme
                    if odd_value <= 0:
                        continue

                    if odd_value >= 1000:
                        print(
                            "SKIP odd_value out of range:",
                            f"match_id={match_id}",
                            f"bookmaker_id={bookmaker_id}",
                            f"market_outcome_id={market_outcome_id}",
                            f"odd_value={odd_value}",
                        )
                        continue

                    if odds_exists(conn, match_id, bookmaker_id, market_outcome_id, odd_value):
                        continue

                    try:
                        with conn.cursor() as cur2:
                            cur2.execute(
                                """
                                insert into odds(
                                    match_id,
                                    bookmaker_id,
                                    market_outcome_id,
                                    odd_value,
                                    collected_at
                                )
                                values (%s, %s, %s, %s, now())
                                """,
                                (match_id, bookmaker_id, market_outcome_id, odd_value),
                            )
                        conn.commit()
                        inserted += 1
                    except Exception as e:
                        try:
                            conn.rollback()
                        except Exception:
                            pass
                        print("DB ERROR insert odds:", e)
                        continue

    return inserted, skipped_no_team, skipped_no_match, skipped_low_coverage


# ------------------------------------------------------------
# Coverage / reports
# ------------------------------------------------------------
def load_league_team_coverage(conn) -> dict[str, int]:
    cov: dict[str, int] = {}
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT l.theodds_key,
                   COUNT(DISTINCT t.id) AS teams_present
            FROM public.leagues l
            LEFT JOIN public.matches m ON m.league_id = l.id
            LEFT JOIN public.teams t ON t.id IN (m.home_team_id, m.away_team_id)
            WHERE l.theodds_key IS NOT NULL
            GROUP BY l.theodds_key
            """
        )
        for k, teams_present in cur.fetchall():
            if k:
                cov[str(k)] = int(teams_present or 0)
    return cov


def write_unmatched_reports(run_id: int, unmatched_rows: list[dict[str, Any]]) -> None:
    if not unmatched_rows:
        return

    csv_path = PROJECT_ROOT / f"unmatched_theodds_{run_id}.csv"
    sql_path = PROJECT_ROOT / f"unmatched_theodds_{run_id}.sql"

    fieldnames = [
        "provider",
        "league_name",
        "event_name",
        "home_raw",
        "away_raw",
        "home_normalized",
        "away_normalized",
        "best_home_candidate",
        "best_away_candidate",
        "best_home_score",
        "best_away_score",
        "match_id",
        "issue_code",
    ]

    with csv_path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in unmatched_rows:
            writer.writerow({k: row.get(k) for k in fieldnames})

    # SQL skeleton jen pro NO_TEAM_MATCH / LOW_COVERAGE
    with sql_path.open("w", encoding="utf-8") as f:
        f.write(f"-- Unmatched theodds aliases from run_id={run_id}\n")
        f.write("-- DOPLN team_id a spusť jen vybrané řádky.\n\n")

        seen_aliases: set[str] = set()
        for row in unmatched_rows:
            if row.get("issue_code") not in {"NO_TEAM_MATCH_HOME", "NO_TEAM_MATCH_AWAY", "NO_TEAM_MATCH_BOTH", "LOW_COVERAGE"}:
                continue

            for alias in [row.get("home_raw"), row.get("away_raw")]:
                if not alias:
                    continue
                key = alias.strip().lower()
                if key in seen_aliases:
                    continue
                seen_aliases.add(key)

                safe = alias.replace("'", "''")
                f.write(f"-- alias: {alias}\n")
                f.write("INSERT INTO public.team_aliases(team_id, alias, source)\n")
                f.write(f"VALUES (/* team_id */ NULL, '{safe}', 'theodds');\n\n")


# ------------------------------------------------------------
# MAIN
# ------------------------------------------------------------
def main():
    if not THEODDS_API_KEY:
        raise RuntimeError("Chybí env THEODDS_API_KEY")

    conn = db()
    run_id = None
    unmatched_rows: list[dict[str, Any]] = []

    totals = {
        "leagues_total": 0,
        "leagues_ok": 0,
        "leagues_422": 0,
        "leagues_error": 0,
        "raw_saved": 0,
        "odds_inserted": 0,
        "skipped_no_team": 0,
        "skipped_no_match": 0,
        "skipped_low_coverage": 0,
        "match_ok_leagues": 0,
    }

    try:
        run_id = start_import_run(conn, source="theodds")
        print("RUN_ID:", run_id)

        preferred_lookup = load_preferred_team_lookup(conn)
        provider_map, alias_map, team_map = load_team_maps(conn)

        print("PREFERRED LOOKUP loaded:", len(preferred_lookup))
        print("PROVIDER MAP loaded    :", len(provider_map))
        print("ALIAS MAP loaded       :", len(alias_map))
        print("TEAM MAP loaded        :", len(team_map))

        market_id = get_h2h_market_id(conn)
        outcome_map = get_market_outcome_map(conn, market_id)

        sport_keys = load_theodds_keys_from_db(conn)
        league_coverage = load_league_team_coverage(conn)

        totals["leagues_total"] = len(sport_keys)
        print("Leagues from DB (theodds_key):", len(sport_keys))

        for i, sport_key in enumerate(sport_keys, start=1):
            print(f"[{i}/{len(sport_keys)}] Fetching: {sport_key}")
            status, payload, endpoint = fetch_odds_for_sport(sport_key)

            raw_payload = {
                "sport_key": sport_key,
                "status_code": status,
                "payload": payload,
            }
            try:
                insert_raw_payload(conn, run_id, "theodds", endpoint, raw_payload)
                totals["raw_saved"] += 1
            except Exception as e:
                try:
                    conn.rollback()
                except Exception:
                    pass
                print("DB ERROR insert api_raw_payloads:", e)

            if status == 422:
                totals["leagues_422"] += 1
                print("SKIP 422 (plan limitation):", sport_key)
                time.sleep(THEODDS_SLEEP_SEC)
                continue

            if status == 0 or status >= 400:
                totals["leagues_error"] += 1
                msg = None
                if isinstance(payload, dict):
                    msg = payload.get("message") or payload.get("error") or payload.get("raw_text")
                print("ERROR league:", sport_key, "status:", status, "msg:", (msg or "")[:200])
                time.sleep(THEODDS_SLEEP_SEC)
                continue

            teams_present = league_coverage.get(sport_key, 0)
            if teams_present < THEODDS_MIN_TEAMS_PRESENT:
                print(f"LOW COVERAGE (teams_present={teams_present} < {THEODDS_MIN_TEAMS_PRESENT}):", sport_key)

            try:
                ins, sk_team, sk_match, sk_cov = parse_and_insert_odds(
                    conn,
                    sport_key,
                    preferred_lookup,
                    provider_map,
                    alias_map,
                    team_map,
                    outcome_map,
                    payload,
                    unmatched_rows,
                )
                totals["odds_inserted"] += ins
                totals["skipped_no_team"] += sk_team
                totals["skipped_no_match"] += sk_match
                totals["skipped_low_coverage"] += sk_cov
                totals["leagues_ok"] += 1
                if ins > 0:
                    totals["match_ok_leagues"] += 1

                print(
                    "Inserted odds:", ins,
                    "| no_team:", sk_team,
                    "| no_match:", sk_match,
                    "| low_coverage:", sk_cov,
                    f"(league: {sport_key})"
                )
            except Exception as e:
                totals["leagues_error"] += 1
                try:
                    conn.rollback()
                except Exception:
                    pass
                print("ERROR parsing/inserting league:", sport_key, e)

            time.sleep(THEODDS_SLEEP_SEC)

        write_unmatched_reports(run_id, unmatched_rows)

        totals["unmatched_rows"] = len(unmatched_rows)

        finish_import_run(conn, run_id, status="ok", details=totals)
        print("DONE. Summary:", totals)

    except Exception as e:
        if conn:
            try:
                conn.rollback()
            except Exception:
                pass
        if run_id is not None:
            try:
                finish_import_run(conn, run_id, status="error", details={**totals, "error": str(e)})
            except Exception:
                pass
        raise
    finally:
        try:
            conn.close()
        except Exception:
            pass


if __name__ == "__main__":
    main()