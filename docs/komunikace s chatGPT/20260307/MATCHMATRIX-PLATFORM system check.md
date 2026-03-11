Writing (temp): C:\MATCHMATRIX-PLATFORM\reports\_tmp_SYSTEM_CHECK_20260307_195947.txt
==============================
MATCHMATRIX SYSTEM CHECK
==============================

[1] Docker containers
NAMES                  IMAGE         STATUS
matchmatrix_postgres   postgres:16   Up 12 hours
matchmatrix_redis      redis:7       Up 12 hours

[2] Docker compose status (optional
no configuration file provided: not found

[3] Postgres quick check (inside container)
psql: warning: extra command-line argument "2>&1" ignored
            db_time            |                                                      pg_version                        
-------------------------------+----------------------------------------------------------------------------------------------------------------------
 2026-03-07 18:59:48.059737+00 | PostgreSQL 16.11 (Debian 16.11-1.pgdg13+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
(1 row)


[4] Ops health (job_runs + targets)
psql: warning: extra command-line argument "2>&1" ignored
 id |    job_code     | status  |          started_at           |          finished_at
----+-----------------+---------+-------------------------------+-------------------------------
 38 | ingest_fixtures | success | 2026-03-06 14:01:42.579953+00 | 2026-03-06 14:02:54.242847+00
 37 | ingest_fixtures | success | 2026-03-06 07:05:40.495997+00 | 2026-03-06 08:35:00.615661+00
 36 | ingest_fixtures | failed  | 2026-03-05 20:38:54.276971+00 | 2026-03-06 07:05:40.038445+00
 35 | ingest_fixtures | failed  | 2026-03-05 20:37:23.592941+00 | 2026-03-05 20:37:24.248751+00
 34 | ingest_fixtures | success | 2026-03-04 08:50:37.846173+00 | 2026-03-04 10:57:53.210132+00
 33 | ingest_fixtures | failed  | 2026-03-04 05:22:22.048351+00 | 2026-03-04 07:18:19.961321+00
 32 | ingest_fixtures | success | 2026-03-03 22:00:53.920184+00 | 2026-03-03 23:29:14.310307+00
 31 | ingest_fixtures | failed  | 2026-03-03 21:35:52.7503+00   | 2026-03-03 21:58:42.262618+00
 30 | ingest_fixtures | failed  | 2026-03-03 21:24:11.557854+00 | 2026-03-03 21:24:12.143094+00
 29 | ingest_teams    | success | 2026-03-02 12:18:51.166925+00 | 2026-03-02 12:22:54.247376+00
 28 | ingest_fixtures | success | 2026-03-02 10:49:26.731291+00 | 2026-03-02 12:15:46.314385+00
 27 | ingest_fixtures | success | 2026-03-02 08:20:53.757507+00 | 2026-03-02 08:38:15.976321+00
 26 | ingest_fixtures | failed  | 2026-03-01 21:06:35.438043+00 | 2026-03-02 08:20:53.277188+00
 25 | ingest_fixtures | success | 2026-03-01 20:18:20.832956+00 | 2026-03-01 20:36:56.538667+00
 24 | ingest_fixtures | success | 2026-02-28 20:39:20.371312+00 | 2026-02-28 21:12:52.622323+00
(15 rows)


psql: warning: extra command-line argument "2>&1" ignored
   provider   |  run_group  | cnt
--------------+-------------+-----
 api_football | EU_exact_v1 |  88
 api_football | EU_top      |  12
(2 rows)


[5] Redis ping
2>&1

Systém nemůže nalézt uvedený soubor.
Done. Open file: C:\MATCHMATRIX-PLATFORM\reports\2026-03-07_SYSTEM_CHECK_20260307_195947.txt
Press any key to continue . . .