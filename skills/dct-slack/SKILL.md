---
name: dct-slack
description: 팀 Slack 메시지 전송 스킬. 본인 계정(/dct-slack, MCP "slack")과 봇(/dct-slack-bot, MCP "slack-bot") 두 모드 지원. 주소록 캐시 공유.
---

# DCT Slack 스킬

`/dct-slack` (본인 계정) 과 `/dct-slack-bot` (봇 `@매도비`) 두 커맨드의 공유 백엔드. 주소록 캐시, ID 해석, 에러 대응 로직을 담당한다.

## 두 모드 비교

| | `/dct-slack` (본인 계정) | `/dct-slack-bot` (봇) |
|---|---|---|
| MCP 키 | `slack` | `slack-bot` |
| MCP 서버 | `slack-mcp-server` | `@modelcontextprotocol/server-slack` |
| 토큰 | `xoxc-` + `xoxd-` (브라우저 세션) | `xoxb-` (AWS Secrets Manager) |
| 발신자 표시 | **본인 이름** | **@매도비** (봇) |
| 도구 prefix | `mcp__slack__*` | `mcp__slack-bot__*` |
| 용도 | 개인 DM, 본인 명의 메시지 | 팀 알림, 공지, 자동화 |

## 설계 원칙

**Slack MCP 서버의 `slack_get_users` 는 한 번에 200명 제한 + cursor 페이지네이션 불안정**하다는 제약이 있다. 전체 워크스페이스에서 이름으로 검색하는 방식은 신뢰할 수 없으므로, 다음 전략을 채택한다:

1. **최초 전송**: 사용자가 **Member ID / Channel ID 를 직접 입력**해야 한다
2. **성공 후 주소록 저장**: 사용자에게 이 ID 의 별칭(이름)을 물어 주소록에 저장
3. **이후 전송**: 이름으로 입력해도 주소록에서 조회해 자동으로 ID 로 변환

전체 유저/채널 검색을 시도하지 않음 → 안정성과 속도 확보.

## 주소록 파일

**경로**: `~/.claude/dct-slack-addressbook.json`

**포맷**:
```json
{
  "users": {
    "정하늘": "U0AL4JJMC48",
    "hnjung": "U0AL4JJMC48"
  },
  "channels": {
    "general": "C01234ABCD",
    "data-consulting": "C56789EFGH"
  }
}
```

- `users` — 사용자 이름/별칭 → User ID (DM 전송용)
- `channels` — 채널 이름 → Channel ID
- 같은 ID 에 여러 별칭을 둘 수 있음 (예: 본명과 영문 핸들 모두 등록)

**파일이 없으면** 빈 객체 `{"users": {}, "channels": {}}` 로 초기화.

## 핵심 도구

| 용도 | 도구 |
|------|------|
| 메시지 전송 | `mcp__slack__slack_post_message` (`channel_id`, `text`) |
| 스레드 답변 | `mcp__slack__slack_reply_to_thread` |
| 주소록 읽기/쓰기 | `Read` / `Write` / `jq` + `Bash` |

## 실행 플로우

### Phase 1 — 인자 파싱
- 첫 토큰 = target
- 나머지 전체 = message (따옴표 없이도 공백 포함 허용)

### Phase 2 — target 유형 판별
1. `^[CGD][A-Z0-9]{8,}$` → **Channel/DM ID** (그대로 사용, 주소록 저장 플로우로)
2. `^U[A-Z0-9]{8,}$` → **User ID** (그대로 사용, 주소록 저장 플로우로)
3. `@` 접두사 또는 일반 텍스트 → **이름** (주소록 조회 플로우로)

### Phase 3a — ID 직접 입력된 경우
1. `mcp__slack__slack_post_message` 호출 (`channel_id` = 입력 ID)
2. 성공 시 `ok: true` 확인
3. 사용자에게 묻기: **"이 ID (`U0AL4JJMC48`) 를 주소록에 어떤 이름으로 저장할까요? (건너뛰려면 skip)"**
4. 이름 입력받으면 `~/.claude/dct-slack-addressbook.json` 에 병합:
   ```bash
   jq --arg name "$NAME" --arg id "$ID" --arg kind "$KIND" '
     .[$kind][$name] = $id
   ' ~/.claude/dct-slack-addressbook.json > tmp && mv tmp ~/.claude/dct-slack-addressbook.json
   ```
   - `kind` 는 ID 접두사에 따라 `users` (U 시작) 또는 `channels` (C/G/D 시작)
5. 저장 완료 메시지 출력

### Phase 3b — 이름 입력된 경우
1. `@` 접두사 제거
2. 주소록 파일 존재 확인 — 없으면 사용자에게 "주소록이 비어있습니다. 먼저 Member ID/Channel ID 로 전송 후 자동 저장됩니다" 안내하고 종료
3. `users` 먼저 조회 → 없으면 `channels` 조회
4. 매칭 실패 → 사용자에게 안내:
   ```
   ❌ '정하늘' 은 주소록에 없습니다.
   등록된 항목: [주소록에 있는 이름 목록]
   새 대상은 먼저 ID 로 전송해주세요. 예: /dct-slack U0AL4JJMC48 안녕
   ```
5. 매칭 성공 → 해당 ID 로 `slack_post_message` 호출

### Phase 4 — 결과 보고
- 성공: `✅ 전송 완료 — <이름 또는 ID> · ts=<timestamp>`
- 실패: 에러 코드에 따라 아래 대응

## 주소록 관리 서브 명령 (향후 확장)

- `/dct-slack --list` — 전체 주소록 출력 (ID 값은 마스킹)
- `/dct-slack --remove <이름>` — 항목 삭제
- `/dct-slack --rename <기존이름> <새이름>` — 별칭 변경

(현재는 사용자가 `~/.claude/dct-slack-addressbook.json` 을 직접 편집 가능)

## 주의 채널 확인

아래 채널 ID 로 전송하려 할 때 **사용자에게 1회 확인**:
- 주소록 `channels` 에서 이름이 `general`, `announcements`, `all-*`, `notice-*` 로 시작
- 채널 이름을 직접 알 수 없는 상황(ID 직접 입력 최초 전송) 에서는 생략

확인 프롬프트:
```
⚠️ '#general' 은 전체 공지 채널입니다. 정말 전송할까요? (y/N)
```

## 에러 대응

### `channel_not_found`
```
❌ 채널을 찾을 수 없습니다.
- 봇(@매도비)이 해당 private 채널에 초대되지 않았거나
- 잘못된 Channel ID 일 수 있습니다.
해결: Slack 에서 `/invite @매도비` 실행 또는 Channel ID 재확인
```

### `not_in_channel`
봇이 채널 멤버가 아님. 같은 안내.

### `missing_scope`
봇 Token Scope 부족. 필요 scope:
- `chat:write` (필수)
- `im:write` (DM 용, 필수)
- `channels:read`, `groups:read` (선택, 현재 스킬은 사용 안 함)
- `users:read` (선택)

Slack Admin 또는 봇 소유자에게 scope 추가 요청 안내.

### `invalid_auth`
토큰 만료. 대응:
```
❌ Slack 봇 토큰 인증 실패
해결: AWS Secrets Manager 의 prod/gen-ai/slack 값이 유효한지 확인
  aws secretsmanager get-secret-value --secret-id prod/gen-ai/slack --region ap-northeast-2 --query SecretString --output text | jq .SLACK_TOKEN

새 토큰으로 교체 후 /dct 6단계 재실행 또는 scripts/refresh-slack-token.sh 사용
```

### `ratelimited`
Slack API rate limit. 반환된 `Retry-After` 만큼 대기 후 1회 재시도.

## Member ID / Channel ID 찾는 법 (사용자 안내용)

사용자가 최초 전송 전에 ID 를 찾아야 할 때 제공할 가이드:

**Member ID (User)**
1. Slack 에서 대상 유저 프로필 클릭
2. 프로필 우측 상단 `⋮` (더보기) → **"멤버 ID 복사"**
3. 형식: `U` 로 시작하는 11자 내외 (예: `U0AL4JJMC48`)

**Channel ID**
1. Slack 에서 채널 이름 우클릭 → **"채널 상세정보 보기"**
2. 하단에 `채널 ID: C0ADLGZ6TBR` 표시
3. 또는 브라우저 Slack URL 끝부분: `/archives/C0ADLGZ6TBR`
4. 형식: `C`(public) / `G`(private legacy) / `D`(DM 채널) 로 시작하는 11자 내외

## 규칙 준수

- **메시지 본문 가공 금지** — 사용자 입력 그대로 전달
- **멘션 자동 추가 금지** — `<@U012ABCD>` 는 사용자가 명시했을 때만
- **Bot 이름 노출 OK** — `@매도비` 는 공개 정보, 에러 메시지에 사용 가능
- **보안**:
  - `~/.claude.json` 의 `mcpServers.slack.env.SLACK_BOT_TOKEN` 을 `Read` 로 전체 출력 금지
  - 주소록 파일(`~/.claude/dct-slack-addressbook.json`) 은 시크릿이 없으므로 읽기/수정 자유
