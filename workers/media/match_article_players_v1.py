# =========================================================
# MATCHMATRIX
# ARTICLE PLAYER MATCHER V1.1
# =========================================================
#
# Co skript dělá:
# Propojuje články s hráči podle výskytu celého jména hráče
# v titulku a textu článku.
#
# Výstup:
# public.article_player_map
#
# Upgrade V1.1:
# - filtruje false-positive hráče typu Patrick, Peter, Nicolas
# - povoluje pouze jména minimálně ze 2 slov
# - chrání trending engine před zkreslením
#
# Web/App:
# - profil hráče
# - player news feed
# - trending players
# - AI feed
# - recommendation engine
# =========================================================

import os
import re
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


# =========================================================
# ENV / DB CONFIG
# =========================================================

load_dotenv()

DB_HOST = os.getenv("PGHOST", "localhost")
DB_PORT = os.getenv("PGPORT", "5432")
DB_NAME = os.getenv("PGDATABASE", "matchmatrix")
DB_USER = os.getenv("PGUSER", "matchmatrix")
DB_PASS = os.getenv("PGPASSWORD", "matchmatrix_pass")


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
# LOAD PLAYERS
# =========================================================

print("LOADING PLAYERS...")

with conn.cursor(cursor_factory=RealDictCursor) as cur:
    cur.execute("""
        SELECT
            id,
            name
        FROM public.players
        WHERE name IS NOT NULL
    """)
    players = cur.fetchall()

print(f"PLAYERS LOADED: {len(players)}")


# =========================================================
# LOAD ARTICLES
# =========================================================

print("LOADING ARTICLES...")

with conn.cursor(cursor_factory=RealDictCursor) as cur:
    cur.execute("""
        SELECT
            id,
            title,
            raw_text
        FROM public.articles
        WHERE raw_text IS NOT NULL
    """)
    articles = cur.fetchall()

print(f"ARTICLES LOADED: {len(articles)}")


# =========================================================
# MATCHING
# =========================================================

matches_inserted = 0
players_skipped_quality = 0

for article in articles:
    article_id = article["id"]

    title = article.get("title") or ""
    raw_text = article.get("raw_text") or ""

    full_text = f"{title} {raw_text}".lower()

    for player in players:
        player_id = player["id"]
        player_name = player["name"]

        if not player_name:
            continue

        normalized_player = player_name.lower().strip()

        # =====================================================
        # QUALITY FILTER V1.1
        # =====================================================
        # Cíl:
        # - vyhodit false-positive jména typu Patrick, Peter,
        #   Richard, Nicolas, Julian, Vladimir
        # - povolit jen celé jméno typu Connor McDavid
        # =====================================================

        name_parts = normalized_player.split()

        if len(name_parts) < 2:
            players_skipped_quality += 1
            continue

        if len(normalized_player) < 8:
            players_skipped_quality += 1
            continue

        # =====================================================
        # SIMPLE EXACT FULL NAME MATCH
        # =====================================================

        pattern = r"\b" + re.escape(normalized_player) + r"\b"

        if re.search(pattern, full_text):
            relevance_score = 100

            with conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO public.article_player_map
                    (
                        article_id,
                        player_id,
                        match_type,
                        match_source,
                        matched_text,
                        relevance_score,
                        is_primary_match
                    )
                    VALUES
                    (
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s
                    )
                    ON CONFLICT (article_id, player_id)
                    DO NOTHING
                """, (
                    article_id,
                    player_id,
                    "exact_full_name",
                    "player_name_quality_v1_1",
                    player_name,
                    relevance_score,
                    True
                ))

            matches_inserted += 1

            print(
                f"MATCH: ARTICLE={article_id} "
                f"PLAYER={player_name}"
            )


# =========================================================
# DONE
# =========================================================

print("=" * 60)
print("MATCHMATRIX ARTICLE PLAYER MATCHER V1.1")
print("=" * 60)
print(f"MATCHES INSERTED: {matches_inserted}")
print(f"PLAYERS SKIPPED BY QUALITY FILTER: {players_skipped_quality}")
print("=" * 60)

conn.close()