---
name: dct-slack-bot
description: 봇(@매도비) 으로 Slack 메시지 전송 — 팀 공지/알림용. 본인 계정 전송은 /dct-slack-bot 사용.
argument-hint: <Member ID | Channel ID | 저장된 이름> <메시지 본문>
---

# /dct-slack-bot-bot — 봇으로 Slack 메시지 전송

봇 `@매도비` 를 통해 `madupteam.slack.com` 의 채널 또는 DM 으로 메시지를 전송한다. **발신자가 봇**으로 표시된다. 본인 계정으로 보내려면 `/dct-slack-bot` 을 사용.

MCP 서버: `slack-bot` (`@modelcontextprotocol/server-slack`, `xoxb-` 토큰). `dct-slack` 스킬에 실제 로직을 위임.

## 사용법

```
/dct-slack-bot <ID | 저장된 이름> <메시지>
```

### 최초 전송 — Member ID / Channel ID 직접 입력
```
/dct-slack-bot U0AL4JJMC48 안녕하세요
/dct-slack-bot C01234ABCD 배포 완료했습니다
/dct-slack-bot D0AKWNL5ULB 메모
```
- 전송 성공 후 Claude 가 **"이 ID 를 주소록에 어떤 이름으로 저장할까요?"** 라고 묻는다
- 이름을 입력하면 `~/.claude/dct-slack-addressbook.json` 에 자동 저장
- 건너뛰고 싶으면 `skip`

### 이후 전송 — 저장된 이름 사용
```
/dct-slack-bot 정하늘 아아ㅏㅇ아아아아
/dct-slack-bot general 배포 완료
/dct-slack-bot data-consulting 스프린트 플래닝 시작합니다
```
- 주소록에 있으면 자동으로 ID 로 변환 후 전송
- 없으면 "주소록에 없음" 안내와 함께 최초 전송 플로우 유도

## 인자 판별 규칙

| 첫 번째 토큰 패턴 | 해석 |
|---|---|
| `^U[A-Z0-9]{8,}$` | User ID → DM 전송 |
| `^C[A-Z0-9]{8,}$` | 공개 Channel ID |
| `^G[A-Z0-9]{8,}$` | Private Channel ID (레거시) |
| `^D[A-Z0-9]{8,}$` | DM Channel ID |
| 그 외 | **이름** → 주소록 조회 |

두 번째 토큰부터 끝까지는 **메시지 본문**. 따옴표 불필요.

## Member ID / Channel ID 찾는 법

**Member ID**
1. Slack 에서 대상 유저 프로필 클릭 → `⋮` 더보기 → **"멤버 ID 복사"**
2. 형식: `U` + 10자 내외 (예: `U0AL4JJMC48`)

**Channel ID**
1. 채널 이름 우클릭 → **"채널 상세정보"** 하단에 표시
2. 또는 브라우저 URL 끝부분 (`/archives/C01234ABCD`)
3. 형식: `C`(public) / `G`(private) / `D`(DM) + 10자 내외

## 주소록

**위치**: `~/.claude/dct-slack-addressbook.json`

```json
{
  "users": { "정하늘": "U0AL4JJMC48" },
  "channels": { "general": "C01234ABCD" }
}
```

- 수동 편집 가능 (같은 ID 에 여러 별칭 등록 OK)
- 파일이 없으면 최초 저장 시 자동 생성

## 실패 대응

| 에러 | 원인 | 해결 |
|---|---|---|
| `channel_not_found` | 봇이 private 채널에 미초대 또는 잘못된 ID | `/invite @매도비` 또는 ID 재확인 |
| `not_in_channel` | 봇이 채널 멤버 아님 | `/invite @매도비` |
| `missing_scope` | 봇 Token Scope 부족 | Slack Admin 에 `chat:write`, `im:write` scope 추가 요청 |
| `invalid_auth` | 봇 토큰 만료 | AWS Secrets Manager `prod/gen-ai/slack` 값 확인, `/dct` 6단계 재실행 |
| `ratelimited` | Slack API rate limit | 자동 재시도 (스킬에서 처리) |

## 규칙 준수
- **메시지 가공 금지** — 사용자 입력 그대로 전달
- **멘션 자동 추가 금지** — `<@U012ABCD>` 는 사용자 명시 시에만
- **주의 채널 확인** — `#general`, `#announcements`, `#all-*` 등은 전송 전 1회 확인 (스킬이 처리)
- **보안** — `~/.claude.json` 의 slack 토큰을 `Read` 로 출력 금지

## 관련
- `dct-slack` 스킬 — 주소록 관리, ID 해석, 전송 로직
- `/dct` 6단계 — Slack MCP 최초 설정 (AWS Secrets Manager 연동)
- `/dct-refresh-slack` — 토큰 로테이션 시 갱신 (향후 추가 예정)
