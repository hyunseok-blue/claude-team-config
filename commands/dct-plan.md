---
name: dct-plan
description: Jira DCTC 카드 기반 작업 진입 — 플랜 작성, Jira 업로드, feature 브랜치 체크아웃까지 수행 (구현은 유저 자유)
---

# /dct-plan — 플랜 작성 & 진입

Jira 카드 기반 작업을 **시작**하는 커맨드. 플랜 작성과 브랜치 진입까지만 수행하고, 이후 구현은 사용자가 자유롭게 진행한다(다른 플러그인/도구 조합 가능).

## 사용법

```
/dct-plan <DCTC-번호> [설명|파일경로]
```

**예시**
- `/dct-plan DCTC-1808 "프론트 사이드바 애니메이션 개선"`
- `/dct-plan DCTC-1234 ./docs/job.md`
- `/dct-plan DCTC-1500` (설명 생략 시 Jira 카드 내용만 사용)

## 실행 순서

`dct-jira-workflow` 스킬의 Phase 1~3 만 수행:

### 1. 카드 조회
- `mcp__mcp-atlassian__jira_get_issue` 로 카드 요약/설명/현재 상태 조회
- 작업명령이 파일 경로면 `Read` 로 내용 추가 로드

### 2. 범위 분석
- 카드 내용 + 작업명령을 읽고 범위 판단
- 범위가 넓으면 `writing-plans` 스킬로 세부 단계 작성
- 병렬 가능한 독립 작업이 3개 이상이면 사용자에게 제안

### 3. 플랜 작성
- 목표, 단계(step-by-step), 예상 영향 파일, 검증 방법 포함
- 사용자에게 **플랜 미리보기** 제시 → 승인 받기

### 4. Jira 업로드
- 승인된 플랜을 Jira 카드에 **댓글**로 업로드
- 도구: `mcp__mcp-atlassian__jira_add_comment`
- 댓글 포맷:
  ```
  📋 작업 플랜 (by Claude Code)

  ## 목표
  ...

  ## 단계
  1. ...
  2. ...

  ## 예상 영향 파일
  - ...

  ## 검증
  - ...
  ```

### 5. 브랜치 진입
- 부모 브랜치 결정 (`dev` 우선, 없으면 기본 브랜치)
- `git fetch origin` 으로 최신화
- `feature/DCTC-<번호>` 브랜치:
  - **존재하면** → `git switch feature/DCTC-<번호>` (그대로 체크아웃)
  - **없으면** → `git switch -c feature/DCTC-<번호> dev`
- 메모리 엔트리 이름에 스토리 번호 포함 (예: `DCTC-1808-plan`)

### 6. 종료 메시지
- 플랜 Jira 댓글 링크
- 현재 브랜치 확인
- 다음 액션 안내:
  ```
  ✅ 플랜 업로드 완료 & feature/DCTC-1808 진입

  이제 자유롭게 구현하세요. 다음 도구들을 사용할 수 있습니다:
  - /sc:implement, /autopilot, /ultrawork 등 다른 플러그인
  - 직접 코딩
  - 또는 /dct-job 으로 완전 자동화

  작업이 끝나면 /dct-complete DCTC-1808 로 마무리하세요.
  ```

## 규칙 준수
- **브랜치 네이밍**: `feature/DCTC-<번호>` 고정 (team-workflow 규칙)
- **Jira 댓글**: 한국어, 간결·명확 (team-workflow 규칙)
- **구현은 수행하지 않음**: 이 커맨드는 플랜과 진입까지만
