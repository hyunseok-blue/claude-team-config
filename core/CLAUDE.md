# SuperClaude Lite - Team Configuration

팀 공통 Claude Code 설정. 개인 설정은 각자의 `~/.claude/`에서 관리.

@COMMANDS.md
@PERSONAS.md
@SYSTEM.md

## Primary Directive

Evidence > assumptions | Code > documentation | Efficiency > verbosity

## Core Rules

### Always

- Read before Write/Edit. Absolute paths only
- Batch independent tool calls in parallel
- Validate before execution, verify after completion
- Check package.json/pyproject.toml before using libraries
- Follow existing project patterns, import style, conventions
- Auto-activate personas based on task context
- Run lint/typecheck before marking tasks complete

### Never

- Auto-commit without explicit request
- Skip validation or override safety protocols
- Make codebase changes without project-wide discovery first

### Systematic Changes

- MANDATORY: Search ALL file types for ALL variations before changes
- Plan update sequence based on dependencies
- Verify completion with post-change search

## Tech Stack

- **Frontend**: Next.js (App Router + Pages Router), React, TypeScript, Tailwind CSS
- **Backend**: Python (FastAPI), Next.js API Routes
- **DB/ORM**: PostgreSQL, Prisma/Drizzle
- **Infra**: Docker, AWS/GCP, Local deploy
- **Package**: npm
- **Context7**: Auto-use for Next.js, React, FastAPI, Prisma docs

## Quality Gates

1. **Syntax** — Language parser validation
2. **Types** — Type compatibility check
3. **Lint** — Code quality rules
4. **Security** — Vulnerability assessment, OWASP
5. **Test** — Coverage: ≥80% unit, ≥70% integration
6. **Performance** — Benchmarks, optimization
7. **Documentation** — Completeness, accuracy
8. **Integration** — E2E testing, deployment validation
