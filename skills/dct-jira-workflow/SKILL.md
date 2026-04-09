---
name: dct-jira-workflow
description: Jira DCTC 카드 기반 작업 실행 스킬. 카드 조회→브랜치 생성→플랜 업로드→구현→댓글 정리까지의 전체 워크플로우를 관리한다.
---

# DCT Jira 워크플로우 스킬

`/dct-job` 커맨드의 백엔드. Jira 카드 단위로 작업을 시작·완료하고 근거를 Jira에 남긴다.

## 핵심 도구 매핑

| 단계 | MCP 도구 |
|------|---------|
| 카드 조회 | `mcp__mcp-atlassian__jira_get_issue` |
| 전이 조회 | `mcp__mcp-atlassian__jira_get_transitions` |
| 상태 변경 | `mcp__mcp-atlassian__jira_transition_issue` |
| 댓글 추가 | `mcp__mcp-atlassian__jira_add_comment` |
| 카드 업데이트 | `mcp__mcp-atlassian__jira_update_issue` |

## 표준 실행 흐름

### Phase 1 — 진입
1. 인자 파싱: `<스토리번호> <타입> <명령|경로>`
2. 카드 조회 → 요약/설명/현재 상태 파악
3. 작업명령이 파일 경로면 `Read` 로 내용 로드

### Phase 2 — 브랜치
1. 부모 브랜치 결정 (`dev` 우선, 없으면 기본 브랜치)
2. `git fetch origin` 후 최신 상태 확인
3. `feature/<스토리번호>` 브랜치 체크아웃 또는 생성
4. 이미 변경사항이 있는지 `git status` 로 확인

### Phase 3 — 플랜
- 작업 범위가 넓으면 `writing-plans` 스킬 호출
- 병렬 가능한 독립 작업이 있으면 사용자에게 제안
- 플랜 확정 시 Jira 댓글로 업로드:
  ```
  📋 작업 플랜 (by Claude Code)

  ## 목표
  ...

  ## 단계
  1. ...
  2. ...

  ## 예상 영향 파일
  - ...
  ```

### Phase 4 — 구현
- `executing-plans` 스킬로 단계별 실행
- 멀티파일 변경은 `executor` 에이전트 위임
- 메모리 엔트리 이름에 스토리 번호 포함

### Phase 5 — 검증
- `verification-before-completion` 스킬 필수
- 테스트/빌드/린트 실행
- 실패 시 수정 반복

### Phase 6 — 마무리
- Jira 카드에 **완료 요약 댓글** 작성 (team-workflow 규칙):
  ```
  ✅ 작업 완료 요약

  ## 변경사항
  - ...

  ## 수정 파일
  - path/to/file.ts
  - ...

  ## 검증
  - 테스트: ...
  - 빌드: ...

  ## 후속 작업
  - ...
  ```
- 사용자가 PR 생성 요청하면 `gh pr create` 실행

## 규칙 준수
- **브랜치 네이밍**: `feature/DCTC-<번호>` 고정
- **커밋 메시지**: 영문 컨벤셔널 커밋 (`feat:`, `fix:`, 등)
- **Confluence**: Data Consulting Team 스페이스의 DCT CP / Matrix 문서만 수정 허용
- **삭제 금지**: Jira 이슈, Confluence 페이지 삭제 절대 금지
