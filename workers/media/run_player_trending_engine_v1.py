# =========================================================
# MATCHMATRIX
# PLAYER TRENDING ENGINE V1
# =========================================================
#
# Co skript dělá:
# ---------------------------------------------------------
# Počítá trending score hráčů podle:
# - počtu článků
# - media aktivity
# - relevance
#
# Zdroj:
# ---------------------------------------------------------
# public.article_player_map
# public.articles
#
# Výstup:
# ---------------------------------------------------------
# public.player_trending
#
# Kde se využije:
# ---------------------------------------------------------
# - homepage trending
# - AI feed
# - recommendation engine
# - player profile
# - breaking news
#
# Web/App:
# ---------------------------------------------------------
# Trending Players
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
# LOAD PLAYER ARTICLE DATA
# =========================================================

print("LOADING PLAYER MEDIA DATA...")

with conn.cursor(cursor_factory=RealDictCursor) as cur:

    cur.execute("""
        SELECT
            apm.player_id,
            COUNT(*) AS article_count,
            MAX(a.created_at) AS last_article_at,
            COALESCE(SUM(apm.relevance_score), 0) AS total_score
        FROM public.article_player_map apm
        JOIN public.articles a
            ON a.id = apm.article_id
        GROUP BY apm.player_id
    """)

    rows = cur.fetchall()

print(f"PLAYERS WITH MEDIA: {len(rows)}")

# =========================================================
# TRENDING CALCULATION
# =========================================================

updated = 0

for row in rows:

    player_id = row["player_id"]
    article_count = row["article_count"]
    total_score = float(row["total_score"] or 0)

    # =====================================================
    # SIMPLE TRENDING FORMULA V1
    # =====================================================

    trending_score = (
        article_count * 10
    ) + total_score

    with conn.cursor() as cur:

        cur.execute("""
            INSERT INTO public.player_trending
            (
                player_id,
                article_count,
                trending_score,
                last_article_at,
                updated_at
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                NOW()
            )
            ON CONFLICT (player_id)
            DO UPDATE SET
                article_count = EXCLUDED.article_count,
                trending_score = EXCLUDED.trending_score,
                last_article_at = EXCLUDED.last_article_at,
                updated_at = NOW()
        """, (
            player_id,
            article_count,
            trending_score,
            row["last_article_at"]
        ))

    updated += 1

# =========================================================
# TOP TRENDING
# =========================================================

print("=" * 60)
print("TOP TRENDING PLAYERS")
print("=" * 60)

with conn.cursor(cursor_factory=RealDictCursor) as cur:

    cur.execute("""
        SELECT
            pt.player_id,
            p.name,
            pt.article_count,
            pt.trending_score
        FROM public.player_trending pt
        JOIN public.players p
            ON p.id = pt.player_id
        ORDER BY pt.trending_score DESC
        LIMIT 20
    """)

    top_rows = cur.fetchall()

for row in top_rows:

    print(
        f"{row['name']} | "
        f"articles={row['article_count']} | "
        f"score={row['trending_score']}"
    )

# =========================================================
# DONE
# =========================================================

print("=" * 60)
print("MATCHMATRIX PLAYER TRENDING ENGINE V1")
print("=" * 60)
print(f"PLAYERS UPDATED: {updated}")
print("=" * 60)

conn.close()