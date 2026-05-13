#!/usr/bin/env bash
# MADUP_CLAUDE auto-sync hook
#
# PostToolUse 훅: ~/.claude 의 추적 대상 MD/스크립트가 바뀌면
# claude-team-config 레포로 디바운스·시크릿 스캔·자동 커밋·푸시.
#
# 비활성화: export MADUP_CLAUDE_REPO= (빈 값) → 훅이 조용히 종료.
# 디바운스: 마지막 동기화 60초 이내 트리거는 스킵.
# 가드레일: 시크릿 정규식 매치 시 푸시 중단 (로컬은 그대로).

set -uo pipefail

REPO_DIR="${MADUP_CLAUDE_REPO:-$HOME/Documents/git/madup/claude-team-config}"
CLAUDE_DIR="$HOME/.claude"
LOCK="/tmp/madup-claude-sync.lock"
DEBOUNCE_SECONDS=60
LOG_TAG="madup-claude-sync"

# logger 가 있으면 syslog 에도 남김 (없으면 무시)
log() { command -v logger >/dev/null 2>&1 && logger -t "$LOG_TAG" "$*" || true; }

# [1] 환경 가드
[[ -z "$REPO_DIR" ]] && exit 0
[[ -d "$REPO_DIR/.git" ]] || exit 0
[[ -d "$REPO_DIR/madup" ]] || exit 0

# [2] 디바운스
if [[ -f "$LOCK" ]]; then
  last=$(stat -f %m "$LOCK" 2>/dev/null || stat -c %Y "$LOCK" 2>/dev/null || echo 0)
  now=$(date +%s)
  if (( now - last < DEBOUNCE_SECONDS )); then
    exit 0
  fi
fi
touch "$LOCK"

# [3] 화이트리스트 rsync — 추적 대상만 레포로 미러
# 단, ~/.claude/CLAUDE.md 등이 없으면 rsync 가 실패해도 전체는 계속 진행
mkdir -p "$REPO_DIR/madup/claude" "$REPO_DIR/madup/agents" "$REPO_DIR/madup/commands" "$REPO_DIR/madup/hooks"

for f in CLAUDE.md RTK.md SYSTEM.md COMMANDS.md PERSONAS.md; do
  [[ -f "$CLAUDE_DIR/$f" ]] && cp "$CLAUDE_DIR/$f" "$REPO_DIR/madup/claude/$f"
done

if [[ -d "$CLAUDE_DIR/agents" ]]; then
  # *.md 만, 서브디렉토리는 제외
  find "$CLAUDE_DIR/agents" -maxdepth 1 -type f -name '*.md' -exec cp {} "$REPO_DIR/madup/agents/" \;
fi

if [[ -f "$CLAUDE_DIR/commands/hq-weekly.md" ]]; then
  cp "$CLAUDE_DIR/commands/hq-weekly.md" "$REPO_DIR/madup/commands/hq-weekly.md"
fi

# rtk-rewrite.sh 만 미러 (auto-sync-md.sh 는 본인이므로 스킵)
[[ -f "$CLAUDE_DIR/hooks/rtk-rewrite.sh" ]] && cp "$CLAUDE_DIR/hooks/rtk-rewrite.sh" "$REPO_DIR/madup/hooks/rtk-rewrite.sh"
[[ -f "$CLAUDE_DIR/hooks/.rtk-hook.sha256" ]] && cp "$CLAUDE_DIR/hooks/.rtk-hook.sha256" "$REPO_DIR/madup/hooks/.rtk-hook.sha256"

# [4] hq-weekly.md 의 비번/절대경로는 스크럽 (사용자가 로컬에서 비번을 다시 적어넣었을 수 있음)
HQ="$REPO_DIR/madup/commands/hq-weekly.md"
if [[ -f "$HQ" ]]; then
  # macOS BSD sed 호환: -i '' 사용
  sed -i '' -E \
    -e 's|HQ_REPORT_PASSWORD=[^[:space:]`<]+|HQ_REPORT_PASSWORD=<YOUR_REPORT_PASSWORD>|g' \
    -e "s|/Users/[a-zA-Z0-9_-]\+/|<YOUR_GIT_ROOT_BASE>/|g" \
    "$HQ" 2>/dev/null || true
fi

# [5] 시크릿 스캔 — 매치 시 푸시 중단
# 정규식 자체가 false positive 되지 않도록 hooks/auto-sync-md.sh, README 는 스캔 제외
# (스캐너가 자기 자신을 매칭하는 함정 회피)
HQ_BANNED=$(printf '%s!%s' "madup" "dataconsulting")
SECRET_REGEX='(figd_[A-Za-z0-9_]{10,}|gho_[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{30,}|PGPASSWORD=[^[:space:]"]{4,}|'"$HQ_BANNED"')'
SCAN_PATHS=("$REPO_DIR/madup/claude" "$REPO_DIR/madup/agents" "$REPO_DIR/madup/commands")
if grep -rEq "$SECRET_REGEX" "${SCAN_PATHS[@]}" 2>/dev/null; then
  log "Secret pattern detected. Aborting auto-sync."
  echo "[madup-claude-sync] 시크릿 패턴이 추적 파일에서 감지되어 자동 푸시를 중단했습니다." >&2
  exit 1
fi

# [6] git diff 가 없으면 종료
cd "$REPO_DIR" || exit 0
if git diff --quiet madup/ && git diff --cached --quiet madup/; then
  exit 0
fi

# [7] 변경 파일 목록(최대 3개) 으로 커밋 메시지 구성
CHANGED=$(git diff --name-only madup/ | head -3 | tr '\n' ' ' | sed 's/ $//')
TS=$(date '+%F %H:%M')

git add madup/ >/dev/null 2>&1
if git -c user.email="skpark@madup.com" -c user.name="madup-claude-bot" \
      commit -m "chore(madup): auto-sync ${CHANGED:-md changes} ($TS)" >/dev/null 2>&1; then
  log "Committed: ${CHANGED:-md changes}"
  # 비동기 푸시 — 사용자 대화 차단 방지
  ( git push origin HEAD 2>&1 | logger -t "$LOG_TAG" || true ) &
fi

exit 0
