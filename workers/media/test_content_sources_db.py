import psycopg

DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)

conn = psycopg.connect(DB_DSN)

rows = conn.execute("""
    SELECT
        id,
        name,
        source_type,
        is_active,
        base_url
    FROM public.content_sources
    WHERE is_active = true
      AND source_type = 'official_site'
    ORDER BY id;
""").fetchall()

print("ROWS:", len(rows))

for row in rows:
    print(row)

conn.close()