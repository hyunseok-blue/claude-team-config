---
name: dct-sc-optimize
description: 성능 병목 분석·3가지 최적화 제안·벤치마크 비교 — 쿼리/메모리/응답시간/번들 최적화
argument-hint: <대상 경로 또는 "설명"> [--type query|memory|latency|bundle|all]
---

# /dct-sc-optimize — 성능 최적화

코드의 성능 병목을 분석하고 **3가지 이상의 최적화 방안**을 제안한다. awesome-claude-code 의 `/optimize` 패턴 참고.

## 사용법

```
/dct-sc-optimize <대상> [--type <유형>]
```

**예시**
- `/dct-sc-optimize src/services/report.py` — 전반적 성능 분석
- `/dct-sc-optimize src/api/ --type query` — DB 쿼리 최적화 집중
- `/dct-sc-optimize "대시보드 로딩이 5초 넘게 걸림" --type latency` — 증상 기반
- `/dct-sc-optimize frontend/src/ --type bundle` — 프론트엔드 번들 크기

## 최적화 유형

| 유형 | 분석 대상 |
|------|---------|
| `query` | N+1 쿼리, 미사용 JOIN, 인덱스 부재, 불필요 SELECT * |
| `memory` | 대량 데이터 일괄 로드, 메모리 누수 패턴, 스트리밍 미사용 |
| `latency` | 동기 블로킹, 직렬 API 호출 (병렬 가능), 캐시 미사용 |
| `bundle` | 미사용 import, 트리쉐이킹 불가 패턴, 이미지/폰트 최적화 |
| `all` | 위 전부 (기본값) |

## 실행 순서

### 1. 대상 분석
- 파일 경로 → 직접 코드 읽기
- 증상 설명 → 관련 파일 `Grep` 으로 탐색
- 프로젝트 기술 스택 파악 (DB 종류, 프레임워크, 빌드 도구)

### 2. 병목 식별
각 유형별 패턴 매칭:
- **query**: `SELECT *`, 루프 내 쿼리 호출, `N+1` 패턴 (`Grep` 으로 ORM 호출 추적)
- **memory**: 대량 리스트 생성 (generator 미사용), 글로벌 캐시 무한 성장
- **latency**: `await` 없는 직렬 호출, `time.sleep`, 동기 HTTP 클라이언트
- **bundle**: `import *`, 동적 import 미사용, 대형 라이브러리 전체 import

### 3. 최적화 제안 (최소 3가지)

각 제안마다:
```
### 제안 1: N+1 쿼리를 JOIN으로 통합

📍 위치: src/services/report.py:78-92
📊 예상 효과: DB 호출 N회 → 1회 (응답시간 ~60% 감소 추정)
⚠️ 위험도: 낮음 (기존 테스트로 검증 가능)

현재:
```python
for user in users:
    orders = db.query(Order).filter(Order.user_id == user.id).all()
```

제안:
```python
orders = db.query(Order).filter(Order.user_id.in_([u.id for u in users])).all()
orders_by_user = defaultdict(list)
for order in orders:
    orders_by_user[order.user_id].append(order)
```
```

### 4. 리포트 생성
```
## ⚡ 성능 최적화 리포트 — <대상>

### 병목 요약
| # | 위치 | 유형 | 심각도 | 예상 효과 |
|---|------|------|--------|---------|
| 1 | report.py:78 | query | P1 | 응답시간 60% ↓ |
| 2 | dashboard.py:120 | latency | P1 | 병렬화로 2초 ↓ |
| 3 | utils.py:45 | memory | P2 | 메모리 30% ↓ |

### 우선 적용 순서
1. 제안 1 (ROI 최고, 위험도 최저)
2. ...

### 적용하시겠습니까?
y → /dct-sc-implement 로 수정 진행
n → 리포트만 유지
```

## 규칙 준수
- 추측 성능 개선 금지 — 코드 증거 기반으로만 제안
- 가독성을 희생하는 미시 최적화 지양 (premature optimization 경고)
- 변경 시 기존 테스트 통과 필수
