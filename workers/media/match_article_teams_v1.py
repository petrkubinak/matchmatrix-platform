import os
import re
import psycopg

from pathlib import Path
from dotenv import load_dotenv
from psycopg.rows import dict_row

ENV_PATH = Path("C:/MatchMatrix-platform/.env")

load_dotenv(dotenv_path=ENV_PATH)

DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)

print("DB_DSN =", DB_DSN)

TEAM_PATTERNS = [
    ("Lakers", "lakers"),
    ("Warriors", "warriors"),
    ("Cavaliers", "cavaliers"),
    ("Knicks", "knicks"),
    ("76ers", "76ers"),
    ("Timberwolves", "timberwolves"),
    ("Spurs", "spurs"),
    ("Thunder", "thunder"),
    ("Canadiens", "canadiens"),
    ("Sabres", "sabres"),
    ("Avalanche", "avalanche"),
    ("Wild", "wild"),
    ("Golden Knights", "golden knights"),
    ("Ducks", "ducks"),
]

def normalize(text):
    if not text:
        return ""
    return re.sub(r"[^a-z0-9 ]", " ", text.lower())

def main():

    print("MATCHMATRIX ARTICLE TEAM MATCHER V1")
    print("=" * 80)

    conn = psycopg.connect(DB_DSN, row_factory=dict_row)

    with conn.cursor() as cur:

        cur.execute("""
            SELECT
                a.id,
                a.title,
                a.url
            FROM public.articles a
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.article_team_map atm
                WHERE atm.article_id = a.id
            )
            ORDER BY a.id
        """)

        rows = cur.fetchall()

        print(f"PENDING: {len(rows)}")
        print("=" * 80)

        inserted = 0
        skipped = 0

        for row in rows:

            article_id = row["id"]

            text = normalize(
                f"{row.get('title') or ''} "
                f"{row.get('url') or ''}"
            )

            matched_any = False

            for display_name, alias in TEAM_PATTERNS:

                if alias.lower() not in text:
                    continue

                cur.execute("""
                    SELECT team_id
                    FROM public.team_aliases
                    WHERE LOWER(alias) = LOWER(%s)
                    LIMIT 1
                """, (alias,))

                team_row = cur.fetchone()

                if not team_row:
                    print(f"TEAM NOT FOUND: {alias}")
                    skipped += 1
                    continue

                team_id = team_row["team_id"]

                cur.execute("""
                    SELECT 1
                    FROM public.article_team_map
                    WHERE article_id = %s
                      AND team_id = %s
                """, (article_id, team_id))

                exists = cur.fetchone()

                if exists:
                    continue

                cur.execute("""
                    INSERT INTO public.article_team_map (
                        article_id,
                        team_id
                    )
                    VALUES (%s, %s)
                """, (
                    article_id,
                    team_id
                ))

                conn.commit()

                matched_any = True
                inserted += 1

                print(
                    f"MAPPED: article={article_id} "
                    f"-> team={display_name} "
                    f"(id={team_id})"
                )

            if not matched_any:
                skipped += 1

    conn.close()

    print("=" * 80)
    print("DONE")
    print("=" * 80)
    print(f"INSERTED: {inserted}")
    print(f"SKIPPED : {skipped}")

if __name__ == "__main__":
    main()