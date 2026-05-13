# MADUP_CLAUDE

> skpark@madup.com 의 Claude Code 풀 셋팅 (OMC + RTK + 페르소나 + AWS 분석 에이전트 + HQ 주간 보고 등)
>
> 누구나 `clone → ./setup-madup.sh` 한 줄로 본인 `~/.claude/` 에 동일한 환경을 만들 수 있고,
> 셋팅 변경 시 PostToolUse 훅이 자동으로 이 레포에 커밋·푸시합니다.

이 디렉토리는 같은 레포의 [SuperClaude Lite](../README.md) 와 **별도 트랙**입니다.
Lite 는 팀 공용 최소 베이스라인이고, MADUP_CLAUDE 는 개인 풀 셋입니다. 둘은 충돌하지 않으니 둘 다 설치해도 됩니다.

---

## 빠른 시작

설치 스크립트는 **순수 Bash** 입니다 (macOS BSD 문법 `stat -f`, `sed -i ''` 사용).
Windows 에서는 **WSL2** 또는 **Git Bash** 를 통해 실행하세요. 네이티브 PowerShell 은 지원하지 않습니다.

### 🍎 macOS

```bash
# 1) 사전 도구 (없으면 설치)
brew install git gh
npm i -g @anthropic-ai/claude-code        # Claude Code CLI

# 2) 클론 + 설치
git clone https://github.com/hyunseokjeong-madup/claude-team-config.git ~/claude-team-config
cd ~/claude-team-config/madup
./setup-madup.sh --dry-run                # 미리보기 (변경 없음)
./setup-madup.sh                          # 실제 설치

# 3) Claude Code 재시작
```

기존 `~/.claude/{CLAUDE,RTK,SYSTEM,COMMANDS,PERSONAS}.md` 는
`~/.claude/backups/madup-claude-YYYYMMDD_HHMMSS/` 에 자동 백업됩니다.

### 🪟 Windows (WSL2 권장)

> Claude Code 가 **WSL 안에서 돌아가는 경우** 이 가이드를 그대로 따르면 `~/.claude` (= WSL 홈) 에 설치됩니다.

```bash
# PowerShell 에서 WSL2 진입 (Ubuntu 기준)
wsl

# 이후는 WSL/Ubuntu 셸 안에서
sudo apt update && sudo apt install -y git curl
# gh CLI 설치 (https://cli.github.com/manual/installation 참조)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install -y gh

# Node + Claude Code
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
npm i -g @anthropic-ai/claude-code

# 클론 + 설치
git clone https://github.com/hyunseokjeong-madup/claude-team-config.git ~/claude-team-config
cd ~/claude-team-config/madup
chmod +x setup-madup.sh hooks/*.sh
./setup-madup.sh --dry-run
./setup-madup.sh
```

#### Windows 네이티브 Claude Code 를 쓰는 경우 (`%USERPROFILE%\.claude`)

WSL 셸 안에서 Windows 측 `.claude` 디렉토리를 지정해 설치:

```bash
# WSL 안에서, Windows 사용자명을 <YOUR_WIN_USER> 로 치환
export CLAUDE_DIR="/mnt/c/Users/<YOUR_WIN_USER>/.claude"
./setup-madup.sh --dry-run
./setup-madup.sh
```

#### Git Bash (WSL 없이) 옵션

WSL 을 못 쓰는 환경이면 **Git for Windows** 의 Git Bash 에서 실행 가능합니다.

```bash
# Git Bash 에서
cd /c/Users/<YOUR_WIN_USER>
git clone https://github.com/hyunseokjeong-madup/claude-team-config.git
cd claude-team-config/madup
chmod +x setup-madup.sh hooks/*.sh
./setup-madup.sh
```

> ⚠️ Git Bash 에서는 `stat -f` (BSD) 가 작동하지 않을 수 있어 디바운스 락이 일부 환경에서 정확히 안 잡힐 수 있습니다. 일반 설치는 정상 작동.

### 🐧 Linux (Ubuntu/Debian)

```bash
sudo apt update && sudo apt install -y git curl
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install -y gh nodejs npm
sudo npm i -g @anthropic-ai/claude-code

git clone https://github.com/hyunseokjeong-madup/claude-team-config.git ~/claude-team-config
cd ~/claude-team-config/madup
./setup-madup.sh
```

> ⚠️ 훅 스크립트 안의 `stat -f %m` (BSD) 는 Linux 에서 자동으로 `stat -c %Y` 로 폴백합니다 — 코드에 두 가지 모두 들어 있어 그대로 작동합니다.

---

## 설치 확인

설치 후 다음 명령으로 적용 상태를 점검할 수 있습니다.

```bash
# 1) 5개 핵심 MD 가 설치됐는지
ls -1 "$HOME/.claude"/{CLAUDE,RTK,SYSTEM,COMMANDS,PERSONAS}.md

# 2) 11개 에이전트
ls -1 "$HOME/.claude/agents/" | grep -c '\.md$'    # → 11 또는 그 이상

# 3) hq-weekly 명령어
ls -1 "$HOME/.claude/commands/hq-weekly.md"

# 4) 훅 실행 권한
ls -la "$HOME/.claude/hooks/"{rtk-rewrite.sh,auto-sync-md.sh} 2>/dev/null

# 5) Claude Code 가 인식하는지 — 재시작 후
claude --help | head -5
```

---

## 들어있는 것

| 영역 | 파일 수 | 내용 |
|---|---|---|
| `claude/` | 5 | `CLAUDE.md` (메인 정책 9.8KB) · `RTK.md` (토큰 절감 프록시) · `SYSTEM.md` · `COMMANDS.md` · `PERSONAS.md` (11종) |
| `agents/` | 11 | AWS 비용 분석 5종 · 강의 자료 4종 · 코딩 커리큘럼 · iterative-task-evaluator · social-media-code-visualizer |
| `commands/` | 1 | `hq-weekly` (DCT 주간 보고 자동화) |
| `hooks/` | 2 | `rtk-rewrite.sh` (RTK 토큰 절감) · `auto-sync-md.sh` (자동 동기화) |
| `templates/` | 1 | `settings.snippet.json` (PostToolUse 훅 머지용) |

### 핵심 정책 (CLAUDE.md 요약)

- **OMC 멀티 에이전트 위임** — haiku/sonnet/opus 비용 기반 라우팅. opus 는 아키텍처 결정에만.
- **병렬 실행 기본 OFF** — "삼중", "ultrawork", "병렬로" 명시 시에만 ON. (개인 비용 데이터 기반 override)
- **디자인 작업 자동 트리거** — 16개 키워드 감지 시 `awesome-design-md` 메모리 로드.
- **이미지 생성은 Codex `image_gen` 빌트인 강제** — SVG/HTML placeholder 금지.
- **Token Efficiency** — context >75% 에서 `--uc` 자동, >150k 에서 `/compact` 권장.

---

## 들어있지 **않은** 것 (의도적 제외)

| 제외 항목 | 이유 |
|---|---|
| `settings.json` / `settings.local.json` | Figma key, PG 비번, AWS zone id 등 시크릿이 평문 포함 → 통째로 안 올림 |
| `sessions/` · `projects/` · `paste-cache/` · `*.jsonl` | 로컬 세션 데이터, 민감 가능성 |
| `plugins/` · `skills/` (심볼릭 링크) | OMC 플러그인 소유물, 별도 설치 경로 |
| `agents/sc/` 서브디렉토리 | OMC 플러그인이 자동 주입 |

`settings.json` 의 훅 설정만 필요하면 `templates/settings.snippet.json` 참조.

---

## 자동 동기화 훅 (선택 — 이걸 켜야 셋팅 변경이 자동 푸시됨)

`templates/settings.snippet.json` 의 `PostToolUse` 블록을 본인 `~/.claude/settings.json` 의 `hooks.PostToolUse` 배열에 머지하세요.

### 동작
1. Edit/Write/MultiEdit 후 추적 대상 MD/스크립트가 변경되면 트리거.
2. **디바운스 60초** — 연속 수정은 한 번에 묶임.
3. **화이트리스트 rsync** — `claude/*.md`, `agents/*.md`, `commands/hq-weekly.md`, `hooks/rtk-rewrite.sh` 만 미러.
4. **시크릿 자동 스크럽** — `hq-weekly.md` 의 비번/절대경로는 매번 플레이스홀더로 치환.
5. **시크릿 정규식 검사** — `figd_`/`gho_`/`ghp_`/`sk-`/`PGPASSWORD=`/`madup!dataconsulting` 매치 시 푸시 중단.
6. **변경 있으면 자동 commit + 비동기 push** — 작성자: `madup-claude-bot`.

### 일시 비활성화

**macOS / Linux / WSL:**
```bash
export MADUP_CLAUDE_REPO=     # 빈 값 — 훅이 조용히 종료
```

**Windows PowerShell** (Claude Code 가 네이티브로 도는 경우):
```powershell
[Environment]::SetEnvironmentVariable("MADUP_CLAUDE_REPO", "", "User")
```

### 레포 위치 변경

**macOS / Linux / WSL** (`~/.zshrc` 또는 `~/.bashrc` 에 추가):
```bash
export MADUP_CLAUDE_REPO=$HOME/code/claude-config
```

**Windows PowerShell** (영구):
```powershell
[Environment]::SetEnvironmentVariable("MADUP_CLAUDE_REPO", "C:\code\claude-config", "User")
```

기본값: `$HOME/Documents/git/madup/claude-team-config`
(Windows 네이티브: `%USERPROFILE%\Documents\git\madup\claude-team-config`)

---

## 제거 / 롤백

### 1. 자동 동기화 훅만 끄기 (가벼움)

`~/.claude/settings.json` 의 `hooks.PostToolUse` 배열에서 `auto-sync-md.sh` 항목 제거:

```json
"PostToolUse": [
  // 이 블록 통째로 삭제
  {
    "matcher": "Edit|Write|MultiEdit",
    "hooks": [
      { "type": "command", "command": "$HOME/.claude/hooks/auto-sync-md.sh" }
    ]
  }
]
```

또는 임시로 환경변수 한 줄:

```bash
# macOS/Linux/WSL
export MADUP_CLAUDE_REPO=

# Windows PowerShell
[Environment]::SetEnvironmentVariable("MADUP_CLAUDE_REPO", "", "User")
```

### 2. 셋팅 전체 롤백 (백업에서 복원)

설치 시 자동 생성된 백업 디렉토리에서 복원합니다.

**macOS / Linux / WSL:**
```bash
# 가장 최근 백업 찾기
ls -td ~/.claude/backups/madup-claude-*/ | head -1

# 복원
LATEST=$(ls -td ~/.claude/backups/madup-claude-*/ | head -1)
cp "$LATEST"*.md ~/.claude/
```

**Windows PowerShell:**
```powershell
$latest = Get-ChildItem "$env:USERPROFILE\.claude\backups\madup-claude-*" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Copy-Item "$($latest.FullName)\*.md" "$env:USERPROFILE\.claude\"
```

### 3. 훅 스크립트 자체 삭제

```bash
rm ~/.claude/hooks/auto-sync-md.sh
```

---

## 사전 요구사항

| 도구 | 필수 | 용도 | 설치 |
|---|---|---|---|
| `git` | ✅ | 레포 클론 + 자동 push | macOS: `brew install git` · Win: [git-scm.com](https://git-scm.com/) (Git Bash 포함) · Linux: `apt install git` |
| `bash` 4.x+ | ✅ | setup·hook 스크립트 | macOS/Linux 기본 · Windows: WSL2 또는 Git Bash |
| `gh` CLI | ✅ | push 인증 | macOS: `brew install gh` · Win/Linux: [cli.github.com](https://cli.github.com/) |
| Claude Code CLI | ✅ | 본체 | `npm i -g @anthropic-ai/claude-code` (Node 18+) |
| `oh-my-claudecode` (OMC) | 권장 | CLAUDE.md 의 OMC 블록 활용 | `npx oh-my-claudecode setup` |
| Context7 MCP | 권장 | 디자인/라이브러리 문서 자동 참조 | `~/.claude/settings.json` 에 등록 (Lite 가 설정 포함) |
| `rtk` CLI | 선택 | 토큰 절감 프록시 (RTK.md) | [github.com/rtk-ai](https://github.com/rtk-ai) |

### gh 인증

설치 후 한 번만:
```bash
gh auth login
# Protocol: HTTPS, Authenticate: yes
```

자동 동기화가 fork 한 레포에 push 하려면 해당 계정에 push 권한이 있어야 합니다.
계정 전환은 `gh auth switch`.

---

## 트러블슈팅

### 설치 직후 Claude Code 가 안 뜸
→ `~/.claude/settings.json` 이 깨졌을 가능성. `settings.json.bak.YYYYMMDD_HHMMSS` 백업으로 복원:
```bash
cp ~/.claude/settings.json.bak.* ~/.claude/settings.json    # 가장 최근 백업
```

### `./setup-madup.sh: Permission denied`
→ 실행 권한 부여:
```bash
chmod +x setup-madup.sh hooks/*.sh
```

### Windows Git Bash 에서 `bad interpreter: /usr/bin/env`
→ Git Bash 의 line ending 문제. CRLF → LF 로 변환:
```bash
sed -i 's/\r$//' setup-madup.sh hooks/*.sh
```

### 자동 동기화가 안 됨 (커밋이 안 쌓임)
체크리스트:
1. `~/.claude/settings.json` 의 `hooks.PostToolUse` 에 `auto-sync-md.sh` 등록됐는지
2. `~/.claude/hooks/auto-sync-md.sh` 실행 권한 있는지 (`ls -la` 로 확인)
3. 디바운스 락 확인: `ls -la /tmp/madup-claude-sync.lock` — 60초 안에 또 시도하면 스킵됨
4. 직접 실행해 에러 보기:
   ```bash
   bash -x ~/.claude/hooks/auto-sync-md.sh
   ```
5. syslog 로그(macOS):
   ```bash
   log show --predicate 'eventMessage CONTAINS "madup-claude-sync"' --last 10m
   ```

### gh push 가 권한 거부됨
```bash
gh auth status                  # 현재 활성 계정 확인
gh auth switch                  # 다른 계정으로 전환
gh auth refresh -s repo,workflow   # 토큰 권한 추가
```

### `MADUP_CLAUDE_REPO` 가 인식 안 됨
환경변수가 Claude Code 프로세스에 전달되려면 **셸 시작 파일**에 export 해야 합니다:
- macOS zsh: `~/.zshrc`
- Linux/WSL bash: `~/.bashrc`
- Windows: 시스템 환경변수 (재로그인 필요)

설정 후 Claude Code 를 재시작하세요.

---

## 주의

- 이 셋팅은 **skpark 개인 환경 기반**입니다. CLAUDE.md 의 디자인 트리거, 메모리 경로, HQ 보고서 워크플로 등은 그대로 쓰면 본인 환경엔 맞지 않을 수 있습니다.
- 자동 동기화 훅을 켜면 **임시 디버깅 수정도 60초 후 자동 푸시**됩니다. 민감한 실험 중에는 `MADUP_CLAUDE_REPO=` 로 끄세요.
- 자동 푸시는 단방향(로컬→레포). 다른 머신에서는 수동 `git pull && ./setup-madup.sh` 필요.
- Windows 네이티브 PowerShell 스크립트는 **없음** — WSL2 또는 Git Bash 경유 필수.
