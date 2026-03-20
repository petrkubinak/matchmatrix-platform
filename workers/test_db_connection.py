import os
import psycopg2

conn = psycopg2.connect(
    host=os.getenv("PGHOST", "localhost"),
    port=os.getenv("PGPORT", "5432"),
    dbname=os.getenv("PGDATABASE", "matchmatrix"),
    user=os.getenv("PGUSER", "matchmatrix"),
    password=os.getenv("PGPASSWORD", ""),
)

with conn:
    with conn.cursor() as cur:
        cur.execute("select current_database(), current_user;")
        print(cur.fetchone())