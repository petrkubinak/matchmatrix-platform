# TicketMatrix / MatchMatrix -- Backend napojení (stav)

**Datum:** 2026-03-05\
**Projekt:** TicketMatrix (frontend) + MatchMatrix (DB)

------------------------------------------------------------------------

# 1. Architektura

## Frontend

TicketMatrix (Next.js 16)\
Path: `C:\MatchMatrix-platform\fronted\matchmatrix-web`\
Port: **3000**

## Backend

Next.js API routes\
`/app/api/*`

## Databáze

PostgreSQL (Docker)

Container: - `matchmatrix_postgres` - `matchmatrix_redis`

DB: - `matchmatrix`

Port: - **5432**

------------------------------------------------------------------------

# 2. Docker služby

    matchmatrix_postgres   0.0.0.0:5432->5432/tcp
    matchmatrix_redis      0.0.0.0:6379->6379/tcp

------------------------------------------------------------------------

# 3. DB připojení pro web

Soubor:

    matchmatrix-web/.env.local

    DATABASE_URL=postgres://mm_web:mm_web_123@127.0.0.1:5432/matchmatrix

------------------------------------------------------------------------

# 4. Webový DB uživatel

Role vytvořená pro frontend:

    mm_web
    password: mm_web_123

Práva:

    CONNECT ON DATABASE matchmatrix
    USAGE ON SCHEMA public
    SELECT ON ALL TABLES
    ALTER DEFAULT PRIVILEGES SELECT

Používá se pouze pro **read‑only API dotazy**.

------------------------------------------------------------------------

# 5. DB helper

Soubor:

    app/lib/db.ts

``` ts
import { Pool } from "pg";

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});
```

------------------------------------------------------------------------

# 6. API endpointy

## Health check

    /api/health/db

Vrací:

``` json
{
  "user": "mm_web",
  "db": "matchmatrix"
}
```

------------------------------------------------------------------------

## Matches today

    /api/matches/today

Příklad odpovědi:

``` json
{
  "items": [
    {
      "match_id": 63044,
      "home_team_name": "Tottenham Hotspur FC",
      "away_team_name": "Crystal Palace FC",
      "league_name": "Premier League",
      "kickoff_at_local": "2026-03-05T19:00:00.000Z"
    }
  ]
}
```

------------------------------------------------------------------------

# 7. Datové zdroje

Views používané API:

    public.v_fd_matches_today
    public.v_fd_matches_tomorrow
    public.v_fd_matches_week
    public.v_fd_leagues_active_week

Data pochází z ingestu:

    football_data_pull_V5.py

------------------------------------------------------------------------

# 8. Opravené problémy během setupu

## ENV konflikt

Windows měl nastavené:

    DATABASE_URL=postgresql://postgres:postgres@localhost:5432/postgres

→ přepisovalo `.env.local`

Vyřešeno:

    [Environment]::SetEnvironmentVariable("DATABASE_URL",$null,"User")

------------------------------------------------------------------------

## DB autentizace

User `matchmatrix` neměl správné heslo pro host připojení.

Vyřešeno vytvořením read‑only role:

    mm_web

------------------------------------------------------------------------

# 9. Stav projektu

✔ Next.js server běží\
✔ DB připojení funguje\
✔ API endpointy vrací data\
✔ Gemini frontend může volat API

------------------------------------------------------------------------

# 10. Další kroky

1.  sjednotit API response

```{=html}
<!-- -->
```
    { count, items }

2.  přidat filtr

```{=html}
<!-- -->
```
    /api/matches/week?league_id=

3.  endpoint detail zápasu

```{=html}
<!-- -->
```
    /api/matches/[match_id]

4.  UI integrace v Gemini

```{=html}
<!-- -->
```
    sidebar leagues
    matches list
    ticket builder

------------------------------------------------------------------------

# 11. Spuštění projektu

    cd C:\MatchMatrix-platform\fronted\matchmatrix-web
    npm run dev -- -p 3000

Web:

    http://localhost:3000
