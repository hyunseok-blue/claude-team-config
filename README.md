# DCT Claude Code Plugin

데이터 컨설팅 팀(DCT)의 AI Native 개발 환경 온보딩 및 **Jira/GitHub 워크플로우 자동화** 플러그인.

## 이게 뭐예요?

데컨팀 신규 팀원이 Claude Code를 빠르게 셋업하고, 팀 표준 워크플로우(Jira 카드 기반 개발 → 브랜치 → 구현 → 댓글 정리)를 한 커맨드로 실행할 수 있게 해주는 **Claude Code 네이티브 플러그인**입니다.

## 주요 기능

### 커맨드
| 커맨드 | 설명 |
|--------|------|
| `/dct` | 신규 팀원 온보딩 — MCP(Atlassian/GitHub) 설정, SSH 키, 팀 CLAUDE.md 배포 |
| `/dct-plan <DCTC-번호> [설명]` | 플랜 작성 → Jira 업로드 → `feature/DCTC-N` 브랜치 진입 (구현은 자유) |
| `/dct-complete <DCTC-번호>` | 결과 요약 → Jira 완료 댓글 → PR 생성 (사용자 확인 후) |
| `/dct-job <DCTC-번호> <타입> <설명>` | 플랜→구현→검증→PR 완전 자동화 파이프라인 |
| `/sc:analyze` | 코드 품질/보안/성능/아키텍처 종합 분석 |
| `/sc:implement` | 기능 구현 (페르소나 자동 활성화) |
| `/sc:troubleshoot` | 이슈 진단 및 해결 |
| `/sc:improve` | 코드 품질 개선 |
| `/sc:test` | 테스트 실행 및 리포트 |
| `/sc:build` | 프로젝트 빌드 |

### 스킬
- `dct-onboarding` — `/dct` 백엔드
- `dct-jira-workflow` — `/dct-job` 백엔드
- `test-driven-development` — TDD 워크플로우
- `systematic-debugging` — 체계적 디버깅
- `writing-plans` / `executing-plans` — 계획 작성·실행
- `verification-before-completion` — 완료 전 검증
- `requesting-code-review` / `receiving-code-review` — 코드 리뷰
- `webapp-testing` — 웹앱 테스트 (Playwright 기반)

### 팀 기본 규칙 (`rules/`)
플러그인 설치 후 `/dct` 실행 시 `~/.claude/rules/` 로 배포되는 8개 규칙:
- `korean-dev.md` — 한국어 응답/커밋, 코드는 영어 유지
- `personal.md` — 사용 정책
- `performance.md` — 모델 선택, 컨텍스트 관리
- `agents.md` — 서브에이전트 위임 기준
- `python.md` — Python 가이드
- `team-workflow.md` — GitHub/Jira/Confluence 워크플로우
- `aws.md` — AWS 작업 가이드
- `doc-updates.md` — 문서 동기화

## 설치

### 방법 1: 플러그인 디렉토리 참조 (로컬 개발)
```bash
git clone https://github.com/hyunseok-blue/claude-team-config.git ~/dct-plugin
claude --plugin ~/dct-plugin
```

### 방법 2: `/plugin install` (권장)
Claude Code 내에서:
```
/plugin install <plugin-source>
```

설치 후 Claude Code를 **재시작**하고 `/dct` 를 실행하세요.

## 빠른 시작

```bash
# 1. 플러그인 설치 (위 참고)

# 2. Claude Code 재시작

# 3. 온보딩 실행
/dct

# 4. Jira 카드 작업 시작
/dct-job DCTC-1808 feat "프론트 사이드바 애니메이션 개선"
```

## MCP 설정

`settings-example.json` 이 리포 루트에 있습니다. `/dct` 커맨드가 이 파일을 참조하여 사용자의 `~/.claude/settings.json` 으로 복사하고, 다음 MCP 서버를 설정하도록 안내합니다:

- **mcp-atlassian** (uvx) — Jira + Confluence
- **github** (Docker + PAT) — `github-mcp-server`

## 구조

```
claude-team-config/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 메타
├── commands/
│   ├── dct.md               # /dct
│   ├── dct-job.md           # /dct-job
│   └── sc/                  # /sc:* 6개
├── skills/                  # 9개 스킬 (dct-* 2개 + 공통 7개)
├── rules/                   # 팀 기본 규칙 8개
├── core/
│   └── CLAUDE.md            # 사용자 전역 CLAUDE.md 템플릿
├── templates/
│   └── project-claude.md.template   # 프로젝트별 CLAUDE.md 템플릿
├── settings-example.json    # MCP 설정 예시
└── README.md
```

## 문의/기여
- 리포: https://github.com/hyunseok-blue/claude-team-config
- 이슈/PR 환영
