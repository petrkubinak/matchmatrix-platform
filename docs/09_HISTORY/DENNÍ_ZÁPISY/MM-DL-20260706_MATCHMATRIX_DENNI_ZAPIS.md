# MM-DL-20260706

# MATCHMATRIX – DENNÍ ZÁPIS – 2026-07-06

---

## Informace o dokumentu

| Položka | Hodnota                                                                  |
|---|--------------------------------------------------------------------------|
| Dokument | MM-DL-20260706                                                           |
| Název dokumentu | MatchMatrix – denní zápis – 2026-07-06                                   |
| Typ dokumentu | DAILY_LOG                                                                |
| Edice | HISTORY                                                                  |
| Verze | 1.0                                                                      |
| Stav | REVIEW                                                                   |
| Datum | 2026-07-06                                                               |
| Autor projektu | Petr                                                                     |
| Technická spolupráce | OpenAI ChatGPT                                                           |
| Projekt | MatchMatrix-platform                                                     |
| Hlavní oblast | Dokumentační databáze, Project Snapshot, A6/A24/A7 a struktura `docs`    |
| Primární prostředí | PC2 – `C:\MatchMatrix-Platform`                                          |
| Předchozí denní zápis | MM-DL-20260705                                                           |
| Navazující dokument | MM-NAV-20260706-01                                                       |
| Primární formát | Markdown (.md)                                                           |
| Cílové umístění | `docs/09_HISTORY/DENNÍ_ZÁPISY/MM-DL-20260706_MATCHMATRIX_DENNI_ZAPIS.md` |

---

# 1. Identifikace denního zápisu

Tento zápis zachycuje pracovní blok dokončený dne 2026-07-06. Hlavním tématem bylo technické dokončení publikování historického Project Snapshotu za březen 2026, oprava databázového importéru A6, ověření celého importního workflow A24 → A6 → A7 a následná kontrola fyzické struktury dokumentačních složek.

Práce byla vedena podle pravidla:

> Vždy pouze jeden příkaz nebo jeden jasný úkon. Po výsledku následuje další krok.

---

# 2. Výchozí stav

Na začátku pracovního bloku platilo:

- Project Snapshot `MM-PS-20260331` byl obsahově dokončen a uložen v repozitáři.
- Commit se snapshotem `aef0c18` byl úspěšně odeslán na GitHub.
- A24 již podporoval dokumenty typu Project Snapshot.
- Skutečný databázový import ještě nebyl dokončen.
- První DRY RUN skončil chybou uvnitř A6.
- V pracovním stromu byly necommitnuté soubory:
  - `MM-DL-20260705`,
  - `MM-NAV-20260705-01`,
  - obsah složky `docs/17_CHAT/`.
- Uživatel požaduje, aby při opravách dostával pouze nový aktivní soubor; původní verzi si sám ukládá do `tools/histori/`.

---

# 3. Provedené práce

## 3.1 Odeslání březnového Project Snapshotu na GitHub

Commit:

```text
aef0c18
```

byl úspěšně odeslán do větve:

```text
main
```

Rozsah push:

```text
97bc0a6..aef0c18
```

Tím byl zdrojový Markdown soubor `MM-PS-20260331` publikován v Git repozitáři.

## 3.2 První DRY RUN importu Project Snapshotu

Byl spuštěn A24:

```text
tools/documentation/25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py
```

pro dokument:

```text
docs/09_HISTORY/PROJECT_SNAPSHOTS/
MM-PS-20260331_MATCHMATRIX_PROJECT_SNAPSHOT_BREZEN_2026.md
```

A24 úspěšně:

- rozpoznal `MM-PS-20260331`,
- sestavil importní manifest,
- předal řízení A6.

A6 však skončil chybou:

```text
UnicodeDecodeError: 'charmap' codec can't decode byte 0x81
```

a následně:

```text
AttributeError: 'NoneType' object has no attribute 'strip'
```

Databázový DRY RUN byl zablokován před dokončením a žádná změna se trvale nezapsala.

## 3.3 Analýza příčiny chyby A6

Byla vypsána relevantní část zdrojového kódu A6.

Příčina byla nalezena ve funkci:

```python
git_snapshot()
```

A6 spouštěl Git pomocí:

```python
subprocess.run(..., text=True, capture_output=True)
```

bez explicitního kódování.

Na Windows se proto použilo systémové kódování `cp1250`, zatímco Git vracel UTF-8 text obsahující české znaky v cestách, například:

```text
docs/09_HISTORY/DENNÍ_ZÁPISY/
docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/
```

Čtecí vlákno `subprocess` spadlo při dekódování. Hodnota `completed.stdout` následně zůstala `None` a volání `.strip()` vyvolalo druhou chybu.

## 3.4 Oprava A6

Aktivní soubor:

```text
tools/documentation/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py
```

byl upraven tak, aby Git výstup vždy četl jako UTF-8:

```python
encoding="utf-8",
errors="replace",
```

Současně bylo přidáno bezpečné zpracování prázdného výstupu:

```python
return (completed.stdout or "").strip()
```

Původní verze byla uživatelem uložena jako:

```text
tools/histori/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V2.py
```

Bylo potvrzeno nové pracovní pravidlo:

> Asistent posílá pouze opravený aktivní soubor. Historickou kopii si uživatel vytváří a ukládá sám.

## 3.5 Úspěšný opakovaný DRY RUN

Po výměně A6 byla nejprve ověřena syntaxe a následně znovu spuštěn A24 DRY RUN.

Výsledek:

```text
FINAL STATUS: HISTORY_DOCUMENT_IMPORT_DRY_RUN_READY
```

Simulovaný import by provedl:

| Objekt | Počet |
|---|---:|
| Dokumenty vložené | 1 |
| Verze vložené | 1 |
| Sekce vložené | 110 |
| Vazby vložené | 1 |
| Historie stavu | 1 |
| Varování | 0 |

DRY RUN byl zakončen rollbackem, tedy bez trvalého zápisu.

## 3.6 Commit a push opravy A6

Do stagingu byly zařazeny pouze:

```text
tools/documentation/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py
tools/histori/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V2.py
```

Byl vytvořen commit:

```text
e108070
```

se zprávou:

```text
fix(documentation): use UTF-8 for Git output in A6
```

Commit byl úspěšně odeslán na GitHub:

```text
aef0c18..e108070  main -> main
```

## 3.7 Dočasné odložení pracovních souborů

Protože skutečný `--apply` A24 vyžaduje čistý Git pracovní strom, byly necommitnuté soubory bezpečně odloženy příkazem `git stash --include-untracked`.

Stash obsahoval:

- `MM-DL-20260705`,
- `MM-NAV-20260705-01`,
- `docs/17_CHAT/`.

Git zobrazil řadu upozornění:

```text
LF will be replaced by CRLF
```

Tato upozornění se týkala konců řádků uložených HTML, CSS a JavaScript souborů v `docs/17_CHAT`. Stash byl přesto vytvořen úspěšně.

Po odložení byl `git status --short` prázdný.

## 3.8 Skutečný import Project Snapshotu do databáze

Byl spuštěn A24 v režimu:

```text
--apply
```

pro:

```text
MM-PS-20260331
```

Git stav při importu:

```text
BRANCH : main
COMMIT : e108070c26aeed156d2402a87a3278c274d1cee1
DIRTY  : False
```

A6 vytvořil importní běh:

```text
IMPORT RUN ID: 30
```

Trvale vložené objekty:

| Objekt | Výsledek |
|---|---:|
| Dokument | 1 |
| Verze | 1 |
| Sekce | 110 |
| Vazby | 1 |
| Historie stavu | 1 |
| Varování | 0 |

Finální stav A6:

```text
DOCUMENT_IMPORT_APPLIED
```

## 3.9 Post-import ověření A7

A7 provedl přírůstkový audit právě importovaného dokumentu.

Výsledek dokumentu:

```text
MM-PS-20260331 | OK | v1.0 | sections=110/110 | relations=1/1
```

Kontroly:

```text
checks_total  : 56
checks_passed : 56
warnings      : 0
blockers      : 0
```

Finální stav:

```text
DOCUMENTATION_IMPORT_VERIFIED
```

Celý pipeline skončil:

```text
HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED
```

## 3.10 Databázový stav po importu

Po úspěšném importu A7 vykázal:

| Databázový objekt | Počet |
|---|---:|
| `documentation.documents` | 314 |
| `documentation.document_versions` | 316 |
| Aktuální verze | 314 |
| `documentation.document_sections` | 3152 |
| `documentation.document_relations` | 112 |
| `documentation.document_status_history` | 316 |
| `documentation.import_runs` | 8 |

Březnový Project Snapshot je tedy:

- v Git repozitáři,
- v dokumentační databázi,
- obsahově rozdělen na 110 sekcí,
- napojen jednou řízenou vazbou,
- ověřen 56 automatickými kontrolami.

## 3.11 Obnovení pracovních souborů ze stash

Po úspěšném importu byl proveden:

```text
git stash pop
```

Soubory byly obnoveny a stash byl odstraněn.

Znovu se objevily jako untracked:

```text
docs/09_HISTORY/DENNÍ_ZÁPISY/MM-DL-20260705_MATCHMATRIX_DENNI_ZAPIS.md
docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260705-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
docs/17_CHAT/
```

## 3.12 Pokus o DRY RUN zápisu a navázání z 2026-07-05

A24 byl spuštěn společně pro:

```text
MM-DL-20260705
MM-NAV-20260705-01
```

Import byl správně zablokován ještě před databází.

Chyba:

```text
Typ dokumentu neodpovídá ID MM-DL-20260705:
'Denní pracovní zápis' != 'DAILY_LOG'
```

A24 vyžaduje kanonické hodnoty:

```text
MM-DL  → DAILY_LOG
MM-NAV → CHAT_CONTINUATION
```

Starší soubory používají popisný český typ a musí být před importem upraveny na řízenou hodnotu.

## 3.13 Kontrola struktury složky `docs`

Při ruční kontrole sdílené složky bylo zjištěno, že v kořeni `docs` nejsou viditelné některé standardní oblasti:

```text
04_DATABASE
05_PROVIDERS
06_LAYERS
07_OPERATOR
13_TEMPLATES
14_EXPORT
15_DRAFT
```

Stejné složky chybějí také v:

```text
docs/99_ARCHIVE/
```

Pravděpodobnou příčinou je, že šlo o prázdné složky. Git prázdné adresáře neeviduje, a proto se při klonování nebo synchronizaci neobnoví.

Byl připraven krok, který má na obou místech:

- vytvořit chybějící adresáře,
- vložit do každého soubor `.gitkeep`.

Uživatel krok odsouhlasil, ale v tomto chatu nebyl dodán terminálový výstup potvrzující jeho skutečné provedení.

Složka `16_...` nebyla vytvořena, protože `MM-STD-007` pro ni aktuálně neurčuje název, prefix ani účel.

---

# 4. Přijatá rozhodnutí

## 4.1 Python subprocess musí mít explicitní UTF-8

V dokumentačních nástrojích spuštěných na Windows se nesmí spoléhat na výchozí systémové kódování při čtení Git nebo jiného externího procesu.

Používá se:

```python
encoding="utf-8"
errors="replace"
```

## 4.2 Opravné soubory se posílají jednotlivě

Při další opravě skriptu:

- asistent pošle pouze nový aktivní soubor,
- uživatel přesune původní verzi do `tools/histori/`,
- ZIP s aktivní a historickou kopií se neposílá, pokud si jej uživatel výslovně nevyžádá.

## 4.3 A24 používá řízené typy historie

Pro import historických provozních dokumentů jsou závazné hodnoty:

```text
DAILY_LOG
CHAT_CONTINUATION
PROJECT_SNAPSHOT
```

Popisné české názvy typu dokumentu nejsou pro databázový import dostatečné.

## 4.4 APPLY probíhá pouze nad čistým Git stromem

Před skutečným databázovým importem musí být Git pracovní strom čistý.

Dočasný stash je možné použít, ale po importu musí být pracovní soubory bezpečně obnoveny a ověřeny.

## 4.5 Prázdné standardní složky musí obsahovat `.gitkeep`

Adresáře definované dokumentační strukturou musí být zachovány i tehdy, když zatím neobsahují dokumenty.

Proto mají obsahovat `.gitkeep`, dokud do nich nevznikne skutečný soubor.

---

# 5. Problémy a jejich řešení

## 5.1 Chyba `UnicodeDecodeError` v A6

**Příčina:** Windows `cp1250` bylo použito pro Git výstup obsahující UTF-8 znaky.

**Řešení:** Explicitní UTF-8 a bezpečné ošetření `None`.

**Výsledek:** DRY RUN i APPLY byly úspěšné.

## 5.2 Nečistý Git strom před APPLY

**Příčina:** Necommitnuté historické dokumenty a archiv chatů.

**Řešení:** Dočasný `git stash --include-untracked`.

**Výsledek:** APPLY proběhl nad čistým stromem a soubory byly následně obnoveny.

## 5.3 Neplatný typ staršího denního zápisu

**Příčina:** Metadata obsahují popisný typ `Denní pracovní zápis`.

**Očekávání A24:** `DAILY_LOG`.

**Výsledek:** Import byl správně zablokován. Dokument zatím nebyl změněn ani importován.

## 5.4 Chybějící fyzické adresáře

**Příčina:** Git neukládá prázdné složky.

**Navržené řešení:** Vytvořit standardní složky v `docs` i `docs/99_ARCHIVE` a vložit `.gitkeep`.

**Aktuální stav:** Provedení zatím není doloženo výstupem `git status --short`.

## 5.5 Rozsáhlý obsah `docs/17_CHAT`

Složka obsahuje uložené HTML stránky a velké množství doprovodných CSS/JS souborů.

Nesmí být přidána do commitu omylem pomocí obecného:

```text
git add .
```

Její dlouhodobá politika archivace, velikost a vhodnost pro Git musí být posouzena samostatně.

---

# 6. Technické výstupy a ověření

## Upravené skripty

```text
tools/documentation/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py
tools/histori/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V2.py
```

## Použité pipeline skripty

```text
tools/documentation/25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py
tools/documentation/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py
tools/documentation/25_1_A_7_AUDIT_DOCUMENT_IMPORT_INTEGRITY_V1.py
```

## Git commity

```text
aef0c18 – Project Snapshot za březen 2026
e108070 – UTF-8 oprava A6
```

## Importovaný dokument

```text
MM-PS-20260331
verze 1.0
stav ACTIVE
```

## Hlavní reporty

```text
reports/documentation/document_database_import_20260706_235956.json
reports/documentation/document_import_verification_20260706_235957.json
reports/documentation/document_import_verification_20260706_235957.csv
reports/documentation/history_document_database_pipeline_20260706_235957.json
```

---

# 7. Výsledky dne

Dokončeno:

- Project Snapshot `MM-PS-20260331` byl commitnut a odeslán na GitHub.
- A6 byl opraven pro bezpečné UTF-8 čtení Git výstupu.
- Oprava A6 byla commitnuta a pushnuta v `e108070`.
- Project Snapshot byl trvale importován do PostgreSQL.
- A7 ověřil 56 z 56 kontrol.
- Databázový import skončil bez varování a blokátorů.
- Pracovní soubory byly po APPLY obnoveny ze stash.
- Byla identifikována příčina blokace starších `MM-DL` a `MM-NAV`.
- Byla identifikována neúplná fyzická struktura `docs`.

Rozpracováno:

- oprava metadat `MM-DL-20260705` a `MM-NAV-20260705-01`,
- obnovení standardních prázdných složek pomocí `.gitkeep`,
- rozhodnutí, jak dlouhodobě spravovat `docs/17_CHAT`.

Odloženo:

- import denního zápisu a navázání z 2026-07-05,
- commit struktury nových složek,
- zahájení rekonstrukce dubna 2026.

---

# 8. Plán pokračování

Doporučené pořadí další práce:

1. ověřit výstup `git status --short` po vytvoření chybějících složek a `.gitkeep`,
2. potvrdit, že se objevily pouze očekávané nové adresáře,
3. neupravovat ani nestagovat `docs/17_CHAT`,
4. změnit metadata:
   - `MM-DL-20260705` → `Typ dokumentu: DAILY_LOG`,
   - `MM-NAV-20260705-01` → `Typ dokumentu: CHAT_CONTINUATION`,
5. spustit A17 audit obou dokumentů,
6. spustit A24 DRY RUN,
7. commitnout a pushnout dokumenty,
8. provést čistý APPLY a A7 ověření,
9. teprve potom pokračovat další historickou etapou.

---

# 9. Jeden hlavní další krok

V novém chatu nejprve ověřit skutečný stav pracovního stromu po pokusu vytvořit chybějící složky:

```powershell
Set-Location "C:\MatchMatrix-Platform"
git status --short
```

Do získání výstupu:

- nevytvářet další složky,
- nestagovat soubory,
- nepoužívat `git add .`,
- neupravovat `docs/17_CHAT`,
- nespouštět A24 APPLY.

---

# 10. Vazba na NAVÁZÁNÍ

Pro tento pracovní den byl vytvořen navazující dokument:

```text
MM-NAV-20260706-01
```

Cílové umístění:

```text
docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/
MM-NAV-20260706-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

---

# 11. Historie verzí

| Verze | Datum      | Popis |
|---|------------|---|
| 1.0 | 2026-07-06 | Zápis dokončení importu březnového Project Snapshotu, opravy A6, databázového ověření a kontroly struktury složek `docs`. |

---

# Závěr

Pracovní blok dokončil celý technický publikační cyklus březnového Project Snapshotu od Git commitu přes bezpečný databázový import až po post-import kontrolu.

Současně byly odhaleny dvě návazné oblasti: nekonzistentní typy starších denních dokumentů a neúplná fyzická struktura dokumentačních adresářů. Další práce má začít jediným ověřením Git stavu, aby bylo přesně známo, co bylo ve složkové struktuře skutečně vytvořeno.
