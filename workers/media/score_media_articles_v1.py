# ============================================================
# score_media_articles_v1.py
# MATCHMATRIX MEDIA ARTICLE SCORER V1
# ============================================================

from __future__ import annotations

import psycopg


DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)


# ============================================================
# LOAD ARTICLES
# ============================================================

def load_articles(conn):

    sql = """
    SELECT
        id,
        COALESCE(author_name, ''),
        COALESCE(summary, ''),
        COALESCE(raw_text, ''),
        COALESCE(title, '')
    FROM public.articles
    ORDER BY id DESC
    LIMIT 500
    """

    return conn.execute(sql).fetchall()


# ============================================================
# ENTITY COUNTS
# ============================================================

def get_entity_count(conn, article_id):

    sql = """
    SELECT
    (
        COALESCE(
            (SELECT COUNT(*) FROM public.article_team_map
             WHERE article_id = %s), 0
        )
        +
        COALESCE(
            (SELECT COUNT(*) FROM public.article_league_map
             WHERE article_id = %s), 0
        )
        +
        COALESCE(
            (SELECT COUNT(*) FROM public.article_player_map
             WHERE article_id = %s), 0
        )
    )
    """

    row = conn.execute(
        sql,
        (
            article_id,
            article_id,
            article_id,
        ),
    ).fetchone()

    return row[0] or 0


# ============================================================
# SCORING
# ============================================================

def calculate_score(
    has_author,
    has_summary,
    has_raw_text,
    playoff_related,
    entity_count,
):

    score = 0

    if has_author:
        score += 10

    if has_summary:
        score += 20

    if has_raw_text:
        score += 30

    if playoff_related:
        score += 25

    score += entity_count * 5

    return float(score)


# ============================================================
# UPDATE
# ============================================================

def update_article_score(
    conn,
    article_id,
    entity_count,
    quality_score,
    has_author,
    has_summary,
    has_raw_text,
    playoff_related,
):

    sql = """
    UPDATE public.articles
    SET
        entity_count = %s,
        quality_score = %s,
        has_author = %s,
        has_summary = %s,
        has_raw_text = %s,
        playoff_related = %s,
        updated_at = now()
    WHERE id = %s
    """

    conn.execute(
        sql,
        (
            entity_count,
            quality_score,
            has_author,
            has_summary,
            has_raw_text,
            playoff_related,
            article_id,
        ),
    )


# ============================================================
# MAIN
# ============================================================

def main():

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    articles = load_articles(conn)

    print("=" * 80)
    print("MATCHMATRIX MEDIA ARTICLE SCORER V1")
    print("=" * 80)
    print(f"ARTICLES: {len(articles)}")
    print("=" * 80)

    updated = 0

    for article in articles:

        article_id = article[0]

        author_name = article[1]
        summary = article[2]
        raw_text = article[3]
        title = article[4]

        has_author = bool(author_name.strip())
        has_summary = bool(summary.strip())
        has_raw_text = bool(raw_text.strip())

        article_text = f"{title} {summary} {raw_text}".lower()

        playoff_related = (
            "playoff" in article_text
            or "stanley cup" in article_text
        )

        entity_count = get_entity_count(
            conn,
            article_id,
        )

        quality_score = calculate_score(
            has_author,
            has_summary,
            has_raw_text,
            playoff_related,
            entity_count,
        )

        update_article_score(
            conn,
            article_id,
            entity_count,
            quality_score,
            has_author,
            has_summary,
            has_raw_text,
            playoff_related,
        )

        updated += 1

        print(
            f"SCORED: article_id={article_id} "
            f"score={quality_score} "
            f"entities={entity_count}"
        )

    print("\n" + "=" * 80)
    print("DONE")
    print("=" * 80)
    print(f"UPDATED: {updated}")
    print("=" * 80)

    conn.close()


if __name__ == "__main__":
    main()