# =========================================================
# MATCHMATRIX
# MEDIA ASSET ENRICHMENT ENGINE V1.1
# =========================================================
#
# Co skript dělá:
# ---------------------------------------------------------
# Zpracovává enrichment queue a doplňuje:
# - player photos
# - team logos
# - league logos
#
# V1.1:
# ---------------------------------------------------------
# Provider-aware enrichment:
# - pokud už má entita reálné HTTP URL, ponechá ho
# - pokud URL chybí, použije fallback placeholder
#
# Zdroj:
# ---------------------------------------------------------
# ops.media_asset_enrichment_queue
#
# Výstup:
# ---------------------------------------------------------
# public.players.photo_url
# public.teams.logo_url
# public.leagues.logo_url
#
# Web/App:
# ---------------------------------------------------------
# - player cards
# - team logos
# - league logos
# - match cards
# - AI feed
#
# =========================================================

import os
from dotenv import load_dotenv
import psycopg2
from psycopg2.extras import RealDictCursor


# =========================================================
# ENV
# =========================================================

load_dotenv()

DB_HOST = os.getenv("PGHOST")
DB_PORT = os.getenv("PGPORT")
DB_NAME = os.getenv("PGDATABASE")
DB_USER = os.getenv("PGUSER")
DB_PASS = os.getenv("PGPASSWORD")


# =========================================================
# CONNECT
# =========================================================

conn = psycopg2.connect(
    host=DB_HOST,
    port=DB_PORT,
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASS
)

conn.autocommit = True


# =========================================================
# LOAD QUEUE
# =========================================================

print("LOADING ENRICHMENT QUEUE...")

with conn.cursor(cursor_factory=RealDictCursor) as cur:
    cur.execute("""
        SELECT
            id,
            entity_type,
            entity_id,
            asset_type
        FROM ops.media_asset_enrichment_queue
        WHERE status = 'pending'
        ORDER BY priority DESC, id
        LIMIT 500
    """)
    queue_rows = cur.fetchall()

print(f"QUEUE ROWS LOADED: {len(queue_rows)}")


# =========================================================
# COUNTERS
# =========================================================

processed = 0
players_updated = 0
teams_updated = 0
leagues_updated = 0
real_urls_used = 0
fallback_urls_used = 0


# =========================================================
# HELPERS
# =========================================================

def is_real_http_url(value):
    if not value:
        return False

    value = str(value).strip().lower()

    return value.startswith("http://") or value.startswith("https://")


# =========================================================
# PROCESS QUEUE
# =========================================================

for row in queue_rows:

    queue_id = row["id"]
    entity_type = row["entity_type"]
    entity_id = row["entity_id"]

    try:

        # =================================================
        # PLAYER PHOTO
        # =================================================

        if entity_type == "player":

            with conn.cursor(cursor_factory=RealDictCursor) as lookup_cur:
                lookup_cur.execute("""
                    SELECT
                        photo_url
                    FROM public.players
                    WHERE id = %s
                """, (entity_id,))
                player_row = lookup_cur.fetchone()

            existing_photo_url = None

            if player_row:
                existing_photo_url = player_row.get("photo_url")

            if is_real_http_url(existing_photo_url):
                final_photo_url = existing_photo_url
                real_urls_used += 1
            else:
                final_photo_url = f"/assets/players/{entity_id}.png"
                fallback_urls_used += 1

            with conn.cursor() as cur:
                cur.execute("""
                    UPDATE public.players
                    SET photo_url = %s
                    WHERE id = %s
                """, (
                    final_photo_url,
                    entity_id
                ))

                cur.execute("""
                    UPDATE ops.media_asset_enrichment_queue
                    SET
                        status = 'done',
                        downloaded_url = %s,
                        updated_at = NOW()
                    WHERE id = %s
                """, (
                    final_photo_url,
                    queue_id
                ))

            players_updated += 1

        # =================================================
        # TEAM LOGO
        # =================================================

        elif entity_type == "team":

            with conn.cursor(cursor_factory=RealDictCursor) as lookup_cur:
                lookup_cur.execute("""
                    SELECT
                        logo_url
                    FROM public.teams
                    WHERE id = %s
                """, (entity_id,))
                team_row = lookup_cur.fetchone()

            existing_logo_url = None

            if team_row:
                existing_logo_url = team_row.get("logo_url")

            if is_real_http_url(existing_logo_url):
                final_logo_url = existing_logo_url
                real_urls_used += 1
            else:
                final_logo_url = f"/assets/teams/{entity_id}.png"
                fallback_urls_used += 1

            with conn.cursor() as cur:
                cur.execute("""
                    UPDATE public.teams
                    SET logo_url = %s
                    WHERE id = %s
                """, (
                    final_logo_url,
                    entity_id
                ))

                cur.execute("""
                    UPDATE ops.media_asset_enrichment_queue
                    SET
                        status = 'done',
                        downloaded_url = %s,
                        updated_at = NOW()
                    WHERE id = %s
                """, (
                    final_logo_url,
                    queue_id
                ))

            teams_updated += 1

        # =================================================
        # LEAGUE LOGO
        # =================================================

        elif entity_type == "league":

            with conn.cursor(cursor_factory=RealDictCursor) as lookup_cur:
                lookup_cur.execute("""
                    SELECT
                        logo_url
                    FROM public.leagues
                    WHERE id = %s
                """, (entity_id,))
                league_row = lookup_cur.fetchone()

            existing_logo_url = None

            if league_row:
                existing_logo_url = league_row.get("logo_url")

            if is_real_http_url(existing_logo_url):
                final_logo_url = existing_logo_url
                real_urls_used += 1
            else:
                final_logo_url = f"/assets/leagues/{entity_id}.png"
                fallback_urls_used += 1

            with conn.cursor() as cur:
                cur.execute("""
                    UPDATE public.leagues
                    SET logo_url = %s
                    WHERE id = %s
                """, (
                    final_logo_url,
                    entity_id
                ))

                cur.execute("""
                    UPDATE ops.media_asset_enrichment_queue
                    SET
                        status = 'done',
                        downloaded_url = %s,
                        updated_at = NOW()
                    WHERE id = %s
                """, (
                    final_logo_url,
                    queue_id
                ))

            leagues_updated += 1

        else:
            with conn.cursor() as cur:
                cur.execute("""
                    UPDATE ops.media_asset_enrichment_queue
                    SET
                        status = 'error',
                        error_message = %s,
                        retry_count = retry_count + 1,
                        updated_at = NOW()
                    WHERE id = %s
                """, (
                    f"Unknown entity_type: {entity_type}",
                    queue_id
                ))

        processed += 1

    except Exception as e:

        with conn.cursor() as cur:
            cur.execute("""
                UPDATE ops.media_asset_enrichment_queue
                SET
                    status = 'error',
                    error_message = %s,
                    retry_count = retry_count + 1,
                    updated_at = NOW()
                WHERE id = %s
            """, (
                str(e),
                queue_id
            ))


# =========================================================
# DONE
# =========================================================

print("=" * 60)
print("MATCHMATRIX MEDIA ASSET ENRICHMENT ENGINE V1.1")
print("=" * 60)
print(f"QUEUE PROCESSED  : {processed}")
print(f"PLAYERS UPDATED  : {players_updated}")
print(f"TEAMS UPDATED    : {teams_updated}")
print(f"LEAGUES UPDATED  : {leagues_updated}")
print(f"REAL URLS USED   : {real_urls_used}")
print(f"FALLBACKS USED   : {fallback_urls_used}")
print("=" * 60)

conn.close()