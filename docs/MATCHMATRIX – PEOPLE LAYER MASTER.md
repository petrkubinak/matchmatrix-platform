# MATCHMATRIX – PEOPLE LAYER MASTER CHECKLIST

## 1. ARCHITEKTURA
[ ] Definovat finální PEOPLE architekturu
[ ] Definovat canonical PEOPLE flow
[ ] Definovat multi-provider PEOPLE strategii
[ ] Definovat provider priority/fallback logiku

---

# 2. DB MODEL

## public
[x] public.players
[x] public.player_provider_map
[x] public.player_season_statistics

[x] public.coaches
[x] public.coach_provider_map
[ ] public.player_profiles
[ ] public.player_media_links
[ ] public.player_translations

---

# 3. STAGING VRSTVA

[x] stg_provider_players
[x] stg_provider_player_stats
[x] stg_provider_player_profiles

[ ] stg_provider_coaches
[ ] stg_provider_coach_profiles
[ ] stg_provider_player_transfers
[ ] stg_provider_player_injuries

---

# 4. PROVIDER AUDIT

[x] provider_people_audit
[x] PEOPLE smoke tests

[ ] PEOPLE provider decision matrix
[ ] PEOPLE provider ranking
[ ] paid/free coverage audit
[ ] fallback provider audit

---

# 5. PROVIDER COVERAGE

## FOOTBALL
[x] api_football players
[x] api_football coaches
[ ] API-Sports PRO activation

## BASKETBALL
[x] api_sport players
[ ] public merge
[ ] coaches reality audit

## AMERICAN FOOTBALL
[x] api_american_football players
[ ] expand scope

## HOCKEY
[ ] people scope validation
[ ] alternate provider audit

## HANDBALL
[ ] people scope validation
[ ] alternate provider audit

## VOLLEYBALL
[ ] people scope validation
[ ] alternate provider audit

## RUGBY
[ ] people scope validation
[ ] alternate provider audit

## TENNIS
[ ] provider documentation audit
[ ] dedicated tennis people provider

## MMA
[ ] provider documentation audit
[ ] fighter profile provider

## CRICKET
[ ] provider documentation audit

---

# 6. INGEST PIPELINE

[ ] RAW workers
[ ] parser workers
[ ] provider map workers
[ ] public merge workers
[ ] statistics merge workers
[ ] profile merge workers

---

# 7. ORCHESTRACE

[ ] PEOPLE scheduler
[ ] PEOPLE planner
[ ] PEOPLE queue
[ ] PEOPLE retry logic
[ ] PEOPLE audit layer
[ ] PEOPLE automation

---

# 8. PLAYER STATISTICS

[ ] unified statistics model
[ ] sport-specific statistics rules
[ ] advanced metrics
[ ] rating engine inputs

---

# 9. MEDIA NAPOJENÍ

[ ] player ↔ articles
[ ] player ↔ highlights
[ ] player ↔ videos
[ ] player trending engine

---

# 10. AI / RATING ENGINE

[ ] player form engine
[ ] player rating engine
[ ] player comparison engine
[ ] scouting engine
[ ] recommendation engine

---

# 11. WEB / APP VÝSTUP

[ ] player pages
[ ] coach pages
[ ] player statistics pages
[ ] player media pages
[ ] trending players
[ ] player search

---

# 12. INFRASTRUKTURA

## CURRENT PC
[x] development
[x] architecture
[x] testing

## FUTURE SECOND PC
[ ] heavy harvesting
[ ] scheduler runtime
[ ] automated backfills
[ ] media harvesting
[ ] AI calculations

---

# 13. PAID PROVIDER ACTIVATION PLAN

[ ] API-Sports PRO
[ ] SportsDataIO
[ ] additional tennis provider
[ ] additional hockey provider
[ ] additional basketball provider

---

# 14. FINÁLNÍ CÍL

Jakmile budou aktivované paid plány:

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

bude běžet automaticky přes scheduler + orchestraci.