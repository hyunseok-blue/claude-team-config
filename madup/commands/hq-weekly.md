# /hq-weekly — DCT 주간 보고 자동화

매드업 데이터컨설팅팀(DCT)의 주간 보고를 골든 템플릿에 맞춰 빌드·배포하는 슬래시 명령.

## 사용

```
/hq-weekly             # 현재 주차 자동 추정 (오늘 기준 ISO 주차)
/hq-weekly W20         # 명시적 주차 지정
/hq-weekly W20 --build-only   # MCP 수집 스킵, 기존 inputs로 빌드만
/hq-weekly W20 --deploy       # 빌드 + Netlify 배포
```

## 작업 디렉토리

`<YOUR_GIT_ROOT>/madup/harness_sys/hq-weekly-report/` — 본인 환경에 맞게 수정 (예: `$HOME/Documents/git/madup/harness_sys/hq-weekly-report/`)

## 흐름 (메인 Claude 세션이 따라야 하는 단계)

### 1. 입력 디렉토리 생성
```bash
mkdir -p inputs/W{NN}
```

### 2. Confluence MCP 수집 (DCT 공간)

`mcp__claude_ai_Atlassian__searchConfluenceUsingCql` 또는 `getConfluencePage` 로
해당 주차의 4개 보고 페이지를 검색·다운로드:

- DCT DE 주간 업무 보고
- DCT OP 주간 업무 보고 (TF)
- DCT BI 주간 업무 보고
- DCT CP 주간 업무 보고

각 본문을 markdown으로 추출해 다음 경로에 저장:
- `inputs/W{NN}/confluence_de.md`
- `inputs/W{NN}/confluence_op.md`
- `inputs/W{NN}/confluence_bi.md`
- `inputs/W{NN}/confluence_cp.md`

### 3. meta.json 자동 채움

`inputs/W19/meta.json` 골든 구조를 reference로:

```json
{
  "week": "W{NN}",
  "iso_year": <YYYY>,
  "iso_week": <NN>,
  "meeting_date": "<YYYY-MM-DD>",
  "meeting_dow": "월",
  "report_period": "...",
  "cycle_label": "DCT (HQ) · <YYYY>-W{NN} 인차지 회의 사이클",
  "title": "HQ 주간 보고 — <YYYY-MM-DD> 인차지 사이클",
  "authors": [...],
  "parts": "DE · OP TF · BI · CP",
  "report_period_short": "...",
  "footer_caption": "DCT 4개 파트 통합",
  "source_pages": [
    {"part": "DE", "id": "<id>", "title": "...", "url": "..."},
    {"part": "OP TF", "id": "<id>", "title": "...", "url": "..."},
    {"part": "BI", "id": "<id>", "title": "...", "url": "..."},
    {"part": "CP", "id": "<id>", "title": "...", "url": "..."}
  ]
}
```

### 4. report.json 작성 (LLM 직접)

`src/parse_confluence.py` 의 `REPORT_SCHEMA_HINT` 와 `inputs/W19/report.json`(골든)을 참고해,
4개 markdown 본문을 읽고 같은 스키마로 dict를 만들어 `inputs/W{NN}/report.json` 으로 저장.

핵심 키:
- `headline`, `exec_summary`, `kpi`, `matrix`, `roadmap`, `people`, `next_week`, `glossary`

### 5. tokens.tsv paste 요청

사용자에게 다음 메시지를 띄우고 응답을 대기:

> "AI Token Monitor 앱 → Leaderboard Weekly 표를 복사해서
> `inputs/W{NN}/tokens.tsv` 에 붙여넣어 주세요.
> 헤더는 `유저\t메시지수\t토큰_사용량\t비용_USD` 입니다.
> 완료되면 'OK' 또는 '됐어' 라고 답해주세요."

### 6. 빌드 + 미리보기

```bash
WEEK=W{NN} npm run build:week
open outputs/W{NN}.html
```

사용자에게 시각 검수 요청 → OK 시 다음 단계.

### 7. 배포

```bash
npm run deploy
```

첫 배포 시:
1. `netlify init` 으로 사이트 생성 (사이트명 결정 필요)
2. `.env` 파일에 `HQ_REPORT_PASSWORD=<YOUR_REPORT_PASSWORD>` 확인 (.gitignore 처리됨)
3. 첫 `netlify deploy --prod` 후 도메인 안내

이후 매주 동일 도메인에 갱신.

## 주의사항

- `tokens.tsv` 는 사용자가 매주 paste 해야 함 (AI Token Monitor 앱이 디스크에 저장 안 함)
- `.env` 파일은 .gitignore 처리됨 — 절대 커밋 금지
- 빌드 실패 시 `inputs/W{NN}/{meta,report}.json` 의 스키마 누락 점검
- index 카드는 평문(제목·헤드라인) 노출 — 보안에 민감한 정보는 본문에만 두고 헤드라인은 일반 표현 사용

## 의존성

```bash
pip install -r requirements.txt   # jinja2, cryptography, python-dotenv
npm install -g netlify-cli         # 배포용 (1회)
```
