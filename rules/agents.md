# Subagent Delegation Rules

## 위임 기준
- **직접 처리**: 단순 조회, 1~2개 파일 수정, 명령어 실행
- **서브에이전트 위임**: 멀티파일 변경, 리팩토링, 디버깅, 코드 리뷰, 보안 검토

## 에이전트별 역할 (oh-my-claudecode 기준)
- `executor` (opus): 코드 구현 작업
- `architect` (opus): 시스템 설계, 구조 결정
- `debugger` (opus): 근본 원인 분석, 버그 추적
- `code-reviewer` (opus): 품질·보안 리뷰
- `security-reviewer` (opus): 취약점 분석
- `test-engineer` (opus): 테스트 전략, TDD
- `document-specialist` (opus): SDK/API 문서 조회
- `verifier` (opus): 작업 완료 검증

## 원칙
- 에이전트별 도구 접근을 제한하여 집중적 실행 유도
- 작성(authoring)과 검토(review)는 별도 pass로 분리 — 동일 컨텍스트에서 자기 검토 금지
- 작업 완료 전 verifier로 결과 검증
