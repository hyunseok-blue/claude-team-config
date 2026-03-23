# Claude Code 팀 설정 공유 안내

## 이게 뭔가요?

Claude Code를 쓸 때 **팀 전체가 일관된 품질로 작업**할 수 있도록 만든 공통 설정 패키지입니다.

설치하면 이런 것들이 추가됩니다:
- **슬래시 커맨드** — `/sc:implement`, `/sc:analyze` 등 8개 커맨드로 표준화된 워크플로우
- **자동 페르소나** — "API" 얘기하면 backend 전문가 모드, "component" 얘기하면 frontend 전문가 모드로 자동 전환
- **품질 스킬** — TDD, 코드리뷰, 디버깅 등 8개 스킬이 자동으로 적용
- **품질 게이트** — Syntax → Types → Lint → Security → Test → Performance → Docs → Integration 8단계 검증

## 왜 만들었나요?

Claude Code는 기본 상태로도 유용하지만, 설정을 잘 잡아두면 체감 품질이 확 달라집니다.

- 코드 분석 시 보안/성능/품질을 **자동으로 다각도 검토**
- 기능 구현 시 프로젝트 컨벤션과 Tech Stack을 **자동 인식**
- 테스트/커밋/리뷰 같은 반복 작업을 **커맨드 하나로 실행**
- 복잡한 문제는 `--think-hard` 플래그로 **깊은 분석 모드** 활성화

각자 처음부터 설정하는 대신, 검증된 설정을 공유해서 바로 쓸 수 있게 한 겁니다.

## 설치 방법 (3분)

```bash
git clone https://github.com/hyunseok-blue/claude-team-config.git
cd claude-team-config
./install.sh
```

- 기존 설정이 있으면 **자동 백업**됩니다 (걱정 안 해도 됨)
- 미리 뭐가 설치되는지 보려면: `./install.sh --dry-run`
- 제거하려면: `./uninstall.sh`

설치 후 Claude Code를 **재시작**하면 적용됩니다.

## 바로 써볼 수 있는 것들

### 슬래시 커맨드
```
/sc:implement 로그인 API --type api        → API 구현 (backend 페르소나 자동 활성화)
/sc:analyze src/ --focus security          → 보안 중심 코드 분석
/sc:test --type unit --coverage            → 테스트 실행 + 커버리지 리포트
/sc:troubleshoot 빌드 에러 --type build    → 체계적 디버깅
/sc:improve src/utils --type quality       → 코드 품질 개선
/sc:git --smart-commit                     → 변경사항 분석해서 커밋 메시지 자동 생성
```

### 깊은 분석이 필요할 때
```
--think       → 여러 파일에 걸친 분석
--think-hard  → 시스템 전체 분석 (리팩토링, 보안 검토)
--ultrathink  → 아키텍처 재설계급 깊은 분석
```

### 페르소나 수동 활성화
```
--persona-frontend    → Next.js/React 전문가 모드
--persona-backend     → FastAPI/API 전문가 모드
--persona-security    → 보안 전문가 모드
--persona-qa          → 테스트/품질 전문가 모드
```

## 프로젝트별 설정 (선택)

각 프로젝트 repo에 `.claude/CLAUDE.md`를 만들면 프로젝트 맞춤 설정도 가능합니다:

```bash
mkdir -p .claude
cp ~/claude-team-config/templates/project-claude.md.template .claude/CLAUDE.md
# 프로젝트에 맞게 수정 후 git commit
```

이걸 git에 커밋하면 해당 프로젝트에서 작업하는 모든 팀원에게 자동 적용됩니다.

## 더 강력하게 쓰고 싶다면

- **oh-my-claudecode (OMC)** 플러그인: 멀티에이전트 병렬 실행, 자동 코드 리뷰 등
- **Context7 MCP**: Next.js, React, FastAPI 공식 문서 자동 참조
- **추가 페르소나**: mentor, performance, devops, refactorer 등 5개 더 추가 가능

관심 있으면 편하게 물어보세요!

## 문제가 있다면

- `./uninstall.sh`로 언제든 원래 상태로 복원 가능
- 기존 개인 설정이 있었다면 `~/.claude/backup-*` 폴더에 백업되어 있음
