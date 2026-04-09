# Performance & Model Selection

## 모델 선택 기준
- **Opus만 사용** — 모든 작업(구현, 리뷰, 디버깅, 테스트, 문서 조회, 검증 등)에 Opus 사용
- Sonnet, Haiku 사용 금지

## 컨텍스트 창 관리
- MCP는 필요한 것만 활성화 — 미사용 MCP는 비활성화 (컨텍스트 최대 절반 소모 가능)
- 활성 MCP 10개 미만, 활성 도구 80개 미만 유지
- `/compact`로 컨텍스트 압박 시 수동 압축
- 독립적인 작업은 `/fork`로 대화 분기하여 병렬 처리

## 병렬 워크플로우
- 겹치지 않는 작업은 별도 Claude 인스턴스로 분리
- Git worktree로 독립 체크아웃 → 충돌 없는 병렬 작업
  ```bash
  git worktree add ../feature-branch feature-branch
  ```
- 장시간 실행 프로세스(pytest, 서버 등)는 tmux 세션 사용
