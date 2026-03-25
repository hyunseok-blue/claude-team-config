# SuperClaude Lite - 팀 Claude Code 설정

팀 공통 Claude Code 설정 패키지. 페르소나 자동 활성화, `/sc:` 커맨드, 품질 스킬을 제공합니다.

## 빠른 시작 (3분)

```bash
# 1. 이 repo 클론
git clone <repo-url>
cd claude-team-config

# 2. 설치 (기존 설정은 자동 백업됨)
chmod +x install.sh
./install.sh

# 3. Claude Code 재시작
```

미리보기만 하려면:
```bash
./install.sh --dry-run
```

## 주요 커맨드

| 커맨드 | 설명 | 예시 |
|--------|------|------|
| `/sc:implement` | 기능 구현 | `/sc:implement 로그인 API --type api` |
| `/sc:analyze` | 코드 분석 | `/sc:analyze src/ --focus security` |
| `/sc:test` | 테스트 실행 | `/sc:test --type unit --coverage` |
| `/sc:troubleshoot` | 디버깅 | `/sc:troubleshoot 빌드 에러 --type build` |
| `/sc:improve` | 코드 개선 | `/sc:improve src/utils --type quality` |
| `/sc:git` | Git 워크플로우 | `/sc:git --smart-commit` |
| `/sc:explain` | 코드 설명 | `/sc:explain src/auth --level intermediate` |
| `/sc:build` | 빌드 | `/sc:build` |

## 페르소나 자동 활성화

대화에서 특정 키워드를 사용하면 전문가 페르소나가 자동 활성화됩니다:

| 키워드 | 페르소나 | 전문 분야 |
|--------|----------|-----------|
| "component", "responsive" | `frontend` | Next.js, React, 접근성 |
| "API", "database" | `backend` | FastAPI, 데이터 무결성 |
| "analyze", "root cause" | `analyzer` | 디버깅, 근본 원인 분석 |
| "test", "quality" | `qa` | 테스트 전략, 품질 관리 |
| "architecture", "design" | `architect` | 시스템 설계, 확장성 |
| "vulnerability", "auth" | `security` | 보안 검토, 위협 모델링 |

수동 활성화: `--persona-frontend`, `--persona-backend` 등

## Thinking 플래그

복잡한 작업에서 더 깊은 분석을 요청할 수 있습니다:

```
--think       → 멀티파일 분석 (기본)
--think-hard  → 시스템 전체 분석 (리팩토링, 보안)
--ultrathink  → 아키텍처 재설계급 분석
```

## 포함된 스킬

| 스킬 | 용도 |
|------|------|
| `test-driven-development` | TDD 워크플로우 |
| `systematic-debugging` | 체계적 디버깅 프로세스 |
| `requesting-code-review` | 코드 리뷰 요청 |
| `receiving-code-review` | 코드 리뷰 피드백 처리 |
| `verification-before-completion` | 완료 전 검증 체크리스트 |
| `writing-plans` | 구현 계획 작성 |
| `executing-plans` | 계획 기반 구현 |
| `webapp-testing` | 웹앱 테스트 |

## 프로젝트별 설정

각 프로젝트에 맞는 `.claude/CLAUDE.md`를 만들 수 있습니다:

```bash
# 프로젝트 루트에서
mkdir -p .claude
cp ~/claude-team-config/templates/project-claude.md.template .claude/CLAUDE.md
# CLAUDE.md를 프로젝트에 맞게 수정
```

이 파일을 git에 커밋하면 팀 전원에게 자동 적용됩니다.

## 고급 설정 (선택)

더 강력한 기능이 필요하면:

1. **oh-my-claudecode (OMC)** — 멀티에이전트 오케스트레이션
   ```
   npx oh-my-claudecode setup
   ```

2. **Context7 MCP** — 라이브러리 문서 자동 참조 (이미 설정에 포함)

3. **추가 페르소나** — `~/.claude/PERSONAS.md`에 직접 추가 가능
   - `mentor`: 코드 설명, 교육
   - `performance`: 성능 최적화
   - `devops`: 인프라, 배포
   - `refactorer`: 리팩토링, 기술 부채
   - `scribe`: 문서 작성

## 토큰 최적화

CLAUDE.md는 매 메시지마다 시스템 프롬프트로 재전송됩니다. 크기를 줄이면 비용이 직접 절감됩니다.

- **`@파일` 참조 비용**: `@COMMANDS.md` + `@PERSONAS.md` + `@SYSTEM.md` = ~14KB (~3,800 토큰/메시지)
- **권장 CLAUDE.md 크기**: 8KB 이하 (핵심 규칙만 포함)
- **불필요한 섹션 제거**: OMC 사용 시 agent_catalog, skills, mcp_routing 등은 플러그인이 자동 주입
- **진심모드 주의**: 삼중 병렬 실행은 비용 3-5배 증가. 기본 비활성화 권장

## 제거

```bash
./uninstall.sh
# 또는 특정 백업에서 복원
./uninstall.sh ~/.claude/backup-20260323-141500
```

## 구조

```
claude-team-config/
├── core/              # 핵심 프레임워크
│   ├── CLAUDE.md      # 메인 설정 (~70줄)
│   ├── COMMANDS.md    # 커맨드 정의
│   ├── PERSONAS.md    # 6개 페르소나
│   └── SYSTEM.md      # 시스템 설정
├── commands/sc/       # 8개 슬래시 커맨드
├── skills/            # 8개 품질 스킬
├── templates/         # 프로젝트 템플릿
├── install.sh         # 설치
└── uninstall.sh       # 제거
```
