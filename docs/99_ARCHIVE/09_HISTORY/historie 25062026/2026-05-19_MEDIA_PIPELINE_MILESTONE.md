# =========================================================
# MATCHMATRIX MASTER NAVÁZÁNÍ
# =========================================================
#
# DATUM:
# ---------------------------------------------------------
# 2026-05-19
#
# TÉMA:
# ---------------------------------------------------------
# LIVE FEED ARCHITECTURE
# VISUAL DISPLAY ENGINE
# PLAYER/TEAM IMAGE RESOLVER
# COMMUNITY + PREDICTION STRATEGY
#
# =========================================================


## LIVE MATCH FEED V1

Byl vytvořen:
- public.v_live_match_feed

Účel:
- frontend-ready LIVE NOW feed
- homepage live section
- mobile app live cards
- AI live feed

View vrací:
- kickoff
- status
- score
- live_minute
- sport icon
- league logo
- country flag
- team logos

Použití na webu:
- LIVE NOW sekce
- live ticker
- live homepage cards
- AI alerts


## SPORT DISPLAY ENGINE

Do public.sports byl přidán:

- display_mode

Hodnoty:
- team_vs_team
- player_vs_player

Použití:
- frontend automaticky ví,
  zda zobrazit:
  - logo týmu
  - nebo fotografii hráče

Aktuální mapování:
- Football → team_vs_team
- Hockey → team_vs_team
- Basketball → team_vs_team
- Tennis → player_vs_player
- MMA → player_vs_player
- Darts → player_vs_player
- Esports → player_vs_player

Význam:
- univerzální multisport frontend architecture
- žádný hardcoded frontend
- jednodušší mobilní aplikace
- univerzální live feed


## LIVE MATCH FEED V2

Byl vytvořen:
- public.v_live_match_feed_v2

Novinky:
- display_mode included
- universal entity naming:
  - home_entity_name
  - away_entity_name
  - home_entity_image
  - away_entity_image

Behavior:
- team sports → používají team logos
- player sports → používají player photos

Fallback:
- pokud player nemá real photo_url:
  - použije:
    /assets/players/{id}.png

Výsledek:
- Tennis live feed nyní vrací:
  - player photos/assets
- Football používá team logos

Použití na webu:
- universal live cards
- mobile live feed
- AI live feed
- future widgets


## PLAYER PHOTO RESOLVER

Byl vytvořen:
- automatic player photo resolver

Logika:
- při display_mode = player_vs_player:
  - lookup do public.players
  - použití photo_url
  - fallback na /assets/players/{id}.png

Budoucí rozšíření:
- MMA fighter photos
- darts player photos
- esports avatars
- CDN image layer


## VISUAL IDENTITY LAYER

Byly připraveny:
- sport icons
- country flags
- team logos
- league logos
- player assets

Standardized paths:
- /assets/sports/
- /assets/flags/
- /assets/teams/
- /assets/leagues/
- /assets/players/

Význam:
- CDN-ready architecture
- cache-friendly
- mobile optimization
- frontend consistency


## COMMUNITY / AMATEUR STRATEGY

Byla potvrzena dlouhodobá strategie:

Uživatelé budou moci:
- zakládat amatérské soutěže
- přidávat týmy
- zapisovat výsledky
- vytvářet kola a zápasy

Po schválení:
- MatchMatrix automaticky generuje:
  - standings
  - form
  - statistics
  - ratings
  - visibility

Budoucí tabulky:
- public.community_competitions
- public.community_teams
- public.community_matches
- public.community_match_results
- ops.community_approval_queue


## COMMUNITY VS PROFI ENGINE

Potvrzena klíčová unikátní feature:

- COMMUNITY VS PROFESSIONAL COMPARISON ENGINE

Cíl:
- amatérské týmy/hráči budou porovnáváni s profi světem

Budoucí AI výstupy:
- „Tým připomíná Atletico Madrid“
- „Hráč stylem připomíná Haalanda“
- „AI odhaduje úroveň League Two“
- „Tým by skončil 12. v dané lize“

Technologie:
- MM Ratings
- AI similarity engine
- style comparison
- form comparison
- strength comparison

Význam:
- virální community engagement
- vysoká retence uživatelů
- unikátní feature oproti konkurenci


## DUAL PRODUCT STRATEGY

Byla potvrzena hlavní produktová strategie:

1)
MATCH INTELLIGENCE / PREDICTIONS

2)
COMMUNITY / FAN ENGAGEMENT

Význam:
- predictions = monetizace
- community = růst + retence + viralita

MatchMatrix bude kombinovat:
- AI predictions
- value betting
- live intelligence
- media AI
- community ecosystem


## AKTUÁLNÍ STAV PROJEKTU

MatchMatrix nyní obsahuje:

- Core Data Layer
- People Layer
- Media Layer
- AI Layer
- Trending Layer
- Visual Identity Layer
- Enrichment Layer
- Universal Match Feed
- Universal Live Feed
- Sport Display Engine
- Player Image Resolver
- Multisport Architecture

Projekt začíná fungovat jako:
- AI sports intelligence platform
- live sports ecosystem
- multisport community platform
- prediction engine architecture
#
# =========================================================