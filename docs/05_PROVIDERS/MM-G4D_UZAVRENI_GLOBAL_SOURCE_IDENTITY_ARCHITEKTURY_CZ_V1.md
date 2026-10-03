# MatchMatrix – G4D – uzavření Global Source Identity architektury

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Pracovní identifikátor | G4D-CLOSURE-20260927 |
| Název dokumentu | MatchMatrix – G4D – uzavření Global Source Identity architektury |
| Typ dokumentu | TECHNICAL_WORK_PACKAGE_CLOSURE |
| Edice | TECH / pracovní technická dokumentace |
| Verze | 1.0 |
| Stav | REVIEW |
| Datum | 2026-09-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Aktivní projekt | MatchMatrix-platform |
| Pracovní oblast | G4 – Provider / Source System |
| Uzavíraný pracovní balík | G4D – Physical Source Identity Consolidation |
| Hlavní databáze | PostgreSQL `matchmatrix` na PC2 |
| Primární formát | Markdown (`.md`) |
| Doporučené umístění | `docs/05_PROVIDERS/MM-G4D_UZAVRENI_GLOBAL_SOURCE_IDENTITY_ARCHITEKTURY_CZ_V1.md` |
| Navazuje na | G4C Source Identity Consolidation Design; G4D-1 až G4D-7 |
| Související pracovní dokumenty | `MM-G4D2_DESIGN_FREEZE_A_KONTRAKT_CZ_V1.xlsx`, `MM-G4D2_KROKY_A_DESIGN_FREEZE_CZ_V1.md`, `MM-G4D2_HISTORICKE_ZNENI_KROKU_CZ_V1.md` |
| Referenční standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-009 |

---

# 1. Účel dokumentu

Tento dokument uzavírá pracovní větev `G4D`, jejímž cílem bylo převést zmrazený návrh globální identity zdrojů MatchMatrix do bezpečné fyzické databázové architektury.

Dokument zachycuje:

- konečný stav etap G4D-1 až G4D-7,
- skutečně provedené fyzické změny databáze,
- validační výsledky,
- zachované bezpečnostní hranice,
- objekty a data, které zůstávají záměrně prázdné,
- legacy evidence, která musí zůstat zachována,
- známé HOLD stavy,
- přesný výchozí stav pro navazující práci.

Hlavním výsledkem G4D není automatické naplnění coverage, bindingu a routingu. Hlavním výsledkem je vytvoření bezpečného canonical identity základu, který již fyzicky existuje v databázi a brání tomu, aby se neověřené vztahy staly schválenou pravdou.

---

# 2. Architektonický princip

Během G4D byl definitivně zachován princip:

```text
SOURCE IDENTITY
!=
RUNTIME ADAPTER IDENTITY
```

Skutečný externí zdroj, například federace, organizátor soutěže, knowledge base nebo media archive, má vlastní canonical identitu.

Runtime adapter představuje technickou cestu, kterou může MatchMatrix použít k získání dat.

Příklad:

```text
EHF / IHF
!=
api_handball
```

Technická existence nebo funkčnost adapteru sama o sobě neprokazuje:

- canonical source binding,
- coverage konkrétní entity,
- coverage konkrétního time mode,
- právní nebo komerční použitelnost,
- schválený routing.

---

# 3. Osm cílových logických objektů

Zmrazený model G4D pracuje s osmi logickými objekty:

```text
1. SOURCE_MASTER
2. SOURCE_ALIAS
3. SOURCE_SPORT
4. SOURCE_ENTITY_TIME_COVERAGE
5. SOURCE_AUDIT_EVIDENCE
6. SOURCE_ROUTING
7. RUNTIME_ADAPTER
8. SOURCE_ADAPTER_BINDING
```

Fyzicky vzniklo sedm nových tabulek. `SOURCE_ROUTING` používá existující fyzickou tabulku:

```text
ops.data_acquisition_source_routing
```

---

# 4. Konečný stav celé větve G4D

```text
G4D-1  READ-ONLY DEPENDENCY AUDIT          COMPLETE
G4D-2  DESIGN FREEZE                       COMPLETE
G4D-3  VALIDATE_ONLY PHYSICAL MIGRATION    COMPLETE / PASS
G4D-4  ADDITIVE APPLY                      COMPLETE / COMMITTED / PASS
G4D-5  COVERAGE / TIME VALIDATE_ONLY       COMPLETE / PASS_ZERO_READY
G4D-6  CONTROLLED ROUTING READINESS        COMPLETE / PASS_ZERO_READY
G4D-7  CLEANUP READINESS                   COMPLETE / PASS_NOT_READY

G4D OVERALL STATUS                         COMPLETE
```

---

# 5. G4D-1 – Dependency / Caller Audit

G4D-1 ověřil, zda existují současní přímí tracked calleři nebo writery pro fyzickou routing tabulku, které by vyžadovaly zachování starého writer kontraktu.

Repo audit na PC2 byl proveden nad:

```text
C:\MatchMatrix-platform
branch: main
```

Výsledek přímého `git grep` pro:

```text
data_acquisition_source_routing
```

byl:

```text
GREP_EXIT = 1
```

To znamenalo, že v aktuálním tracked `main` repozitáři nebyla nalezena přímá reference na tuto tabulku.

Tento nález umožnil pokračovat s canonical `source_id` kontraktem bez potřeby zachovávat legacy `REFERENCE` writer kompatibilitu.

---

# 6. G4D-2 – Design Freeze

G4D-2 zmrazil logický kontrakt.

Klíčové zmrazené hodnoty:

```text
canonical source identities     17
source aliases                  35
source × sport relations        17
runtime adapter identities      27
```

Dvě původní pseudo-source kategorie nebyly zařazeny do canonical seed:

```text
official_club_websites
official_league_websites
```

Důvod:

Nejde o jednotlivé stabilní externí identity, ale o kategorie budoucích konkrétních zdrojů.

---

# 7. G4D-3 – VALIDATE_ONLY fyzická migrace

G4D-3 ověřil celý fyzický model bez trvalých změn databáze.

## 7.1 Physical target contract

Bylo potvrzeno mimo jiné:

```text
public.sports.code
```

jako canonical sport code reference.

Existující `ops.data_acquisition_source_routing` měla před změnou 0 řádků a neobsahovala `source_id`.

## 7.2 Validace G4C V01–V12

Všechny definované validační podmínky prošly:

```text
V01 PASS
V02 PASS
V03 PASS
V04 PASS
V05 PASS
V06 PASS
V07 PASS
V08 PASS
V09 PASS
V10 PASS
V11 PASS
V12 PASS
```

## 7.3 G4D-3 fyzická validace

Výsledek:

```text
PASS COUNT    = 17
BLOCKER COUNT = 0
FINAL STATUS  = VALIDATE_ONLY_PASS
```

Ověřený bezpečný seed:

```text
SOURCE_MASTER           17
SOURCE_ALIAS            35
SOURCE_SPORT            17
SOURCE_AUDIT_EVIDENCE   57
RUNTIME_ADAPTER         27

SOURCE_ENTITY_TIME_COVERAGE  0
SOURCE_ADAPTER_BINDING       0
SOURCE_ROUTING               0
```

## 7.4 Evidence resolution

Legacy source evidence:

```text
TOTAL        61
RESOLVED     57
PSEUDO HOLD   4
```

Nebyl proveden automatický převod pseudo-source evidence na canonical identity.

## 7.5 Rollback proof

Po VALIDATE_ONLY rollbacku bylo ověřeno:

```text
TARGET_TABLES_REMOVED                    PASS
ROUTING_SOURCE_ID_REMOVED                PASS
ROUTING_ROWS_ZERO                        PASS
LEGACY_IDENTIFIERS_NOT_NULL_RESTORED     PASS
ORIGINAL_ACTIVE_SOURCE_INDEX_RESTORED    PASS
ORIGINAL_APPROVED_PRIMARY_INDEX_RESTORED PASS
ORIGINAL_REFERENCE_ROLE_RESTORED         PASS
POST_ROLLBACK_COMPLETE                   PASS
```

Celkem:

```text
8 / 8 PASS
```

---

# 8. G4D-4 – ADDITIVE APPLY

G4D-4 provedl první skutečný fyzický APPLY.

Šlo o transakční additive migration s validačními kontrolami před `COMMIT`.

## 8.1 Vytvořené canonical objekty

Po commitu existují:

```text
ops.source_master
ops.source_alias
ops.source_sport
ops.source_entity_time_coverage
ops.source_audit_evidence
ops.runtime_adapter
ops.source_adapter_binding
```

`ops.data_acquisition_source_routing` byla upravena tak, aby používala canonical `source_id`.

## 8.2 Trvalý seed po APPLY

```text
source_master           17
source_alias            35
source_sport            17
source_audit_evidence   57
runtime_adapter         27
```

Záměrně zůstalo:

```text
source_entity_time_coverage  0
source_adapter_binding       0
data_acquisition_source_routing 0
```

## 8.3 Routing contract po APPLY

Persistentní kontrakt byl ověřen:

```text
source_id BIGINT NOT NULL
```

Legacy identifikační sloupce byly ponechány jako nullable:

```text
source_name
source_origin
source_ref_id
```

Canonical role kontrakt:

```text
PRIMARY
FALLBACK
MERGE
VALIDATION
NOT_USED
```

Bylo potvrzeno:

- canonical active routing uniqueness přes `source_id`,
- maximálně jeden aktivní `PRIMARY` na exact scope,
- zachování approval protection,
- active alias uniqueness.

## 8.4 Post-commit verification

První post-commit kontrola:

```text
TARGET_TABLES_PRESENT              PASS
SAFE_SEED_COUNTS                   PASS
HOLD_TABLES_EMPTY                  PASS
ROUTING_SOURCE_ID_PRESENT          PASS
ROUTING_CANONICAL_INDEXES          PASS
ACTIVE_ALIAS_UNIQUENESS            PASS
APPROVAL_PROTECTION_PRESERVED      PASS
G4D4_APPLY_COMPLETE                PASS
```

Celkem:

```text
8 / 8 PASS
```

Druhá nezávislá READ ONLY kontrola:

```text
TARGET_TABLES_PRESENT        PASS
SAFE_SEED_COUNTS             PASS
HOLD_TARGETS_EMPTY           PASS
ROUTING_SOURCE_ID            PASS
ROUTING_LEGACY_NULLABLE      PASS
CANONICAL_ROUTING_INDEX      PASS
ONE_ACTIVE_PRIMARY_INDEX     PASS
TARGET_ROLE_CONTRACT         PASS
APPROVAL_PROTECTION          PASS
```

Celkem:

```text
9 / 9 PASS
```

## 8.5 DBeaver ochrana proti druhému APPLY

Po úspěšném commitu byl skript omylem spuštěn znovu.

Precheck správně zastavil druhý běh hláškou:

```text
BLOCKER: at least one G4D target table already exists
```

Tato hláška nepředstavovala selhání prvního APPLY.

Následné nezávislé persistence checks potvrdily, že první APPLY byl již úspěšně committed.

---

# 9. G4D-5 – Coverage / Time Validate-Only

Cílem bylo zjistit, zda lze některou existující coverage evidence bezpečně převést do:

```text
ops.source_entity_time_coverage
```

Target grain:

```text
source_id
× sport_code
× layer_type
× entity
× time_mode
```

## 9.1 Provider coverage

Existující legacy provider coverage:

```text
ops.provider_entity_coverage = 107 rows
```

Všechny tyto řádky mají runtime adapter identitu, ale žádný z nich nemá explicitně doložený canonical source binding.

Výsledek:

```text
107 × HOLD_NO_SOURCE_ADAPTER_BINDING
107 × HOLD_NO_EXACT_TIME_MODE
```

## 9.2 Source coverage matrix

Existující canonical source-oriented coverage evidence:

```text
ops.source_coverage_matrix = 7 rows
```

Všech 7 řádků bylo možné přiřadit ke canonical source identity:

```text
European Handball Federation
source_id = 2
```

Ale nebylo možné bezpečně určit úplný target tuple.

Chybělo přesné doložení:

```text
layer_type
entity mapping
time_mode
```

Historický záznam byl navíc nejednoznačný mezi:

```text
HISTORY_FAN
HISTORY_PREDICTION
```

## 9.3 Výsledek G4D-5

```text
TARGET_COVERAGE_CURRENT_ROWS          0
PROVIDER_ENTITY_COVERAGE_ROWS       107
PROVIDER_ROWS_WITH_RUNTIME_ADAPTER  107
PROVIDER_ROWS_WITH_SOURCE_BINDING     0
PROVIDER_READY_FOR_TIME_COVERAGE      0
SOURCE_COVERAGE_MATRIX_ROWS            7
SOURCE_COVERAGE_CANONICAL_ID_RESOLVED  7
SOURCE_COVERAGE_EXACT_TIME_MODE         0
READY_TARGET_ROWS                       0
```

Finální stav:

```text
G4D-5 = COMPLETE / PASS_ZERO_READY
```

Nebylo vloženo žádné coverage datum odhadem.

---

# 10. G4D-6 – Controlled Routing Readiness

G4D-6 ověřil, zda existuje jakýkoli scope, který splňuje podmínky pro řízený routing.

Výsledek:

```text
SOURCE_ENTITY_TIME_COVERAGE_ROWS       0
CONFIRMED_COVERAGE_ROWS                0
PRIMARY_READY_SCOPES                   0
NONBLOCKED_COVERAGE_SCOPES             0
CURRENT_ROUTING_ROWS                   0
CURRENT_ACTIVE_ROUTING_ROWS            0
CURRENT_APPROVED_ROUTING_ROWS          0
ORPHAN_ROUTING_WITHOUT_COVERAGE        0
PRIMARY_WITHOUT_CONFIRMED_COVERAGE     0
G4D6_READY_ROUTES                      0
```

Finální stav:

```text
G4D-6 = COMPLETE / PASS_ZERO_READY
```

Controlled routing APPLY nebyl spuštěn, protože neexistoval žádný explicitně potvrzený route candidate.

---

# 11. G4D-7 – Cleanup Readiness

G4D-7 ověřil, zda lze po zavedení canonical identity vrstvy odstranit některé legacy struktury.

Výsledek:

```text
CANONICAL_IDENTITY_LAYER        PASS
CANONICAL_EVIDENCE_LAYER        PASS
CANONICAL_RUNTIME_LAYER         PASS

COVERAGE_MIGRATION_COMPLETE     NOT_READY
ADAPTER_BINDING_MIGRATION       NOT_READY
ROUTING_POPULATED               NOT_READY
```

Legacy retention:

```text
LEGACY_PROVIDER_COVERAGE_RETENTION   KEEP_REQUIRED
LEGACY_PROVIDER_SPORT_RETENTION      KEEP_REQUIRED
SPECIALIZED_AUDIT_TABLES_RETENTION  KEEP_REQUIRED
DESTRUCTIVE_CLEANUP_READY            PASS_NOT_READY
```

Nebyla provedena žádná destruktivní cleanup operace.

---

# 12. Legacy evidence, která musí zůstat zachována

Konec G4D potvrzuje, že následující obsah stále představuje potřebný zdroj důkazů:

```text
provider_entity_coverage       107
provider_sport_matrix           16

source_discovery_audit_tracker  15
source_commercial_model          6
source_legal_audit               1
source_activation_roadmap        4
source_intelligence_map          6
source_quality_score             1
source_coverage_matrix           7
source_review_results           13
source_verification_log          8
```

Tyto legacy/specialized tabulky nesmějí být odstraněny pouze proto, že canonical identity vrstva již existuje.

---

# 13. Finální closure snapshot

Finální READ ONLY snapshot po dokončení celé větve:

```text
LEGACY_PROVIDER_ENTITY_COVERAGE  107
LEGACY_PROVIDER_SPORT_MATRIX       16
RUNTIME_ADAPTER                    27
SOURCE_ADAPTER_BINDING              0
SOURCE_ALIAS                       35
SOURCE_AUDIT_EVIDENCE              57
SOURCE_ENTITY_TIME_COVERAGE         0
SOURCE_MASTER                      17
SOURCE_ROUTING                      0
SOURCE_SPORT                       17
```

Tento snapshot je referenčním výchozím bodem po G4D.

---

# 14. Co G4D fyzicky dokončilo

G4D dokončilo:

- jednotnou canonical source identity vrstvu,
- canonical alias vrstvu,
- source × sport vztahy,
- konsolidovanou source audit evidence vrstvu,
- runtime adapter registr,
- canonical `source_id` kontrakt v routing tabulce,
- fyzické uniqueness a approval ochrany,
- oddělení source identity od runtime adapter identity,
- bezpečný rámec pro budoucí coverage, binding a routing.

---

# 15. Co G4D záměrně nedokončilo

G4D záměrně nevytvořilo neověřené vztahy.

Zůstává otevřeno:

```text
SOURCE_ENTITY_TIME_COVERAGE = 0
SOURCE_ADAPTER_BINDING      = 0
SOURCE_ROUTING              = 0
```

To není technický dluh vzniklý chybou migrace.

Jde o řízený stav, protože existující evidence zatím neprokazuje přesné canonical vztahy v požadované granularitě.

---

# 16. Bezpečnostní princip po G4D

Po dokončení G4D platí:

```text
NO EVIDENCE
→ NO CANONICAL COVERAGE
→ NO SOURCE-ADAPTER BINDING
→ NO APPROVED ROUTING
```

Zvlášť platí:

```text
RUNTIME_TESTED
!=
CONFIRMED COVERAGE
```

A:

```text
ADAPTER EXISTS
!=
SOURCE BINDING EXISTS
```

A:

```text
LEGACY PRIMARY FLAG
!=
APPROVED CANONICAL PRIMARY ROUTE
```

---

# 17. Známé technické incidenty během práce

## 17.1 G4D-3 temporary validation table

Po rollbacku nebyla dostupná temporary validační tabulka.

To bylo očekávané chování rollbacku, nikoli selhání migrace.

## 17.2 G4D-4 druhé spuštění

Opakované spuštění APPLY bylo zastaveno ochranným precheckem, protože cílové objekty již po prvním commitu existovaly.

Persistence checks následně potvrdily správný committed stav.

## 17.3 G4D-5 první READ ONLY script

První verze klasifikačního SQL použila CTE `provider_cov` mimo scope jediného bezprostředně následujícího SELECT.

PostgreSQL proto v dalším SELECT hlásil:

```text
relation "provider_cov" does not exist
```

Chyba byla pouze ve validačním SQL a nemohla změnit databázi.

V2 znovu definovala CTE před každým samostatným SELECT a proběhla správně.

---

# 18. PROJECT SNAPSHOT

```text
Projekt                        MatchMatrix-platform
Oblast                         G4 Provider / Source System
G4D status                     COMPLETE
Canonical source identities    17
Canonical aliases              35
Source-sport relations         17
Canonical audit evidence       57
Runtime adapters               27
Canonical coverage             0
Source-adapter binding         0
Canonical routing              0
Legacy provider coverage       107
Legacy provider sport matrix   16
Destructive cleanup            NOT READY / NOT EXECUTED
```

---

# 19. DATABASE SNAPSHOT

Persistentní canonical struktura je po G4D aktivní.

Canonical identity a auditní seed je fyzicky uložen.

Coverage, binding a routing jsou záměrně prázdné.

Legacy evidence je zachována a představuje vstup do další řízené evidence práce.

---

# 20. CURRENT STATUS

| Oblast | Stav |
|---|---|
| G4D-1 | COMPLETE |
| G4D-2 | COMPLETE |
| G4D-3 | COMPLETE / PASS |
| G4D-4 | COMPLETE / COMMITTED / PASS |
| G4D-5 | COMPLETE / PASS_ZERO_READY |
| G4D-6 | COMPLETE / PASS_ZERO_READY |
| G4D-7 | COMPLETE / PASS_NOT_READY |
| Canonical identity | ACTIVE |
| Canonical evidence | ACTIVE |
| Runtime adapter registry | ACTIVE |
| Canonical coverage | WAITING_FOR_EVIDENCE |
| Source-adapter binding | WAITING_FOR_EVIDENCE |
| Canonical routing | WAITING_FOR_CONFIRMED_COVERAGE |
| Legacy cleanup | BLOCKED_BY_UNRESOLVED_EVIDENCE |

---

# 21. OPEN QUESTIONS

G4D samotné nemá žádný technický blocker.

Pro navazující práci zůstává nutné postupně doložit:

1. které runtime adaptery skutečně reprezentují přístup ke kterým canonical source identities,
2. pro jaký sport a entitu binding platí,
3. jaký přesný `time_mode` je doložen pro konkrétní coverage,
4. která coverage je pouze plánovaná, technicky připravená nebo runtime tested,
5. která coverage může být povýšena na `CONFIRMED`,
6. které exact scopes mohou následně získat routing role.

---

# 22. NEXT STEP

Následující pracovní oblast nesmí začít automatickým naplněním coverage nebo routingu.

Doporučený první krok je:

```text
PILOT HB – SOURCE EVIDENCE INVENTORY
READ ONLY
```

Cíl:

- vzít házenou jako pilot,
- odděleně inventarizovat canonical sources a runtime adaptery,
- dohledat explicitní binding evidence,
- dohledat exact entity + time_mode coverage evidence,
- připravit pouze kandidáty,
- nevkládat nic do canonical coverage/binding/routing bez validačního důkazu.

---

# 23. AI CONTEXT

Při navázání nesmí AI:

- znovu navrhovat G4D architekturu,
- opakovat G4D-1 až G4D-7,
- automaticky mapovat `api_handball` na EHF nebo IHF,
- převádět 107 legacy provider coverage řádků do canonical coverage,
- převádět runtime tested stav na confirmed coverage,
- vytvářet PRIMARY/FALLBACK/MERGE routing bez exact coverage evidence,
- mazat legacy source/provider evidence.

AI má vycházet z toho, že G4D je uzavřené a canonical identity základ je aktivní.

---

# 24. Historie verzí

| Verze | Datum | Autor | Popis | Stav |
|---|---|---|---|---|
| 1.0 | 2026-09-27 | Petr + OpenAI ChatGPT | První uzavírací technický protokol G4D po finálním closure snapshotu | REVIEW |

---

# Závěr

Pracovní větev G4D byla dokončena úspěšně.

Canonical Source Identity architektura již není pouze návrhem. Je fyzicky přítomná v databázi a má ověřený identity, alias, sport, evidence a runtime adapter základ.

Současně byly zachovány všechny důležité governance hranice. Žádná coverage, source-adapter vazba ani route nebyla vytvořena pouhým odhadem nebo převodem legacy flagu.

Tento stav je považován za správný a bezpečný výchozí bod pro další evidence-driven rozvoj Provider / Source vrstvy MatchMatrix.
