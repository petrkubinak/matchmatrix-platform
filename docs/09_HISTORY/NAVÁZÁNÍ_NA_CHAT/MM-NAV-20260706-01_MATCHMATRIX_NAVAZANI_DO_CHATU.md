# MM-NAV-20260706-01

# MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU – 2026-07-06

---

## Informace o dokumentu

| Položka | Hodnota                                                                                |
|---|----------------------------------------------------------------------------------------|
| Dokument | MM-NAV-20260706-01                                                                     |
| Název dokumentu | MatchMatrix – navázání do nového chatu – 2026-07-06                                    |
| Typ dokumentu | CHAT_CONTINUATION                                                                      |
| Edice | HISTORY                                                                                |
| Verze | 1.0                                                                                    |
| Stav | REVIEW                                                                                 |
| Datum | 2026-07-06                                                                             |
| Pořadí v rámci dne | 01                                                                                     |
| Datum a čas vytvoření | 2026-07-06 – noční pracovní blok                                                       |
| Autor projektu | Petr                                                                                   |
| Technická spolupráce | OpenAI ChatGPT                                                                         |
| Projekt | MatchMatrix-platform                                                                   |
| Pracovní oblast | Dokumentační databáze, Project Snapshoty a struktura `docs`                            |
| Etapa | Dokončení publikování `MM-PS-20260331` a příprava historických zápisů                  |
| Zdroj | MM-DL-20260706                                                                         |
| Související denní zápis | MM-DL-20260706                                                                         |
| Primární prostředí | PC2 – `C:\MatchMatrix-Platform`                                                        |
| Primární formát | Markdown (.md)                                                                         |
| Cílové umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260706-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |

---

# 1. Účel dokumentu

Tento dokument předává přesný stav po úspěšném dokončení Git a databázového publikování březnového Project Snapshotu `MM-PS-20260331`.

Nový chat nemá znovu opravovat A6 ani znovu importovat Project Snapshot. Má nejprve ověřit fyzický stav chybějících složek a poté dokončit standardizaci a import historických dokumentů z 2026-07-05.

Závazné pracovní pravidlo:

> Vždy pouze jeden příkaz nebo jeden jasný úkon. Po výsledku následuje další krok.

---

# 2. Výchozí kontext

Předchozí etapa řešila:

- podporu Project Snapshotů v A17 a A24,
- publikování `MM-PS-20260331`,
- chybu A6 při čtení Git výstupu na Windows,
- čistý databázový APPLY,
- následný audit A7,
- návrat pracovních souborů ze stash,
- přípravu importu denního zápisu a NAVÁZÁNÍ z 2026-07-05,
- kontrolu úplnosti složkové struktury `docs`.

Hlavní technické prostředí:

```text
C:\MatchMatrix-Platform
```

Git větev:

```text
main
```

Poslední pushnutý commit:

```text
e108070
```

---

# 3. CURRENT STATUS – aktuální stav

## Git

Větev `main` je synchronizována s `origin/main` k commitu:

```text
e108070c26aeed156d2402a87a3278c274d1cee1
```

Po návratu stash byly přítomny untracked položky:

```text
docs/09_HISTORY/DENNÍ_ZÁPISY/MM-DL-20260705_MATCHMATRIX_DENNI_ZAPIS.md
docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260705-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
docs/17_CHAT/
```

Následně byl navržen příkaz pro vytvoření chybějících složek a `.gitkeep`, ale jeho výstup nebyl v předchozím chatu doložen.

## Databáze

Project Snapshot:

```text
MM-PS-20260331
```

je trvale uložen a ověřen.

Finální stav pipeline:

```text
HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED
```

## Dokumentační workflow

A24, A6 a A7 jsou pro Project Snapshot ověřeny v reálném APPLY běhu.

A6 již bezpečně čte Git výstup jako UTF-8.

---

# 4. Co bylo dokončeno

## 4.1 Project Snapshot

Dokument:

```text
docs/09_HISTORY/PROJECT_SNAPSHOTS/
MM-PS-20260331_MATCHMATRIX_PROJECT_SNAPSHOT_BREZEN_2026.md
```

byl:

- commitnut,
- pushnut na GitHub,
- importován do PostgreSQL,
- rozdělen na 110 sekcí,
- napojen jednou dokumentovou vazbou,
- ověřen 56 z 56 kontrol.

## 4.2 Oprava A6

Aktivní soubor:

```text
tools/documentation/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py
```

obsahuje:

```python
encoding="utf-8"
errors="replace"
return (completed.stdout or "").strip()
```

Historická kopie:

```text
tools/histori/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V2.py
```

Commit:

```text
e108070
```

je na GitHubu.

## 4.3 Databázové ověření

A7 vykázal:

```text
checks_total  : 56
checks_passed : 56
warnings      : 0
blockers      : 0
```

Databázový stav po importu:

```text
documents                : 314
document_versions        : 316
current_versions         : 314
document_sections        : 3152
document_relations       : 112
document_status_history  : 316
import_runs              : 8
```

## 4.4 Obnova pracovních souborů

Stash byl vrácen a následně odstraněn.

Nedošlo ke ztrátě:

- denního zápisu,
- navázání,
- obsahu `docs/17_CHAT`.

---

# 5. Co zůstává rozpracováno

## 5.1 Chybějící složky dokumentace

V kořeni `docs` nejsou nebo nebyly viditelné:

```text
04_DATABASE
05_PROVIDERS
06_LAYERS
07_OPERATOR
13_TEMPLATES
14_EXPORT
15_DRAFT
```

Stejné oblasti chybějí nebo chyběly v:

```text
docs/99_ARCHIVE/
```

Byl navržen příkaz, který je vytvoří a vloží do nich `.gitkeep`.

Provedení však zatím není doloženo výstupem Git.

## 5.2 Starší denní dokumenty

A24 blokuje:

```text
MM-DL-20260705
```

protože metadata používají:

```text
Denní pracovní zápis
```

místo:

```text
DAILY_LOG
```

Soubor NAV musí používat:

```text
CHAT_CONTINUATION
```

## 5.3 `docs/17_CHAT`

Složka obsahuje rozsáhlé uložené webové stránky včetně HTML, CSS a JavaScript zdrojů.

Zatím není rozhodnuto:

- zda má být celý obsah verzován v Git,
- zda má být archivován mimo Git,
- zda se mají ukládat pouze hlavní HTML soubory,
- zda mají být doprovodné `_files` adresáře ignorovány.

Do rozhodnutí se nesmí přidávat do commitu.

---

# 6. OPEN QUESTIONS – otevřené úkoly

Priorita 1:

- ověřit `git status --short` po vytvoření chybějících adresářů.

Priorita 2:

- opravit metadata `MM-DL-20260705` a `MM-NAV-20260705-01`.

Priorita 3:

- spustit A17 audit obou dokumentů.

Priorita 4:

- provést A24 DRY RUN, commit, push a čistý APPLY.

Pozdější úkol:

- stanovit governance pravidlo pro `docs/17_CHAT`.

---

# 7. Rizika a upozornění

## 7.1 Nepoužívat `git add .`

Tento příkaz by mohl omylem přidat celý rozsáhlý obsah:

```text
docs/17_CHAT/
```

Stagovat se mají vždy pouze přesně určené soubory a `.gitkeep`.

## 7.2 Netvrdit, že složky již byly vytvořeny

Uživatel vytvoření odsouhlasil, ale předchozí chat neobsahuje výstup potvrzující dokončení příkazu.

Nejprve je nutné ověření.

## 7.3 Neopakovat import Project Snapshotu

`MM-PS-20260331` je již úspěšně vložen a ověřen.

Další běh není součástí prvního kroku nového chatu.

## 7.4 Složku `16_...` nevytvářet

Aktuální `MM-STD-007` nedefinuje:

- její název,
- prefix,
- účel.

Její vznik musí předcházet samostatné standardizační rozhodnutí.

## 7.5 Zachovat přesné kanonické typy

Používají se:

```text
DAILY_LOG
CHAT_CONTINUATION
PROJECT_SNAPSHOT
```

Nepoužívat volné české popisy jako hodnotu pole `Typ dokumentu`.

---

# 8. Přijatá rozhodnutí

1. A6 musí na Windows používat explicitní UTF-8 při čtení externích procesů.
2. Při opravě skriptu se uživateli posílá pouze opravený aktivní soubor.
3. Původní verzi si uživatel ukládá do `tools/histori/`.
4. A24 APPLY se provádí pouze nad čistým Git stromem.
5. Standardní prázdné složky musí být chráněny souborem `.gitkeep`.
6. `docs/17_CHAT` se nesmí přidat do Git bez samostatného rozhodnutí.
7. Každý další technický krok se zadává jednotlivě.

---

# 9. Ověřené zdroje a odkazy

## Skripty

```text
tools/documentation/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py
tools/documentation/25_1_A_7_AUDIT_DOCUMENT_IMPORT_INTEGRITY_V1.py
tools/documentation/25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
tools/documentation/25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py
tools/histori/25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V2.py
```

## Dokumenty

```text
MM-PS-20260331
MM-DL-20260705
MM-NAV-20260705-01
MM-DL-20260706
MM-NAV-20260706-01
MM-STD-007
MM-DOC-900
```

## Git

```text
aef0c18 – přidání březnového Project Snapshotu
e108070 – oprava UTF-8 čtení Git výstupu v A6
```

## Reporty

```text
reports/documentation/document_database_import_20260706_235956.json
reports/documentation/document_import_verification_20260706_235957.json
reports/documentation/document_import_verification_20260706_235957.csv
reports/documentation/history_document_database_pipeline_20260706_235957.json
reports/documentation/history_document_database_pipeline_20260707_000245.json
```

---

# 10. AI CONTEXT

Jsi technický asistent projektu MatchMatrix-platform.

Komunikuj česky.

Uživatel požaduje:

- vždy pouze jeden příkaz nebo jeden jasný úkon,
- přesnou cestu ke každému souboru,
- po každém kroku vyčkat na výstup,
- neposílat dlouhou sekvenci příkazů dopředu,
- při opravě skriptu poslat pouze nový aktivní soubor,
- historickou kopii vytváří uživatel sám v `tools/histori/`.

Neopakuj již dokončené:

- opravu A6,
- commit `e108070`,
- import `MM-PS-20260331`,
- audit A7.

Neprováděj obecné `git add .`.

---

# 11. PROJECT SNAPSHOT

Aktuální dokumentační pipeline:

```text
Markdown dokument
→ A17 standard compliance audit
→ A24 history document orchestration
→ A6 database import
→ A7 post-import integrity audit
→ PostgreSQL schema documentation
```

Ověřený Project Snapshot:

```text
MM-PS-20260331
verze 1.0
stav ACTIVE
```

Celý cyklus Git → DB → audit je dokončen.

Nynější práce je přesunuta z Project Snapshotu na:

- historické denní dokumenty,
- strukturu složek `docs`,
- budoucí správu `docs/17_CHAT`.

---

# 12. DATABASE SNAPSHOT

Poslední ověřený stav:

| Objekt | Počet |
|---|---:|
| Dokumenty | 314 |
| Verze dokumentů | 316 |
| Aktuální verze | 314 |
| Sekce | 3152 |
| Vazby | 112 |
| Historie stavů | 316 |
| Importní běhy | 8 |

Poslední úspěšný importní běh Project Snapshotu:

```text
IMPORT RUN ID: 30
```

A7:

```text
56/56 PASS
0 warnings
0 blockers
```

---

# 13. NEXT STEP – jeden doporučený další krok

Spusť pouze:

```powershell
Set-Location "C:\MatchMatrix-Platform"
git status --short
```

Pošli celý výstup.

Cíl:

- ověřit, zda byly skutečně vytvořeny `.gitkeep` v nových složkách,
- přesně zjistit všechny aktuální untracked soubory,
- zabránit nechtěnému zařazení `docs/17_CHAT`.

Do obdržení výstupu nedělat nic dalšího.

---

# 14. Očekávané složky k ověření

V aktivní části:

```text
docs/04_DATABASE/.gitkeep
docs/05_PROVIDERS/.gitkeep
docs/06_LAYERS/.gitkeep
docs/07_OPERATOR/.gitkeep
docs/13_TEMPLATES/.gitkeep
docs/14_EXPORT/.gitkeep
docs/15_DRAFT/.gitkeep
```

V archivu:

```text
docs/99_ARCHIVE/04_DATABASE/.gitkeep
docs/99_ARCHIVE/05_PROVIDERS/.gitkeep
docs/99_ARCHIVE/06_LAYERS/.gitkeep
docs/99_ARCHIVE/07_OPERATOR/.gitkeep
docs/99_ARCHIVE/13_TEMPLATES/.gitkeep
docs/99_ARCHIVE/14_EXPORT/.gitkeep
docs/99_ARCHIVE/15_DRAFT/.gitkeep
```

Pokud se tyto cesty ve výstupu neobjeví, složky nebyly vytvořeny nebo nejsou v aktuálně kontrolovaném repozitáři.

---

# 15. Historie verzí

| Verze | Datum      | Popis |
|---|------------|---|
| 1.0 | 2026-07-06 | Navázání po dokončení importu `MM-PS-20260331`, opravě A6 a zjištění chybějících složek dokumentace. |

---

# Závěr

Project Snapshot za březen 2026 je technicky uzavřen: je v Git, v databázi a prošel integritním auditem.

Nový chat má pokračovat ověřením Git pracovního stromu. Teprve podle skutečného výstupu se rozhodne, zda se dokončí `.gitkeep` struktura, nebo se přejde k opravě typů `DAILY_LOG` a `CHAT_CONTINUATION`.
