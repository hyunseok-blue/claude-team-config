#!/bin/bash
# tool-health-check.sh — SessionStart 훅
# claude / codex / agy(Gemini) 의 설치·버전·인증 상태를 가볍게 점검해 1~3줄로 보고한다.
# 설계 원칙: 빠르고 비차단. 도구가 깨져 있어도 "알리기만" 하고 세션 시작을 막지 않는다(항상 exit 0).
# 네트워크 인증 검증 같은 무거운 작업은 하지 않는다(SessionStart는 매번 돌기 때문).

# 버전 한 줄 추출(없으면 "missing"), 절대 실패하지 않게 || 처리
ver() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    # 첫 줄에서 숫자.숫자[.숫자] 패턴만 뽑음. 못 뽑으면 "ok"
    local v
    v="$("$name" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)"
    echo "${v:-ok}"
  else
    echo "missing"
  fi
}

CLAUDE_V="$(ver claude)"
CODEX_V="$(ver codex)"
AGY_V="$(ver agy)"

# 인증 상태(가벼운 로컬 확인만)
#  - agy: ~/.gemini OAuth 디렉토리 존재 여부
#  - codex: ~/.codex 설정 디렉토리 존재 여부 (실제 토큰 유효성은 검사하지 않음 — 비용 회피)
AGY_AUTH="?"; [ -d "$HOME/.gemini" ] && AGY_AUTH="auth✓" || AGY_AUTH="auth✗"
CODEX_AUTH="?"; [ -d "$HOME/.codex" ] && CODEX_AUTH="cfg✓" || CODEX_AUTH="cfg✗"

# 페르소나 파일 상태(작업1 연계)
PERSONA="?"; [ -f "$HOME/.claude/fable5-persona.md" ] && PERSONA="fable5✓" || PERSONA="fable5✗"

echo "🔧 tools: claude ${CLAUDE_V} | codex ${CODEX_V} ${CODEX_AUTH} | agy ${AGY_V} ${AGY_AUTH} | persona ${PERSONA}"

# missing 항목이 있으면 한 줄 더 경고(자동 설치/업데이트는 하지 않음 — 사용자 정책: 안전 우선)
WARN=""
[ "$CLAUDE_V" = "missing" ] && WARN="${WARN} claude"
[ "$CODEX_V" = "missing" ] && WARN="${WARN} codex"
[ "$AGY_V" = "missing" ] && WARN="${WARN} agy"
[ -n "$WARN" ] && echo "⚠️  미설치/경로없음:${WARN} — 확인 필요 (자동 설치 안 함)"

exit 0
