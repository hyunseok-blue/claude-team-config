---
name: dct-rtk
description: RTK(Rust Token Killer) 설치 및 Claude Code 통합 — Bash 출력을 자동 압축해 토큰 소비 60~90% 절감
---

# /dct-rtk — RTK 설치 및 Claude Code 연동

Claude Code 세션에서 Bash 명령 출력을 자동으로 필터링·압축해 **토큰 소비를 60~90% 줄여주는** CLI 프록시 [RTK](https://github.com/rtk-ai/rtk) 를 설치하고 Claude Code hook 으로 연동한다.

## 동작 원리

RTK 는 MCP 서버가 아닌 **CLI 프록시**. Claude Code 의 `PreToolUse` hook 을 통해 `git status` → `rtk git status` 처럼 투명하게 명령을 rewrite 하고, 출력에서 노이즈(주석, 공백, 보일러플레이트)를 제거한 뒤 LLM 에 전달한다.

- 100+ 명령 지원 (git, npm, docker, kubectl, aws, cargo, pip 등)
- 오버헤드 < 10ms (Rust 단일 바이너리)
- 30분 세션 기준 ~118K 토큰 → ~24K 토큰 (약 80% 절감)

## 실행 단계

### 0. 환경 진단 (자동)

```bash
# RTK 설치 여부
which rtk 2>/dev/null && rtk --version

# Claude Code hook 등록 여부
cat ~/.claude/settings.json 2>/dev/null | jq '.hooks.PreToolUse // empty' 2>/dev/null | grep -q 'rtk' && echo "RTK hook registered" || echo "RTK hook not registered"
```

- RTK 설치됨 + hook 등록됨 → **"RTK 이미 설정 완료입니다"** 출력 후 종료
- RTK 설치됨 + hook 미등록 → 2단계(hook 설정)부터 진행
- RTK 미설치 → 1단계부터 진행

### 1. RTK 설치

Homebrew 사용 (macOS 권장):

```bash
brew install rtk
```

Homebrew 가 없거나 Linux 인 경우:

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

설치 확인:

```bash
rtk --version
```

### 2. Claude Code hook 등록

RTK 의 내장 초기화로 Claude Code PreToolUse hook 을 자동 등록한다:

```bash
rtk init -g
```

- `-g` : 글로벌 설정 (`~/.claude/settings.json`) 에 hook 등록
- 기존 hook 이 있으면 RTK hook 을 **추가** (기존 hook 덮어쓰지 않음)

등록 결과 확인:

```bash
rtk init --show
```

### 3. 검증

```bash
# hook 등록 확인 (값 전체 출력 금지 — 키 존재만 확인)
jq '.hooks.PreToolUse | length' ~/.claude/settings.json

# RTK 필터링 동작 테스트
rtk git status
```

정상이면 Claude Code **재시작** 안내. 재시작 후 Bash 도구의 `git status`, `ls`, `docker ps` 등이 자동으로 RTK 를 거쳐 압축된 출력이 전달된다.

### 4. (선택) Telemetry 비활성화

RTK 는 기본적으로 익명 사용 통계를 수집한다. 비활성화하려면:

```bash
export RTK_TELEMETRY_DISABLED=1
```

영구 적용 시 셸 프로필(`~/.zshrc` 등)에 추가.

## 제거

```bash
rtk init -g --uninstall
brew uninstall rtk
```

## 참고

- RTK 는 Claude Code 내장 도구(`Read`, `Grep`, `Glob`)에는 영향 없음 — Bash 도구로 실행되는 셸 명령에만 적용
- 설정 파일: `~/.config/rtk/config.toml` (macOS: `~/Library/Application Support/rtk/config.toml`)
- 명령 실패 시 원본 전체 출력을 자동 저장 (tee 기능)
- 리포: https://github.com/rtk-ai/rtk
