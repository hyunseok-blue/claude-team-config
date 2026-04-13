---
name: dct-sc-test
description: 테스트 실행·커버리지 분석·누락 테스트 자동 생성 — pytest/jest/vitest 등 프레임워크 자동 감지
argument-hint: [대상 경로] [--generate] [--coverage] [--fix]
---

# /dct-sc-test — 테스트 실행 및 관리

프로젝트의 테스트를 실행하고, 커버리지를 분석하고, 누락된 테스트를 자동 생성한다.

## 사용법

```
/dct-sc-test [대상] [옵션]
```

**예시**
- `/dct-sc-test` — 전체 테스트 실행
- `/dct-sc-test src/api/ --coverage` — 커버리지 포함 실행
- `/dct-sc-test src/services/auth.py --generate` — auth.py 에 대한 테스트 자동 생성
- `/dct-sc-test --fix` — 실패한 테스트 자동 수정 시도

## 실행 순서

### 1. 테스트 프레임워크 자동 감지
- `package.json` → jest, vitest, mocha
- `pyproject.toml` / `pytest.ini` / `setup.cfg` → pytest
- `Cargo.toml` → cargo test
- `go.mod` → go test
- 감지 실패 시 사용자에게 문의

### 2. 테스트 실행
- 감지된 프레임워크로 실행 (`Bash` 도구)
- `--coverage` 시 커버리지 플래그 추가
- 실행 결과 파싱 (통과/실패/스킵 수, 실패 메시지)

### 3. 결과 리포트

```
## 🧪 테스트 리포트

### 실행 결과
- ✅ 통과: 42
- ❌ 실패: 2
- ⏭️ 스킵: 3
- 소요 시간: 12.3s

### 실패 상세
1. test_auth.py::test_login_expired_token
   AssertionError: expected 401, got 200
   → 원인 추정: 토큰 만료 검증 로직 누락
   → 수정 제안: src/auth/validator.py:45 에 만료 체크 추가

2. ...

### 커버리지 (--coverage 시)
- 전체: 78%
- 미커버 파일 Top 5:
  - src/services/payment.py (32%)
  - src/api/webhook.py (45%)
  - ...
```

### 4. 누락 테스트 생성 (`--generate`)
- 대상 파일의 공개 함수/메서드 목록 추출
- 기존 테스트와 비교해 **커버되지 않는 함수** 식별
- 테스트 코드 자동 생성:
  - 정상 케이스 (happy path)
  - 엣지 케이스 (빈 값, None, 경계값)
  - 에러 케이스 (예외 발생 시나리오)
- 생성된 테스트 실행해 통과 확인

### 5. 실패 테스트 수정 (`--fix`)
- 실패 원인 분석 (assertion 값, traceback)
- **테스트가 틀렸는지 vs 코드가 틀렸는지** 판단:
  - 테스트 기대값이 잘못됨 → 테스트 수정
  - 코드 로직 버그 → 코드 수정 (사용자 확인 후)
- 수정 후 재실행해 통과 확인

## 규칙 준수
- 테스트 파일: `test_` 접두사 (Python), `*.test.ts` / `*.spec.ts` (JS/TS)
- 기존 테스트 스타일 따르기 (mock 패턴, fixture 구조 등)
- `--fix` 로 코드 수정 시 반드시 사용자 확인
