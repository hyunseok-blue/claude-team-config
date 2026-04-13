---
name: dct-sc-debug
description: 에러 분석·근본 원인 추적·수정 제안 — 스택 트레이스 파싱, 재현 테스트, 경쟁 가설 검증
argument-hint: "<에러 설명 또는 스택 트레이스>" [--repro] [--fix]
---

# /dct-sc-debug — 디버깅

에러나 버그를 체계적으로 분석해 **근본 원인(root cause)** 을 추적하고 수정안을 제시한다. 기존 `/sc:troubleshoot` 강화 버전.

## 사용법

```
/dct-sc-debug "<에러 설명>" [옵션]
```

**예시**
- `/dct-sc-debug "로그인 후 리다이렉트 안됨"` — 증상 기반 디버깅
- `/dct-sc-debug "TypeError: Cannot read property 'id' of undefined"` — 스택 트레이스 분석
- `/dct-sc-debug "DCTC-1234 에서 리포트된 버그"` — Jira 카드 참조
- `/dct-sc-debug "./error-log.txt" --repro --fix` — 로그 파일 + 재현 + 자동 수정

## 실행 순서

### Phase 1 — 증상 수집
1. 입력이 파일 경로 → `Read` 로 에러 로그 로드
2. 입력이 Jira 카드 번호 → `jira_get_issue` 로 카드 설명 조회
3. 스택 트레이스가 포함돼 있으면 자동 파싱:
   - 파일 경로, 라인 번호, 함수명 추출
   - 에러 타입 분류 (TypeError, ValueError, NetworkError 등)

### Phase 2 — 경쟁 가설 수립
입력된 증상으로부터 **최소 3개의 가설**을 세운다:
```
## 가설

1. [가능성 높음] 토큰 만료 검증 로직이 누락됨
   → 근거: auth/validator.py 에 expiry 체크 없음
   → 검증 방법: validator.py 읽어서 확인

2. [가능성 중간] 리다이렉트 URL 이 하드코딩됨
   → 근거: 환경별로 다른 URL 필요
   → 검증 방법: config 파일에서 redirect_url 검색

3. [가능성 낮음] CORS 설정 문제
   → 근거: 크로스 도메인 요청일 수 있음
   → 검증 방법: 미들웨어 CORS 설정 확인
```

### Phase 3 — 가설 검증
각 가설을 **코드 증거 기반**으로 검증:
1. 관련 파일 `Read` + `Grep` 으로 탐색
2. 가설마다 "확증 / 반증 / 미확인" 판정
3. 가장 유력한 가설에 집중

### Phase 4 — 근본 원인 확정
```
## 🔍 근본 원인

**auth/validator.py:45** — `validate_token()` 함수에서 토큰 만료 시간(`exp`)을
체크하지 않고 서명만 검증함. 만료된 토큰도 유효로 판정되어 리다이렉트 실패.

### 증거
- validator.py:45: `jwt.decode(token, key)` — `options={"verify_exp": True}` 누락
- 테스트에서도 만료 토큰 케이스 없음
- 로그에 `401` 이 아닌 `200` 반환 기록

### 영향 범위
- auth/validator.py (직접)
- api/login.py, api/refresh.py (호출부)
```

### Phase 5 — 재현 테스트 (`--repro`)
- 근본 원인을 재현하는 **실패 테스트** 자동 작성
- 실행해서 실제로 실패하는지 확인
- 이 테스트가 수정 후 통과해야 하는 기준 역할

### Phase 6 — 수정 (`--fix`)
사용자 확인 후:
1. 최소한의 코드 수정 적용
2. 재현 테스트 + 기존 테스트 재실행
3. 전부 통과하면 완료 리포트

## 규칙 준수
- 추측 수정 금지 — 반드시 파일을 읽고 증거 확보 후 수정
- 수정 범위 최소화 — 버그와 관련 없는 코드 리팩토링 금지
- `--fix` 없이는 분석·리포트만 (코드 수정 안 함)
