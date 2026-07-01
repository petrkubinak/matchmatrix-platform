# MM-STD-007

# IDENTIFIKACE A ČÍSLOVÁNÍ DOKUMENTŮ MATCHMATRIX

## STANDARD

---

## Informace o dokumentu

| Položka | Hodnota |
|---------|---------|
| Dokument | MM-STD-007 |
| Název | Identifikace a číslování dokumentů |
| Edice | MM-STD |
| Verze | 1.1 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |

---

# 1. Účel

Tento standard definuje jednotný systém identifikace dokumentů, jejich číslování, názvů souborů a umístění ve složkách projektu MatchMatrix.

Cílem je vytvořit dlouhodobě stabilní systém, který bude používán uživateli, automatizačními nástroji i budoucím Documentation Management System.

Standard rozlišuje:

1. běžné dokumenty s pořadovým číslem,
2. denní zápisy identifikované datem,
3. dokumenty NAVÁZÁNÍ identifikované datem a pořadím v rámci daného dne.

---

# 2. Základní principy

- Document ID je jedinečný a neměnný.
- Název dokumentu lze měnit bez změny Document ID.
- Fyzické umístění dokumentu neurčuje jeho identitu.
- Prefix dokumentu určuje jeho typ.
- Každý typ dokumentu používá vlastní definované identifikační pravidlo.
- Běžné dokumenty používají samostatné pořadové číselné řady.
- Denní provozní dokumenty mohou místo pořadového čísla používat datum.
- Verze dokumentu se spravuje v metadatech a historii verzí, nikoli změnou Document ID.
- Stejný Document ID nesmí být přidělen dvěma různým dokumentům.
- Po přidělení a registraci se Document ID znovu nepoužívá.

---

# 3. Struktura Document ID

## 3.1 Běžné dokumenty

Běžné dokumenty používají formát:

```text
MM-XXX-NNN
```

kde:

- **MM** = MatchMatrix,
- **XXX** = typ dokumentu,
- **NNN** = pořadové číslo v rámci daného typu.

Příklad:

```text
MM-DOC-001
MM-STD-004
MM-REF-001
MM-DB-012
MM-OPS-021
```

## 3.2 Denní zápisy

Denní zápis používá formát:

```text
MM-DL-YYYYMMDD
```

kde:

- **MM** = MatchMatrix,
- **DL** = Daily Log / denní zápis,
- **YYYY** = rok,
- **MM** = měsíc,
- **DD** = den.

Příklad:

```text
MM-DL-20260624
```

Identifikátor znamená denní zápis za 24. června 2026.

## 3.3 Dokumenty NAVÁZÁNÍ do nového chatu

Dokument NAVÁZÁNÍ používá formát:

```text
MM-NAV-YYYYMMDD-PP
```

kde:

- **MM** = MatchMatrix,
- **NAV** = dokument NAVÁZÁNÍ do nového chatu,
- **YYYYMMDD** = datum vzniku dokumentu,
- **PP** = pořadí dokumentu NAVÁZÁNÍ v rámci daného dne.

Pořadí se zapisuje dvoumístně:

```text
01
02
03
...
10
11
```

Příklad:

```text
MM-NAV-20260624-01
MM-NAV-20260624-02
MM-NAV-20260624-03
```

Tyto identifikátory označují první, druhý a třetí dokument NAVÁZÁNÍ vytvořený dne 24. června 2026.

---

# 4. Prefixy dokumentů

| Oblast nebo typ | Prefix | Příklad |
|-----------------|--------|---------|
| 00_DOCUMENTATION | MM-DOC | MM-DOC-001 |
| 01_MASTER | MM-MST | MM-MST-001 |
| 02_GOVERNANCE | MM-GOV | MM-GOV-001 |
| 03_ARCHITECTURE | MM-ARC | MM-ARC-001 |
| 04_DATABASE | MM-DB | MM-DB-001 |
| 05_PROVIDERS | MM-PRV | MM-PRV-001 |
| 06_LAYERS | MM-LAY | MM-LAY-001 |
| 07_OPERATOR | MM-OPS | MM-OPS-001 |
| 08_DEVELOPMENT | MM-DEV | MM-DEV-001 |
| 09_HISTORY | MM-HIS | MM-HIS-001 |
| Denní zápis | MM-DL | MM-DL-20260624 |
| NAVÁZÁNÍ do nového chatu | MM-NAV | MM-NAV-20260624-01 |
| 10_REFERENCE | MM-REF | MM-REF-001 |
| 11_VISUAL | MM-VIS | MM-VIS-001 |
| 12_STANDARD | MM-STD | MM-STD-001 |
| 13_TEMPLATES | MM-TPL | MM-TPL-001 |
| 14_EXPORT | MM-EXP | MM-EXP-001 |
| 15_DRAFT | MM-DRF | MM-DRF-001 |
| 99_ARCHIVE | MM-ARCV | MM-ARCV-001 |

Prefix `MM-HIS` zůstává určen pro běžné historické dokumenty. Denní zápisy a dokumenty NAVÁZÁNÍ používají vlastní typové prefixy bez ohledu na to, zda jsou později uloženy do historické nebo archivní složky.

---

# 5. Názvy souborů

## 5.1 Běžný formát

Doporučený formát:

```text
<Document ID>_<NAZEV_DOKUMENTU>.md
```

Příklad:

```text
MM-DB-001_DATABASE_NAMING_STANDARD.md
MM-DOC-001_DOCUMENTATION_FRAMEWORK.md
MM-OPS-003_OPERATOR_PANEL_GUIDE.md
```

## 5.2 Denní zápis

Doporučený název:

```text
MM-DL-YYYYMMDD_MATCHMATRIX_DENNI_ZAPIS.md
```

Příklad:

```text
MM-DL-20260624_MATCHMATRIX_DENNI_ZAPIS.md
```

## 5.3 NAVÁZÁNÍ do nového chatu

Doporučený název:

```text
MM-NAV-YYYYMMDD-PP_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

Příklad:

```text
MM-NAV-20260624-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
MM-NAV-20260624-02_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

## 5.4 Pravidla názvů souborů

Používají se:

- velká písmena,
- znak `_` jako oddělovač významových částí názvu,
- znak `-` uvnitř Document ID,
- názvy souborů bez diakritiky,
- přípona podle formátu, například `.md`, `.docx` nebo `.pdf`,
- verze dokumentu se do názvu aktivního souboru standardně nepřidává.

Název aktivního souboru zůstává stabilní. Změny dokumentu se evidují v metadatech a historii verzí.

---

# 6. Číslování a pravidla jedinečnosti

## 6.1 Běžné dokumenty

Každá běžná oblast začíná číslem `001`.

Číselné řady jsou na sobě nezávislé.

Příklad:

```text
MM-DOC-001
MM-DOC-002

MM-DB-001
MM-DB-002

MM-OPS-001
MM-OPS-002
```

Nový dokument v jedné oblasti nikdy neovlivní číslování ostatních oblastí.

## 6.2 Denní zápisy

Pro každý kalendářní den projektu vzniká nejvýše jeden hlavní denní zápis.

Jeho identifikátor je určen datem pracovního dne:

```text
MM-DL-YYYYMMDD
```

Pravidla:

- datum vyjadřuje den, který zápis dokumentuje,
- datum se zapisuje bez oddělovačů,
- datum musí být platné kalendářní datum,
- pro stejný den nesmí vzniknout druhý Document ID typu `MM-DL`,
- další práce doplněná během stejného dne se zapisuje do stejného denního zápisu,
- pozdější oprava stejného denního zápisu nemění Document ID,
- při opravě nebo doplnění se zvýší verze uvnitř dokumentu,
- datum zajišťuje přirozené chronologické řazení a jedinečnost.

Příklad:

```text
MM-DL-20260624
```

Následující identifikátory jsou neplatné:

```text
MM-DL-2026-06-24
MM-DL-24062026
MM-DL-20260230
```

## 6.3 Dokumenty NAVÁZÁNÍ

V jednom dni může vzniknout více dokumentů NAVÁZÁNÍ.

Pravidla:

- první dokument dne používá pořadí `01`,
- další dokumenty používají `02`, `03` a pokračují vzestupně,
- pořadí se v rámci jednoho dne nesmí opakovat,
- pořadí se po přidělení znovu nepoužívá,
- i jediný dokument NAVÁZÁNÍ v daném dni používá pořadí `01`,
- nový samostatný předávací kontext znamená nové pořadové číslo,
- oprava nebo nová verze téhož dokumentu NAVÁZÁNÍ nemění pořadí ani Document ID,
- verze se mění pouze uvnitř dokumentu,
- datum vyjadřuje den vzniku konkrétního dokumentu NAVÁZÁNÍ.

Příklad:

```text
MM-NAV-20260624-01
MM-NAV-20260624-02
MM-NAV-20260625-01
```

Dne 25. června začíná pořadí znovu hodnotou `01`.

Následující identifikátory jsou neplatné:

```text
MM-NAV-20260624
MM-NAV-20260624-1
MM-NAV-24-06-2026-01
MM-NAV-20260230-01
```

## 6.4 Verze versus identita

Document ID označuje dokument. Verze označuje jeho vývoj.

Příklad:

```text
Document ID: MM-DL-20260624
Verze: 1.0
```

Po doplnění stejného denního zápisu:

```text
Document ID: MM-DL-20260624
Verze: 1.1
```

Document ID i název aktivního souboru zůstávají stejné.

---

# 7. Vazba na Documentation Management System

Budoucí Documentation Management System bude používat Document ID jako primární identifikátor.

Bude spravovat:

- metadata,
- historii verzí,
- vazby mezi dokumenty,
- indexy,
- exporty,
- kontrolu jedinečnosti,
- přidělování pořadí dokumentů NAVÁZÁNÍ.

Pro denní zápisy musí systém vynucovat jedinečnost kombinace:

```text
document_type = DAILY_LOG
work_date
```

Pro dokumenty NAVÁZÁNÍ musí systém vynucovat jedinečnost kombinace:

```text
document_type = CHAT_CONTINUATION
document_date
daily_sequence
```

Doporučená validační pravidla:

```text
Denní zápis:
^MM-DL-[0-9]{8}$

NAVÁZÁNÍ:
^MM-NAV-[0-9]{8}-[0-9]{2}$
```

Regulární výraz ověřuje pouze strukturu. Aplikace musí navíc ověřit, že část `YYYYMMDD` představuje skutečné kalendářní datum.

---

# 8. Výjimky a migrace starších dokumentů

Přečíslování dokumentů se neprovádí, pokud již byly publikovány jako `ACTIVE`, pokud není schválena řízená migrace.

Dočasná pracovní označení jsou přípustná pouze ve stavu `DRAFT`.

Při převodu starších denních zápisů:

- datum se určuje podle dne, který zápis dokumentuje,
- jeden denní zápis se označí jako kanonický,
- více starších zdrojů stejného dne se sloučí nebo se ponechá jako archivní podklad navázaný na kanonický denní zápis,
- archivní zdroj nesmí získat druhý kanonický identifikátor `MM-DL` pro stejné datum.

Při převodu starších dokumentů NAVÁZÁNÍ:

- pořadí se určí podle skutečného času nebo pořadí jejich vzniku,
- pokud přesný čas není znám, pořadí se přidělí podle doložitelného pořadí v archivu,
- přidělené pořadí se zaznamená do migračního protokolu,
- po registraci se pořadí nemění.

---

# 9. Závěr

Jednotný systém identifikace dokumentů je základním stavebním prvkem dokumentačního systému MatchMatrix.

Běžné dokumenty používají stabilní pořadové číselné řady. Denní zápisy používají datum ve formátu `YYYYMMDD`, které současně určuje dokumentovaný den a zajišťuje jedinečnost. Dokumenty NAVÁZÁNÍ používají datum a dvoumístné pořadí v rámci daného dne.

Oddělení identity dokumentu od názvu souboru, verze a fyzického umístění zajišťuje dlouhodobou stabilitu, jednoznačnost a připravenost na budoucí automatizaci.

---

## Historie verzí

| Verze | Datum | Popis |
|--------|-------|-------|
| 1.0 | 2026 | První vydání standardu identifikace a číslování dokumentů. |
| 1.1 | 2026-06-30 | Doplněna datumová identifikace denních zápisů `MM-DL-YYYYMMDD` a identifikace dokumentů NAVÁZÁNÍ `MM-NAV-YYYYMMDD-PP`. |
