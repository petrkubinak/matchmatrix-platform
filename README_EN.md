# ⚽ MatchMatrix Platform

> **Internal Multi-Sport Data Platform powering the TicketMatrix ecosystem**

![Status](https://img.shields.io/badge/Status-Active%20Development-blue)
![Python](https://img.shields.io/badge/Python-3.14-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-blue)
![GitHub](https://img.shields.io/badge/GitHub-MatchMatrix-black)
![License](https://img.shields.io/badge/License-Private-red)

---

# About

**MatchMatrix Platform** is the internal sports data and intelligence platform behind the **TicketMatrix** project.

It provides a unified architecture for collecting, validating, enriching and managing sports data from multiple providers.

The platform is designed for long-term scalability and serves as the foundation for analytics, AI models and future sports applications.

---

# Platform Architecture

```text
                         TicketMatrix

          Public Web • Mobile • AI • Predictions

                              ▲
                              │
                     Powered by

                              ▲

=========================================================

                   MatchMatrix Platform

=========================================================

Core Database
Historical Harvest
Source Intelligence
People Layer
Media Layer
Governance
OPS Control Center
Workers
API
```

---

# Supported Sports

Current implementation includes:

* Football
* Hockey
* Basketball
* Baseball
* MMA
* Cricket
* Tennis
* American Football
* Volleyball
* Handball

The architecture has been designed to support additional sports in the future.

---

# Repository Structure

```text
MatchMatrix-platform/

db/
docs/
ingest/
infra/
ops/
tools/
workers/
```

---

# Documentation

All project documentation is maintained inside the **docs** directory.

| Documentation          | Location              |
| ---------------------- | --------------------- |
| Documentation Standard | docs/00_DOCUMENTATION |
| Master Documentation   | docs/01_MASTER        |
| Governance             | docs/02_GOVERNANCE    |
| Architecture           | docs/03_ARCHITECTURE  |
| Database               | docs/04_DATABASE      |
| Providers              | docs/05_PROVIDERS     |
| Layers                 | docs/06_LAYERS        |
| Operator               | docs/07_OPERATOR      |
| Development            | docs/08_DEVELOPMENT   |
| Project History        | docs/09_HISTORY       |
| Reference              | docs/10_REFERENCE     |
| Visual Assets          | docs/11_VISUAL        |
| Archive                | docs/99_ARCHIVE       |

> **Documentation Principle**
> Every piece of information exists in a single authoritative location.
> README provides an overview, while complete technical documentation is maintained inside the **docs** directory.

---

# Technologies

* Python
* PostgreSQL
* PowerShell
* Git
* GitHub
* Docker *(planned)*

---

# Current Status

| Module                | Status |
| --------------------- | ------ |
| Documentation         | ✅      |
| Governance            | ✅      |
| Database Architecture | ✅      |
| OPS Control Center    | ✅      |
| Historical Harvest    | 🟡     |
| Source Intelligence   | 🟡     |
| People Layer          | 🟡     |
| Media Layer           | 🟡     |
| Prediction Engine     | ⏳      |
| TicketMatrix          | ⏳      |

---

# Quick Start

```bash
git clone https://github.com/petrkubinak/matchmatrix-platform.git

cd matchmatrix-platform
```

Detailed setup instructions are available in the project documentation.

---

# License

Private project.

Copyright © Petr Kubínák

All rights reserved.
