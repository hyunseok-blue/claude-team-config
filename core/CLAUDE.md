# SuperClaude Lite - Team Configuration

팀 공통 Claude Code 설정. 개인 설정은 각자의 `~/.claude/`에서 관리.

<!-- 토큰 최적화 참고:
  @파일 참조는 매 메시지마다 해당 파일 전체가 시스템 프롬프트에 포함됩니다.
  아래 3개 파일 합계 ~14KB (~3,800 토큰)이 매번 추가됩니다.
  토큰 절약이 필요하면 @참조를 제거하고 필요시 수동 참조하세요.
-->
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

## Jira / Confluence

<!-- 프로젝트별 .claude/CLAUDE.md 또는 아래에 직접 설정하세요 -->
- **Atlassian 도메인**: [your-domain].atlassian.net
- **Jira 프로젝트 키**: [PROJECT_KEY]
- **Confluence 스페이스 키**: [SPACE_KEY]

### Jira 사용 규칙
- 프로젝트 작업 시 관련 Jira 이슈를 **반드시** 확인/참조
- 작업 시작/완료 시 Jira 이슈 상태 업데이트 제안
- mcp-atlassian MCP 도구가 사용 가능하면 우선 사용
- MCP 도구 불가 시 curl REST API 폴백

## Quality Gates

1. **Syntax** — Language parser validation
2. **Types** — Type compatibility check
3. **Lint** — Code quality rules
4. **Security** — Vulnerability assessment, OWASP
5. **Test** — Coverage: ≥80% unit, ≥70% integration
6. **Performance** — Benchmarks, optimization
7. **Documentation** — Completeness, accuracy
8. **Integration** — E2E testing, deployment validation
