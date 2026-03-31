import os
import psycopg2

dsn = os.environ.get("DB_DSN")
print("DB_DSN =", dsn)

conn = psycopg2.connect(dsn)
cur = conn.cursor()

cur.execute("select count(*) from public.teams")
print("teams =", cur.fetchone()[0])

cur.execute("select count(*) from public.team_provider_map where provider = 'theodds'")
print("theodds provider_map =", cur.fetchone()[0])

cur.execute("select count(*) from public.team_aliases where source = 'theodds'")
print("theodds aliases =", cur.fetchone()[0])

conn.close()