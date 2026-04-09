---
name: dct
description: 데이터 컨설팅 팀(DCT) Claude Code 온보딩 — MCP 셋업, SSH 키 생성, 팀 CLAUDE.md/rules 배포 가이드
---

# /dct — DCT 온보딩

데컨팀 신규 팀원이 Claude Code를 처음 셋업할 때 실행. MCP 연결과 팀 기본 설정을 단계별로 안내한다.

## 실행 단계

`dct-onboarding` 스킬을 참조하여 아래 순서로 진행:

### 1. 사용자가 `settings-example.json` 직접 편집
사용자는 리포 루트의 `settings-example.json` 파일을 에디터로 열어 Atlassian 값을 실제 값으로 교체한다. **Claude 는 이 단계에서 대기**.

- 발급처: https://id.atlassian.com/manage-profile/security/api-tokens
- 교체 대상 키: `JIRA_USERNAME`, `JIRA_API_TOKEN`, `CONFLUENCE_USERNAME`, `CONFLUENCE_API_TOKEN`

> **⚠️ 커밋 금지 경고**: `settings-example.json` 은 git 추적 대상이다. 실제 토큰을 채운 뒤 **절대 `git add` / 커밋하지 말 것**. 작업이 끝나면 `git checkout settings-example.json` 으로 플레이스홀더 버전으로 되돌려 둔다. Claude 도 이 파일을 스테이지에 올리지 않는다.

사용자가 "작성 완료" 라고 알리면 다음 단계로.

### 2. `settings-example.json` → `~/.claude/settings.json` 병합 반영
사용자가 채운 `settings-example.json` 의 `mcpServers.mcp-atlassian` 객체를 기존 `~/.claude/settings.json` 에 **병합**한다.

1. 기존 `~/.claude/settings.json` 존재 여부 확인
   - **존재**: `cp ~/.claude/settings.json ~/.claude/settings.json.bak-$(date +%Y%m%d-%H%M%S)` 로 백업. **절대 `Write` 로 통째 덮어쓰지 말 것** (하단 "절대 규칙" 참조)
   - **없음**: 신규 생성 가능
2. `settings-example.json` 에서 플레이스홀더(`YOUR_..._HERE`, `your-email@example.com` 등)가 남아있는지 검증 — 남아있으면 중단하고 사용자에게 재편집 요청
3. **병합 방식으로 반영** (`jq` 사용):
   ```bash
   jq --slurpfile src <(jq '.mcpServers["mcp-atlassian"]' settings-example.json) \
      '.mcpServers["mcp-atlassian"] = $src[0]' \
      ~/.claude/settings.json > ~/.claude/settings.json.tmp \
      && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
   ```
   - `mcp-atlassian` 키만 추가/갱신. `hooks`, `statusLine`, `enabledPlugins` 등 다른 키는 반드시 보존
   - `github` MCP 섹션은 병합하지 않음 (DCT 는 `gh` CLI 사용)
4. 검증: `jq '.mcpServers | keys' ~/.claude/settings.json` 으로 `mcp-atlassian` 키 존재 확인 (값은 출력하지 말 것)
5. **작업 종료 후 반드시 `git checkout settings-example.json`** 으로 리포 파일을 플레이스홀더 버전으로 되돌림 — 실수 커밋 방지

### 3. GitHub SSH 키 생성 및 등록 (조건부)
**기존 SSH 키가 이미 있으면 재사용한다.** 먼저 `ls ~/.ssh/*.pub 2>/dev/null` 로 기존 키 확인.

- **기존 키 있음** (`id_ed25519.pub`, `id_rsa.pub` 등) → 건너뛰고 4단계로. 키 이름에 `dct` 가 붙어있지 않아도 무방
- **기존 키 없음** → 아래 명령으로 새 키 생성:
  ```bash
  ssh-keygen -t ed25519 -C "$(whoami)@madup-dct" -f ~/.ssh/id_ed25519
  ```
  - 파일 이름은 기본 `id_ed25519` 권장 (별도 이름은 필수 아님)
  - 생성 후 `~/.ssh/id_ed25519.pub` 내용을 GitHub 계정 → Settings → SSH and GPG keys 에 등록
- `~/.ssh/config` 는 기본 키를 쓰면 별도 설정 불필요. 여러 계정을 분리해야 하는 경우에만 Host 블록 추가

### 4. `gh` CLI 인증 (`gh auth login`)
GitHub PR 생성 및 이슈 조회는 `gh` CLI 로 수행한다. PAT 수동 발급 없이 OAuth flow로 인증한다.

```bash
gh auth login
```
- `GitHub.com` 선택
- `SSH` 프로토콜 선택 (3단계에서 만든 SSH 키와 연동)
- 브라우저 인증 (one-time code)
- 완료 후 확인:
  ```bash
  gh auth status
  ```
  `Logged in to github.com` 및 `Git operations protocol: ssh` 가 보여야 정상.
- 이미 로그인돼 있으면 이 단계는 건너뛴다.

### 5. 팀 기본 CLAUDE.md / rules 배포 (조건부)
**기존 파일이 이미 있으면 건너뛴다.** 사용자가 OMC 등 다른 환경을 이미 설정해둔 경우 통째 교체는 치명적 손실을 유발하므로 절대 덮어쓰지 않는다 ("절대 규칙" 참조).

분기 로직:
- **`~/.claude/CLAUDE.md` 없음** → 플러그인 `core/CLAUDE.md` 를 그대로 복사
- **`~/.claude/CLAUDE.md` 있음** → **건너뛰기**. 사용자에게 "기존 CLAUDE.md 가 존재하여 배포를 건너뜁니다. 필요하면 플러그인의 `core/CLAUDE.md` 내용을 수동으로 참고해 병합하세요" 안내만 출력
- **`~/.claude/rules/` 디렉터리 없음** → 플러그인 `rules/*.md` 전체 복사
- **`~/.claude/rules/` 존재** → 파일별로 검사, **없는 파일만** 추가 복사. 기존 파일은 **덮어쓰지 않음**

### 6. 최종 점검
- `mcp-atlassian` 연결 확인 (예: `mcp__mcp-atlassian__jira_get_user_profile`)
- `gh auth status` 로 GitHub 인증 확인 (`Git operations protocol: ssh`)
- `~/.claude/CLAUDE.md` 와 `~/.claude/rules/` 존재 확인
- 다음 커맨드 안내: `/dct-job DCTC-1234 feat "작업 설명"`

## 주의사항

### 🚨 절대 규칙 — 기존 파일 통째 교체 금지
**`~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `~/.claude/rules/*` 등 사용자의 기존 설정 파일은 어떤 경우에도 `Write` 도구로 통째 덮어쓰지 않는다.** 기존 파일에는 OMC 훅, 권한, 플러그인 설정, 커스텀 메모리 등 플러그인이 모르는 내용이 들어있을 수 있고, 통째 교체 시 **복구 불가능한 손실**이 발생한다.

**필수 절차**:
1. **항상 먼저 백업**: `cp <file> <file>.bak-$(date +%Y%m%d-%H%M%S)` — 실패해도 복원 가능
2. **기존 구조 파악**: `jq 'keys'` 로 최상위 키만 확인 (값은 출력하지 말 것 — 시크릿 노출 방지)
3. **병합 방식 사용**:
   - `settings.json` → `jq` 로 `mcpServers.mcp-atlassian` 같은 **특정 키만 추가/갱신**
   - `CLAUDE.md` → 통째 교체 시 반드시 사용자에게 **diff 를 보여주고 명시적 승인** 받기
   - `rules/*.md` → 파일 단위로, 기존 동일 파일이 있으면 **덮어쓰기 전 사용자 확인**
4. **통째 덮어쓰기는 기존 파일이 존재하지 않을 때만 허용** (신규 생성)
5. **백업 경로를 사용자에게 명확히 알림** — 문제 발생 시 즉시 복원 가능하도록

이 규칙은 `/dct`, `/dct-job`, `/dct-plan`, `/dct-complete` 모든 커맨드에 공통 적용된다.

### 그 외
- API 토큰은 절대 커밋/로그/채팅에 노출 금지
- Claude 는 `~/.claude/settings.json` 전체를 `Read` 로 출력하지 않는다 (시크릿이 세션 로그에 남음). 검증은 `jq` 또는 `grep` 으로 키/패턴만 확인
- 덮어쓰기는 반드시 사용자 확인 후 진행
