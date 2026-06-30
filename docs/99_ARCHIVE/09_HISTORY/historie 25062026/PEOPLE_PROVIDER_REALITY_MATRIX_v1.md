# MATCHMATRIX – PEOPLE PROVIDER REALITY MATRIX V1

Datum: 2026-05-20

## Cíl

Zmapovat providery pro PEOPLE layer podle sportů:

- players
- coaches
- player profiles
- season statistics
- match/game statistics
- photos
- injuries
- transfers
- social/media enrichment

---

## 1. FOOTBALL

### Primary provider
API-Football / API-Sports

### Stav v MatchMatrix
- players: PUBLIC_CONFIRMED
- coaches: STAGING_CONFIRMED
- season statistics: PUBLIC_CONFIRMED
- match player statistics: PROVIDER EXISTS, RAW NOT IMPLEMENTED
- profiles: PARTIAL

### Paid plan relevance
PRO pravděpodobně odemkne širší coverage a vyšší request limit.

### Další akce
- připravit endpoint audit pro fixture player statistics
- připravit RAW worker
- připravit parser do staging
- připravit merge do public.player_match_statistics

---

## 2. BASKETBALL

### Kandidáti
- API-Sports Basketball
- SportsDataIO NBA
- Sportradar NBA
- balldontlie

### Stav v MatchMatrix
- api_sport players: STAGING_CONFIRMED
- sportsdataio NBA players: PARSED
- season/player stats: potřeba ověřit
- game/player stats: provider audit required

### Další akce
- ověřit API-Sports Basketball player game statistics
- ověřit SportsDataIO NBA game/player stats
- rozhodnout primary provider

---

## 3. HOCKEY

### Kandidáti
- SportsDataIO NHL
- NHL public API
- Sportradar NHL
- API-Sports Hockey

### Stav v MatchMatrix
- SportsDataIO NHL players: PARSED
- API-Sports Hockey players: endpoint empty / scope issue
- match/game player stats: provider audit required

### Další akce
- ověřit SportsDataIO NHL player game stats
- ověřit NHL public API použitelnost
- rozhodnout, zda SportsDataIO bude primary PEOPLE provider

---

## 4. BASEBALL

### Kandidáti
- SportsDataIO MLB
- MLB Stats API
- Sportradar MLB
- API-Sports Baseball

### Stav v MatchMatrix
- SportsDataIO MLB players: PARSED
- API-Sports Baseball players: empty / scope issue
- player game stats: provider audit required

### Další akce
- ověřit SportsDataIO MLB player game stats
- ověřit MLB Stats API
- rozhodnout primary provider

---

## 5. AMERICAN FOOTBALL

### Kandidáti
- API-American-Football
- SportsDataIO NFL
- Sportradar NFL

### Stav v MatchMatrix
- API-American-Football players: PUBLIC_CONFIRMED
- coaches: empty / scope issue
- player game stats: provider audit required

### Další akce
- ověřit endpointy pro player game stats
- ověřit SportsDataIO NFL jako alternativu

---

## 6. TENNIS

### Kandidáti
- API-Tennis
- SportsDataIO Tennis
- Sportradar Tennis
- balldontlie ATP/WTA

### Stav v MatchMatrix
- people endpoint: DOC_CHECK_REQUIRED
- player stats: provider audit required

### Další akce
- projít dokumentaci
- rozhodnout dedicated tennis people provider

---

## 7. MMA

### Kandidáti
- SportsDataIO MMA/UFC
- balldontlie MMA
- API-MMA
- Sportradar MMA

### Stav v MatchMatrix
- SportsDataIO MMA fighters: PARSED
- api_mma people endpoint: DOC_CHECK_REQUIRED
- fight/player stats: provider audit required

### Další akce
- ověřit fighter profiles
- ověřit fight stats
- rozhodnout primary provider

---

## 8. HANDBALL / VOLLEYBALL / RUGBY / FIELD HOCKEY / DARTS / ESPORTS

### Stav
Zatím slabší nebo nejistá provider coverage.

### Další akce
- nejdřív držet CORE layer
- PEOPLE layer řešit až po hlavních sportech
- hledat alternativní specializované providery

# MATCHMATRIX – PEOPLE PROVIDER PRIORITY V1

Datum: 2026-05-20

---

# FOOTBALL (FB)

PRIMARY:
API-Football / API-Sports PRO

SECONDARY:
SportsDataIO
Sportradar (future enterprise)

STATUS:
PRIMARY CONFIRMED

CURRENT MATCHMATRIX STATUS:
- players PUBLIC_CONFIRMED
- coaches STAGING_CONFIRMED
- season stats CONFIRMED
- player profiles PARTIAL
- match player stats NOT IMPLEMENTED YET

EXPECTED STRENGTH:
- best football coverage
- deep fixture/player stats
- lineups
- injuries
- transfers
- odds
- events

PRIORITY:
CRITICAL

---

# BASKETBALL (BK)

PRIMARY:
API-Sports Basketball

SECONDARY:
SportsDataIO NBA

STATUS:
PARTIAL CONFIRMED

CURRENT MATCHMATRIX STATUS:
- api_sport players STAGING_CONFIRMED
- SportsDataIO NBA players parsed
- match stats not verified

EXPECTED STRENGTH:
- world leagues
- NBA detail
- player game stats
- advanced analytics

PRIORITY:
HIGH

---

# HOCKEY (HK)

PRIMARY:
SportsDataIO NHL

SECONDARY:
NHL API
API-Hockey

STATUS:
PARTIAL CONFIRMED

CURRENT MATCHMATRIX STATUS:
- SportsDataIO NHL players parsed
- API-Hockey people endpoints empty

EXPECTED STRENGTH:
- NHL player depth
- game logs
- roster detail

PRIORITY:
HIGH

---

# BASEBALL (BSB)

PRIMARY:
SportsDataIO MLB

SECONDARY:
MLB Stats API

STATUS:
PARTIAL CONFIRMED

CURRENT MATCHMATRIX STATUS:
- SportsDataIO MLB players parsed
- API-Baseball people endpoints empty

EXPECTED STRENGTH:
- MLB player depth
- player game logs
- season analytics

PRIORITY:
HIGH

---

# AMERICAN FOOTBALL (AFB)

PRIMARY:
API-American-Football

SECONDARY:
SportsDataIO NFL

STATUS:
PARTIAL CONFIRMED

CURRENT MATCHMATRIX STATUS:
- players PUBLIC_CONFIRMED
- coaches empty/scope issue

EXPECTED STRENGTH:
- NFL player coverage
- game logs
- injuries

PRIORITY:
HIGH

---

# TENNIS (TN)

PRIMARY:
TBD

SECONDARY:
SportsDataIO Tennis
Sportradar Tennis

STATUS:
DOC AUDIT REQUIRED

CURRENT MATCHMATRIX STATUS:
- provider documentation not fully verified

EXPECTED STRENGTH:
- ATP/WTA player profiles
- rankings
- match stats

PRIORITY:
MEDIUM

---

# MMA

PRIMARY:
SportsDataIO MMA

SECONDARY:
API-MMA

STATUS:
PARTIAL CONFIRMED

CURRENT MATCHMATRIX STATUS:
- SportsDataIO fighters parsed

EXPECTED STRENGTH:
- fighter profiles
- fight history
- fight analytics

PRIORITY:
MEDIUM

---

# VOLLEYBALL / HANDBALL / RUGBY / FH / DRT / ESPORTS

STATUS:
LOW CONFIDENCE / LIMITED PROVIDER COVERAGE

STRATEGY:
- maintain core layer first
- people layer later
- evaluate specialized providers

PRIORITY:
LOW

---

# LONG-TERM MATCHMATRIX STRATEGY

MatchMatrix nebude závislý na jednom provideru.

Strategie:
BEST PROVIDER PER SPORT

provider
→ staging
→ canonical normalization
→ unified public layer
→ AI/rating/media/web layer

Cíl:
vybudovat multisport canonical sports graph platform.
