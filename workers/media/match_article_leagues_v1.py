import psycopg
from psycopg.rows import dict_row

DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)

# FIXED LEAGUE IDS
# -----------------------------
# NHL            -> 22390
# NBA            -> 23344
# LaLiga         -> 20859
# Bundesliga     -> 20856
# Premier League -> 20855
# UEFA           -> 20969

LEAGUE_ID_MAP = {
    "NHL": 22390,
    "NBA": 23344,
    "LaLiga": 20859,
    "Bundesliga": 20856,
    "Premier League": 20855,
    "UEFA": 20969
}


def detect_league(row):

    source_name = row.get("source_name") or ""
    article_url = row.get("url") or ""

    # SOURCE NAME FIRST
    if source_name in LEAGUE_ID_MAP:
        return source_name

    # URL FALLBACKS
    url_lower = article_url.lower()

    if "nba.com" in url_lower:
        return "NBA"

    if "nhl.com" in url_lower:
        return "NHL"

    if "laliga.com" in url_lower:
        return "LaLiga"

    if "bundesliga.com" in url_lower:
        return "Bundesliga"

    if "premierleague.com" in url_lower:
        return "Premier League"

    if "uefa.com" in url_lower:
        return "UEFA"

    return None


def main():

    print("MATCHMATRIX ARTICLE LEAGUE MATCHER V2")
    print("=" * 80)

    conn = psycopg.connect(DB_DSN, row_factory=dict_row)

    inserted = 0
    skipped = 0
    missing_league = 0
    duplicates = 0

    with conn.cursor() as cur:

        cur.execute("""
            SELECT
                a.id,
                a.url,
                cs.name AS source_name
            FROM public.articles a
            LEFT JOIN public.content_sources cs
                ON cs.id = a.content_source_id
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.article_league_map alm
                WHERE alm.article_id = a.id
            )
            ORDER BY a.id
        """)

        rows = cur.fetchall()

        print(f"PENDING: {len(rows)}")
        print("=" * 80)

        for row in rows:

            article_id = row["id"]

            detected_league = detect_league(row)

            if not detected_league:
                skipped += 1

                print(
                    f"SKIPPED: article={article_id} "
                    f"(league not detected)"
                )

                continue

            league_id = LEAGUE_ID_MAP.get(detected_league)

            if not league_id:

                missing_league += 1

                print(
                    f"LEAGUE ID MISSING: "
                    f"{detected_league}"
                )

                continue

            cur.execute("""
                INSERT INTO public.article_league_map (
                    article_id,
                    league_id
                )
                VALUES (%s, %s)
                ON CONFLICT DO NOTHING
            """, (
                article_id,
                league_id
            ))

            if cur.rowcount == 0:

                duplicates += 1

                print(
                    f"DUPLICATE: article={article_id}"
                )

                continue

            inserted += 1

            print(
                f"MAPPED: article={article_id} "
                f"-> league={detected_league} "
                f"(id={league_id})"
            )

        conn.commit()

    conn.close()

    print("=" * 80)
    print("DONE")
    print("=" * 80)
    print(f"INSERTED       : {inserted}")
    print(f"SKIPPED        : {skipped}")
    print(f"MISSING LEAGUE : {missing_league}")
    print(f"DUPLICATES     : {duplicates}")


if __name__ == "__main__":
    main()