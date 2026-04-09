# Python 개발 작업 가이드

## 프로젝트 환경
- 가상환경 확인 후 작업 (venv, poetry, conda 등 프로젝트에 맞는 환경 사용)
- `pyproject.toml` 또는 `requirements.txt` 존재 여부 확인 후 의존성 관리
- Python 버전은 프로젝트 설정(`.python-version`, `pyproject.toml`)에 명시된 버전 준수

## 코드 스타일
- **PEP 8** 준수 (들여쓰기 4칸, 줄 길이 등)
- 프로젝트에 formatter/linter 설정이 있으면 해당 설정 따르기 (ruff, black, flake8, isort 등)
- Type hint 적극 사용 — 함수 시그니처에 파라미터 타입과 리턴 타입 명시
- f-string 사용 권장 (`.format()`, `%` 포매팅 대신)
- 변수/함수명은 `snake_case`, 클래스명은 `PascalCase`

## 구조 및 패턴
- import 순서: 표준 라이브러리 → 서드파티 → 로컬 모듈 (빈 줄로 구분)
- 순환 import 주의 — 발견 시 구조 개선 제안
- `*` import 금지 (`from module import *`)
- 예외 처리 시 bare `except:` 금지 — 구체적 예외 클래스 명시
- 가변 기본 인자 금지 (`def func(items=[])` → `def func(items=None)`)

## 테스트
- pytest 기반 테스트 우선
- 테스트 파일은 `test_` 접두사, 테스트 함수도 `test_` 접두사
- 코드 변경 후 관련 테스트 실행하여 검증

## 보안
- 하드코딩된 시크릿/비밀번호/API 키 금지 — 환경변수 또는 시크릿 매니저 사용
- `eval()`, `exec()` 사용 금지 (보안 취약점)
- SQL 쿼리 작성 시 파라미터 바인딩 사용 (f-string으로 쿼리 조합 금지)
- `pickle`로 신뢰할 수 없는 데이터 역직렬화 금지
