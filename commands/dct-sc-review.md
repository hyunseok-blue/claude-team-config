---
name: dct-sc-review
description: 코드 리뷰 — 품질/보안/성능 체크 + 구체적 수정 제안 + PR 준비 상태 판정
argument-hint: [대상 경로 | --staged | --branch] [--strict]
---

# /dct-sc-review — 코드 리뷰

변경된 코드를 리뷰하고 **구체적 수정 제안**을 제시한다. PR 제출 전 셀프 리뷰 또는 팀원 리뷰 대행 용도.

## 사용법

```
/dct-sc-review [대상] [옵션]
```

**예시**
- `/dct-sc-review --staged` — git staged 파일만 리뷰
- `/dct-sc-review --branch` — 현재 브랜치의 base 대비 전체 diff 리뷰
- `/dct-sc-review src/api/auth.py` — 특정 파일 리뷰
- `/dct-sc-review --branch --strict` — 엄격 모드 (스타일 지적 포함)

## 리뷰 대상 결정

| 옵션 | 동작 |
|------|------|
| `--staged` | `git diff --cached` 로 staged 변경사항만 |
| `--branch` | `git diff $(git merge-base HEAD dev)...HEAD` 로 브랜치 전체 diff |
| `<경로>` | 지정 파일/디렉터리 전체 |
| (없음) | `--branch` 와 동일 |

## 실행 순서

### 1. 변경사항 수집
- 대상에 따라 `git diff` 또는 `Read` 로 코드 로드
- 변경된 파일 목록, 추가/삭제 라인 수 집계

### 2. 리뷰 체크리스트

**필수 체크 (항상)**
- [ ] 로직 정확성 — 의도한 동작과 실제 코드의 일치
- [ ] 엣지 케이스 — None, 빈 값, 경계값 처리
- [ ] 에러 핸들링 — 적절한 예외 처리, 사용자 노출 에러 메시지
- [ ] 보안 — 인젝션, 하드코딩 시크릿, 인증 누락
- [ ] 네이밍 — 변수/함수명이 동작을 정확히 설명하는지

**엄격 모드 추가 (`--strict`)**
- [ ] 코드 스타일 — PEP 8, ESLint 규칙 등 프로젝트 컨벤션
- [ ] 타입 힌트 — 함수 시그니처에 타입 명시 (Python)
- [ ] 불필요한 변경 — 기능과 관계없는 포맷/리팩토링 혼입
- [ ] 테스트 커버리지 — 변경된 코드에 대한 테스트 존재 여부
- [ ] 문서 — 공개 API 변경 시 docstring/주석 업데이트

### 3. 리뷰 리포트

```
## 📝 코드 리뷰 — <브랜치/파일>

### 요약
- 변경 파일: 5개 (+120, -45)
- 리뷰 모드: branch / strict

### 발견 사항

🔴 반드시 수정
- **src/api/auth.py:67** — `password` 를 로그에 평문 출력
  ```python
  # 현재
  logger.info(f"Login attempt: {username}, {password}")
  # 수정
  logger.info(f"Login attempt: {username}")
  ```

🟡 수정 권장
- **src/services/report.py:23** — `except Exception` 은 너무 넓음
  → 구체적 예외 (`ValueError`, `KeyError`) 로 좁히기

💬 의견 (수정 안 해도 됨)
- **src/utils/helper.py:10** — `get_data` 보다 `fetch_user_reports` 가 명확

### PR 준비 상태
🟡 소폭 수정 후 PR 가능 (🔴 1건 해결 필요)
```

### 4. 후속 액션
- 🔴 항목 수정 후 `/dct-sc-review --staged` 재실행
- 전부 통과하면 "PR 준비 완료" 판정
- `/dct-complete DCTC-XXXX` 로 PR 생성 연계

## 규칙 준수
- **독립적 리뷰** — 자기가 쓴 코드를 리뷰하는 상황이므로 객관성 유지
- 리뷰 내용은 **구체적 코드 제안** 포함 (추상적 지적 금지)
- 파일 경로는 `file:line` 형식
- 변경하지 않은 코드에 대한 리뷰는 `💬 의견` 으로만 (수정 강요 금지)
