# ⚽ MatchMatrix Platform

> **Interní multisportovní datová platforma pro ekosystém TicketMatrix**

![Status](https://img.shields.io/badge/Status-Active%20Development-blue)
![Python](https://img.shields.io/badge/Python-3.14-blue)
![Database](https://img.shields.io/badge/PostgreSQL-18-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%2011-success)
![License](https://img.shields.io/badge/License-Private-red)

---

# O projektu

**MatchMatrix Platform** je interní technologická platforma určená pro sběr, správu, validaci, obohacování a analýzu sportovních dat.

Platforma tvoří datový základ veřejného projektu **TicketMatrix** a zajišťuje jednotnou správu sportovních informací napříč různými poskytovateli.

Cílem projektu je vytvořit dlouhodobě udržitelnou sportovní databázi využitelnou pro:

* historická data,
* živá data,
* analytiku,
* AI modely,
* predikce,
* TicketMatrix,
* další budoucí aplikace.

---

# Architektura ekosystému

```text
                    TicketMatrix
           Veřejná webová a mobilní aplikace

        Statistiky • AI • Predikce • Tikety

                       ▲
                       │
             využívá služby platformy

                       ▲

=========================================================

               MatchMatrix Platform

      Interní datová a analytická platforma

=========================================================

Database
Governance
Historical Harvest
Source Intelligence
People Layer
Media Layer
OPS Control Center
Workers
API
```

---

# Architektura zpracování dat

```text
Sports Data Providers
            │
            ▼
      INGEST LAYER
            │
            ▼
    STAGING DATABASE
            │
            ▼
 VALIDATION & GOVERNANCE
            │
            ▼
     PUBLIC DATABASE
            │
      ┌─────┼─────────┐
      ▼     ▼         ▼

OPS Panel Documentation API

            │
            ▼

Prediction Engine
TicketMatrix
```

---

# Podporované sporty

Aktuálně:

* ⚽ Fotbal
* 🏒 Hokej
* 🏀 Basketbal
* ⚾ Baseball
* 🥋 MMA
* 🏏 Cricket
* 🎾 Tenis
* 🏈 Americký fotbal
* 🏐 Volejbal
* 🤾 Házená

Platforma je navržena jako univerzální a umožňuje rozšíření o další sporty.

---

# Struktura projektu

```text
MatchMatrix-platform/

db/
docs/
ingest/
infra/
legacy/
ops/
tools/
workers/

README.md
README_EN.md
.gitignore
.gitattributes
```

---

# Dokumentace

Veškerá projektová dokumentace je uložena ve složce **docs**.

| Oblast                | Umístění                |
| --------------------- | ----------------------- |
| Dokumentační standard | `docs/00_DOCUMENTATION` |
| Master dokumentace    | `docs/01_MASTER`        |
| Governance            | `docs/02_GOVERNANCE`    |
| Architektura          | `docs/03_ARCHITECTURE`  |
| Databáze              | `docs/04_DATABASE`      |
| Poskytovatelé dat     | `docs/05_PROVIDERS`     |
| Datové vrstvy         | `docs/06_LAYERS`        |
| Operator              | `docs/07_OPERATOR`      |
| Vývoj                 | `docs/08_DEVELOPMENT`   |
| Historie projektu     | `docs/09_HISTORY`       |
| Reference             | `docs/10_REFERENCE`     |
| Vizuály               | `docs/11_VISUAL`        |
| Archiv                | `docs/99_ARCHIVE`       |

> **Princip projektu:** Každá informace existuje pouze na jednom autoritativním místě. README slouží jako rozcestník, kompletní dokumentace je vedena ve složce `docs`.

---

# Použité technologie

* Python 3.14
* PostgreSQL 18
* PowerShell
* Git
* GitHub
* Docker (připravováno)

---

# Stav projektu

| Modul                   | Stav |
| ----------------------- | ---- |
| Dokumentace             | ✅    |
| Governance              | ✅    |
| Databázová architektura | ✅    |
| OPS Control Center      | ✅    |
| Historical Harvest      | 🟡   |
| Source Intelligence     | 🟡   |
| People Layer            | 🟡   |
| Media Layer             | 🟡   |
| Prediction Engine       | ⏳    |
| TicketMatrix            | ⏳    |

---

# Jak začít

```bash
git clone https://github.com/petrkubinak/matchmatrix-platform.git

cd matchmatrix-platform
```

Další informace naleznete v dokumentaci ve složce `docs`.

---

# Licence

Soukromý projekt.

Copyright © Petr Kubínák

Všechna práva vyhrazena.
