# MM-STD-007

# IDENTIFIKACE A ČÍSLOVÁNÍ DOKUMENTŮ MATCHMATRIX

## STANDARD

---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-STD-007 |
| Název | Identifikace a číslování dokumentů |
| Edice | MM-STD |
| Verze | 1.0 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |

---

# 1. Účel

Tento standard definuje jednotný systém identifikace dokumentů, jejich číslování, názvů souborů a umístění ve složkách projektu MatchMatrix.

Cílem je vytvořit dlouhodobě stabilní systém, který bude využíván jak uživateli, tak budoucím Documentation Management System.

---

# 2. Základní principy

- Document ID je jedinečný a neměnný.
- Název dokumentu lze měnit bez změny Document ID.
- Fyzické umístění dokumentu neurčuje jeho identitu.
- Každá oblast dokumentace má vlastní číselnou řadu.
- Prefix dokumentu určuje jeho typ.
- Složka určuje tematickou oblast.

---

# 3. Struktura Document ID

Každý dokument používá formát:

```text
MM-XXX-NNN
```

kde:

- **MM** = MatchMatrix
- **XXX** = typ dokumentu
- **NNN** = pořadové číslo v rámci daného typu

Příklad:

```text
MM-DOC-001
MM-STD-004
MM-REF-001
MM-DB-012
MM-OPS-021
```

---

# 4. Prefixy dokumentů

| Složka | Prefix | Příklad |
|--------|---------|----------|
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
| 10_REFERENCE | MM-REF | MM-REF-001 |
| 11_VISUAL | MM-VIS | MM-VIS-001 |
| 12_STANDARD | MM-STD | MM-STD-001 |
| 13_TEMPLATES | MM-TPL | MM-TPL-001 |
| 14_EXPORT | MM-EXP | MM-EXP-001 |
| 15_DRAFT | MM-DRF | MM-DRF-001 |
| 99_ARCHIVE | MM-ARCV | MM-ARCV-001 |

---

# 5. Názvy souborů

Doporučený formát:

```text
<Document ID>_<NÁZEV_DOKUMENTU>.md
```

Příklad:

```text
MM-DB-001_DATABASE_NAMING_STANDARD.md
MM-DOC-001_DOCUMENTATION_FRAMEWORK.md
MM-OPS-003_OPERATOR_PANEL_GUIDE.md
```

Používají se:

- velká písmena,
- znak "_" jako oddělovač,
- přípona dle formátu (.md, .docx, .pdf).

---

# 6. Číslování

Každá oblast začíná číslem **001**.

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

---

# 7. Vazba na Documentation Management System

Budoucí Documentation Management System bude používat Document ID jako primární identifikátor.

Bude spravovat:

- metadata,
- historii verzí,
- vazby mezi dokumenty,
- indexy,
- exporty.

---

# 8. Výjimky

Přečíslování dokumentů se neprovádí, pokud již byly publikovány jako ACTIVE.

Dočasná pracovní označení jsou přípustná pouze ve stavu DRAFT.

---

# 9. Závěr

Jednotný systém identifikace dokumentů je základním stavebním prvkem dokumentačního systému MatchMatrix.

Oddělení identity dokumentu od názvu souboru a fyzického umístění zajišťuje dlouhodobou stabilitu, jednoznačnost a připravenost na budoucí automatizaci.

---

## Historie verzí

| Verze | Datum | Popis |
|--------|--------|-------|
| 1.0 | 2026 | První vydání standardu identifikace a číslování dokumentů. |
