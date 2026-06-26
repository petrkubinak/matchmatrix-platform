# MATCHMATRIX – PEOPLE LAYER MASTER ZÁPIS
Datum: 2026-05-20

---

# 1. STAV PEOPLE VRSTVY

PEOPLE vrstva již není pouze návrh nebo experiment.

Architektura PEOPLE layer byla potvrzena jako funkční:
- canonical public model funguje
- provider mapping funguje
- staging flow funguje
- merge pipeline funguje
- player statistics flow funguje
- provider audit systém funguje

Hlavní cíl další fáze:
připravit PEOPLE layer do stavu, kdy po aktivaci placených providerů poběží automatický harvesting přes scheduler/orchestrace bez nutnosti dalších zásadních architektonických změn.

---

# 2. POTVRZENÉ TABULKY

## PUBLIC

Aktuálně existují a jsou používány:

- public.players
- public.player_provider_map
- public.player_external_identity
- public.player_season_statistics
- public.player_match_statistics
- public.player_social_links
- public.player_team_history
- public.player_translations
- public.player_trending
- public.coaches
- public.coach_provider_map
- public.article_player_map

## STAGING

Aktuálně existují:

- staging.stg_provider_players
- staging.stg_provider_player_profiles
- staging.stg_provider_player_stats
- staging.stg_provider_player_season_stats
- staging.stg_provider_coaches

---

# 3. REÁLNÉ COUNTS

## PUBLIC

article_player_map:
1701

coaches:
3

coach_provider_map:
3

player_external_identity:
639

player_provider_map:
18959

players:
18959

player_season_statistics:
3121

player_trending:
406

## STAGING

stg_provider_coaches:
19

stg_provider_player_profiles:
961

stg_provider_players:
18934

stg_provider_player_season_stats:
105834

---

# 4. HLAVNÍ AUDIT ZJIŠTĚNÍ

## PLAYER MAPPING

Audit potvrdil:

- 105834 staging rows
- 105834 mapped rows
- 0 unmapped rows

To znamená:
player_provider_map funguje správně.

Neexistuje problém s canonical player mappingem.

---

# 5. SEASON STATISTICS GRAIN

Bylo potvrzeno:

105834 rows ve staging NEJSOU hotové sezonní statistiky.

Jedná se o:
stat_name / stat_value model.

Příklad:

- goals
- assists
- appearances
- minutes_played
- rating
- tackles_total

Každý stat je samostatný řádek.

---

# 6. UNIQUE PLAYER SEASON GRAIN

Audit potvrdil:

- 3414 unique player-season-team combinations
- 3121 public.player_season_statistics rows

To znamená:

season statistics merge funguje přibližně na 91 % coverage.

---

# 7. EDGE CASES

Byly identifikovány edge cases:

- transfery mezi týmy
- více týmů během sezóny
- více lig během sezóny
- duplicity provider dat
- cup + league kombinace

Tyto edge cases pravděpodobně způsobují rozdíl cca 293 kombinací mezi staging a public.

Nejde o kritický problém.

---

# 8. PROVIDER REALITY

## CONFIRMED

### Football
api_football:
- players PUBLIC_CONFIRMED
- coaches STAGING_CONFIRMED

### American Football
api_american_football:
- players PUBLIC_CONFIRMED

### Basketball
api_sport:
- players STAGING_CONFIRMED

---

# 9. SPORTS S ČÁSTEČNÝM / EMPTY PEOPLE COVERAGE

Aktuálně:
endpoint existuje, ale vrací empty data:

- HK
- HB
- VB
- RGB
- BSB
- BK coaches
- AFB coaches

Nutné:
- scope validation
- provider reality audit
- případně alternate provider

---

# 10. SPORTS VYŽADUJÍCÍ DOC AUDIT

Nutné ověřit provider dokumentaci:

- TN
- MMA
- CK

---

# 11. HLAVNÍ STRATEGICKÝ SMĚR

PEOPLE layer bude připravena před aktivací paid providerů.

Cíl:
po aktivaci PRO plánů pouze:
- zapnout providery
- aktivovat scheduler
- spustit orchestrace
- automaticky plnit DB

---

# 12. BUDOUCÍ INFRASTRUKTURA

Současný PC:
- development
- testing
- architecture
- audits

Budoucí druhý PC:
- heavy harvesting
- scheduler runtime
- automated backfills
- media harvesting
- AI calculations
- large-scale provider pulls

---

# 13. DALŠÍ PRIORITY

## PRIORITA 1
PEOPLE automation + orchestrace

## PRIORITA 2
paid provider readiness

## PRIORITA 3
player_match_statistics layer

## PRIORITA 4
player social / translations / history

## PRIORITA 5
merge stabilization pro transfer edge cases

---

# 14. FINÁLNÍ CÍL

provider
→ RAW
→ staging
→ parser
→ provider map
→ canonical merge
→ public.players
→ public.player_season_statistics
→ media linkage
→ AI/rating
→ web/app output

vše automaticky přes scheduler/orchestraci.

---

# 15. HLAVNÍ ZÁVĚR

PEOPLE vrstva je architektonicky potvrzená a funkční.

Projekt již nestaví prototyp PEOPLE layer,
ale reálnou multisport canonical PEOPLE platformu připravenou na scale harvesting po aktivaci placených providerů.