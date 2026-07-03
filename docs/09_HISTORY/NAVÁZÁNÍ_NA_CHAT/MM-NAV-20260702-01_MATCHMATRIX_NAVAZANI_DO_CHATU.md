# MM-NAV-20260702-01

# MATCHMATRIX – NAVÁZÁNÍ DO NOVÉHO CHATU – 2026-07-02

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-NAV-20260702-01 |
| Název | MatchMatrix – navázání do nového chatu – 2026-07-02 |
| Typ | Navázání pracovního chatu |
| Verze | 1.0 |
| Stav | REVIEW |
| Datum | 2026-07-02 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Hlavní oblast | Historický dokumentační korpus |
| Související denní zápis | MM-DL-20260702 |
| Primární prostředí | PC2 – `C:\MatchMatrix-Platform` |
| Primární formát | Markdown (.md) |

---

# 1. Účel navázání

Tento dokument předává přesný stav větve pro import historických dokumentů MatchMatrix do PostgreSQL.

Nový chat musí pokračovat přímo z posledního validačního výsledku. Nesmí znovu opakovat již dokončenou inventuru ani spouštět produkční import.

Pracovní pravidlo uživatele:

> Vždy pouze jeden příkaz nebo jeden jasný úkon. Po výsledku následuje další krok.

---

# 2. Aktivní soubor

```text
C:\MatchMatrix-Platform\tools\documentation\25_1_A_25_IMPORT_HISTORY_CORPUS_TO_DB_V1.py
```

Stav:

```text
soubor existuje                  : ANO
syntaxe                          : OK
kompilace s -W error             : OK
validate-only                    : PROVEDENO
databázový dry run               : NEPROVEDEN
produkční apply                  : NEPROVEDEN
```

---

# 3. Zdrojový archiv

```text
\\192.168.3.119\matchmatrix\docs\99_ARCHIVE\09_HISTORY\historie 25062026
```

Původní inventura:

```text
303 souborů
144 md
105 txt
28 png
9 docx
6 sql
5 csv
4 pdf
2 xlsx
```

Původní soubory se nesmějí měnit, mazat ani přejmenovávat.

---

# 4. Databázový model

Používají se existující tabulky:

```text
documentation.documents
documentation.document_versions
documentation.document_sections
documentation.document_status_history
documentation.import_runs
```

Historické dokumenty mají být vedeny jako:

```text
Document ID     : MM-HIS-####
document_type   : HIS
status          : ARCHIVED
source_of_truth : FILE
```

Celý obsah jde do `document_versions.content_markdown`. Přirozené nadpisy nebo technické bloky jdou do `document_sections`. Zdrojové cesty, skutečný formát, hashe a duplicity se ukládají do `metadata JSONB`.

Aktuálně je v databázi:

```text
MM-HIS dokumenty : 0
```

---

# 5. Poslední validační výsledek

Poslední spuštěný příkaz:

```powershell
py -3.14 ".\tools\documentation\25_1_A_25_IMPORT_HISTORY_CORPUS_TO_DB_V1.py" --validate-only
```

Výstup:

```text
EXCLUDED_SENSITIVE : KeePass.pdf

source_files                        : 302
corpus_documents                    : 291
content_duplicate_groups            : 10
source_files_in_duplicate_groups    : 21
sections                            : 2028
warnings                            : 31
FINAL STATUS                        : HISTORY_CORPUS_VALIDATED_WITH_WARNINGS
```

Report:

```text
C:\MatchMatrix-platform\reports\documentation\history_corpus_manifest_20260702_233243.json
```

Aktuální manifest:

```text
C:\MatchMatrix-platform\reports\documentation\history_corpus_manifest_latest.json
```

---

# 6. Kritický otevřený bod

Bezpečnostní patch měl vyloučit dva soubory:

```text
KeePass.pdf
komunikace s chatGPT/02_2026/název v dockeru plus heslo.png
```

Výstup však potvrdil pouze:

```text
EXCLUDED_SENSITIVE : KeePass.pdf
```

Druhý citlivý PNG soubor se jako vyloučený neobjevil.

To znamená:

- bezpečnostní filtr zatím není úplný,
- databázový dry run se ještě nesmí spustit,
- `--apply` je výslovně zakázán,
- je nutné zjistit skutečnou relativní cestu nebo přesný název PNG souboru v manifestu.

Možnou příčinou je rozdíl v názvu, kódování znaků nebo relativní cestě. Skutečný důvod zatím není potvrzen.

---

# 7. První a jediný další krok

V novém chatu nejprve vyhledej v aktuálním manifestu všechny záznamy, jejichž cesta nebo název obsahuje:

```text
heslo
docker
název v dockeru
```

Cílem prvního kroku je pouze získat přesnou relativní cestu druhého citlivého souboru.

Po obdržení výstupu teprve připrav jeden patch bezpečnostní výjimky.

---

# 8. Následující pořadí práce

Až po opravě druhé výjimky:

1. znovu spustit `--validate-only`,
2. potvrdit oba řádky `EXCLUDED_SENSITIVE`,
3. ověřit stabilitu přidělení `MM-HIS-####`,
4. provést databázový dry run s rollbackem,
5. zkontrolovat databázové počty a integritu,
6. teprve potom rozhodnout o `--apply`.

V jednom kroku se nesmí poslat více příkazů.

---

# 9. Důležitá pravidla

- Nepoužívat OCR pro obrázky v této fázi.
- Neopravovat obsah historických dokumentů.
- Nevyžadovat kanonickou hlavičku historických souborů.
- Zachovat všechny původní zdrojové cesty.
- U obsahových duplicit uložit jeden obsah a více variant.
- Skutečný formát souboru má přednost před příponou.
- Nezapisovat hesla do reportů, dokumentace ani chatu.
- Nespouštět `--apply` bez výslovného potvrzení uživatele.

---

# 10. Další relevantní dokončené práce

Kanonická dokumentační databáze je ověřena:

```text
415/415 kontrol
0 warnings
0 blockers
92/92 vztahů
DOCUMENTATION_IMPORT_VERIFIED
```

Dokumentační panel Q2 a slovníková navigace jsou hotové.

Související Git commity:

```text
74f8807 feat(documentation): add glossary navigation and Q2 documentation panel
a3eeba1 fix(documentation): synchronize glossary paths and import integrity
```

A25 zatím nebyl commitnut.

---

# 11. Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 1.0 | 2026-07-02 | První vydání navazujícího dokumentu. |

---

# Závěr

Historický importér je vytvořen, kompiluje se bez varování a úspěšně zpracoval archiv do 291 obsahových dokumentů a 2028 sekcí.

Práce je bezpečně zastavena před databázovým importem, protože druhý citlivý PNG soubor nebyl podle výstupu skutečně vyloučen. Prvním krokem nového chatu je pouze zjištění jeho přesné relativní cesty v aktuálním manifestu.
