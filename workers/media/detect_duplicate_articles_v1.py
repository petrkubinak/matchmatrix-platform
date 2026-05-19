# ============================================================
# detect_duplicate_articles_v1.py
# MATCHMATRIX MEDIA DUPLICATE DETECTOR V1
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


SQL = """
SELECT
    LOWER(TRIM(title)) AS normalized_title,
    COUNT(*) AS duplicate_count,
    array_agg(id ORDER BY id DESC) AS article_ids
FROM public.articles
WHERE title IS NOT NULL
GROUP BY LOWER(TRIM(title))
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, normalized_title;
"""


def main():

    conn = psycopg.connect(DB_DSN)

    rows = conn.execute(SQL).fetchall()

    print("=" * 80)
    print("MATCHMATRIX MEDIA DUPLICATE DETECTOR V1")
    print("=" * 80)
    print(f"DUPLICATE GROUPS: {len(rows)}")
    print("=" * 80)

    for row in rows:

        title = row[0]
        count = row[1]
        article_ids = row[2]

        print()
        print(f"DUPLICATES: {count}")
        print(f"TITLE     : {title}")
        print(f"ARTICLE IDS: {article_ids}")

    print("\n" + "=" * 80)
    print("DONE")
    print("=" * 80)

    conn.close()


if __name__ == "__main__":
    main()
