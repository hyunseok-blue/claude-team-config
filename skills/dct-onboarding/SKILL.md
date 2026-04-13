---
name: dct-onboarding
description: 데이터 컨설팅 팀(DCT) Claude Code 신규 셋업 가이드. Atlassian MCP, SSH 키, gh CLI, 팀 CLAUDE.md/rules 배포를 단계별로 안내한다. Slack/AWS는 선택 단계.
---

# DCT 온보딩 스킬

`/dct` 커맨드의 백엔드. 신규 팀원이 AI Native 개발 환경에 빠르게 적응하도록 돕는다.

## 설계 원칙

- **Claude 는 토큰 값을 직접 보지 않는다** — 사용자가 리포의 `settings-example.json` 을 에디터로 직접 편집 → 완료 후 `jq` 로 `~/.claude.json` 에 병합
- **기존 파일 통째 덮어쓰기 절대 금지** — 백업 후 `jq` 병합, 또는 신규 생성 시에만 Write 허용
- **이미 설정된 항목은 건너뛴다** — 기존 SSH 키, `gh` 로그인, CLAUDE.md, rules 존재 시 스킵
- **GitHub 는 `gh` CLI + SSH 조합** — GitHub MCP/Docker/PAT 방식은 사용하지 않음
- **진단 먼저, 가이드 나중** — 모든 단계 시작 전 자동 환경 진단 후 ❌ 항목만 안내

## 환경 진단 (Step 0)

온보딩 시작 시 아래를 자동 검사해 체크리스트 형식으로 출력한다. **토큰 값은 절대 출력하지 않고**, 키 존재 여부·명령 성공 여부만 확인.

| 항목 | 검사 명령 | ✅ 기준 |
|------|---------|---------|
| Atlassian MCP | `jq '.mcpServers["mcp-atlassian"] // empty' ~/.claude.json` | 비어있지 않음 |
| SSH 키 | `ls ~/.ssh/*.pub` | 1개 이상 존재 |
| gh CLI | `gh auth status` | `Logged in` 포함 |
| CLAUDE.md | `ls ~/.claude/CLAUDE.md` | 파일 존재 |
| rules/ | `ls ~/.claude/rules/*.md \| wc -l` | 8개 이상 |
| AWS CLI | `aws sts get-caller-identity` | exit code 0 |
| Slack MCP | `jq '.mcpServers.slack // empty' ~/.claude.json` | 비어있지 않음 |

- ✅ → 해당 체크리스트 단계 건너뛰기
- ❌ → 해당 단계 번호와 함께 안내
- 전부 ✅ → "온보딩 완료 상태입니다" 출력 후 종료

## 체크리스트

### A. Atlassian (Jira + Confluence) MCP — 필수
- [ ] `uvx` 설치 확인 (없으면 `brew install uv` 또는 `pip install uv`)
- [ ] API 토큰 발급 (https://id.atlassian.com/manage-profile/security/api-tokens)
- [ ] 리포 `settings-example.json` 에 `JIRA_USERNAME`, `JIRA_API_TOKEN`, `CONFLUENCE_USERNAME`, `CONFLUENCE_API_TOKEN` 입력 (사용자 직접)
- [ ] 기존 `~/.claude.json` 백업 (`cp … .bak-$(date +%Y%m%d-%H%M%S)`)
- [ ] `jq` 로 `mcpServers.mcp-atlassian` 키만 병합 — `hooks`, `statusLine`, `enabledPlugins` 등 기존 키 보존
- [ ] `git checkout settings-example.json` 으로 리포 파일 플레이스홀더 복원 (실수 커밋 방지)
- [ ] Claude Code 재시작 후 `mcp-atlassian` 도구 노출 확인

### B. GitHub 인증 — 필수
- [ ] SSH 키 존재 확인 (`ls ~/.ssh/*.pub`)
  - 기존 키 있음 (`id_ed25519.pub`, `id_rsa.pub` 등) → **재사용**, C 단계로
  - 없으면 `ssh-keygen -t ed25519 -C "$(whoami)@madup-dct" -f ~/.ssh/id_ed25519` (기본 이름 권장, `_dct` 접미사 강제 아님)
- [ ] 공개키를 GitHub 계정 → Settings → SSH and GPG keys 에 등록
- [ ] `gh` CLI 인증 상태 확인 (`gh auth status`)
  - 이미 로그인돼 있으면 건너뛰기
  - 아니면 `gh auth login` → `GitHub.com` → `SSH` → 브라우저 인증
  - 완료 후 `Git operations protocol: ssh` 확인

### C. 팀 기본 설정 배포 (조건부)
기존 파일 존재 시 **건너뛴다**. OMC 등 다른 환경을 이미 설정한 사용자를 보호.
- [ ] `~/.claude/CLAUDE.md` 없음 → 플러그인 `core/CLAUDE.md` 복사
- [ ] `~/.claude/CLAUDE.md` 있음 → **스킵**, 사용자에게 "수동 병합 참고" 안내
- [ ] `~/.claude/rules/` 없음 → `rules/*.md` 8개 복사
- [ ] `~/.claude/rules/` 있음 → 파일 단위 검사, **없는 파일만** 추가 복사 (기존 덮어쓰기 금지)

### D. Slack MCP (선택)
개인 DM, 채널 조회, 메시지 전송이 필요한 경우만.
- [ ] `korotovsky/slack-mcp-server` 사용 (브라우저 xoxc/xoxd 토큰 기반)
- [ ] `madupteam.slack.com` 브라우저 로그인 후 개발자 도구에서 `xoxc-...`, `xoxd-...` 추출
- [ ] `settings-example.json` 의 slack 섹션에 토큰 입력
- [ ] `SLACK_MCP_ADD_MESSAGE_TOOL` 에 전송 허용 채널 ID 화이트리스트 (예: `C01234ABCD,C05678EFGH`) — 기본값 `false` 로 전송 비활성화 권장
- [ ] `jq` 로 `~/.claude.json` 에 병합
- [ ] **주의**: 본인 Slack 세션 기반이라 로그아웃/장기 미접속 시 재발급 필요

### E. AWS CLI (선택)
AWS 리소스 접근이 필요한 경우만. MCP 는 설치하지 않고 CLI 만 설정 (Claude 가 Bash 로 `aws` 직접 호출).
- [ ] AWS CLI 설치 확인 (`aws --version`, 없으면 `brew install awscli`)
- [ ] Access Key + Secret 발급 (IAM Console)
- [ ] `aws configure` — 기본 프로필, 기본 리전 `ap-northeast-2` (서울)
- [ ] `aws sts get-caller-identity` 로 인증 검증
- [ ] 한 번 설정하면 모든 AWS SDK/CLI/Claude Bash 호출에서 공유됨

### F. 최종 검증
- [ ] `jq '.mcpServers | keys' ~/.claude/settings.json` 로 MCP 목록 확인 (값은 출력 금지)
- [ ] `gh auth status` 로 GitHub 인증 확인
- [ ] `~/.claude/CLAUDE.md` 와 `~/.claude/rules/` 존재 확인
- [ ] `/dct-plan DCTC-TEST` 같은 명령으로 스모크 테스트 (실제 카드가 없어도 MCP 호출 흐름 확인 가능)

## 보안 원칙

- **API 토큰/키는 절대 대화·로그·커밋에 노출 금지**
- **사용자가 직접 파일에 입력** — Claude 가 토큰 값을 받아서 쓰지 않는다
- **`~/.claude.json` 을 `Read` 도구로 전체 출력 금지** — 토큰이 세션 로그에 남는다. 검증은 `jq '.mcpServers | keys'` 또는 `grep -c` 로만
- **백업 경로를 사용자에게 명확히 알림** — 복원 원라이너 예시도 함께 (`cp ~/.claude/settings.json.bak-<ts> ~/.claude/settings.json`)
- **`settings-example.json` 커밋 방지** — 토큰 채운 후 반드시 `git checkout settings-example.json`

## 실패 시 대응

- **MCP 연결 실패** → `jq . ~/.claude/settings.json` 으로 JSON 문법 검증, `uvx` 설치 여부, 토큰 유효성 확인
- **`gh` 인증 실패** → `gh auth logout && gh auth login`, SSH 키 등록 상태 확인
- **SSH 인증 실패** → `~/.ssh/config` 권한(600), `ssh -T git@github.com` 테스트
- **Slack MCP 연결 실패** → 토큰 만료 가능성, 브라우저에서 로그인 상태 확인 후 토큰 재추출
- **AWS CLI 실패** → `~/.aws/credentials`, `~/.aws/config` 직접 확인 (`cat` 하지 말고 `aws configure list` 사용해서 값 노출 최소화)

## 복구 원라이너

```bash
# settings.json 백업에서 복구
cp ~/.claude/settings.json.bak-<timestamp> ~/.claude/settings.json

# CLAUDE.md 백업에서 복구
cp ~/.claude/CLAUDE.md.bak-<timestamp> ~/.claude/CLAUDE.md
```

사용자가 문제 발생 시 즉시 복원할 수 있도록 백업 생성 시점에 정확한 경로를 알린다.
