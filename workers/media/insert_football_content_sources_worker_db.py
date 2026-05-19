import psycopg

DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)

rows = [
    ("Premier League", "official_site", "https://www.premierleague.com/news", "en", "GB", True, True),
    ("LaLiga", "official_site", "https://www.laliga.com/en-GB/news", "en", "ES", True, True),
    ("Bundesliga", "official_site", "https://www.bundesliga.com/en/bundesliga/news", "en", "DE", True, True),
    ("Serie A", "official_site", "https://www.legaseriea.it/en/media/serie-a", "en", "IT", True, True),
    ("Ligue 1", "official_site", "https://www.ligue1.com/news", "en", "FR", True, True),
]

conn = psycopg.connect(DB_DSN)
conn.autocommit = True

for row in rows:
    conn.execute(
        """
        INSERT INTO public.content_sources (
            name,
            source_type,
            base_url,
            language_code,
            country_code,
            is_official,
            is_active,
            notes
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, 'Football official site news source.')
        ON CONFLICT DO NOTHING;
        """,
        row,
    )

check = conn.execute("""
    SELECT id, name, source_type, is_active, base_url
    FROM public.content_sources
    WHERE is_active = true
      AND source_type = 'official_site'
    ORDER BY id;
""").fetchall()

print("ROWS:", len(check))
for r in check:
    print(r)

conn.close()