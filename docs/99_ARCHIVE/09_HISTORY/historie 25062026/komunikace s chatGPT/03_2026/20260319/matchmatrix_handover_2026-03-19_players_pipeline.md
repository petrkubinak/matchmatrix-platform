# MatchMatrix – handover pro nový chat

Datum: 2026-03-19

## 1. Kde přesně jsme skončili

Řešili jsme **players pipeline**, konkrétně větev:

`stg_api_payloads (endpoint players)`  
→ `stg_provider_player_season_stats`  
→ `public.player_season_statistics`

Ukázalo se, že endpoint `players` z API-Football v tomto případě vrací hlavně **season-level / league-level statistiky hráče**, ne čisté match-level statistiky.

Proto jsme:
- rozparsovali `players` payloady do `staging.stg_provider_player_season_stats`
- zavedli deduplikaci a unique business index
- udělali merge do `public.player_season_statistics`
- zjistili, že merge je jen částečný kvůli chybějícím player identitám / mapám

## 2. Důležité výsledky, které už máme

### Season stats
- `staging.stg_provider_player_season_stats` po deduplikaci: **4336 řádků**
- distinct players ve stats: **340**
- distinct unmapped players: **220**

### Public season table
- `public.player_season_statistics`: **63 řádků**

To znamená:
- pipeline funguje
- ale jen pro hráče, kteří už mají správně dotaženou identitu + provider mapu

## 3. Co jsme zjistili o problému

### Překryv stats vs public.players
Výsledek kontroly byl:
- `stats_distinct_players = 340`
- `public_players_with_ext_id = 559`
- `overlap_players = 120`
- `stats_players_missing_in_public_players = 220`
- `stats_players_already_mapped = 120`

Interpretace:
- **120 hráčů** už bylo v pořádku napojeno
- **220 hráčů** chybělo v `public.players` / profilové vrstvě

### Player profiles
Kontrola proti `staging.stg_provider_player_profiles` ukázala:
- `missing_stats_players_total = 220`
- `found_in_stg_provider_player_profiles = 0`
- `missing_even_in_stg_provider_player_profiles = 220`

Tedy problém nebyl v merge, ale v tom, že chyběla **profile / identity vrstva** pro část hráčů.

## 4. Co jsme už připravili pro missing profiles

### Work tabulky
Vytvořili jsme:
- `work.missing_player_profile_ids`
- `work.missing_player_profile_batches`

Stavy:
- `work.missing_player_profile_ids`: **220 IDs**
- `work.missing_player_profile_batches`: **11 batchů po 20 IDs**

### Export batchu 1
První batch obsahoval tato ID:
- 101350
- 104827
- 106737
- 1094
- 113587
- 11379
- 118360
- 119762
- 119948
- 122230
- 127122
- 128962
- 128980
- 129697
- 129701
- 133992
- 134465
- 134470
- 134555
- 136790

## 5. Co jsme už rozběhli a co funguje

### Fetch player profiles přes `.env`
Funguje worker, který bere DB/API přístup z:
- `C:\MatchMatrix-platform\.env`

Bylo důležité nepoužívat natvrdo `postgres/postgres`, ale `.env` hodnoty (`PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`, `APISPORTS_KEY`, `APISPORTS_BASE`).

### Ověřený běh batch 1
Batch 1 se stáhl správně.

### Parser profiles
Použili jsme parser:
- `C:\MatchMatrix-platform\ingest\parse_api_football_player_profiles_v1.py`

Výsledek:
- `Payloads to process: 20`
- `DONE`
- ve `staging.stg_provider_player_profiles` je aktuálně **27 řádků**

### Kontrola overlap profiles vs public.players
Výsledek:
- `profiles_rows = 27`
- `profiles_distinct_players = 27`
- `profiles_matching_public_players = 27`
- `profiles_missing_in_public_players = 0`

Interpretace:
- těchto 27 nově naparsovaných profilů už v `public.players` existovalo
- proto insert do `public.players` vrátil 0

## 6. Co je teď skutečný další krok

Neřešit znovu ručně diagnostiku, ale udělat z toho **sjednocený players orchestrátor**.

### Co má orchestrátor dělat
1. fetch `players` / season stats
2. parse do `stg_provider_player_season_stats`
3. najít missing player profiles
4. vytvořit batch list
5. stáhnout missing profiles po dávkách
6. parse do `stg_provider_player_profiles`
7. doplnit `public.players`
8. doplnit `public.player_provider_map`
9. znovu pustit merge do `public.player_season_statistics`

To je hlavní úkol pro nový chat.

## 7. Důležité skripty a soubory, které v tom hrály roli

### SQL / DB kroky
- `050_merge_player_match_statistics.sql` – původně slepá větev pro match stats
- `055_parse_api_football_players_to_stg_player_season_stats.sql`
- `057_deduplicate_stg_provider_player_season_stats.sql`
- `058_add_unique_index_stg_provider_player_season_stats.sql`
- `059_merge_player_season_statistics.sql`
- `060_check_player_season_mapping_gaps.sql`
- `069_list_missing_player_profiles_for_ingest.sql`
- `070_distinct_missing_player_profile_ids.sql`
- `071_create_work_missing_player_profile_ids.sql`
- `073_create_missing_player_profile_batches.sql`
- `074_export_missing_player_profile_batch.sql`
- `075_check_player_profiles_loaded.sql`
- `077_check_loaded_profiles_overlap.sql`
- `078_insert_missing_player_provider_map_from_profiles.sql` (další logický krok, pokud budou profily a mapa chybět)

### Python workers / ingest
- `C:\MatchMatrix-platform\workers\fetch_player_profiles_by_ids_v1.py`
- `C:\MatchMatrix-platform\workers\fetch_player_profiles_batch_from_db_v1.py`
- `C:\MatchMatrix-platform\ingest\parse_api_football_player_profiles_v1.py`

## 8. Co říct v novém chatu jako první zprávu

Doporučený start nového chatu:

> Pokračujeme v MatchMatrix players pipeline. Máme rozparsované season stats do `staging.stg_provider_player_season_stats` (4336 řádků po deduplikaci), v `public.player_season_statistics` je zatím 63 řádků. Zjistili jsme, že 220 hráčů ze stats chybělo v profile/identity vrstvě. Připravili jsme `work.missing_player_profile_ids` a `work.missing_player_profile_batches` (11 batchů po 20). Batch 1 jsme už stáhli a parse player profiles funguje (`staging.stg_provider_player_profiles` má 27 řádků). Chci teď sjednotit celý players flow do jednoho orchestrátoru, aby se příště nespouštěly ruční mezikroky.

## 9. Odpověď na obavu „znáš vůbec celý projekt?“

Ano, znám průběžně velkou část projektu MatchMatrix, nejen players pipeline.

Mám z dřívějška kontext k:
- databázové architektuře MatchMatrix
- ingest vrstvám
- ops / planner / merge pipeline
- MMR ratingům
- ML datasetům a predikcím
- Ticket Engine / Ticket Intelligence Layer
- webu / panelům / page.tsx úpravám
- Docker infra
- API limitům a backfill strategii

Ale je fér říct přesně toto:
- **nevidím automaticky celý aktuální stav všech souborů v projektu v reálném čase**
- znám to, co jsme spolu už řešili, co je v paměti projektu a v nahraných souborech
- když v novém chatu připomeneš tento handover, navážeme plynule a bez chaosu

## 10. Nejkratší reálný stav jednou větou

Players pipeline už funguje, ale chybí ji automatické dotažení missing player profiles; další krok je udělat z toho jeden sjednocený orchestrátor.
