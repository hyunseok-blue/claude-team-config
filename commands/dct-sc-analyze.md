---
name: dct-sc-analyze
description: 코드 품질/보안/성능/아키텍처 종합 분석 — 심각도 등급 리포트 + 실행 가능한 개선안
argument-hint: <대상 경로> [--focus quality|security|performance|architecture|all] [--depth quick|deep]
---

# /dct-sc-analyze — 코드 종합 분석

지정한 경로의 코드를 **품질·보안·성능·아키텍처** 4개 축으로 분석하고, 심각도 등급(P0~P3)이 매겨진 리포트를 생성한다.

## 사용법

```
/dct-sc-analyze <대상 경로> [--focus <축>] [--depth quick|deep]
```

**예시**
- `/dct-sc-analyze src/` — 전체 분석 (기본 depth: quick)
- `/dct-sc-analyze src/api --focus security --depth deep` — 보안 심층 분석
- `/dct-sc-analyze ./services/auth --focus performance` — 성능 집중

## 인자

| 인자 | 설명 | 기본값 |
|------|------|--------|
| `대상 경로` | 분석할 디렉터리 또는 파일 | 필수 |
| `--focus` | 집중 분석 축 (`quality`, `security`, `performance`, `architecture`, `all`) | `all` |
| `--depth` | `quick` (파일 구조 + 패턴 검색) / `deep` (전체 코드 리딩 + 의존성 추적) | `quick` |

## 실행 순서

### 1. 대상 탐색
- `Glob` 으로 대상 경로의 파일 구조 파악 (언어별 분류)
- `--depth deep` 이면 모든 파일을 `Read` 로 순차 로드

### 2. 축별 분석

**Quality (품질)**
- 코드 중복, dead code, 과도한 복잡도 (순환 복잡도 추정)
- 네이밍 일관성, 함수/클래스 크기
- 에러 핸들링 패턴, bare except 사용 여부
- SOLID 원칙 위반

**Security (보안)**
- OWASP Top 10 패턴 매칭 (SQL injection, XSS, command injection 등)
- 하드코딩된 시크릿/API 키 (`Grep` 으로 `password`, `secret`, `api_key`, `token` 등 검색)
- 의존성 취약점 가능성 (알려진 위험 패키지)
- 인증/인가 로직 누락

**Performance (성능)**
- N+1 쿼리 패턴, 불필요한 루프 내 I/O
- 대용량 데이터 메모리 로드 (pagination 부재)
- 캐시 미사용, 인덱스 누락 가능성
- 비동기 처리가 필요한 동기 블로킹

**Architecture (아키텍처)**
- 레이어 분리 (controller/service/repository 등)
- 순환 의존성, 모듈 결합도
- 설정 하드코딩 vs 환경변수/설정 파일
- 확장성 병목 지점

### 3. 리포트 생성

```
## 🔍 코드 분석 리포트 — <대상 경로>

### 요약
- 파일 수: N개 (Python M, TypeScript K, ...)
- 분석 depth: quick/deep
- Focus: all/quality/security/...

### 발견 사항

🔴 P0 — 즉시 수정 필요
- [파일:라인] 설명 (축: security)
  → 제안: ...

🟡 P1 — 다음 스프린트에 수정 권장
- ...

🟢 P2 — 개선하면 좋음
- ...

⚪ P3 — 참고
- ...

### 통계
| 축 | P0 | P1 | P2 | P3 |
|---|---|---|---|---|
| Quality | 0 | 2 | 5 | 3 |
| Security | 1 | 0 | 1 | 0 |
| ...

### 우선순위 액션 플랜
1. ...
2. ...
```

### 4. 후속 안내
- P0 이 있으면 즉시 수정 제안 (사용자 확인 후 `/dct-sc-implement` 로 연계)
- Jira 카드가 있으면 분석 결과를 댓글로 등록 가능 (사용자 확인 후)

## 규칙 준수
- 한국어 리포트
- 파일 경로는 `file:line` 형식으로 클릭 가능하게
- `~/.claude.json`, `~/.claude/settings.json` 등은 분석 대상에서 제외
