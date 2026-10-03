# MM-STD-011

# STANDARD SPRÁVY AKTIVNÍHO SYSTÉMU, RUNTIME MANIFESTU A LEGACY MATCHMATRIX

## APPROVED STANDARD

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-STD-011 |
| Document ID | MM-STD-011 |
| Název | Standard správy aktivního systému, runtime manifestu a legacy MatchMatrix |
| Typ dokumentu | ACTIVE_SYSTEM_RUNTIME_GOVERNANCE_STANDARD |
| Edice | MM-STD |
| Verze | 1.0 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT |
| Datum založení | 2026-10-01 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Cílové umístění | `docs/12_STANDARD/` |
| Aktivní soubor | `docs/12_STANDARD/MM-STD-011_STANDARD_SPRAVY_AKTIVNIHO_SYSTEMU_RUNTIME_MANIFESTU_A_LEGACY_MATCHMATRIX.md` |
| Cílový runtime kořen | `\\Matchmatrix\matchmatrix\MATCHMATRIX_ACTIVE_SYSTEM\` |
| Stav registrace | REGISTERED – zapsáno v `MM-STD-1000`, identita `MM-STD-011` ověřena dle `MM-STD-007` |
| Navazuje na | MM-STD-003, MM-STD-004, MM-STD-007, MM-STD-009, MM-STD-1000, MM-DOC-300, MM-DOC-800 |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---:|---|---|---|
|   1.0 | 2026-10-01 | APPROVED | První schválená verze standardu pro jednu kanonickou ACTIVE runtime strukturu, strojově čitelný runtime manifest, řízenou migraci, klasifikaci ACTIVE / LEGACY / UNKNOWN, verzování nahrazených programových souborů a vazbu na existující dokumentační standardy MatchMatrix. |

---

## Úvod a účel dokumentu

Projekt MatchMatrix obsahuje rozsáhlý soubor Python, PowerShell, VBS, CMD, BAT, SQL, konfiguračních, panelových a dalších provozních artefaktů vznikajících v několika vývojových etapách.

V průběhu vývoje mohou v repozitáři současně existovat:

- aktuální produkční soubory,
- starší funkční generace,
- historické kopie,
- experimentální varianty,
- testovací skripty,
- nástroje určené pouze pro jednorázový audit,
- soubory s verzemi v názvu,
- soubory bez zřejmé runtime vazby,
- části již uložené v `legacy`,
- soubory, jejichž skutečný stav není bez auditu jednoznačný.

Účelem tohoto standardu je zavést řízený systém, ve kterém je možné kdykoliv spolehlivě určit:

1. který soubor je aktuálně aktivní,
2. jakou má roli,
3. odkud je spouštěn,
4. na čem závisí,
5. jaké další artefakty spouští,
6. zda byl runtime ověřen,
7. která verze byla nahrazena,
8. kde je uložena historická kopie,
9. jak lze změnu vrátit zpět,
10. jak je změna zachycena v dokumentaci a Git historii.

Cílem je vytvořit jednu důvěryhodnou provozní pravdu pro aktivní systém MatchMatrix bez ztráty historie a bez vzniku paralelního dokumentačního systému.

---

## Související dokumenty

Tento standard nenahrazuje existující dokumentační ani vývojové standardy. Doplňuje je pro oblast runtime artefaktů a aktivního systému.

Závazné návaznosti:

- `MM-STD-003` – Standard životního cyklu dokumentace a verzování,
- `MM-STD-004` – Standard názvosloví a struktury dokumentace,
- `MM-STD-007` – Identifikace a číslování dokumentů MatchMatrix,
- `MM-STD-009` – AI Context a Project Snapshot,
- `MM-STD-1000` – Index standardů MatchMatrix,
- `MM-DOC-300` – MatchMatrix Architecture,
- `MM-DOC-800` – MatchMatrix Development Handbook,
- `MM-DOC-900` – MatchMatrix Denní zápisy,
- `MM-DOC-901` – MatchMatrix NAVÁZÁNÍ,
- příslušné providerové, databázové a provozní dokumenty podle měněné oblasti.

---

# 1. Základní principy

## 1.1 Jedna aktivní runtime pravda

Pro jeden konkrétní provozní účel smí existovat právě jeden artefakt označený jako kanonicky aktivní.

Pokud existuje více souborů se stejnou nebo podobnou funkcí, nesmí být pouze podle názvu automaticky určeno, který je aktuální.

Stav musí být potvrzen důkazem, například:

- aktivním importem,
- přímým voláním z panelu,
- launcherem,
- schedulerem,
- databázovým command queue,
- runtime logem,
- auditním během,
- explicitní aktivní konfigurací.

## 1.2 ACTIVE není určeno pouze názvem souboru

Soubor není ACTIVE jen proto, že:

- má nejvyšší číslo verze,
- nemá v názvu slovo `old`,
- leží mimo složku `legacy`,
- byl změněn nejpozději,
- má název `FINAL`, `NEW`, `FIX` nebo podobný příznak.

ACTIVE stav musí být ověřen skutečnou vazbou na runtime nebo explicitním schválením po technickém auditu.

## 1.3 Historie se neztrácí

Nahrazený aktivní soubor se nemaže bez řízeného důvodu.

Před výměnou musí být:

1. identifikován,
2. archivován do LEGACY,
3. označen verzí archivu,
4. zapsán do runtime manifestu nebo changelogu,
5. dohledatelný vůči nové aktivní verzi.

## 1.4 Bezpečnost před rychlostí

Žádný soubor se nepřesouvá do LEGACY pouze proto, že vypadá starý.

Pokud není stav prokázán, používá se klasifikace `UNKNOWN` nebo `LEGACY_CANDIDATE`.

## 1.5 Migrace nesmí rozbít runtime

Fyzické přesunutí aktivního artefaktu je povoleno až po identifikaci jeho:

- importů,
- hardcoded cest,
- relativních cest,
- launcherů,
- schedulerů,
- panelových vazeb,
- databázových příkazů,
- dalších runtime závislostí.

---

## 1.99 Závěr kapitoly

Kapitola stanovila základní princip jediné aktivní runtime pravdy, povinné důkazní ověření a zákaz neřízeného přesunu nebo mazání nejasných souborů.

---

# 2. Rozsah standardu

Standard se vztahuje na aktivní technické artefakty MatchMatrix, zejména:

- Python skripty,
- PowerShell skripty,
- VBS launchery,
- CMD a BAT soubory,
- aktivní SQL provozní skripty,
- panely a ovládací nástroje,
- scheduler a queue workery,
- ingest workery,
- providerové moduly,
- pull / harvest skripty,
- parsery,
- staging a merge procesy,
- People Layer,
- Media Layer,
- Odds Layer,
- ratingové a predikční procesy,
- Ticket Engine,
- provozní konfigurace,
- auditní a monitoring nástroje, pokud jsou součástí běžného provozu,
- frontendové zdrojové soubory, pokud budou do ACTIVE systému řízeně zahrnuty.

Standard se nevztahuje automaticky na:

- externí závislosti typu `node_modules`,
- cache,
- `__pycache__`,
- dočasné soubory,
- logy,
- jednorázové exporty,
- databázové zálohy,
- pracovní přílohy,
- generované build artefakty,
- řízenou dokumentaci v `docs`, která podléhá primárně dokumentačním standardům.

Dokumentace zůstává kanonicky spravována ve stávající dokumentační struktuře a Git repozitáři.

---

## 2.99 Závěr kapitoly

Kapitola oddělila aktivní runtime artefakty od dokumentace, externích závislostí, logů, cache a dočasných souborů.

---

# 3. Kanonický ACTIVE systém

## 3.1 Cílový kořen

Cílový kořen aktivního runtime systému je:

```text
\\Matchmatrix\matchmatrix\MATCHMATRIX_ACTIVE_SYSTEM\
```

Tento kořen představuje cílovou kanonickou strukturu aktivních provozních artefaktů.

## 3.2 Přechodový režim

Do úplného dokončení migrace zůstává současný provozní projekt:

```text
C:\MatchMatrix-platform\
```

zdrojem skutečného runtime tam, kde ještě nebyla konkrétní větev bezpečně přepnuta.

Samotná přítomnost kopie v `MATCHMATRIX_ACTIVE_SYSTEM` neznamená, že z ní již produkce skutečně běží.

Každá migrovaná větev musí mít stav uvedený v manifestu.

## 3.3 Základní struktura ACTIVE systému

Cílová struktura obsahuje zejména:

```text
MATCHMATRIX_ACTIVE_SYSTEM\
├── 00_ENTRYPOINTS\
├── 01_ORCHESTRATION\
├── 02_INGEST\
├── 03_PEOPLE\
├── 04_MEDIA\
├── 05_ODDS\
├── 06_MODELS\
├── 07_TICKET_ENGINE\
├── 08_DATABASE\
├── 09_OPS\
├── 10_FRONTEND\
├── 11_TOOLS\
├── 12_CONFIG\
├── 13_TESTS\
├── 14_DOCUMENTATION\
└── SYSTEM_MANIFEST\
```

`14_DOCUMENTATION` nesmí vytvářet druhou kanonickou dokumentaci vedle `docs`. Může obsahovat pouze runtime odkazy, lokální technické instrukce nebo generované vazby, pokud budou později výslovně schváleny. Primární dokumentace zůstává v `docs`.

## 3.4 Sportovní struktura

Sportovní podsložky se vytvářejí podle skutečně evidovaného a schváleného sportovního rozsahu platformy.

Při vzniku tohoto návrhu je v `ops.ingest_targets` evidováno 14 sportovních kódů:

```text
AFB
BK
BSB
CK
DRT
ESP
FB
FH
HB
HK
MMA
RGB
TN
VB
```

Odpovídající názvy složek musí být jednotné napříč oblastmi INGEST a PEOPLE.

---

## 3.99 Závěr kapitoly

Kapitola stanovila cílový ACTIVE kořen, přechodový režim vůči `C:\MatchMatrix-platform` a hlavní adresářovou strukturu bez automatického přepnutí dosud neověřených runtime větví.

---

# 4. Klasifikace runtime artefaktů

Každý auditovaný artefakt získá právě jeden hlavní klasifikační stav.

## 4.1 ACTIVE_ENTRYPOINT

Artefakt, který uživatel nebo systém přímo spouští.

Příklady:

- hlavní panel,
- aktivní VBS launcher,
- plánovaná úloha,
- command center entrypoint.

## 4.2 ACTIVE_RUNTIME

Artefakt prokazatelně volaný aktivním entrypointem nebo jiným ACTIVE runtime artefaktem.

## 4.3 ACTIVE_SUPPORT

Podpůrný modul, konfigurace, knihovna nebo helper nutný pro funkci ACTIVE runtime větve.

## 4.4 UNKNOWN

Stav není dosud prokázán.

UNKNOWN artefakt se nesmí bez dalšího auditu přesunout do LEGACY ani odstranit.

## 4.5 LEGACY_CANDIDATE

Artefakt vypadá jako nahrazený nebo historický, ale ještě nebylo dokončeno ověření všech vazeb.

## 4.6 LEGACY_CONFIRMED

Artefakt je prokazatelně nahrazený a není používán aktivním runtime.

Teprve tento stav opravňuje k řízenému přesunu do LEGACY.

## 4.7 BLOCKED

Artefakt nelze bezpečně klasifikovat nebo migrovat kvůli chybějícím důkazům, konfliktu cest, nejasné závislosti nebo nedokončenému auditu.

---

## 4.99 Závěr kapitoly

Kapitola zavedla jednoznačné runtime klasifikace, které zabraňují zaměnění starého souboru za aktivní nebo naopak předčasnému přesunu důležitého souboru do LEGACY.

---

# 5. SYSTEM_MANIFEST

## 5.1 Účel

`SYSTEM_MANIFEST` je strojově čitelná provozní evidence skutečného aktivního systému.

Není druhou dokumentací projektu.

Dokumentační standardy určují pravidla. Runtime manifest eviduje aktuální technický stav.

## 5.2 Umístění

```text
\\Matchmatrix\matchmatrix\MATCHMATRIX_ACTIVE_SYSTEM\SYSTEM_MANIFEST\
```

## 5.3 Základní soubory

Po schválení tohoto standardu se doporučuje používat:

```text
ACTIVE_SYSTEM_MANIFEST.csv
ACTIVE_DEPENDENCIES.csv
ACTIVE_ENTRYPOINTS.csv
MIGRATION_STATUS.csv
CHANGELOG.md
```

## 5.4 ACTIVE_SYSTEM_MANIFEST.csv

Minimální pole:

```text
artifact_key
file_name
artifact_type
domain
role
sport_scope
classification
source_path
canonical_active_path
runtime_source
verification_level
sha256
last_verified_at
legacy_sequence
notes
```

`artifact_key` je interní stabilní technický klíč runtime artefaktu. Není Document ID a nesmí být zaměňován s identitou řízeného dokumentu dle MM-STD-007.

## 5.5 ACTIVE_DEPENDENCIES.csv

Minimální pole:

```text
source_artifact_key
target_artifact_key
dependency_type
discovery_method
status
last_verified_at
notes
```

Příklady `dependency_type`:

- IMPORT,
- SUBPROCESS,
- POWERSHELL_CALL,
- LAUNCHER,
- PANEL_ACTION,
- SCHEDULER,
- DB_COMMAND,
- CONFIG_REFERENCE,
- FILE_REFERENCE.

## 5.6 ACTIVE_ENTRYPOINTS.csv

Minimální pole:

```text
entrypoint_key
name
entrypoint_type
source_path
canonical_active_path
launch_method
classification
last_verified_at
notes
```

## 5.7 MIGRATION_STATUS.csv

Minimální pole:

```text
artifact_key
source_path
target_path
classification
migration_status
reference_update_status
smoke_test_status
rollback_status
last_action_at
notes
```

## 5.8 CHANGELOG.md

Zachycuje významné změny ACTIVE runtime systému, zejména:

- první zařazení aktivního artefaktu,
- fyzický přesun,
- změnu runtime cesty,
- výměnu aktivního souboru,
- přesun předchozí verze do LEGACY,
- rollback,
- změnu klasifikace,
- významnou změnu dependency mapy.

---

## 5.99 Závěr kapitoly

Kapitola definovala runtime manifest jako strojově čitelný obraz aktuálního systému, nikoli jako náhradu existující dokumentace.

---

# 6. Úrovně důkazu a ověření

## 6.1 DISCOVERED

Soubor byl nalezen v projektu, ale jeho skutečná role není ověřena.

## 6.2 STATIC_VERIFIED

Byla ověřena statická vazba, například import, subprocess, cesta nebo konfigurace.

## 6.3 RUNTIME_VERIFIED

Byl pozorován nebo auditně potvrzen skutečný runtime běh.

## 6.4 END_TO_END_VERIFIED

Byla potvrzena celá funkční větev od entrypointu po očekávaný výstup.

## 6.5 GOVERNANCE_VERIFIED

Kromě runtime byl potvrzen také odpovídající governance kontrakt, například enabled target, approved policy, scope nebo jiná schválená podmínka.

Pro přesun kritického produkčního artefaktu do nové kanonické cesty se požaduje nejméně `RUNTIME_VERIFIED`; u kritických orchestration a harvest větví se doporučuje `END_TO_END_VERIFIED` nebo `GOVERNANCE_VERIFIED`.

---

## 6.99 Závěr kapitoly

Kapitola stanovila, že ACTIVE stav musí být podložen měřitelnou úrovní důkazu a ne pouhým odhadem podle názvu nebo data souboru.

---

# 7. Pravidla názvů aktivních programových souborů

## 7.1 Soulad s MM-DOC-800

Tento standard nesmí v DRAFT ani během počáteční migrace automaticky měnit zavedené aktivní názvy programových souborů.

`MM-DOC-800` v aktuální dokumentované podobě připouští u aktivních skriptů dohodnuté aktivní označení, typicky `_V1`.

Proto platí přechodové pravidlo:

> Při první migraci se název prokazatelně aktivního runtime souboru zachová, pokud jeho změna není samostatně schválena a všechny závislosti nejsou bezpečně přesměrovány.

## 7.2 Stabilní kanonický název po migraci

Jakmile je soubor zařazen do ACTIVE systému, jeho potvrzený aktivní název se považuje za stabilní kanonický název pro danou runtime větev.

To platí i tehdy, pokud název historicky obsahuje označení typu `_v1`, `_v3` nebo jiné generační označení.

Číslo v historicky zavedeném názvu se nesmí automaticky zvyšovat při každé další obsahové úpravě.

## 7.3 Budoucí sjednocení názvů

Případné odstranění historických verzovacích tokenů z aktivních názvů bude samostatná řízená změna.

Před jejím zavedením musí být:

1. upraven nebo výslovně sladěn `MM-DOC-800`,
2. ověřeny všechny importy a cesty,
3. provedena řízená migrace,
4. proveden smoke test,
5. aktualizován runtime manifest,
6. změna zapsána do dokumentace.

Tím se zabrání rozporu mezi tímto standardem a již zavedeným Development Handbookem.

---

## 7.99 Závěr kapitoly

Kapitola zachovává kompatibilitu s existujícím MM-DOC-800 a odděluje okamžitou runtime inventuru od případného budoucího přejmenování aktivních skriptů.

---

# 8. LEGACY a verzování nahrazených programových souborů

## 8.1 Základní princip

Před nahrazením aktivního souboru se jeho úplná předchozí kopie uloží do odpovídající LEGACY větve.

Aktivní systém vždy obsahuje pouze aktuální aktivní variantu dané runtime role.

## 8.2 Sekvence LEGACY verzí

Pro nově řízené výměny se používá sekvence:

```text
V1
V2
V3
...
```

Sekvence vyjadřuje pořadí archivace v rámci konkrétní aktivní role, nikoli automaticky produktovou nebo dokumentovou verzi.

## 8.3 Existující soubory s verzí v názvu

Pokud již aktivní soubor obsahuje historickou verzi v názvu, nesmí být kvůli zavedení tohoto standardu automaticky přejmenován.

V takovém případě se:

- zachová jeho aktivní název,
- pořadí archivace vede v poli `legacy_sequence`,
- archivní kopie se pojmenuje tak, aby nevznikla kolize ani dvojí význam verze,
- přesný archivní název musí být zapsán v manifestu.

Příklad přechodového stavu:

```text
ACTIVE:
run_ingest_cycle_v3.py

LEGACY pořadí:
legacy_sequence = V1
```

Fyzický archivní název se stanoví při migraci konkrétní větve tak, aby zachoval původní název a současně jednoznačně vyjádřil archivní pořadí.

## 8.4 LEGACY není aktivní runtime

LEGACY soubor:

- nesmí být cílem běžného launcheru,
- nesmí být implicitně importován aktivním kódem,
- nesmí být součástí scheduleru,
- nesmí být aktivním command queue příkazem,
- smí být použit pro rollback pouze řízeným postupem.

---

## 8.99 Závěr kapitoly

Kapitola zavedla řízenou archivaci předchozích programových verzí bez nebezpečného automatického přejmenování historicky zavedených aktivních souborů.

---

# 9. Cílová LEGACY struktura

Cílem je dlouhodobě oddělit aktivní runtime od historických programových souborů.

Preferovaný logický model:

```text
MATCHMATRIX_LEGACY\
├── 00_ENTRYPOINTS\
├── 01_ORCHESTRATION\
├── 02_INGEST\
├── 03_PEOPLE\
├── 04_MEDIA\
├── 05_ODDS\
├── 06_MODELS\
├── 07_TICKET_ENGINE\
├── 08_DATABASE\
├── 09_OPS\
├── 10_FRONTEND\
├── 11_TOOLS\
├── 12_CONFIG\
└── 13_TESTS\
```

Existující `C:\MatchMatrix-platform\legacy\` zůstává během migrace platným historickým zdrojem a nesmí být hromadně přesouván nebo přejmenován bez samostatné inventury.

Konečné fyzické umístění `MATCHMATRIX_LEGACY` bude potvrzeno samostatným migračním krokem.

---

## 9.99 Závěr kapitoly

Kapitola definuje cílové oddělení aktivního a historického runtime, ale chrání existující legacy obsah před neřízeným hromadným přesunem.

---

# 10. Řízený postup migrace

Každá runtime větev se migruje samostatně.

Povinný postup:

```text
DISCOVERY
→ DEPENDENCY MAP
→ CLASSIFICATION
→ COPY / PREPARE
→ REFERENCE UPDATE
→ STATIC TEST
→ RUNTIME TEST
→ SWITCHOVER
→ VERIFY
→ ARCHIVE PREVIOUS
→ MANIFEST UPDATE
→ DOCUMENTATION UPDATE
→ GIT
```

## 10.1 Discovery

Identifikují se všechny kandidátní soubory dané funkční větve.

## 10.2 Dependency Map

Ověří se:

- kdo soubor spouští,
- koho soubor spouští,
- importy,
- subprocess vazby,
- PowerShell vazby,
- hardcoded cesty,
- relativní cesty,
- databázové command texty,
- plánované úlohy,
- panelové button bindings.

## 10.3 Classification

Každý soubor získá klasifikaci dle kapitoly 4.

## 10.4 Copy / Prepare

Artefakt může být nejprve připraven v cílové struktuře bez okamžitého přepnutí produkce.

## 10.5 Reference Update

Cesty a importy se aktualizují řízeně pouze v rozsahu konkrétní migrované větve.

## 10.6 Test

Nejméně:

- syntax / import test,
- existence dependencies,
- smoke test,
- podle významu end-to-end test.

## 10.7 Switchover

Teprve po úspěšném testu se nová kanonická cesta stává produkční.

## 10.8 Archive Previous

Původní aktivní varianta se přesune nebo zkopíruje do LEGACY podle schváleného migračního postupu.

## 10.9 Manifest a dokumentace

Aktualizuje se runtime manifest a významná změna se zapíše do existující dokumentace MatchMatrix.

---

## 10.99 Závěr kapitoly

Kapitola stanovila transakční způsob migrace po funkčních větvích, nikoli jednorázový hromadný přesun celého repozitáře.

---

# 11. Runtime dependency chain

U kritických pipeline musí být možné zobrazit celý skutečný řetězec spuštění.

Příklad orchestration mapy:

```text
PANEL
→ LAUNCHER
→ INGEST CYCLE
→ PLANNER
→ UNIFIED INGEST
→ PROVIDER REGISTRY
→ PROVIDER
→ PULL
→ RAW
→ PARSER
→ STAGING
→ MERGE
→ PUBLIC
→ AUDIT
```

Každý článek se eviduje samostatně.

Pokud pipeline obsahuje speciální větev, musí být v dependency mapě explicitně uvedena.

Hardcoded special case se nesmí považovat za univerzální architekturu pouze proto, že aktuálně funguje pro jeden provider nebo jednu entitu.

---

## 11.99 Závěr kapitoly

Kapitola vyžaduje skutečnou execution mapu místo předpokládané architektury a připravuje základ pro bezpečné zobecňování orchestrace.

---

# 12. Provider, sport a entity governance

ACTIVE systém musí být připraven na multisportovní a vícezdrojovou architekturu.

Aktivace konkrétní runtime větve se nesmí odvozovat pouze z názvu provideru.

Cílový rozhodovací model je:

```text
SPORT
→ PROVIDER
→ ENTITY
→ OBDOBÍ
→ CAPABILITY / DŮKAZ
→ GOVERNANCE
→ COVERAGE ROLE
→ RUNTIME ROUTING
```

Pokud provider neposkytuje dostatečná data pro konkrétní entitu, entita se pro něj nesmí aktivovat pouze proto, že jiná entita stejného provideru funguje.

To se týká například vrstev:

- players,
- player statistics,
- lineups,
- events,
- coaches,
- odds,
- media,
- dalších sport-specific dat.

Runtime manifest musí umožnit určit, pro kterou kombinaci provider / sport / entity je daný artefakt skutečně relevantní.

---

## 12.99 Závěr kapitoly

Kapitola propojuje ACTIVE runtime strukturu s providerovou a coverage governance a zabraňuje hardcoded předpokladu, že jeden provider pokrývá všechny entity sportu.

---

# 13. Git a GitHub

## 13.1 Git zůstává historií zdrojového projektu

Tento standard nenahrazuje Git historii.

GitHub zůstává hlavním verzovaným zdrojem projektového kódu a dokumentace podle existujícího workflow.

## 13.2 ACTIVE runtime není náhradou repozitáře

`MATCHMATRIX_ACTIVE_SYSTEM` je kanonická provozní struktura aktivního systému.

Její vztah k Git repozitáři musí být jednoznačně definován před plným přepnutím produkce.

Nesmí vzniknout stav, kdy se změna provede pouze v ACTIVE runtime a není dohledatelná v projektovém zdrojovém repozitáři, pokud daný artefakt do Git repozitáře patří.

## 13.3 Významná změna

Významné změny se zaznamenávají nejméně do:

- Git historie,
- SYSTEM_MANIFEST changelogu,
- denního zápisu,
- NAV dokumentu při předání do nového chatu nebo etapy,
- architektonického nebo vývojového dokumentu, pokud změna mění trvalé pravidlo systému.

---

## 13.99 Závěr kapitoly

Kapitola zachovává GitHub jako verzovaný zdroj projektu a vymezuje ACTIVE systém jako provozní pravdu, nikoli jako náhradu správy zdrojového kódu.

---

# 14. Vazba na dokumentační standardy

## 14.1 Žádná paralelní dokumentace

SYSTEM_MANIFEST není nový dokumentační framework.

Normativní pravidla zůstávají v `docs`.

## 14.2 MM-STD-003

Princip jediné aktivní pravdy a řízené historie se přebírá analogicky, ale tento standard jej aplikuje na runtime artefakty.

Dokumentový archiv `docs/99_ARCHIVE` a programový LEGACY archiv jsou dvě odlišné oblasti.

## 14.3 MM-STD-004

Tento standard nezavádí nový dokumentový prefix ani nemění pravidla názvů řízené dokumentace.

## 14.4 MM-STD-007

`MM-STD-011` je ověřené a přidělené Document ID tohoto standardu. Před jeho potvrzením byly provedeny předepsané kontroly:

- index standardů,
- aktivní dokumentace,
- Git historie,
- `docs/99_ARCHIVE`,
- dokumentační databáze,
- historické aliasy.

## 14.5 MM-STD-1000

Nový standard se nesmí považovat za plně zavedený, dokud není zapsán v `MM-STD-1000`. Pro `MM-STD-011` je podmínka registrace splněna.

## 14.6 MM-DOC-800

Do doby koordinované aktualizace názvosloví aktivních programových souborů se zachovávají existující názvy a tento standard nesmí jednostranně přepisovat pravidla Development Handbooku.

---

## 14.99 Závěr kapitoly

Kapitola výslovně chrání soulad s existujícím dokumentačním systémem a zakazuje zavedení MM-STD-011 jako izolovaného paralelního pravidla.

---

# 15. Rollback

Každá změna aktivního runtime artefaktu musí mít možnost řízeného návratu, pokud je technicky realizovatelná.

Před switchoverem musí být známé:

- předchozí aktivní umístění,
- archivní kopie,
- změněné reference,
- způsob vrácení reference,
- databázové nebo konfigurační dopady,
- podmínky, kdy je rollback nutný.

Rollback nesmí automaticky vracet databázové změny, pokud by tím vznikla nekonzistence. Databázový rollback se řídí vlastní transakční a migrační governance.

---

## 15.99 Závěr kapitoly

Kapitola stanovila povinnost plánovat návrat před aktivací nové runtime varianty a odděluje souborový rollback od databázového rollbacku.

---

# 16. Kontrolní checklist před označením ACTIVE

Artefakt může být označen jako kanonicky ACTIVE pouze tehdy, pokud jsou podle jeho významu splněny relevantní body:

- [ ] soubor existuje,
- [ ] jeho role je popsána,
- [ ] je znám jeho skutečný spouštěč,
- [ ] jsou známé hlavní downstream závislosti,
- [ ] byly zkontrolovány hardcoded cesty,
- [ ] byly zkontrolovány importy,
- [ ] byla zkontrolována scheduler / panel / DB command vazba,
- [ ] klasifikace není založena pouze na názvu nebo datu,
- [ ] existuje důkaz alespoň STATIC_VERIFIED,
- [ ] pro produkční přepnutí existuje runtime důkaz,
- [ ] cílová cesta je správná,
- [ ] není vytvořena druhá paralelní aktivní varianta,
- [ ] předchozí aktivní varianta je dohledatelná,
- [ ] je připraven rollback,
- [ ] manifest byl aktualizován,
- [ ] významná změna byla zapsána do dokumentace,
- [ ] změna je podle potřeby publikována do Git.

---

## 16.99 Závěr kapitoly

Kapitola stanovila minimální Definition of Active pro runtime artefakty MatchMatrix.

---

# 17. Výjimky

Výjimka z tohoto standardu musí být:

1. explicitní,
2. časově nebo věcně omezená,
3. zaznamenaná v manifestu nebo dokumentaci,
4. odůvodněná technickou nutností,
5. nesmí vytvořit neoznačenou druhou aktivní pravdu.

Výjimkou může být například dočasný pracovní experiment, který ještě nevstoupil do produkčního runtime.

---

## 17.99 Závěr kapitoly

Kapitola umožňuje řízené výjimky, ale zakazuje skryté paralelní runtime větve bez evidovaného stavu.

---

# 18. Aktivace tohoto standardu

Verze 1.0 je ve stavu `APPROVED`.

Stav `APPROVED` znamená, že dokument prošel řízenou kontrolou a uživatelským schválením. Neznamená automaticky, že byla dokončena fyzická migrace runtime, aktivace SYSTEM_MANIFEST kontraktu nebo produkční switchover.

Před potvrzením identity a schválením verze 1.0 byly provedeny zejména:

1. ověření volnosti a správnosti `MM-STD-011` dle `MM-STD-007`,
2. kontrola aktivní dokumentace a `docs/99_ARCHIVE`,
3. kontrola Git historie,
4. kontrola dokumentační databáze,
5. zápis standardu do `MM-STD-1000`,
6. kontrola rozporů s `MM-DOC-800`,
7. A17 / dokumentační kontrola podle aktuálního workflow,
8. uživatelské schválení.

Po obsahových opravách tohoto dokumentu a indexu musí znovu proběhnout příslušná kontrola a publikační workflow. Databázový import smí pokračovat přes `A24 VALIDATE_ONLY` a teprve po úspěšné validaci přes řízený APPLY.

Aktivace prvního finálního SYSTEM_MANIFEST kontraktu následuje až po dokončení dokumentační publikace a před zahájením řízeného switchoveru první runtime větve.

---

## 18.99 Závěr kapitoly

Kapitola potvrzuje stav `APPROVED`, odděluje schválení dokumentu od produkčního switchoveru a zachovává povinnost dokončit validační, databázové a publikační kroky před aktivací prvního SYSTEM_MANIFEST kontraktu.
---

# 19. Závěr

MatchMatrix potřebuje jasně oddělit:

```text
CO JE AKTIVNÍ
CO JE HISTORICKÉ
CO JE NEOVĚŘENÉ
CO JE POUZE TEST
CO JE SKUTEČNĚ SPOUŠTĚNO
```

`MATCHMATRIX_ACTIVE_SYSTEM` má vytvořit jedinou přehlednou kanonickou strukturu aktivních runtime artefaktů.

`SYSTEM_MANIFEST` má být strojově čitelným důkazem skutečného stavu.

LEGACY má bezpečně uchovávat nahrazené programové verze.

GitHub a existující dokumentační framework zůstávají hlavním systémem řízené dokumentace a historie projektu.

Zavedení tohoto standardu proto není pouhý přesun souborů. Jde o řízenou konsolidaci skutečné provozní architektury MatchMatrix.

---

# AI CONTEXT

Tento dokument stanovuje schválený standard pro správu aktivního runtime systému MatchMatrix.

Klíčové zásady pro AI:

- nepovažovat nejvyšší číslo verze automaticky za aktivní soubor,
- nepřesouvat UNKNOWN soubory do LEGACY bez důkazu,
- pracovat po jedné runtime větvi,
- rozlišovat statický důkaz od skutečného runtime důkazu,
- zachovávat existující názvy během první migrace,
- nevytvářet paralelní dokumentaci vedle `docs`,
- SYSTEM_MANIFEST chápat jako provozní registr, nikoli nový Documentation Management System,
- respektovat vazbu na MM-STD-003, MM-STD-004, MM-STD-007, MM-STD-1000 a MM-DOC-800,
- před každým přepnutím ověřit rollback.

---

# PROJECT SNAPSHOT

K datu 2026-10-01:

- byl vytvořen cílový kořen `\\Matchmatrix\matchmatrix\MATCHMATRIX_ACTIVE_SYSTEM\`,
- byla vytvořena základní adresářová kostra,
- v oblasti PEOPLE a INGEST je připravena sportovní struktura pro aktuální sportovní rozsah,
- probíhá audit skutečné runtime orchestrace,
- potvrzená cesta zahrnuje panel, `run_ingest_cycle_v3.py`, `run_ingest_planner_jobs.py`, `run_unified_ingest_v1.py` a provider registry,
- fyzický přesun produkčního runtime zatím nebyl proveden,
- standard `MM-STD-011` je schválen a registrován; SYSTEM_MANIFEST kontrakt zatím není aktivován, dokud není dokončena dokumentační publikace a založena jeho první řízená verze.

---

# DATABASE SNAPSHOT

Aktuální sportovní kódy z `ops.ingest_targets` při vzniku návrhu:

```text
AFB
BK
BSB
CK
DRT
ESP
FB
FH
HB
HK
MMA
RGB
TN
VB
```

Tento seznam je projektový snapshot, nikoli neměnný limit standardu.

---

# CURRENT STATUS

```text
STANDARD_STATUS           = APPROVED
DOCUMENT_ID               = MM-STD-011
REGISTRATION_STATUS       = REGISTERED
MM_STD_1000_REGISTRATION  = REGISTERED
ACTIVE_SYSTEM_ROOT        = CREATED
DIRECTORY_SKELETON        = CREATED
DOCUMENTATION_DB_IMPORT   = PENDING_A24
RUNTIME_MIGRATION         = NOT_STARTED
SYSTEM_MANIFEST_CONTRACT  = APPROVED_PENDING_INITIALIZATION
PRODUCTION_SWITCHOVER     = NOT_STARTED
```

---

# OPEN QUESTIONS

1. Finální fyzické umístění sjednoceného `MATCHMATRIX_LEGACY`.
2. Zda a kdy bude `MATCHMATRIX_ACTIVE_SYSTEM` přímo Git working tree, deployment target nebo řízená runtime kopie.
3. Finální pravidlo fyzického názvu archivních souborů, jejichž aktivní název již obsahuje historický token `_vN`.
4. Rozsah budoucího sjednocení aktivních názvů programových souborů a odpovídající změna `MM-DOC-800`.
5. Které testovací a auditní utility mají být ACTIVE_SUPPORT a které pouze historické / ad hoc nástroje.

---

# NEXT STEP

Po sjednocení metadat `MM-STD-011` a aktualizaci `MM-STD-1000`:

1. znovu spustit dokumentační kontrolu / A17 nad opravenými dokumenty,
2. spustit A24 v režimu `VALIDATE_ONLY`,
3. po úspěšné validaci provést řízený A24 APPLY,
4. ověřit synchronizaci dokumentační databáze a Git/GitHub publikace,
5. založit první řízenou verzi SYSTEM_MANIFEST,
6. zahájit řízenou migraci první potvrzené runtime větve:

```text
PANEL
→ INGEST CYCLE
→ PLANNER
→ UNIFIED INGEST
→ PROVIDER REGISTRY
→ PROVIDER
```

Bulk harvest ani hromadný přesun UNKNOWN artefaktů se před dokončením příslušných auditů nepovoluje.
