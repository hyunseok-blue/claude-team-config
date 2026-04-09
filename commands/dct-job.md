---
name: dct-job
description: Jira DCTC 카드 기반 작업 실행 — 브랜치 생성, 플랜 작성, 구현, Jira 댓글 정리까지 자동화
---

# /dct-job — Jira 기반 작업 실행

## 사용법

```
/dct-job <스토리번호> <작업종류> <작업명령|파일경로>
```

**예시**
- `/dct-job DCTC-1808 feat "프론트 사이드바 애니메이션 개선"`
- `/dct-job DCTC-1234 fix ./docs/job.md`
- `/dct-job DCTC-1500 refactor "auth 미들웨어 정리"`

## 인자

| 인자 | 설명 | 예시 |
|------|------|------|
| 스토리번호 | Jira 카드 번호 | `DCTC-1808` |
| 작업종류 | 커밋/브랜치 타입 | `feat`, `fix`, `refactor`, `chore`, `docs`, `test` |
| 작업명령 | 작업 설명 문자열 또는 명세 파일 경로 | `"사이드바 개선"` 또는 `./docs/job.md` |

## 실행 단계

`dct-jira-workflow` 스킬을 참조하여 아래 순서로 진행:

### 1. Jira 카드 조회
- `mcp__mcp-atlassian__jira_get_issue` 로 카드 요약/설명/현재 상태 조회
- 카드 없으면 중단하고 사용자에게 알림

### 2. 브랜치 준비
- 부모 브랜치는 `dev` (또는 리포 기본 브랜치 자동 감지)
- 브랜치명: `feature/<스토리번호>` (예: `feature/DCTC-1808`)
- 이미 있으면 `git switch`, 없으면 `git switch -c feature/<스토리번호> dev`

### 3. 작업 범위 분석
- 작업명령을 읽고 범위 판단:
  - **넓음** → `writing-plans` 스킬로 플랜모드 진입, 단계별 설계
  - **좁음** → 바로 구현 단계로 이동
- 병렬 처리 가능 여부 판단 후 사용자에게 제안 (예: 독립적인 파일 수정이 3개 이상이면 병렬 추천)

### 4. 플랜 업로드
- 플랜이 작성되면 Jira 카드에 **댓글** 또는 **description 업데이트** 로 기록
- 도구: `mcp__mcp-atlassian__jira_add_comment` (기본) 또는 `jira_update_issue`
- 사용자 승인 후 구현 착수

### 5. 구현 실행
- `executing-plans` 스킬로 단계별 진행
- 코드 변경은 `executor` 서브에이전트에 위임 (멀티파일일 경우)
- 작업 컨텍스트 메모리 기록 시 이름에 스토리 번호 포함 (예: `DCTC-1808-sidebar-animation`)

### 6. 검증
- `verification-before-completion` 스킬로 완료 전 증거 수집
- 테스트 실행, 빌드 확인, 관련 스모크 테스트

### 7. Jira 댓글 정리
- 작업 완료 후 Jira 카드에 **전체 작업 내용 요약 댓글** 작성
- 제3자가 봐도 이해할 수 있게 **간결·명확**하게 (team-workflow 규칙 준수)
- 포함 항목:
  - 변경 요약 (무엇을 왜 바꿨는지)
  - 수정된 주요 파일
  - 테스트/검증 결과
  - 후속 작업 필요 여부

### 8. PR 생성 (사용자 요청 시)
- `gh pr create` 로 PR 생성, 제목에 `[DCTC-XXXX]` 포함
- PR 본문에 Jira 카드 링크 자동 삽입

## 참조 규칙
- `~/.claude/rules/team-workflow.md` — 브랜치 네이밍, Jira/Confluence 작업 경계
- `~/.claude/rules/korean-dev.md` — 커밋 메시지 영문, 응답 한글
- `~/.claude/rules/doc-updates.md` — 작업 완료 직전 관련 문서 동기화
