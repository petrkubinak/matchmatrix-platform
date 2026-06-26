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
