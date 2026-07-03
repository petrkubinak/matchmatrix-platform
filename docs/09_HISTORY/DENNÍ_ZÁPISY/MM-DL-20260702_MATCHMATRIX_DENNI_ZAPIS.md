# MM-DL-20260702

# MATCHMATRIX – DENNÍ ZÁPIS – 2026-07-02

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DL-20260702 |
| Název | MatchMatrix – denní zápis – 2026-07-02 |
| Typ | Denní pracovní zápis |
| Verze | 1.0 |
| Stav | REVIEW |
| Datum | 2026-07-02 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Hlavní oblast | Dokumentační systém a historický korpus |
| Primární prostředí | PC2 – `C:\MatchMatrix-Platform` |
| Navazující dokument | MM-NAV-20260702-01 |
| Primární formát | Markdown (.md) |

---

# 1. Cíl pracovního dne

Hlavním cílem bylo dokončit kontrolu kanonické dokumentační databáze a připravit bezpečný způsob uložení historických dokumentů MatchMatrix do PostgreSQL.

Historické soubory mají sloužit jako znalostní základ projektu. Nemají být přepisovány do současné struktury ani blokovány kvůli chybějícím hlavičkám, starým názvům nebo nestandardnímu obsahu. Databáze má zachovat celý dostupný obsah, původní zdrojové cesty, formáty, hashe a přirozené sekce.

---

# 2. Výchozí stav

Na začátku práce již existovalo:

- schéma PostgreSQL `documentation`,
- kanonické tabulky dokumentů, verzí, sekcí, vazeb a importních běhů,
- importní workflow současných dokumentů,
- dokumentační panel s navigací mezi dokumenty,
- archiv historických souborů v umístění:

```text
\\192.168.3.119\matchmatrix\docs\99_ARCHIVE\09_HISTORY\historie 25062026
```

Otevřené otázky:

- zda použít existující databázové tabulky, nebo vytvářet nové,
- jak přidělit historickým záznamům stabilní identitu,
- jak zachovat celý obsah bez násilné standardizace,
- jak rozpoznat skutečný formát souboru,
- jak evidovat fyzické a obsahové duplicity,
- jak zabránit vložení souborů s hesly nebo jinými citlivými údaji.

---

# 3. Dokončení kanonické dokumentační větve

## 3.1 Dokumentační panel Q2

Byla vytvořena a otestována nová verze panelu:

```text
tools/matchmatrix_control_panel_V20_1_Q2_PC1_GLOSSARY_NAVIGATION.py
```

Byl připraven také spouštěč bez zobrazeného PowerShell okna:

```text
tools/launchers/SPUSTIT_MATCHMATRIX_PANEL_V20.1.Q2_PC1.vbs
```

Panel nyní podporuje navigaci:

```text
pojem
→ český překlad
→ stručné vysvětlení
→ související kapitola
→ celý zdrojový dokument
```

Bylo opraveno otevírání plného dokumentu. Panel nyní vyžaduje přesnou shodu interního `Document ID`, aby nemohl otevřít starší nebo nesprávně pojmenovaný soubor.

## 3.2 Referenční dokumenty

Byly vytvořeny:

```text
docs/10_REFERENCE/MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md
docs/10_REFERENCE/MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md
```

Přijaté pravidlo:

- MM-REF-001 je stručný překladový slovník,
- MM-REF-002 obsahuje delší vysvětlení, vazby a navigaci,
- stavové kódy a rozsáhlé definice nemají zatěžovat překladový slovník.

## 3.3 Oprava kanonického importéru

Byly upraveny dokumentační skripty související s novým slovníkem a importním manifestem.

Importér A6 byl následně opraven tak, aby:

- synchronizoval vazby podle aktuálního manifestu,
- odstranil zastaralé vazby,
- správně doplnil historii stavu i při změně aktuální verze bez změny textového stavu,
- evidoval počet odstraněných vazeb.

Výsledky opravného běhu:

```text
relations_deleted       : 1
status_history_inserted : 1
```

Finální kontrola kanonického dokumentačního systému:

```text
checks_total       : 415
checks_passed      : 415
warnings           : 0
blockers           : 0
expected_relations : 92
database_relations : 92
final_status       : DOCUMENTATION_IMPORT_VERIFIED
```

Související změny byly odeslány na GitHub v commitech:

```text
74f8807 feat(documentation): add glossary navigation and Q2 documentation panel
a3eeba1 fix(documentation): synchronize glossary paths and import integrity
```

---

# 4. Inventura historického archivu

Archiv obsahuje celkem 303 souborů.

Rozdělení podle přípon:

```text
144 × .md
105 × .txt
 28 × .png
  9 × .docx
  6 × .sql
  5 × .csv
  4 × .pdf
  2 × .xlsx
```

Byly vytvořeny inventurní a auditní reporty ve složce:

```text
C:\MatchMatrix-Platform\reports\documentation
```

Hlavní reporty:

```text
history_archive_inventory_20260702.csv
history_archive_hash_inventory_20260702.csv
history_archive_duplicates_20260702.csv
history_content_preview_20260702.csv
history_encoding_audit_20260702.csv
```

Binární hash audit zjistil:

```text
11 skupin přesných duplicit
23 souborů v přesných duplicitních skupinách
```

Přijaté rozhodnutí:

- původní soubory se nebudou mazat,
- databáze uchová jeden obsah a všechny zdrojové cesty,
- fyzický hash a obsahový hash se budou evidovat odděleně.

---

# 5. Soubory s nesprávnou příponou

Dva soubory označené jako CSV byly podle vnitřní struktury rozpoznány jako XLSX:

```text
komunikace s chatGPT/03_2026/20260302/EU_leagues.csv
komunikace s chatGPT/03_2026/20260302/Evropa do MatchMatrix.csv
```

Oba mají rozdílné binární SHA-256, ale stejný normalizovaný obsah sešitů.

Výsledek:

- budou vedeny jako jeden obsahový dokument,
- obě původní cesty zůstanou evidovány jako zdrojové varianty,
- importér nesmí slepě důvěřovat příponě souboru.

---

# 6. Ověření databázového modelu

Byla zkontrolována struktura, povinné sloupce, omezení a indexy tabulek:

```text
documentation.documents
documentation.document_versions
documentation.document_sections
documentation.document_status_history
documentation.import_runs
```

Bylo potvrzeno, že nové tabulky zatím nejsou potřeba.

Navržené mapování:

```text
documents
→ základní identita a metadata historického dokumentu

document_versions
→ celý vytěžený obsah, zdrojová cesta a obsahový hash

document_sections
→ přirozené nadpisy nebo technické vyhledávací bloky

document_status_history
→ auditní historie stavu ARCHIVED

import_runs
→ evidence validačních a importních běhů
```

Historické dokumenty mohou používat:

```text
Document ID    : MM-HIS-####
document_type  : HIS
status         : ARCHIVED
source_of_truth: FILE
```

Kontrola databáze potvrdila:

```text
existující MM-HIS dokumenty : 0
```

---

# 7. Vytvoření importéru historického korpusu

Byl vytvořen samostatný skript:

```text
tools/documentation/25_1_A_25_IMPORT_HISTORY_CORPUS_TO_DB_V1.py
```

Podporované režimy:

```text
--validate-only
bez --apply = databázový dry run s rollbackem
--apply     = skutečný import
```

Hlavní schopnosti:

- rekurzivní načtení archivu,
- detekce skutečného formátu podle obsahu,
- načtení textových souborů v několika kódováních,
- extrakce DOCX a XLSX,
- volitelná extrakce PDF,
- metadata-only evidence obrazových příloh,
- SHA-256 fyzického souboru,
- SHA-256 normalizovaného obsahu,
- seskupování obsahových duplicit,
- evidence všech zdrojových variant,
- vytvoření přirozených vyhledávacích sekcí,
- zápis importních běhů do databáze.

Importér byl uložen na PC2 a jeho syntaxe byla ověřena.

---

# 8. První validační běh

První `--validate-only` běh vrátil:

```text
source_files                        : 303
corpus_documents                    : 292
content_duplicate_groups            : 10
source_files_in_duplicate_groups    : 21
sections                            : 2029
warnings                            : 32
final_status                        : HISTORY_CORPUS_VALIDATED_WITH_WARNINGS
```

Varování:

```text
28 × BINARY_ATTACHMENT_METADATA_ONLY
 4 × PDF_TEXT_EXTRACTION_DEPENDENCY_MISSING
```

Obrázky byly záměrně evidovány bez OCR. Čtyři PDF byly evidovány bez plné textové extrakce, protože nebyla dostupná knihovna `pypdf`.

---

# 9. Ochrana citlivých souborů

Při kontrole varování byly označeny dva soubory, které nesmějí být součástí databázového korpusu:

```text
KeePass.pdf
komunikace s chatGPT/02_2026/název v dockeru plus heslo.png
```

Importér byl rozšířen o seznam explicitně vyloučených relativních cest.

Původní soubory zůstávají v archivu. Nemají být importovány, indexovány ani použity pro vyhledávání.

---

# 10. Oprava kompilace

Při kompilaci se zobrazilo varování kvůli zpětným lomítkům v úvodním docstringu:

```text
SyntaxWarning: "\d" is an invalid escape sequence
```

Modulový docstring byl změněn na raw string.

Přísná kontrola následně prošla:

```powershell
py -3.14 -W error -m py_compile ".\tools\documentation\25_1_A_25_IMPORT_HISTORY_CORPUS_TO_DB_V1.py"
```

Výsledek:

```text
COMPILE_WITHOUT_WARNINGS_OK
```

---

# 11. Druhý validační běh po bezpečnostním patchi

Na konci dne byl proveden nový validační běh.

Výsledek:

```text
EXCLUDED_SENSITIVE : KeePass.pdf

source_files                        : 302
corpus_documents                    : 291
content_duplicate_groups            : 10
source_files_in_duplicate_groups    : 21
sections                            : 2028
warnings                            : 31
final_status                        : HISTORY_CORPUS_VALIDATED_WITH_WARNINGS
```

Vytvořený report:

```text
C:\MatchMatrix-platform\reports\documentation\history_corpus_manifest_20260702_233243.json
```

Aktuální reporty:

```text
C:\MatchMatrix-platform\reports\documentation\history_corpus_manifest_latest.json
C:\MatchMatrix-platform\reports\documentation\history_corpus_manifest_latest.csv
```

## Důležité zjištění

Z výstupu je potvrzeno pouze vyloučení souboru:

```text
KeePass.pdf
```

Druhý citlivý PNG soubor se ve výstupu jako `EXCLUDED_SENSITIVE` neobjevil.

Proto nelze považovat bezpečnostní filtr za dokončený. Pravděpodobně není přesná shoda relativní cesty nebo názvu. Důvod musí být zítra ověřen přímo podle nového manifestu nebo skutečného názvu souboru.

---

# 12. Přijatá rozhodnutí

1. Historické dokumenty zůstávají oddělené od kanonických dokumentů.
2. Historie nebude nuceně přepisována do současné struktury.
3. Celý vytěžený obsah se uloží do `document_versions`.
4. Sekce slouží pouze pro vyhledávání a navigaci.
5. Duplicity se nesmějí mazat ze zdrojového archivu.
6. Skutečný formát souboru má přednost před jeho příponou.
7. Citlivé soubory musí být vyloučeny ještě před databázovým dry runem.
8. Produkční `--apply` zůstává zakázán, dokud nebude bezpečnostní filtr kompletní.
9. Další práce pokračuje zásadně po jednom příkazu.

---

# 13. Aktuální stav

Dokončeno:

```text
Kanonický dokumentační import ověřen       DONE
Dokumentační panel Q2                       DONE
Slovník a výkladový rejstřík                DONE
Inventura historického archivu              DONE
Analýza duplicit                            DONE
Ověření databázového modelu                 DONE
Importér A25                                DONE
První validace                              DONE
Kompilace bez varování                      DONE
Druhá validace po patchi                    DONE
Vyloučení KeePass.pdf                       DONE
```

Otevřeno:

```text
Vyloučení PNG s údajem o hesle               PENDING
Kontrola stabilního přidělování MM-HIS ID    PENDING
Databázový dry run                           PENDING
Databázový audit dry runu                    PENDING
Produkční APPLY                              PENDING
Finální audit historického korpusu           PENDING
Git commit A25                               PENDING
```

Databáze na konci dne stále obsahuje:

```text
MM-HIS dokumenty : 0
```

Žádný skutečný import historického korpusu dnes neproběhl.

---

# 14. První krok pro další pracovní den

Nejprve je nutné zjistit přesnou cestu druhého citlivého PNG souboru v aktuálním manifestu a opravit bezpečnostní výjimku.

Teprve po potvrzení obou výjimek může následovat kontrola stability identifikátorů a databázový dry run.

Přesný navazující stav je uveden v dokumentu:

```text
MM-NAV-20260702-01
```

---

# 15. Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 1.0 | 2026-07-02 | První vydání denního zápisu. |

---

# Závěr

Dnešní práce uzavřela kanonickou dokumentační větev jako plně ověřenou a připravila samostatný importní mechanismus pro historický znalostní korpus MatchMatrix.

Archiv 303 souborů byl úspěšně analyzován, deduplikován podle normalizovaného obsahu a rozdělen do více než dvou tisíc vyhledávacích sekcí. Produkční import nebyl spuštěn, protože bezpečnostní kontrola odhalila, že druhý citlivý soubor zatím nebyl skutečně vyloučen.

Projekt tak končí v bezpečném stavu bez změny historického archivu a bez zápisu `MM-HIS` dokumentů do databáze.
