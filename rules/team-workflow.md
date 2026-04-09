# 팀 워크플로우 규칙 (GitHub / Jira / Confluence)

## GitHub
- 신규 작업 시 Jira 카드 기준으로 브랜치 생성
  - 네이밍: `feature/DCTC-{카드번호}` (예: `feature/DCTC-1808`)
  - 작업 종류(feat / fix 등) 구분하여 커밋 메시지에 반영

## Jira (Atlassian MCP)
- 사용자가 "완료", "끝" 등의 멘트로 작업 종료 + 정리를 요청하면, 해당 Jira 카드에 전체 작업 내용을 댓글로 정리
- 제3자가 봐도 이해할 수 있게 **간결하고 명확하게** 작성
- 사용 도구: `mcp__mcp-atlassian__jira_add_comment`
- 허용 작업: **읽기 / 수정(댓글도포함)**

## Confluence (Atlassian MCP)
- **Data Consulting Team** 스페이스에서만 작업
- 허용 작업: **읽기 / 수정 / 생성** (삭제 금지)
- 편집 가능 문서 범위: **DCT CP**, **Matrix** 문서로 제한
- 그 외 스페이스/문서는 접근 금지
