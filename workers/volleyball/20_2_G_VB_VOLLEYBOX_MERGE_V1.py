# -*- coding: utf-8 -*-
"""
===============================================================================
MATCHMATRIX 20_2_G – VB VOLLEYBOX MERGE V1
===============================================================================

CO TO JE:
První merge worker pro Volleybox hráče.

K ČEMU TO JE:
Převede hráče ze staging.stg_provider_players do produkční People vrstvy:
- public.players
- public.player_provider_map
- public.player_external_identity

KDE TO UVIDÍME:
DBeaver:
SELECT * FROM public.players WHERE ext_source = 'volleybox';
SELECT * FROM public.player_provider_map WHERE provider = 'volleybox';
SELECT * FROM public.player_external_identity WHERE provider = 'volleybox';

JAK SE TO VYUŽIJE:
Tím ověříme kompletní cestu nového providera:
DISCOVERY → VALIDATION → ACCEPT → RAW → PARSE → STAGING → PUBLIC

NAVAZUJE NA:
20_2_F_VB_VOLLEYBOX_STAGING_V1

DALŠÍ KROK:
20_2_H_VB_VOLLEYBOX_PUBLIC_AUDIT_V1

SPUŠTĚNÍ:
cd C:\\MatchMatrix-platform
C:\\Python314\\python.exe workers\\volleyball\\20_2_G_VB_VOLLEYBOX_MERGE_V1.py
===============================================================================
"""

from __future__ import annotations

import psycopg2


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

PROVIDER = "volleybox"
SPORT_CODE = "VB"
SPORT_ID = 10


def get_or_create_player(cur, row: dict) -> int:
    cur.execute(
        """
        SELECT id
        FROM public.players
        WHERE ext_source = %s
          AND ext_player_id = %s
        LIMIT 1
        """,
        (PROVIDER, row["external_player_id"]),
    )
    existing = cur.fetchone()

    if existing:
        return int(existing[0])

    cur.execute(
        """
        INSERT INTO public.players (
            team_id,
            name,
            first_name,
            last_name,
            short_name,
            birth_date,
            nationality,
            position,
            shirt_number,
            height_cm,
            weight_kg,
            is_active,
            ext_source,
            ext_player_id,
            created_at,
            updated_at,
            photo_url,
            sport_id
        )
        VALUES (
            NULL,
            %(name)s,
            %(first_name)s,
            %(last_name)s,
            %(short_name)s,
            NULL,
            %(nationality)s,
            %(position)s,
            NULL,
            %(height_cm)s,
            %(weight_kg)s,
            TRUE,
            %(ext_source)s,
            %(ext_player_id)s,
            NOW(),
            NOW(),
            NULL,
            %(sport_id)s
        )
        RETURNING id
        """,
        {
            "name": row["player_name"],
            "first_name": row["first_name"],
            "last_name": row["last_name"],
            "short_name": row["short_name"],
            "nationality": row["nationality"],
            "position": row["position_code"],
            "height_cm": row["height_cm"],
            "weight_kg": row["weight_kg"],
            "ext_source": PROVIDER,
            "ext_player_id": row["external_player_id"],
            "sport_id": SPORT_ID,
        },
    )

    return int(cur.fetchone()[0])


def upsert_provider_map(cur, player_id: int, row: dict) -> None:
    cur.execute(
        """
        SELECT id
        FROM public.player_provider_map
        WHERE provider = %s
          AND provider_player_id = %s
        LIMIT 1
        """,
        (PROVIDER, row["external_player_id"]),
    )

    existing = cur.fetchone()

    if existing:
        cur.execute(
            """
            UPDATE public.player_provider_map
            SET
                player_id = %s,
                provider_player_name = %s,
                provider_team_id = %s,
                provider_team_name = %s,
                is_active = TRUE,
                updated_at = NOW()
            WHERE id = %s
            """,
            (
                player_id,
                row["player_name"],
                row["external_team_id"],
                row["team_name"],
                existing[0],
            ),
        )
        return

    cur.execute(
        """
        INSERT INTO public.player_provider_map (
            provider,
            provider_player_id,
            player_id,
            provider_team_id,
            provider_team_name,
            provider_player_name,
            is_active,
            created_at,
            updated_at
        )
        VALUES (
            %s,%s,%s,%s,%s,%s,TRUE,NOW(),NOW()
        )
        """,
        (
            PROVIDER,
            row["external_player_id"],
            player_id,
            row["external_team_id"],
            row["team_name"],
            row["player_name"],
        ),
    )


def upsert_external_identity(cur, player_id: int, row: dict) -> None:
    cur.execute(
        """
        SELECT id
        FROM public.player_external_identity
        WHERE provider = %s
          AND external_player_id = %s
        LIMIT 1
        """,
        (PROVIDER, row["external_player_id"]),
    )

    existing = cur.fetchone()

    if existing:
        cur.execute(
            """
            UPDATE public.player_external_identity
            SET
                player_id = %s,
                external_team_id = %s,
                external_league_id = %s,
                season = %s,
                confidence_score = 100,
                match_method = 'provider_id_exact',
                is_primary = TRUE,
                is_active = TRUE,
                updated_at = NOW()
            WHERE id = %s
            """,
            (
                player_id,
                row["external_team_id"],
                row["external_league_id"],
                row["season"],
                existing[0],
            ),
        )
        return

    cur.execute(
        """
        INSERT INTO public.player_external_identity (
            player_id,
            provider,
            external_player_id,
            external_team_id,
            external_league_id,
            season,
            confidence_score,
            match_method,
            is_primary,
            is_active,
            created_at,
            updated_at
        )
        VALUES (
            %s,%s,%s,%s,%s,%s,100,'provider_id_exact',TRUE,TRUE,NOW(),NOW()
        )
        """,
        (
            player_id,
            PROVIDER,
            row["external_player_id"],
            row["external_team_id"],
            row["external_league_id"],
            row["season"],
        ),
    )


def main() -> int:
    print("=" * 80)
    print("MATCHMATRIX 20_2_G – VB VOLLEYBOX MERGE V1")
    print("=" * 80)

    conn = None

    inserted_or_matched = 0
    failed = 0

    try:
        conn = psycopg2.connect(**DB_CONFIG)

        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT
                    id,
                    provider,
                    sport_code,
                    external_player_id,
                    player_name,
                    birth_date,
                    nationality,
                    external_team_id,
                    season,
                    first_name,
                    last_name,
                    short_name,
                    position_code,
                    height_cm,
                    weight_kg,
                    external_league_id,
                    team_name,
                    league_name,
                    source_endpoint
                FROM staging.stg_provider_players
                WHERE provider = %s
                  AND sport_code = %s
                  AND external_player_id IS NOT NULL
                  AND player_name IS NOT NULL
                ORDER BY id DESC
                """,
                (PROVIDER, SPORT_CODE),
            )

            columns = [d[0] for d in cur.description]
            rows = [dict(zip(columns, r)) for r in cur.fetchall()]

            print(f"STAGING ROWS: {len(rows)}")

            for row in rows:
                print("-" * 80)
                print(f"PLAYER: {row['player_name']} | external_id={row['external_player_id']}")

                try:
                    player_id = get_or_create_player(cur, row)
                    upsert_provider_map(cur, player_id, row)
                    upsert_external_identity(cur, player_id, row)

                    inserted_or_matched += 1
                    print(f"MERGE OK: public.players.id={player_id}")

                except Exception as e:
                    failed += 1
                    print(f"ERROR: {type(e).__name__}: {e}")

        if failed:
            conn.rollback()
        else:
            conn.commit()

    except Exception as e:
        if conn:
            conn.rollback()
        print(f"FATAL: {type(e).__name__}: {e}")
        return 1

    finally:
        if conn:
            conn.close()

    print("=" * 80)
    print("SUMMARY")
    print(f"MERGED: {inserted_or_matched}")
    print(f"FAILED: {failed}")
    print("=" * 80)

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())