# MatchMatrix – Players pipeline audit → rozšíření ingestu hráčů

## Co je připraveno

Připravil jsem 3 soubory:

1. `036_ops_extend_stg_provider_players.sql`
2. `run_players_bridge_v2.py`
3. `sql_players_pipeline_audit_queries.sql`

Vyšlo jsem z aktuálního stavu databáze, kde:

- `staging.players_import` už obsahuje rozšířená pole jako `first_name`, `last_name`, `height_cm`, `weight_kg`, `preferred_foot`, `position_code`, `provider_league_id`, `provider_team_id`, `season`, `league_name`, `source_endpoint`.
- `staging.stg_provider_players` je proti tomu dnes úzká tabulka a drží jen základní pole.
- `public.players` už naopak některá rozšířená pole podporuje (`first_name`, `last_name`, `short_name`, `position`, `height_cm`, `weight_kg`, `ext_source`, `ext_player_id`).

To potvrzuje, že hlavní problém je ztráta atributů mezi `players_import` a `stg_provider_players`, ne pouze merge vrstva. fileciteturn4file0 fileciteturn4file8

---

## Kam soubory uložit

### 1) SQL migrace
Ulož jako:

`C:\MatchMatrix-platform\db\migrations\036_ops_extend_stg_provider_players.sql`

### 2) Bridge worker
Ulož jako:

`C:\MatchMatrix-platform\workers\run_players_bridge_v2.py`

### 3) Audit query script
Ulož jako:

`C:\MatchMatrix-platform\db\ad_hoc\sql_players_pipeline_audit_queries.sql`

---

## Co udělat v pořadí

### Krok 1 – aplikace migrace
Spusť v Docker Postgres kontejneru:

```bash
docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix < "C:/MatchMatrix-platform/db/migrations/036_ops_extend_stg_provider_players.sql"
```

Pokud to spouštíš z PowerShellu na Windows a path mapping dělá problém, otevři si soubor v DBeaveru a spusť ho ručně.

### Krok 2 – bridge do unified staging
Spusť:

```bash
C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_players_bridge_v2.py
```

### Krok 3 – audit po bridge
Spusť audit query script:

```sql
-- obsah souboru:
C:\MatchMatrix-platform\db\ad_hoc\sql_players_pipeline_audit_queries.sql
```

---

## Co ještě chybí do úplného dokončení

Ještě není připravená úprava `run_unified_staging_to_public_merge_v3.py`, aby do `public.players` propsal nová pole.

Doporučené mapování:

- `stg_provider_players.player_name -> public.players.name`
- `stg_provider_players.first_name -> public.players.first_name`
- `stg_provider_players.last_name -> public.players.last_name`
- `stg_provider_players.short_name -> public.players.short_name`
- `stg_provider_players.position_code -> public.players.position`
- `stg_provider_players.height_cm -> public.players.height_cm`
- `stg_provider_players.weight_kg -> public.players.weight_kg`
- `provider -> public.players.ext_source`
- `external_player_id -> public.players.ext_player_id`

A map tabulka `public.player_provider_map` už na to má unikátní index nad `(provider, provider_player_id)`. `staging.stg_provider_players` má také unikátní index nad `(provider, external_player_id)`. fileciteturn4file13

---

## Důležitá poznámka k source ingestu

Aktuálně je stále root cause i v source ingestu, protože poslední známé počty jsou jen cca:

- `staging.players_import = 480`
- `staging.stg_provider_players = 475`
- `public.players = 475`

To znamená, že i po rozšíření schema + bridge je potřeba ještě zkontrolovat `pull_api_football_players.ps1`, hlavně:

- zda stahuje všechny plánované ligy,
- zda stahuje všechny sezóny,
- zda stránkuje,
- zda ukládá celé `raw_json`,
- zda plní `provider_league_id`, `provider_team_id`, `season`, `league_name`, `source_endpoint`.

Tyto nízké počty jsou zdokumentované v pracovním zápisu. fileciteturn4file3turn4file10

---

## Doporučený další krok

Po nasazení těchto tří souborů navazuje:

1. patch `run_unified_staging_to_public_merge_v3.py`
2. audit `pull_api_football_players.ps1`
3. zařazení entity `players` jako standardního planner jobu v `ops.ingest_planner`

Podle dokumentace je `ops.ingest_planner` už navržený pro entity `provider`, `sport_code`, `entity`, `provider_league_id`, `season`, `run_group`, `priority`, `status`, takže players do této architektury přirozeně zapadnou. fileciteturn4file6turn4file7
