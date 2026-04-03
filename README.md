# AI.mirante ⚓

[![Ruby](https://img.shields.io/badge/Ruby-3.3.0-red)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-7.2.0-red)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)](https://www.postgresql.org/)
[![Build Status](https://img.shields.io/github/actions/workflow/status/gabrielcoelho90/aimirante/ci.yml)](https://github.com/gabrielcoelho90/aimirante/actions)
[![License](https://img.shields.io/badge/License-Proprietary-darkred)](LICENSE)

AI.mirante is an AI-powered study platform built exclusively for Brazilian Navy Senior Officers preparing for the **CEMOS** (Curso de Estado-Maior para Oficiais Superiores) admission exam. It combines Retrieval-Augmented Generation (RAG), Spaced Repetition (SRS), and AI-generated summaries to help officers efficiently study the official bibliography — making the most of their limited time.

---

## Table of Contents

- [The Problem](#the-problem)
- [Installation](#installation)
- [Usage](#usage)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [Support](#support)
- [License](#license)
- [Authors & Acknowledgments](#authors--acknowledgments)
- [Project Status & Roadmap](#project-status--roadmap)

---

## The Problem

Senior Officers of the Brazilian Navy must pass the **CEMOS admission exam** to reach the rank of Capitão de Mar e Guerra — the last rank before the Admiralty. The exam is increasingly competitive, with a massive volume of study material that does not align with the daily routine of a 40-year-old officer with family responsibilities.

Officers are starting to study 1-2 years in advance, using 60 days of vacation exclusively for studying, and some even rent separate apartments to stay focused — away from their families.

**AI.mirante was built to solve this.**

---

## Installation

### Prerequisites

Make sure you have the following installed:

- Ruby 3.3.0
- Rails 7.2.0
- PostgreSQL 16
- Redis
- Node.js 20+

### Step-by-step

```bash
# 1. Clone the repository
git clone https://github.com/gabrielcoelho90/aimirante.git
cd aimirante

# 2. Install Ruby dependencies
bundle install

# 3. Install JavaScript dependencies
npm install

# 4. Set up environment variables
cp .env.example .env
# Open .env and fill in your API keys (see Environment Variables section below)

# 5. Create and migrate the database
rails db:create db:migrate

# 6. Seed initial data (subjects and categories)
rails db:seed

# 7. Start the development server
bin/dev
```

The app will be available at `http://localhost:3000`.

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Database
DATABASE_URL=postgresql://localhost/aimirante_development

# OpenAI — used for embeddings
OPENAI_API_KEY=your_key_here

# Anthropic — used for RAG responses and summaries
ANTHROPIC_API_KEY=your_key_here

# Redis — used for background jobs
REDIS_URL=redis://localhost:6379

# Authentication
DEVISE_JWT_SECRET_KEY=your_secret_here
```

---

## Usage

### Study Bot (RAG)
Ask questions in natural language and receive answers based exclusively on the official CEMOS bibliography — with source and page references.

```
"What is the doctrine for the employment of naval power?"
→ Answer based on indexed books, with source citation."
```

### Summaries
Access pre-generated summaries for each subject at three levels of depth — Quick (1 page), Medium (5 pages), and Complete (10+ pages).

### Flashcards with Spaced Repetition
Study flashcards organized by subject. Rate each card by difficulty and the SM-2 algorithm schedules the next review at the optimal time for long-term retention.

### Simulated Exams *(coming soon)*
Generate practice exams by subject or covering all subjects, in the style of the actual CEMOS exam, with answer keys and explanations.

---

## Requirements

| Technology | Version | Purpose |
|---|---|---|
| Ruby | 3.3.0 | Backend language |
| Rails | 7.2.0 | Web framework |
| PostgreSQL | 16 | Primary database |
| pgvector | latest | Vector similarity search |
| Redis | 7+ | Background job queue |
| Sidekiq | 7+ | Async PDF processing |
| Node.js | 20+ | JavaScript runtime |
| React | 18+ | Frontend framework |
| Vite | 8+ | Frontend build tool |
| OpenAI API | — | Text embeddings |
| Anthropic API | — | LLM for RAG and summaries |

---

## Contributing

This is a proprietary project and is not open for external contributions at this time.

If you are a Brazilian Navy officer and would like to suggest features, report issues, or contribute study materials, please reach out via the support channels below.

---

## Support

For bug reports and feature requests, please open an issue on GitHub:
👉 [github.com/gabrielcoelho90/aimirante/issues](https://github.com/gabrielcoelho90/aimirante/issues)

For general inquiries:
📧 contato@aimirante.com.br

---

## License

Proprietary — All rights reserved. © 2026 AI.mirante

Unauthorized copying, distribution, or use of this software is strictly prohibited.

---

## Authors & Acknowledgments

**Gabriel Coelho** — Founder & Developer
- Software Developer, former Brazilian SpecOps
- [github.com/gabrielcoelho90](https://github.com/gabrielcoelho90)

Special thanks to the Brazilian Navy officers who shared their experience and pain points that made this product possible.

---

## Project Status & Roadmap

**Current Status:** 🚧 Active Development — MVP in progress

### Completed
- [x] Project setup — Rails 7.2 + PostgreSQL
- [x] GitHub repository and branch strategy
- [x] Architecture Decision Records (ADRs)

### In Progress
- [ ] Authentication with anti-sharing (Devise + device fingerprinting)
- [ ] PDF ingestion pipeline (chunking + embeddings + pgvector)

### Planned
- [ ] Study bot (RAG)
- [ ] Pre-generated summaries (3 levels)
- [ ] Flashcards with Spaced Repetition (SM-2)
- [ ] Simulated exams by subject
- [ ] User file upload (personal RAG)
- [ ] Geopolitics news feed
- [ ] Mobile app

### Known Issues
None at this stage.
