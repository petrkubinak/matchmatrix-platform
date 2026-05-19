# =========================================================
# MATCHMATRIX
# MEDIA ASSET ENRICHMENT QUEUE BUILDER V1
# =========================================================
#
# Co skript dělá:
# ---------------------------------------------------------
# Automaticky vytváří enrichment queue pro:
# - player photos
# - team logos
# - league logos
#
# Výstup:
# ---------------------------------------------------------
# ops.media_asset_enrichment_queue
#
# K čemu to je:
# ---------------------------------------------------------
# Připravuje centrální řízenou frontu
# pro asset enrichment layer.
#
# Web/App:
# ---------------------------------------------------------
# - player cards
# - team pages
# - league pages
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
# COUNTERS
# =========================================================

players_added = 0
teams_added = 0
leagues_added = 0

# =========================================================
# PLAYERS WITHOUT PHOTO
# =========================================================

print("LOADING PLAYERS WITHOUT PHOTO...")

with conn.cursor(cursor_factory=RealDictCursor) as cur:

    cur.execute("""
        SELECT
            id
        FROM public.players
        WHERE photo_url IS NULL
        LIMIT 5000
    """)

    players = cur.fetchall()

for row in players:

    with conn.cursor() as cur:

        cur.execute("""
            INSERT INTO ops.media_asset_enrichment_queue
            (
                entity_type,
                entity_id,
                asset_type,
                provider,
                priority,
                status
            )
            VALUES
            (
                'player',
                %s,
                'photo',
                'auto_enrichment',
                100,
                'pending'
            )
            ON CONFLICT
            DO NOTHING
        """, (
            row["id"],
        ))

    players_added += 1

# =========================================================
# TEAMS WITHOUT LOGO
# =========================================================

print("LOADING TEAMS WITHOUT LOGO...")

with conn.cursor(cursor_factory=RealDictCursor) as cur:

    cur.execute("""
        SELECT
            id
        FROM public.teams
        WHERE logo_url IS NULL
        LIMIT 5000
    """)

    teams = cur.fetchall()

for row in teams:

    with conn.cursor() as cur:

        cur.execute("""
            INSERT INTO ops.media_asset_enrichment_queue
            (
                entity_type,
                entity_id,
                asset_type,
                provider,
                priority,
                status
            )
            VALUES
            (
                'team',
                %s,
                'logo',
                'auto_enrichment',
                90,
                'pending'
            )
            ON CONFLICT
            DO NOTHING
        """, (
            row["id"],
        ))

    teams_added += 1

# =========================================================
# LEAGUES WITHOUT LOGO
# =========================================================

print("LOADING LEAGUES WITHOUT LOGO...")

with conn.cursor(cursor_factory=RealDictCursor) as cur:

    cur.execute("""
        SELECT
            id
        FROM public.leagues
        WHERE logo_url IS NULL
        LIMIT 5000
    """)

    leagues = cur.fetchall()

for row in leagues:

    with conn.cursor() as cur:

        cur.execute("""
            INSERT INTO ops.media_asset_enrichment_queue
            (
                entity_type,
                entity_id,
                asset_type,
                provider,
                priority,
                status
            )
            VALUES
            (
                'league',
                %s,
                'logo',
                'auto_enrichment',
                80,
                'pending'
            )
            ON CONFLICT
            DO NOTHING
        """, (
            row["id"],
        ))

    leagues_added += 1

# =========================================================
# DONE
# =========================================================

print("=" * 60)
print("MATCHMATRIX MEDIA ASSET ENRICHMENT QUEUE BUILDER V1")
print("=" * 60)
print(f"PLAYERS ADDED : {players_added}")
print(f"TEAMS ADDED   : {teams_added}")
print(f"LEAGUES ADDED : {leagues_added}")
print("=" * 60)

conn.close()