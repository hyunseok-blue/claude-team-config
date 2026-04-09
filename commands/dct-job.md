---
name: dct-job
description: Jira DCTC 카드 기반 작업을 완전 자동화 — 플랜→구현→검증→PR까지 논스톱 실행
argument-hint: <DCTC-번호> <feat|fix|refactor|chore> "<작업 설명 또는 파일경로>"
---

# /dct-job — 완전 자동화 파이프라인

Jira 카드 작업을 **처음부터 끝까지 자동으로** 수행하는 커맨드. 플랜과 마무리를 수동으로 나누고 싶다면 `/dct-plan` + `/dct-complete` 조합을 사용하라.

## 사용법

```
/dct-job <DCTC-번호> <작업종류> <작업명령|파일경로>
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

## 실행 파이프라인

### Phase A — 플랜 & 진입 (내부적으로 /dct-plan 로직 수행)
1. `mcp__mcp-atlassian__jira_get_issue` — 카드 조회
2. 범위 분석 → `writing-plans` 스킬로 단계 설계
3. 병렬 가능성 분석 및 사용자 제안
4. 플랜 Jira 댓글 업로드 (`jira_add_comment`)
5. `dev` 에서 `feature/DCTC-<번호>` 체크아웃 (있으면 switch)

### Phase B — 구현 (완전 자동화의 핵심)
1. `executing-plans` 스킬로 단계별 실행
2. 멀티파일 변경은 `executor` 에이전트에 위임
3. 각 단계 완료 시 체크포인트 (논블로킹 검증)

### Phase C — 검증
1. `verification-before-completion` 스킬 수행
2. 테스트/빌드/린트 실행
3. 실패 시 수정 루프 (최대 3회, 이후 사용자 개입 요청)

### Phase D — 마무리 (내부적으로 /dct-complete 로직 수행)
1. 작업 결과 요약 생성
2. Jira 카드에 완료 댓글 등록
3. 사용자에게 PR 생성 여부 확인 (y/N)
4. y 인 경우 `gh pr create` 로 PR 생성 + Jira 카드에 PR 링크 댓글

## 중단 지점
다음 시점에서 사용자 확인을 받음:
- 플랜 승인 (Phase A.4 이전)
- 구현 실패 3회 초과 (Phase C)
- PR 생성 여부 (Phase D.3)

## 참조 규칙
- `~/.claude/rules/team-workflow.md` — 브랜치 네이밍, Jira/Confluence 작업 경계
- `~/.claude/rules/korean-dev.md` — 응답/커밋 한국어, 코드는 영어
- `~/.claude/rules/doc-updates.md` — 작업 완료 직전 관련 문서 동기화
- `~/.claude/rules/agents.md` — 멀티파일은 executor 서브에이전트 위임

## 수동 분리 버전
완전 자동화가 아니라 **단계별로 다른 도구를 섞어 쓰고 싶다면**:

1. `/dct-plan DCTC-1808 "설명"` — 플랜 & 진입
2. (자유) — `/sc:implement`, `/autopilot`, 직접 코딩 등 무엇이든
3. `/dct-complete DCTC-1808` — 마무리 & PR
