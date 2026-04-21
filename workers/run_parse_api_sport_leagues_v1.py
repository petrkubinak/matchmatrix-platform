#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import annotations

import argparse
import json
import os
import traceback
from typing import Any, Dict, List, Optional, Tuple

import psycopg2


def log(message: str) -> None:
    print(f"[run_parse_api_sport_leagues_v1] {message}")


def normalize_sport_code(value: Optional[str]) -> Optional[str]:
    if value is None:
        return None

    v = str(value).strip()
    if not v:
        return None

    mapping = {
        "football": "FB",
        "hockey": "HK",
        "basketball": "BK",
        "volleyball": "VB",
        "handball": "HB",
        "baseball": "BSB",
        "rugby": "RGB",
        "mma": "MMA",
        "american_football": "AFB",
        "nfl": "AFB",
        "tennis": "TN",
        "cricket": "CK",
        "field_hockey": "FH",
        "esports": "ESP",
        "darts": "DRT",
    }

    key = v.lower()
    if key in mapping:
        return mapping[key]

    return v.upper()


def safe_bool(value: Any, default: bool = True) -> bool:
    if value is None:
        return default
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return bool(value)

    text = str(value).strip().lower()
    if text in {"true", "1", "yes", "y"}:
        return True
    if text in {"false", "0", "no", "n"}:
        return False

    return default


def get_db_conn():
    dsn = os.getenv("DB_DSN", "").strip()
    if dsn:
        log("Používám DB_DSN z ENV.")
        return psycopg2.connect(dsn)

    host = os.getenv("POSTGRES_HOST", "localhost")
    port = os.getenv("POSTGRES_PORT", "5432")
    dbname = os.getenv("POSTGRES_DB", "matchmatrix")
    user = os.getenv("POSTGRES_USER", "matchmatrix")
    password = os.getenv("POSTGRES_PASSWORD", "matchmatrix_pass")

    log(f"DB connect: host={host} port={port} db={dbname} user={user}")

    return psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password,
    )


def extract_results_array(payload: Dict[str, Any]) -> List[Dict[str, Any]]:
    response = payload.get("response")
    if isinstance(response, list):
        return [item for item in response if isinstance(item, dict)]
    return []


def parse_league_row(
    item: Dict[str, Any],
    fallback_sport_code: Optional[str],
    fallback_season: Optional[str],
) -> List[Dict[str, Any]]:
    """
    API-Sports leagues může vracet dva tvary:

    A)
    {
      "league": {"id": ..., "name": ...},
      "country": {...},
      "seasons": [...]
    }

    B)
    {
      "id": ...,
      "name": ...,
      "country": {...},
      "seasons": [...]
    }
    """

    if "league" in item and isinstance(item.get("league"), dict):
        league_obj = item.get("league") or {}
    else:
        league_obj = item

    country = item.get("country") or {}
    seasons = item.get("seasons") or []

    external_league_id = None
    if league_obj.get("id") is not None:
        ext_val = str(league_obj.get("id")).strip()
        if ext_val:
            external_league_id = ext_val

    league_name = None
    if league_obj.get("name") is not None:
        name_val = str(league_obj.get("name")).strip()
        if name_val:
            league_name = name_val

    country_name = None
    if isinstance(country, dict) and country.get("name") is not None:
        country_val = str(country.get("name")).strip()
        if country_val:
            country_name = country_val

    sport_code = normalize_sport_code(
        item.get("sport")
        or league_obj.get("sport")
        or fallback_sport_code
    )

    parsed_rows: List[Dict[str, Any]] = []

    if seasons and isinstance(seasons, list):
        for season_item in seasons:
            if not isinstance(season_item, dict):
                continue

            # API-Sports někde vrací "year", jinde "season"
            season_value = season_item.get("year")
            if season_value is None:
                season_value = season_item.get("season")

            season_text = str(season_value).strip() if season_value is not None else fallback_season

            parsed_rows.append({
                "external_league_id": external_league_id,
                "league_name": league_name,
                "country_name": country_name,
                "season": season_text,
                "is_active": safe_bool(season_item.get("current"), True),
                "sport_code": sport_code,
            })

    if not parsed_rows:
        parsed_rows.append({
            "external_league_id": external_league_id,
            "league_name": league_name,
            "country_name": country_name,
            "season": fallback_season,
            "is_active": True,
            "sport_code": sport_code,
        })

    return parsed_rows


def is_valid_league_row(row: Dict[str, Any]) -> bool:
    ext_id = row.get("external_league_id")
    if ext_id is None:
        return False

    ext_text = str(ext_id).strip()
    if not ext_text:
        return False

    return True


def fetch_pending_payloads(
    conn,
    provider: str,
    sport: Optional[str],
    entity: str,
    limit: int = 50,
) -> List[Tuple]:
    sql = """
        SELECT
            id,
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            payload_json
        FROM staging.stg_api_payloads
        WHERE provider = %s
          AND entity_type = %s
          AND parse_status = 'pending'
          AND (%s IS NULL OR lower(coalesce(sport_code, '')) = lower(%s))
        ORDER BY id ASC
        LIMIT %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (provider, entity, sport, sport, limit))
        return cur.fetchall()


def upsert_stg_provider_league(
    conn,
    provider: str,
    sport_code: Optional[str],
    external_league_id: str,
    league_name: Optional[str],
    country_name: Optional[str],
    season: Optional[str],
    raw_payload_id: int,
    is_active: bool,
) -> None:
    with conn.cursor() as cur:
        update_sql = """
            UPDATE staging.stg_provider_leagues
               SET league_name    = %s,
                   country_name   = %s,
                   raw_payload_id = %s,
                   is_active      = %s,
                   updated_at     = now()
             WHERE provider = %s
               AND coalesce(sport_code, '') = coalesce(%s, '')
               AND external_league_id = %s
               AND coalesce(season, '') = coalesce(%s, '')
        """
        cur.execute(
            update_sql,
            (
                league_name,
                country_name,
                raw_payload_id,
                is_active,
                provider,
                sport_code,
                external_league_id,
                season,
            ),
        )

        if cur.rowcount == 0:
            insert_sql = """
                INSERT INTO staging.stg_provider_leagues
                (
                    provider,
                    sport_code,
                    external_league_id,
                    league_name,
                    country_name,
                    season,
                    raw_payload_id,
                    is_active,
                    created_at,
                    updated_at
                )
                VALUES
                (
                    %s, %s, %s, %s, %s, %s, %s, %s, now(), now()
                )
            """
            cur.execute(
                insert_sql,
                (
                    provider,
                    sport_code,
                    external_league_id,
                    league_name,
                    country_name,
                    season,
                    raw_payload_id,
                    is_active,
                ),
            )


def mark_payload_parsed(conn, payload_id: int, message: str) -> None:
    sql = """
        UPDATE staging.stg_api_payloads
           SET parse_status = 'parsed',
               parse_message = %s
         WHERE id = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (message[:1000], payload_id))


def mark_payload_failed(conn, payload_id: int, message: str) -> None:
    sql = """
        UPDATE staging.stg_api_payloads
           SET parse_status = 'failed',
               parse_message = %s
         WHERE id = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (message[:1000], payload_id))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--provider", required=True)
    parser.add_argument("--sport", required=False, default=None)
    parser.add_argument("--entity", required=False, default="leagues")
    parser.add_argument("--limit", required=False, type=int, default=50)
    args = parser.parse_args()

    provider = args.provider.strip()
    sport = args.sport.strip() if args.sport else None
    entity = args.entity.strip()

    if entity.lower() != "leagues":
        log(f"Unsupported entity for this parser: {entity}")
        return 2

    conn = get_db_conn()
    conn.autocommit = False

    processed = 0
    inserted_or_updated = 0
    failed = 0
    skipped_invalid = 0

    try:
        payload_rows = fetch_pending_payloads(
            conn=conn,
            provider=provider,
            sport=sport,
            entity="leagues",
            limit=args.limit,
        )

        log(f"Pending payloads found: {len(payload_rows)}")

        for row in payload_rows:
            payload_id = row[0]
            row_provider = row[1]
            row_sport_code = row[2]
            row_entity_type = row[3]
            row_endpoint_name = row[4]
            row_external_id = row[5]
            row_season = row[6]
            payload_json = row[7]

            try:
                if payload_json is None:
                    raise ValueError("payload_json is NULL")

                if isinstance(payload_json, str):
                    payload = json.loads(payload_json)
                else:
                    payload = payload_json

                items = extract_results_array(payload)
                log(f"Payload id={payload_id} response items={len(items)}")

                payload_row_count = 0
                payload_skipped = 0

                for item in items:
                    parsed_rows = parse_league_row(
                        item=item,
                        fallback_sport_code=row_sport_code,
                        fallback_season=row_season,
                    )

                    for parsed in parsed_rows:
                        if not is_valid_league_row(parsed):
                            payload_skipped += 1
                            skipped_invalid += 1
                            log(
                                "SKIP invalid league row "
                                f"| payload_id={payload_id} "
                                f"| external_league_id={parsed.get('external_league_id')} "
                                f"| league_name={parsed.get('league_name')} "
                                f"| country_name={parsed.get('country_name')} "
                                f"| season={parsed.get('season')}"
                            )
                            continue

                        upsert_stg_provider_league(
                            conn=conn,
                            provider=row_provider,
                            sport_code=parsed["sport_code"],
                            external_league_id=str(parsed["external_league_id"]).strip(),
                            league_name=parsed["league_name"],
                            country_name=parsed["country_name"],
                            season=parsed["season"],
                            raw_payload_id=payload_id,
                            is_active=parsed["is_active"],
                        )
                        payload_row_count += 1
                        inserted_or_updated += 1

                mark_payload_parsed(
                    conn,
                    payload_id,
                    f"Parsed OK | rows={payload_row_count} | skipped_invalid={payload_skipped} | entity={row_entity_type} | endpoint={row_endpoint_name}",
                )
                conn.commit()
                processed += 1

            except Exception as row_exc:
                conn.rollback()
                failed += 1
                err_text = f"{type(row_exc).__name__}: {row_exc}"

                try:
                    mark_payload_failed(conn, payload_id, err_text)
                    conn.commit()
                except Exception:
                    conn.rollback()

                log(f"FAILED payload_id={payload_id} -> {err_text}")
                traceback.print_exc()

        log("======================================================")
        log(f"Processed payloads : {processed}")
        log(f"Upserted rows      : {inserted_or_updated}")
        log(f"Skipped invalid    : {skipped_invalid}")
        log(f"Failed payloads    : {failed}")
        log("======================================================")

        return 0 if failed == 0 else 1

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())