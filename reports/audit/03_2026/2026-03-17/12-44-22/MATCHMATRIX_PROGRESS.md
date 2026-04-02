# MatchMatrix – denní přehled vývoje

Datum: 17.03.2026  
Čas kontroly systému: 12:44

---

## 1. Co je MatchMatrix

MatchMatrix je datová a analytická platforma pro sportovní data.
Systém sbírá data ze zdrojů, ukládá je do databáze, připravuje statistiky
a vytváří podklady pro budoucí predikce a inteligentní práci s tikety.

---

## 2. Co se dnes zkontrolovalo

Byl zkontrolován projekt v těchto částech:

- Celý projekt
- Workers
- Ingest
- API-Football
- Scripts
- Dump
- DB
- Docs

Celkem bylo projito 793 sledovaných souborů.

Ve srovnání s minulým auditem:
- bylo přidáno 793 nových souborů


---

## 3. Stav databáze

Databázový audit se nepodařilo načíst.

Důvod:
column "provider" does not exist
LINE 2:     select coalesce(provider,'?') as provider,
                            ^


To znamená, že panel momentálně nevidí do PostgreSQL a je potřeba
zkontrolovat připojení nebo běh kontejneru s databází.


---

## 4. Stav systému a repozitáře

Git větev:
- main

Poslední commit:
- ca41518 | 2026-03-17 10:32:39 +0100 | MatchMatrix ingest + players pipeline updates

Aktuální neuložené změny:
- M MatchMatrix-platform/.dbeaver/.project-metadata.json.bak
-  M MatchMatrix-platform/.dbeaver/project-metadata.json
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202602272251_leagues.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202602282349.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202603012240.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202603020927.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202603022246.sql
-  D MatchMatrix-platform/Dump/dump-matchmatrix-202603091608.sql

Pokud zde vidíš změny, které mají zůstat, je dobré je po práci uložit do Git a GitHub.

---

## 5. Kam jsme se dnes posunuli

Na základě dnešního auditu je vidět, že projekt má:
- funkční kontrolu souborů
- přehled o změnách proti minulému běhu
- kontrolu Git stavu

- připravený databázový audit, ale je potřeba opravit připojení


Hlavní změněné soubory dnes:
- backups\postgres_dumps\dump-matchmatrix-202602131248.sql
- db\audit\079_audit_player_season_statistics_report_v1.sql
- db\audit\080_debug_player_stats_merge_mapping_v1.sql
- db\audit\cleanup_player_season_stats_scope_95_2024_v1.sql
- db\checks\001_daily_ingest_healthcheck.sql
- db\checks\011_check_new_core_tables.sql
- db\checks\013_check_players_coverage.sql
- db\checks\MATCHMATRIX_DAILY_STATUS.sql

---

## 6. V čem budeme pokračovat

Doporučené další kroky:
- opravit připojení panelu k databázi
- po opravě znovu spustit FULL audit
- ověřit OPS tabulky a stav planneru

---

## 7. Doporučení před ukončením práce

Nezapomenout:
- zkontrolovat změněné soubory
- uložit důležité skripty
- vytvořit Git commit
- poslat změny na GitHub

Doporučené příkazy:
git add .
git commit -m "MatchMatrix update"
git push
