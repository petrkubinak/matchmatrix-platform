MATCHMATRIX – DENNÍ ZÁPIS
Datum: 2026-06-07
Oblast: Team Governance + Player Governance + OPS Panel V18
1. TEAM DUPLICATE PREVENTION DOKONČENO
CO TO JE

Governance vrstva pro kontrolu duplicit týmů.

CO JSME UDĚLALI

Dokončeny bloky:

17_9_A Team Duplicate Audit
17_9_B Canonical Audit
17_9_C Merge Candidates
17_9_D Missing Canonical Plan
17_9_E Reference Audit
17_9_F Missing Canonical Merge
17_9_G Real Provider Duplicate
17_9_H Review Hold
17_9_I Dashboard
17_9_J Insert Guard
17_9_K Guard Summary
VÝSLEDEK
CRITICAL = 0
HIGH = 7
MEDIUM = 84
LOW = 352

STATUS = CONTROLLED_HOLD
ZÁPIS DO RUNTIME AUDIT
TEAM_DUPLICATE_PREVENTION = READY
TEAM_INSERT_GUARD = ACTIVE
2. PLAYER IDENTITY GOVERNANCE DOKONČENO
CO TO JE

Governance vrstva pro ochranu identit hráčů.

DOKONČENÉ BLOKY
18_A Player Duplicate Audit
18_B Canonical Identity Audit
18_C Review Hold
18_D Dashboard
18_E Insert Guard
18_F Guard Summary
VÝSLEDEK
CRITICAL = 0
HIGH = 0
MEDIUM = 106
LOW = 15

HOLD = 121
HOLD SKUPINY
SAFE_DIFFERENT_BIRTH_DATE = 15
SUSPECT_MISSING_BIRTH_DATE = 2
SUSPECT_NO_BIRTH_DATE = 104
INSERT GUARD
provider_player_guard_rows = 19396
name_birth_guard_rows = 5145
hold_identity_guard_rows = 121
ZÁPIS DO RUNTIME AUDIT
PLAYER_DUPLICATE_PREVENTION = READY
PLAYER_IDENTITY_GOVERNANCE = ACTIVE
PLAYER_INSERT_GUARD = ACTIVE
3. PLAYER PROVIDER MAP GOVERNANCE DOKONČENO
CO TO JE

Kontrola integrity:

public.players
public.player_provider_map
public.player_external_identity
DOKONČENÉ BLOKY
18_1_A Governance Audit
18_1_B Collision Plan
18_1_C Collision Hold
18_1_D Governance Dashboard
18_1_E Missing Provider Map Fix Plan
18_1_F Gibson Auto Fix
18_1_G Gibson Rollback
18_1_H Final Dashboard
NALEZENÉ KOLIZE
Benny
2001 vs 2000
různí hráči
Vitinho
1992 vs 2002
různí hráči
L. Jenkins
1991 vs 2006
různí hráči
Hiago
2002-01-28
2002-01-28

pravděpodobný merge kandidát
HOLD VÝSLEDEK
POSSIBLE_PLAYER_MERGE = 1
PROVIDER_MAP_REVIEW = 3
G. GIBSON

Pokus o automatické vytvoření provider identity.

Nalezen konflikt:

api_football
external_player_id = 57185

už patřil jinému hráči.

Oprava vrácena zpět.

FINÁLNÍ STAV
provider_identity_collision_rows = 8
collision_hold_groups = 4

possible_merge_groups = 1
provider_map_review_groups = 3

player_without_provider_map_rows = 1

ok_rows = 20027

STATUS = CONTROLLED_HOLD
ZÁPIS DO RUNTIME AUDIT
PLAYER_PROVIDER_MAP_GOVERNANCE = CONTROLLED_HOLD

PLAYER_PROVIDER_COLLISIONS = HOLD_MANUAL_REVIEW

PEOPLE_PROVIDER_INGEST_STATUS = SAFE_WITH_HOLD
4. OPS RUNTIME AUDIT AKTUALIZOVÁN

Do:

ops.runtime_entity_audit

zapsány:

team_duplicate_prevention
player_identity_governance
player_provider_map_governance
AKTUÁLNÍ STAV
matchmatrix_governance

ALL

team_duplicate_prevention
CONFIRMED

player_identity_governance
CONFIRMED

player_provider_map_governance
PARTIAL
(CONTROLLED_HOLD)
5. OPS PANEL V18
CO JSME UDĚLALI

Přidána sekce:

PEOPLE GOVERNANCE STATUS

na základě:

ops.runtime_entity_audit
ZJIŠTĚNÍ

Panel je funkční.

Ale vzhled není dostatečně profesionální.

CO SE NÁM NELÍBÍ
Graf nahoře

Současný:

CORE
PEOPLE
MEDIA
ODDS
CELKEM

má malou informační hodnotu.

KPI

Pořád příliš mnoho technických KPI.

Například:

Planner
Backlog
Ready

jsou vhodné spíše pro OPS.

Příliš mnoho tabulek

Panel působí jako:

DBeaver Dashboard

a ne jako:

MatchMatrix Command Center
PLÁN NA ZÍTŘEK
PRIORITA 1

Redesign horní části V18.

Místo:

CORE
PEOPLE
MEDIA
ODDS
CELKEM

vytvořit:

PROJEKT
SPORTY
PROVIDEŘI
PEOPLE
MEDIA
ODDS
WEB
PRIORITA 2

Nový hlavní ukazatel:

MATCHMATRIX CELKEM

36 %

velký dominantní blok.

PRIORITA 3

Nový graf:

Místo současných čar:

Governance %
Provider readiness %
Harvest readiness %
Web readiness %

sledování vývoje projektu.

PRIORITA 4

Governance Dashboard

Zobrazit:

🟢 Team Duplicate Prevention

🟢 Player Identity Governance

🟡 Player Provider Map Governance

s jednoduchým stavem.

STAV PROJEKTU PŘI UKONČENÍ DNE
TEAM_DUPLICATE_PREVENTION = READY

PLAYER_DUPLICATE_PREVENTION = READY

PLAYER_IDENTITY_GOVERNANCE = ACTIVE

PLAYER_PROVIDER_MAP_GOVERNANCE = CONTROLLED_HOLD

CRITICAL = 0
HIGH = 0

Databázová governance je nyní ve velmi dobrém stavu a zítra budeme pokračovat redesignem OPS Panelu V18, aby se z něj stalo skutečné řídicí centrum MatchMatrix.