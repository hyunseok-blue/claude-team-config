---
name: dct-slack
description: 본인 Slack 계정으로 메시지 전송 — 웹에서 치는 것과 동일하게 표시. 봇 전송은 /dct-slack-bot 사용.
argument-hint: <Member ID | Channel ID | 저장된 이름> <메시지 본문>
---

# /dct-slack — 본인 계정으로 Slack 메시지 전송

`madupteam.slack.com` 에서 **본인 계정 그대로** 채널 또는 DM 으로 메시지를 전송한다. 봇이 아닌 **사용자 본인이 보낸 것**으로 표시된다.

MCP 서버: `slack` (`@korotovsky/slack-mcp-server`, `xoxc-`/`xoxd-` 브라우저 세션 토큰)

> **봇(`@매도비`)으로 보내려면**: `/dct-slack-bot` 사용

## 사용법

```
/dct-slack <ID | 저장된 이름> <메시지>
```

### 최초 전송 — Member ID / Channel ID 직접 입력
```
/dct-slack U0AL4JJMC48 안녕하세요
/dct-slack C01234ABCD 배포 완료했습니다
```
- 전송 성공 후 "이 ID 를 주소록에 어떤 이름으로 저장할까요?" → 주소록 자동 저장
- 건너뛰려면 `skip`

### 이후 전송 — 저장된 이름 사용
```
/dct-slack 정하늘 확인했어요
/dct-slack mkt_데이터컨설팅_cp 스프린트 완료
```
- 주소록 조회 → ID 변환 → 전송
- 없으면 "주소록에 없음" + ID 직접 입력 안내

## 인자 판별 규칙

| 첫 번째 토큰 패턴 | 해석 |
|---|---|
| `^U[A-Z0-9]{8,}$` | User ID → DM 전송 |
| `^C[A-Z0-9]{8,}$` | 공개 Channel ID |
| `^G[A-Z0-9]{8,}$` | Private Channel ID |
| `^D[A-Z0-9]{8,}$` | DM Channel ID |
| 그 외 | **이름** → 주소록 조회 |

두 번째 토큰부터 끝까지는 **메시지 본문**. 따옴표 불필요.

## MCP 도구 매핑

본인 계정 전송은 `mcp__slack__*` (korotovsky 서버) 도구를 사용한다:
- `mcp__slack__slack_post_message` — 메시지 전송
- `mcp__slack__slack_list_channels` — 채널 목록 (참고용)
- `mcp__slack__slack_get_channel_history` — 채널 히스토리

> **주의**: `mcp__slack-bot__*` (봇 서버) 와 혼동하지 말 것.

## 주소록

`/dct-slack` 과 `/dct-slack-bot` 은 **같은 주소록 파일**을 공유한다:
- 위치: `~/.claude/dct-slack-addressbook.json`
- 한쪽에서 등록한 이름은 다른 쪽에서도 사용 가능

## 토큰 관리

| 항목 | 내용 |
|---|---|
| 토큰 종류 | `xoxc-` (Local Storage) + `xoxd-` (Cookie `d`) |
| 추출 방법 | `madupteam.slack.com` 브라우저 → DevTools → Application |
| 수명 | Slack 세션 유지 중에는 수개월 유효 |
| 만료 조건 | 로그아웃, 패스워드 변경, 장기 미접속 |
| 재발급 | 브라우저 DevTools 에서 다시 추출 → `~/.claude.json` 의 `mcpServers.slack.env` 갱신 |
| 보안 경고 | 브라우저 세션 탈취 방식. Slack ToS 회색 지대. 팀 정책 확인 후 사용 |

## 실패 대응

| 에러 | 원인 | 해결 |
|---|---|---|
| `channel_not_found` | 본인이 해당 채널에 미가입 | 채널 가입 후 재시도 |
| `invalid_auth` | xoxc/xoxd 세션 만료 | 브라우저에서 토큰 재추출 → `~/.claude.json` 갱신 → Claude Code 재시작 |
| `ratelimited` | Slack API rate limit | 자동 재시도 |

## 규칙 준수
- **메시지 가공 금지** — 사용자 입력 그대로 전달
- **멘션 자동 추가 금지**
- **주의 채널 확인** — `#general`, `#announcements` 등은 전송 전 1회 확인
- **보안** — `~/.claude.json` 의 slack 토큰을 `Read` 로 출력 금지

## 관련
- `/dct-slack-bot` — 봇 `@매도비` 로 전송 (팀 공지/알림용)
- `dct-slack` 스킬 — 주소록 관리, ID 해석, 전송 로직
- `/dct` 7단계 — Slack MCP 설정 (봇 + 개인)
