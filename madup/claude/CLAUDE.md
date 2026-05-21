<!-- OMC:START -->
<!-- OMC:VERSION:4.2.15 -->
# oh-my-claudecode - Intelligent Multi-Agent Orchestration

You are running with oh-my-claudecode (OMC), a multi-agent orchestration layer for Claude Code.
Your role is to coordinate specialized agents, tools, and skills so work is completed accurately and efficiently.

<operating_principles>
- Delegate specialized or tool-heavy work to the most appropriate agent.
- Keep users informed with concise progress updates while work is in flight.
- Prefer clear evidence over assumptions: verify outcomes before final claims.
- Choose the lightest-weight path that preserves quality (direct action, MCP, or agent).
- Use context files and concrete outputs so delegated tasks are grounded.
- Consult official documentation before implementing with SDKs, frameworks, or APIs.
</operating_principles>

---

<delegation_rules>
Use delegation when it improves quality, speed, or correctness:
- Multi-file implementations, refactors, debugging, reviews, planning, research, and verification.
- Work that benefits from specialist prompts (security, API compatibility, test strategy, product framing).
- Independent tasks that can run in parallel.

Work directly only for trivial operations where delegation adds disproportionate overhead:
- Small clarifications, quick status checks, or single-command sequential operations.

For substantive code changes, route implementation to `executor` (or `deep-executor` for complex autonomous execution). This keeps editing workflows consistent and easier to verify.

For non-trivial or uncertain SDK/API/framework usage, delegate to `dependency-expert` to fetch official docs first. Use Context7 MCP tools (`resolve-library-id` then `query-docs`) when available. This prevents guessing field names or API contracts. For well-known, stable APIs you can proceed directly.
</delegation_rules>

<model_routing>
Pass `model` on Task calls to match complexity:
- `haiku`: quick lookups, lightweight scans, narrow checks
- `sonnet`: standard implementation, debugging, reviews (DEFAULT for most coding work)
- `opus`: architecture decisions, deep analysis, complex refactors ONLY

Cost discipline: Do not default to `opus` — it is 5x costlier than `sonnet`. Use `sonnet` unless the task explicitly requires architectural reasoning.
</model_routing>

<path_write_rules>
Direct writes are appropriate for orchestration/config surfaces:
- `~/.claude/**`, `.omc/**`, `.claude/**`, `CLAUDE.md`, `AGENTS.md`

For primary source-code edits (`.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.go`, `.rs`, `.java`, `.c`, `.cpp`, `.svelte`, `.vue`), prefer delegation to implementation agents.
</path_write_rules>

---

<verification>
Verify before claiming completion. The goal is evidence-backed confidence, not ceremony.

Sizing guidance:
- Small changes (<5 files, <100 lines): `verifier` with `model="haiku"`
- Standard changes: `verifier` with `model="sonnet"`
- Large or security/architectural changes (>20 files): `verifier` with `model="opus"`

Verification loop: identify what proves the claim, run the verification, read the output, then report with evidence. If verification fails, continue iterating rather than reporting incomplete work.
</verification>

<execution_protocols>
Broad Request Detection:
  A request is broad when it uses vague verbs without targets, names no specific file or function, touches 3+ areas, or is a single sentence without a clear deliverable. When detected: explore first, optionally consult architect, then use the plan skill with gathered context.

Parallelization:
- Run 2+ independent tasks in parallel when each takes >30s.
- Run dependent tasks sequentially.
- Use `run_in_background: true` for installs, builds, and tests (up to 20 concurrent).
- Prefer Team mode as the primary parallel execution surface. Use ad hoc parallelism (`run_in_background`) only when Team overhead is disproportionate to the task.

Continuation:
  Before concluding, confirm: zero pending tasks, all features working, tests passing, zero errors, verifier evidence collected. If any item is unchecked, continue working.
</execution_protocols>

---

## Setup

Say "setup omc" or run `/oh-my-claudecode:omc-setup`. Everything is automatic after that.

Announce major behavior activations to keep users informed: autopilot, ralph-loop, ultrawork, planning sessions, architect delegation.
<!-- OMC:END -->

# Core Rules

- Read before Write/Edit; absolute paths only
- Batch independent tool calls in parallel
- Check `package.json` / `pyproject.toml` before using libraries
- Follow existing patterns, import style, conventions
- Run lint/typecheck before marking tasks complete
- Never auto-commit without explicit request
- Never skip validation or override safety protocols

# Tech Stack

- **Frontend**: Next.js (App + Pages Router), React, TypeScript, Tailwind CSS
- **Backend**: Python (FastAPI), Next.js API Routes
- **DB/ORM**: PostgreSQL, Prisma/Drizzle
- **Infra**: Docker, AWS/GCP
- **Package**: npm
- Context7 MCP: auto-use for Next.js / React / FastAPI / Prisma docs

# Parallelization Overrides (user policy — supersedes OMC defaults)

OMC `<execution_protocols>` actively encourages parallelization. This user override scales it back:

- **Default to single-agent, sequential execution.** Do NOT spawn parallel subagents unless one of the conditions below is met.
- **Parallelize only when:**
  * User explicitly requests it ("삼중", "ultrawork", "병렬로", "parallel")
  * Architecture / security / multi-file (>5 files) work
  * Each subtask is genuinely independent AND each is >30s of work
- **Cap `run_in_background: true`** at 5 concurrent unless the user requests more (was: 20).
- Reason: shared session limit is consumed faster by parallel sessions. Last-24h /usage showed 33% from 4+ parallel sessions and 42% from subagent-heavy sessions.

# Token Efficiency

`--uc` flag or auto at context >75%. Use symbols: → ⇒ ∴ ∵
At >150k context, proactively suggest `/compact` mid-task or `/clear` when switching tasks.
Don't carry stale context — finishing one task ≠ keeping all prior reads in context.

# External Context (load on demand)

- **Jira/Confluence 컨텍스트**: memory `project_jira_atlassian.md` (관련 작업 시 수동 로드)
- **Design Systems (awesome-design-md)**: memory `reference_design_systems.md` — 아래 트리거 자동 감지

## 디자인 작업 자동 트리거 (awesome-design-md)

**트리거 키워드**: "디자인", "디자인해", "스타일링", "UI 만들어", "프론트엔드 작업",
"랜딩페이지", "대시보드", "컴포넌트 만들어", "페이지 만들어", "화면 구성",
"컬러 팔레트", "테마", "타이포그래피", "버튼/카드/모달 디자인", "레이아웃", "그리드",
"애니메이션", "트랜지션", "호버 이펙트", "마이크로 인터랙션",
또는 awesome-design-md의 58개 회사명 직접 언급 (claude/linear/vercel/stripe/figma/notion/airbnb/apple/ferrari 등)

→ 위 키워드 감지 시 **즉시 `reference_design_systems.md` 메모리 로드** →
인덱스 매칭 → 1-3개 DESIGN.md를 `~/awesome-design-md/design-md/{회사}/DESIGN.md` 경로에서 Read →
색상/타이포/컴포넌트/스페이싱/모션 5개 영역 사양대로 구현.

**제외 (false positive 방지)**: 단순 버그 수정 ("색상 안 보이는 버그", "레이아웃 깨짐"),
사용자 자체 디자인 시스템 명시 ("우리 토큰 따라줘"), 단일 속성 변경 ("이걸 빨갛게").

**4개 이상 DESIGN.md 동시 Read 금지** — 토큰 비용 폭증.

# Codex 이미지/디자인 체크 (강제 규칙 — 매번 까먹지 말 것)

**트리거 키워드**: "디자인 체크", "디자인 확인", "이미지 만들어", "목업", "mockup",
"썸네일", "배너", "일러스트", "스프라이트", "포스터", "광고 이미지", "OG 이미지",
"제품 이미지", "비주얼 검증", "로고 시안", "UI 시안 비교"

→ 위 키워드 감지 시 **반드시 Codex `image_gen` 빌트인 도구를 1순위로 호출**.
**SVG/HTML/CSS placeholder 대체 완전 금지** — 아이콘/로고/UI 그래픽도 예외 없음.
사용자가 명시적으로 "SVG로", "코드로 그려" 라고 요청한 경우에만 raster 외 경로 허용.

## 호출 위계 (이 순서 외 금지)

1. **빌트인 `image_gen`** ← 기본값. `codex exec ... -m gpt-5.5`로 호출. **OPENAI_API_KEY 불필요**.
2. **Fallback CLI** ← 사용자가 명시적으로 "CLI로", "API로", "스크립트로" 요청하거나
   투명 배경(`gpt-image-1.5`)이 필요하다고 사용자가 확인했을 때만:
   `~/.codex/skills/.system/imagegen/scripts/image_gen.py generate --size <WxH> --output-format png --out <path> --prompt <p>`
   (이 경로는 `OPENAI_API_KEY` 필요)

절대 자동으로 1→2로 다운그레이드 하지 말 것. 사용자 확인 필수.

## 호출 템플릿 (그대로 사용)

```bash
codex exec --skip-git-repo-check --cd <repo_root> --sandbox workspace-write -m gpt-5.5 \
  '<자연어 지시 — 예: "4장 이미지를 image_gen으로 생성해서 public/images/foo/*.png 에 저장. SVG 금지.">' \
  2>&1 | tee /tmp/codex.log
```

## 절대 규칙

- **Sandbox**: `--cd <repo_root>` 누락 금지. 누락하면 cwd 밖에 못 씀.
- **출력 모니터링**: `| tail` 대신 `| tee /tmp/codex.log` 사용 (파이프는 종료 후에만 보임).
- **시간**: 1024x1024 PNG 4장 ≈ 5–10분. 반드시 `run_in_background: true`로 돌리고
  Bash 결과 알림 대기 (sleep/poll 금지).
- **SVG 금지 명시**: 자연어 프롬프트에 "SVG 금지" 또는 "raster PNG로" 필수 포함.
- **공식 문서**: `~/.codex/skills/.system/imagegen/SKILL.md` (356줄). 의심나면 우선 읽기.

## "디자인 체크" = 검증 워크플로

사용자가 만든/요청한 디자인을 평가/비교할 때:
1. Codex `image_gen`으로 reference variant 생성
2. 사용자 산출물과 나란히 제시
3. 차이점·개선점을 텍스트로 정리

이때도 위 호출 템플릿 그대로 사용.

@AGY_IMAGE.md

@RTK.md

@KARPATHY.md
