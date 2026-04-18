# AI.mirante — Project Context

This file contains the full context of the AI.mirante project — decisions made, stack chosen, product vision, and current status. Use this file to onboard new conversations with Claude or any new developer.

---

## Product

### What is AI.mirante?
AI.mirante is an AI-powered study platform built exclusively for Brazilian Navy Senior Officers preparing for the **CEMOS** (Curso de Estado-Maior para Oficiais Superiores — Senior Officers' Staff Course) admission exam.

### The Problem
- The CEMOS exam is increasingly competitive with limited spots
- The bibliography is massive — 6 subjects, 64 PDFs, ~138 MB of dense material
- Officers are in their 40s with busy careers, families, and limited study time
- Officers start studying 1-2 years in advance, use 60 days of vacation for study, and some rent separate apartments to stay focused
- Passing the exam means a promotion to Capitão de Mar e Guerra (the last rank before the Admiralty) — worth R$ 3,000/month more for the rest of their career

### The Solution
A platform that indexes the entire official CEMOS bibliography in a vector database and delivers:
- AI-powered study bot (RAG) — answers based on the official bibliography only
- Pre-generated summaries at 3 levels (quick, medium, complete)
- Flashcards with Spaced Repetition System (SM-2 algorithm)
- Simulated exams (coming soon)
- Personal file upload for RAG (coming soon)

### Why AI.mirante wins vs ChatGPT
- Answers come from the exact official bibliography — not the generic internet
- Built specifically for CEMOS — knows what the exam tests
- Integrated SRS flashcards with the official material
- Simulated exams in the style of the actual CEMOS exam
- Built by a Navy officer — credibility no competitor can replicate

### Business Model
| Plan | Price |
|---|---|
| Monthly | R$ 197/month |
| Semi-annual | R$ 997 |
| Annual | R$ 1,697 |

Target margin: ~96% (API cost ~R$ 4/user/month)

### Anti-sharing Strategy
- One active device per user at a time
- Device fingerprinting (fingerprintjs)
- Automatic logout on new device login with email notification
- Rate limiting per user

---

## Study Material

All material downloaded from the official Brazilian Navy website (marinha.mil.br/egn/concursos).

| Subject | PDFs | Size |
|---|---|---|
| Estratégia (Strategy) | 26 | 101 MB |
| Serviço de Intendência (Supply) | 21 | 14.9 MB |
| História (History) | 6 | 9.4 MB |
| Planejamento Militar (Military Planning) | 6 | 9.7 MB |
| Política (Politics) | 2 | 2.4 MB |
| Geopolítica (Geopolitics) | 3 | 1.2 MB |
| **Total** | **64** | **~138 MB** |

---

## Technical Stack

### Architecture
Monorepo with two separate projects:
```
aimirante/
  backend/    → Rails API
  frontend/   → React + Vite
```

### Backend
| Technology | Version | Purpose |
|---|---|---|
| Ruby | 3.3.0 | Backend language |
| Rails | 7.2.0 | Web framework (API mode) |
| PostgreSQL | 16 | Primary database |
| pgvector | latest | Vector similarity search (RAG) |
| Redis | 7+ | Background job queue |
| Sidekiq | 7+ | Async PDF processing |
| Devise | latest | Authentication |
| JWT | latest | Token-based auth + anti-sharing |

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| Node.js | 20+ | JavaScript runtime |
| React | 18+ | Frontend framework |
| Vite | 8+ | Build tool |

### AI / ML
| Technology | Purpose |
|---|---|
| OpenAI text-embedding-3-small | Text embeddings for vector search |
| Anthropic Claude API | LLM for RAG responses and summaries |

### Infrastructure
| Technology | Purpose |
|---|---|
| Railway or Render | Hosting (TBD) |
| AWS S3 | PDF storage |
| aimirante.com.br | Domain (registered) |

---

## Key Architectural Decisions

### ADR-001 — Rails API mode + React (not Rails Full + Hotwire)
**Decision:** Use Rails in API mode with a separate React frontend.
**Reason:** React is more valuable for the developer's career goals, better for highly interactive UI (chat, flashcards), and easier to extend to mobile in the future.

### ADR-002 — pgvector instead of Pinecone
**Decision:** Use pgvector extension on PostgreSQL as the vector database.
**Reason:** Keeps everything in one database, reduces infrastructure complexity and cost for MVP.

### ADR-003 — Claude (Anthropic) as the primary LLM
**Decision:** Use Claude API for RAG responses and summary generation.
**Reason:** Better performance on dense document reading compared to alternatives.

### ADR-004 — Monorepo
**Decision:** Keep backend and frontend in one GitHub repository.
**Reason:** Simpler to manage as a solo developer.

### ADR-005 — Pre-generated summaries
**Decision:** Generate summaries in advance (not on-demand).
**Reason:** Reduces API costs and response time. Process once, serve to all users.

---

## Development Roadmap

### Phase 1 — Foundation (current)
- [x] Environment setup (Ruby 3.3.0, PostgreSQL 16, Rails 7.2.0, Node.js)
- [x] Monorepo structure (backend + frontend)
- [x] GitHub repository (github.com/gabrielcoelho90/aimirante)
- [x] Professional README
- [ ] Git configuration (name + email)
- [ ] GitHub Projects kanban setup
- [ ] ADR documentation

### Phase 2 — Authentication
- [ ] Devise + JWT setup
- [ ] Device fingerprinting (anti-sharing)
- [ ] User model + migrations

### Phase 3 — RAG Pipeline
- [ ] PDF ingestion pipeline (chunking + embeddings)
- [ ] pgvector setup and configuration
- [ ] Study bot (RAG chat)

### Phase 4 — Core Features
- [ ] Pre-generated summaries (3 levels)
- [ ] Flashcards with SM-2 algorithm
- [ ] User performance dashboard

### Phase 5 — Frontend
- [ ] React app structure
- [ ] Authentication screens
- [ ] Chat interface
- [ ] Flashcard interface
- [ ] Dashboard

### Phase 6 — Production
- [ ] Simulated exam generator
- [ ] Stripe billing integration
- [ ] Deployment (Railway or Render)
- [ ] Domain configuration (aimirante.com.br)

---

## Go-to-market Strategy
- Launch publicly (not closed beta)
- Collect feedback inside the platform (thumbs up/down on RAG responses, NPS)
- Target: Brazilian Navy Senior Officers preparing for CEMOS
- Distribution: Word of mouth within the Navy (founder is a Navy officer)

---

## Repository
- GitHub: github.com/gabrielcoelho90/aimirante
- Domain: aimirante.com.br

## Developer
- Name: Gabriel Coelho
- Role: Founder + Solo Developer + Product Owner
- Background: Brazilian Navy Officer
- GitHub: github.com/gabrielcoelho90

---

## Engineering Principles

These principles guide how this project is built.

### 1. This is not "vibe coding" — it is XP accelerated by AI
Vibe coding without discipline produces throwaway prototypes. This project follows Extreme Programming practices with Claude Code as the pair programming partner. The AI types fast, the human decides direction.

### 2. The human decides WHAT. The AI decides HOW.
- Developer: defines direction, questions decisions, interrupts over-engineering, brings domain knowledge
- Claude Code: writes code, runs tests, proposes solutions, executes refactoring
- Inverting this dynamic always produces worse results

### 3. TDD from the first commit — never retroactive
- Every feature has tests written alongside the code, never after
- More lines of tests than lines of code is the goal (ratio ~1.5x)
- Tests are the safety net that allows the AI to modify code with confidence
- Without tests, every AI change is a gamble

### 4. Every commit passes CI — no exceptions
CI pipeline runs on every push:
- RuboCop (code style)
- Brakeman (security static analysis)
- Full test suite
- No "broken commit that will be fixed in the next one"
- Every commit on main is production-ready

### 5. Continuous refactoring — never accumulate technical debt
- Small refactoring commits constantly (Extract, DRY, Simplify)
- Never let files grow to 5,000 lines and then do "emergency surgery"
- When the AI proposes something over-engineered: stop and simplify
- The AI stacks code — the human prunes it regularly

### 6. Small releases — each commit is atomic
- Each commit adds one thing, passes CI, is ready to deploy
- If something goes wrong, revert one commit
- No big bang merges, no "I'll fix it later" commits

### 7. Security is a habit, not a phase
- Brakeman runs on every commit
- Vulnerabilities are fixed the moment they appear
- Never a "security sprint at the end"

### 8. CLAUDE.md is the living spec
- This file (renamed to CLAUDE.md) is read by Claude Code before every session
- Every architectural decision, known pitfall, and pattern is documented here
- Documentation investment returns immediately — the AI actually reads it
- When a new problem is discovered, document the solution here immediately

### 9. The AI never says no — the developer is the adult in the room
- The AI implements anything asked with equal enthusiasm
- The developer is the brake, the code review, and the quality gate
- If something feels over-engineered: it is. Simplify.

### 10. Commit distribution target
| Category | Target % |
|---|---|
| New features (feat:) | ~37% |
| Bug fixes (fix:) | ~16% |
| Refactoring (refactor:) | ~10% |
| Security (security:) | ~8% |
| Deploy/infra (chore:) | ~11% |
| Tests/CI (test:) | ~16% |
| Documentation (docs:) | ~10% |

If 100% of commits are features, the project is accumulating invisible debt.

---

## Language Convention
- **Code:** English (variables, methods, classes, table names, columns)
- **UI:** Portuguese (all user-facing text)
- **Commits:** English (Conventional Commits format — feat:, fix:, docs:, etc.)
- **Documentation:** English
