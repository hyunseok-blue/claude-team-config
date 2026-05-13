#!/usr/bin/env bash
# MADUP_CLAUDE setup — skpark@madup.com 개인 풀 셋팅을 ~/.claude/ 에 설치
#
# 사용법:
#   ./setup-madup.sh              # 실 설치
#   ./setup-madup.sh --dry-run    # 미리보기
#   ./setup-madup.sh --force      # 백업 없이 덮어쓰기
#
# 기존 ~/.claude/{CLAUDE,RTK,SYSTEM,COMMANDS,PERSONAS}.md 는
# 자동으로 ~/.claude/backups/madup-claude-YYYYMMDD_HHMMSS/ 에 백업됨.
#
# settings.json 은 의도적으로 자동 설치하지 않음 (시크릿 보호).
# 자동 동기화 훅을 켜려면 templates/settings.snippet.json 을 참조해
# 본인 settings.json 의 hooks.PostToolUse 에 머지.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
BACKUP_DIR="$CLAUDE_DIR/backups/madup-claude-$(date +%Y%m%d_%H%M%S)"

DRY=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRY=true; shift ;;
    --force|-f)   FORCE=true; shift ;;
    -h|--help)
      sed -n '1,18p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

run() {
  echo "  \$ $*"
  $DRY || "$@"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  MADUP_CLAUDE installer"
echo "  target: $CLAUDE_DIR"
$DRY  && echo "  mode:   DRY RUN"
$FORCE && echo "  mode:   FORCE (no backup of conflicts)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# [1] 디렉토리 준비
run mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/hooks"

# [2] 백업 (FORCE 가 아닌 경우)
if ! $FORCE; then
  NEED_BACKUP=false
  for f in CLAUDE.md RTK.md SYSTEM.md COMMANDS.md PERSONAS.md; do
    [[ -f "$CLAUDE_DIR/$f" ]] && NEED_BACKUP=true
  done
  if $NEED_BACKUP; then
    echo "[backup] 기존 MD → $BACKUP_DIR"
    run mkdir -p "$BACKUP_DIR"
    for f in CLAUDE.md RTK.md SYSTEM.md COMMANDS.md PERSONAS.md; do
      [[ -f "$CLAUDE_DIR/$f" ]] && run cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/"
    done
  fi
fi

# [3] 핵심 MD 5종 설치
echo "[install] core MD → $CLAUDE_DIR/"
for f in CLAUDE.md RTK.md SYSTEM.md COMMANDS.md PERSONAS.md; do
  run cp "$SCRIPT_DIR/claude/$f" "$CLAUDE_DIR/$f"
done

# [4] agents/*.md
echo "[install] agents → $CLAUDE_DIR/agents/"
for f in "$SCRIPT_DIR"/agents/*.md; do
  run cp "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

# [5] commands
echo "[install] commands → $CLAUDE_DIR/commands/"
for f in "$SCRIPT_DIR"/commands/*.md; do
  run cp "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
done

# [6] hooks (실행 권한 부여)
echo "[install] hooks → $CLAUDE_DIR/hooks/"
for f in "$SCRIPT_DIR"/hooks/*.sh; do
  dest="$CLAUDE_DIR/hooks/$(basename "$f")"
  run cp "$f" "$dest"
  run chmod +x "$dest"
done
# .rtk-hook.sha256 (있을 때만)
if [[ -f "$SCRIPT_DIR/hooks/.rtk-hook.sha256" ]]; then
  run cp "$SCRIPT_DIR/hooks/.rtk-hook.sha256" "$CLAUDE_DIR/hooks/.rtk-hook.sha256"
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if $DRY; then
  echo "  ✅ DRY RUN 완료 — 실제 설치하려면 --dry-run 없이 다시 실행"
else
  echo "  ✅ 설치 완료"
  echo
  echo "  다음 단계 (선택):"
  echo "  1. Claude Code 재시작"
  echo "  2. 자동 동기화 훅을 켜려면:"
  echo "     templates/settings.snippet.json 의 PostToolUse 블록을"
  echo "     ~/.claude/settings.json 의 hooks.PostToolUse 배열에 추가"
  echo "  3. 자동 동기화는 MADUP_CLAUDE_REPO 환경변수가 설정된 곳을 대상으로 함"
  echo "     기본값: \$HOME/Documents/git/madup/claude-team-config"
  [[ -d "$BACKUP_DIR" ]] && echo "  4. 백업: $BACKUP_DIR"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
