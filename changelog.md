# Changelog — canvas-design-kr

All notable changes to this skill are documented here.

Versioning follows the convention of this author's skill suite:
**increment by 0.0.1 per modification** (patch). Breaking core-structure
changes bump the minor component (0.x.0). `Created` date fixed to the
original creation date; `metadata.updated` refreshed per change.

---

## [1.1.0] — 2026-04-19

### Build / Packaging Fix — Claude Desktop ZIP 검증기 호환 (사전 배포)

**문제**: v1.1.0 코어 ZIP을 Claude Desktop에 업로드하면
`Zip file contains path with invalid characters` 오류로 거부됨.

**원인**: Google Fonts의 가변 폰트 원본 배포 파일명 `NotoSansKR[wght].ttf`
에 포함된 대괄호(`[`, `]`)가 Claude Desktop의 ZIP 파일명 검증기에서
"invalid characters"로 분류된다. 대괄호는 기술적으로 파일 시스템에서
허용되는 문자지만, Windows 전통 및 일부 ZIP 스펙 검증기에서는 엄격히
거부되는 경향이 있다.

**해결**: 코어 가변 폰트 파일명을 **`NotoSansKR-VF.ttf`** 로 변경
(VF = Variable Font, 업계 관례 접미사). 폰트 바이너리는 그대로이며
파일명만 바뀌었으므로 가변 축(`wght` 100–900) 기능은 완전히 유지된다.

**영향**:

- SKILL.md, README.md, changelog.md, NOTICE.txt, MANIFEST.txt, 전 스크립트,
  GitHub Actions 워크플로우에서 파일명 참조를 일괄 교체
- `build_core_from_fullpack.{sh,ps1}` 및 `build_full_pack.{sh,ps1}`은
  원본 `NotoSansKR[wght].ttf` (Google Fonts 배포분) 또는 이미 리네임된
  `NotoSansKR-VF.ttf` 둘 다 소스로 받아들이고, 출력 ZIP에는 항상
  `NotoSansKR-VF.ttf`로 기록
- PIL 코드 예시가 단순해짐 — 더 이상 대괄호 이스케이프·`-LiteralPath`
  우회 필요 없음

---

### Added — `scripts/verify_cjk_support.py` (CJK 실측 검증 도구)

**배경**: v1.1.0 코어 설계 직후 영문 공식 문서(Google Fonts 설명,
RightFont, Namuwiki 등)에 "Nanum fonts support Hangeul and Latin only"
라는 기술이 확인되어 `NanumBrushScript`·`NanumPenScript`·`JejuGothic`의
한자 미지원 가능성이 제기됐다. 이는 코어 5종 중 3종의 CJK 지원 주장을
뒤흔드는 문제라, 판단 전 **실측 먼저** 수행했다.

**실측 방법**: `fontTools`로 각 폰트의 cmap 테이블을 직접 파싱,
CJK 유니코드 범위 3개(U+4E00–9FFF Unified, U+3400–4DBF Ext-A,
U+F900–FAFF Compatibility)에 포함된 글리프 수와 스킬 철학 9자
(餘·白·丹·靑·縫·補·古·調·湍) 지원 여부를 검증.

**실측 결과 (2026-04-19)**:

| 폰트 | 철학 9자 | 일상 13자 | CJK 총합 | 판정 |
| --- | --- | --- | --- | --- |
| NotoSansKR-VF.ttf | 9/9 | 13/13 | 8,566 | ✅ 완전 |
| NotoSansKR[wght].ttf (동일 바이너리) | 9/9 | 13/13 | 8,566 | ✅ 완전 |
| NanumMyeongjo-OldHangul.ttf | 9/9 | 13/13 | 5,005 | ✅ 완전 |
| NanumBrushScript-Regular.ttf | **9/9** | **13/13** | **4,888** | **✅ 완전** |
| NanumPenScript-Regular.ttf | **9/9** | **13/13** | **4,888** | **✅ 완전** |
| JejuGothic-Regular.ttf | **9/9** | **13/13** | **4,888** | **✅ 완전** |

세 폰트의 CJK 총합이 정확히 **4,888**로 동일. KS X 1001 완성형 한자
세트(4,888자)가 NAVER·제주도 표준 배포분에 의도적으로 포함된 근거.
영문 문서의 "Hangeul + Latin only" 기술은 실제 폰트 바이너리와 다르며,
**v1.1.0의 "코어 5종 모두 CJK 완전 지원" 주장은 실측으로 재확인됨**.

**조치**:

- **`scripts/verify_cjk_support.py` 신규 추가** — 위 실측 절차를 재현
  가능하게 도구화. 인자 없이 실행하면 스킬 디렉터리 자동 탐색, 상세
  리포트 출력. 옵션:
  - `--json` — 빌드 스크립트용 기계 판독 출력
  - `--strict` — 미지원 폰트 발견 시 exit code 2 반환 (CI/CD용)
- **`build_core_from_fullpack.{sh,ps1}` 빌드 전 자동 검증 추가** —
  기본 활성. 스킬 철학 한자가 하나라도 빠진 코어가 감지되면 빌드 중단.
  강제 진행 시 `--no-verify-cjk` (bash) 또는 `-NoVerifyCjk` (PowerShell).
- **GitHub Actions 워크플로우에 "Verify CJK support (fail fast)"
  스텝 추가** — 태그 푸시 시 저장소의 코어 폰트가 실측 검증을
  통과해야만 이후 ZIP 빌드로 진행.

**교훈**: 폰트 지원 여부는 영문 설명이나 한국어 소개 페이지보다
**바이너리 cmap 실측**이 신뢰할 수 있다. 공식 문서는 "원래 설계 의도"를
서술하는 반면 실제 파일에는 KS 완성형 한자가 포함된 경우가 많다.
향후 코어 교체·확장 시에도 `verify_cjk_support.py --strict` 선행 필수.

---

### Breaking Change — 코어 폰트 구성 파괴적 재설계 (마이너 버전업)

**문제**: v1.0.x 코어 24종은 모두 Google Fonts 배포 서브셋 바이너리라
**CJK 한자를 원천 미지원**이었다. 스킬의 핵심 철학 이름
(`餘白·丹靑·縫補·古調·餘湍`)을 렌더링하려 해도 □로 출력되는 아이러니
가 지속됐다.

v1.0.x의 대응은 "한자가 필요하면 풀 폰트팩을 설치하라"는 안내였으나:

- Claude Desktop은 ZIP 업로드만 지원, 풀팩 인스톨러 실행 불가
- claude.ai 웹도 동일 — 스크립트 실행 권한 없음
- **Desktop/claude.ai 사용자는 한자 기능을 영구적으로 사용할 수 없었다**
- Claude Desktop↔CLI 스킬 폴더 공유는 공식 지원되지 않음이 재확인됨
  (`claude_desktop_config.json`은 MCP 설정용, 스킬 경로 설정 불가)

**근본 해결**: 코어 자체가 CJK를 완전 지원해야 Desktop/claude.ai
사용자도 한자 기능을 쓸 수 있다. 이를 위해 **코어 구성을 파괴적으로
재설계**한다.

### Breaking — 코어 구성 (24종 → 5종, ~28.5 MB)

| 신규 코어 | 크기 | CJK 지원 |
| --- | --- | --- |
| `NotoSansKR-VF.ttf` | 9.93 MB | ✅ 8,566자 (한·영·한자 통합 가변 폰트) |
| `NanumMyeongjo-OldHangul.ttf` | 9.25 MB | ✅ 5,005자 (명조 + 옛한글 + 한문) |
| `NanumBrushScript-Regular.ttf` | 3.66 MB | ✅ 4,888자 (붓글씨 캘리) |
| `NanumPenScript-Regular.ttf` | 3.47 MB | ✅ 4,888자 (펜글씨) |
| `JejuGothic-Regular.ttf` | 2.42 MB | ✅ 4,888자 (향토 디스플레이) |

**합계 ~28.5 MB** — Claude Desktop 30 MB 비압축 한도 내.

### Removed (풀팩으로 이동) — 24종

v1.0.x 코어 전체가 풀팩으로 이동:

- Pretendard (Regular/Bold/Black)
- NanumSquare Regular/Bold
- NanumSquareRound Regular/Bold
- NanumSquareNeo Regular/Bold
- NanumHuman Light/Regular/Bold
- NanumGothic-Light
- NanumMyeongjo-Regular
- BlackHanSans, DoHyeon, Sunflower-Bold
- WorkSans Regular/Bold
- Lora, Italiana, BigShoulders-Bold
- InstrumentSerif, JetBrainsMono

### 실측 근거

v1.0.7에서 "CJK 한자 지원 폰트" 표 파일명을 실제와 일치시키는 작업이
있었음. 실측 결과:

- `NotoSansKR-VF.ttf` / `NotoSerifKR[wght].ttf` (실제 파일명, Google
  Fonts 표준 가변 폰트 네이밍)
- `NanumMyeongjo-Bold/Regular` (풀팩 포함): **서브셋이라 한자 0/8 미지원**
- `NanumMyeongjo-OldHangul`: 명조 계열 한자 **8/8 완전 지원**

### Added

#### `scripts/build_core_from_fullpack.ps1` + `.sh` (신규)

유지보수자가 로컬 풀팩(`assets/fonts/` 129종)에서 5종만 추출하여 새
코어 ZIP을 빌드하기 위한 스크립트.

```bash
bash scripts/build_core_from_fullpack.sh --output canvas-design-kr-v1.1.0.zip
```

```powershell
.\scripts\build_core_from_fullpack.ps1 -Output canvas-design-kr-v1.1.0.zip
```

- 5종 폰트만 추출
- SKILL.md, README.md, changelog.md, LICENSE, NOTICE 포함
- `scripts/discover_fonts.py`, `scripts/install_full_fonts.*`,
  `scripts/build_full_pack.*` 포함
- `assets/fonts/MANIFEST.txt` 자동 재생성
- 대응하는 `*-OFL.txt` 라이선스 파일 포함

#### `scripts/build_full_pack.ps1` + `.sh` (신규)

유지보수자가 로컬 풀팩(`assets/fonts/` 129종)에서 v1.1.0 코어 5종을
제외한 **124종 + OFL 라이선스 전체**를 추출해 GitHub Release에 올릴
풀팩 ZIP을 빌드하는 스크립트.

```bash
bash scripts/build_full_pack.sh --output canvas-design-kr-fonts-full-v1.1.0.zip
```

```powershell
.\scripts\build_full_pack.ps1 -Output canvas-design-kr-fonts-full-v1.1.0.zip
```

- `install_full_fonts.sh/.ps1`이 다운로드·압축 해제할 수 있는 구조
  (최상위 `fonts/` 하위에 TTF/OTF/OFL 배치)
- 대괄호 파일명(`NotoSansKR-VF.ttf`) 안전 처리 (`-LiteralPath` /
  NUL 구분자 `find -print0`)
- 소스에 폰트가 100종 미만이면 빌드 거부 (풀팩 미설치 감지)

#### RULE 1 (SKILL.md)

"코어에서 이미 한자 지원" 명시. v1.0.x의 "한자 사용 시 풀팩 필요"
경고는 모두 삭제. `pick_cjk_font()` 헬퍼 함수 추가.

#### 환경 감지 섹션 (SKILL.md)

3가지 실행 환경(Claude Code / Desktop / claude.ai 웹)을 구분해 스크립
트 실행 가능 여부와 권장 접근법을 명시.

### Changed

- **SKILL.md 전면 개편**:
  - description: v1.1.0 코어 5종 기준으로 재작성, CJK 완전 지원 강조
  - RULE 0: 환경 감지 + 방법 A(스크립트)/B(인라인) 분리
  - RULE 1: "코어에서 이미 한자 지원" 신설, 풀팩 필요 경고 삭제
  - 코어 매니페스트 표: 5종 전체 CJK ✅
  - `pick_cjk_font()` 함수: NotoSansKR → OldHangul → JejuGothic → Brush → Pen
  - 풀팩 폴백 매핑 표 전면 개편 (24종 제거된 폰트 → 코어 대체 경로)
  - 철학 예시(餘白, 丹靑, 古調): 폰트 참조를 v1.1.0 코어 기준으로 변경

- **README.md 전면 개편**:
  - `claude_desktop_config.json` 관련 내용 전부 삭제 (근거 없음 확인)
  - 3가지 환경별 설치 방법을 별도 섹션으로 분리
  - Claude Code / Claude Desktop / claude.ai 웹 각각 정확히 기술
  - v1.0.x → v1.1.0 마이그레이션 표 추가 (파일명 치환 가이드)
  - 풀팩 설치는 Claude Code 전용임을 명시

- **`assets/fonts/MANIFEST.txt`**: 5종으로 재작성
- **`scripts/discover_fonts.py`**:
  - PACK 판정 기준 조정: `core` = 5, `full` ≥ 100
  - `incomplete` 경계: `1 ≤ n < 5`
- **`scripts/install_full_fonts.ps1`**: 기본 `$Version` v1.0.5 → v1.1.0
- **`scripts/install_full_fonts.sh`**: `DEFAULT_VERSION` v1.0.5 → v1.1.0
- `metadata.version`: 1.0.7 → 1.1.0 (파괴적 변경으로 마이너 버전업)
- `metadata.updated`: 2026-04-19

### Migration from v1.0.x to v1.1.0

v1.0.x에서 생성된 Python 디자인 코드는 **v1.1.0에서 거의 모두 실패**한
다. 다음 폰트 파일명 치환이 필요:

| v1.0.x | v1.1.0 |
| --- | --- |
| `Pretendard-*.otf` | `NotoSansKR-VF.ttf` + variation (weight) |
| `NanumSquare-*.ttf`, `NanumSquareRound/Neo-*` | `NotoSansKR-VF.ttf` |
| `NanumGothic-Light.ttf` | `NotoSansKR-VF.ttf` (weight=300) |
| `NanumMyeongjo-Regular.ttf` | `NanumMyeongjo-OldHangul.ttf` |
| `BlackHanSans / DoHyeon-Regular.ttf` | `NotoSansKR-VF.ttf` (weight=900) |
| `Sunflower-Bold.ttf` | `JejuGothic-Regular.ttf` |
| `NanumHuman-*.ttf` | `NotoSansKR-VF.ttf` |
| `WorkSans / Lora / Italiana / BigShoulders / InstrumentSerif / JetBrainsMono` | 풀팩 필요, 또는 `NotoSansKR` 라틴 활용 |

**NotoSansKR 가변 폰트 사용 예**:

```python
font = ImageFont.truetype(os.path.join(FONT_DIR, "NotoSansKR-VF.ttf"), 64)
try:
    font.set_variation_by_axes([700])   # Bold
except AttributeError:
    pass  # PIL 10.0 이하는 기본 weight
```

**설치 절차**:

1. **Claude Code 사용자**: 기존 `~/.claude/skills/canvas-design-kr/`
   디렉터리를 백업 후 v1.1.0으로 교체. 풀팩이 필요하면 재설치.
2. **Claude Desktop 사용자**: 기존 스킬 제거 후 v1.1.0 ZIP 재업로드.
   이제 `餘白` 등 한자 철학명이 즉시 렌더링됨.
3. **claude.ai 웹 사용자**: Desktop과 동일 절차.

**가장 큰 이득**: Desktop/claude.ai 웹 사용자에게 한자 기능이 처음 열림.

---

## [1.0.7] — 2026-04-18

### Fixed — "CJK 한자 지원 폰트" 표 파일명 실측 일치

**문제**: SKILL.md의 CJK 지원 폰트 안내에서 가변 폰트 파일명이 잘못
기재되어 있었음. Google Fonts의 variable font 원본 배포 네이밍은
대괄호(`[wght]`) 접미사를 사용한다.

**수정 (v1.0.7 당시)**:

- `NotoSansKR-Variable.ttf` → `NotoSansKR[wght].ttf`
- `NotoSerifKR-Variable.ttf` → `NotoSerifKR[wght].ttf`
- CJK 지원 실측 결과 기재:
  - `NotoSansKR[wght]` (당시 파일명): 8,566자 지원 (실측 8/8)
  - `NanumMyeongjo-OldHangul`: 5,005자 지원 (실측 8/8)
  - `NanumMyeongjo-Regular/Bold` (서브셋): 0/8 미지원

> **후속 참고**: v1.1.0에서 이 파일명은 Claude Desktop ZIP 검증기가
> 대괄호를 거부하는 문제로 **`NotoSansKR-VF.ttf`** 로 다시 변경됨.
> 상세는 v1.1.0 "Build / Packaging Fix" 섹션 참고.

### Changed — Metadata

- `metadata.version`: 1.0.6 → 1.0.7
- `metadata.updated`: 2026-04-18

---

## [1.0.6] — 2026-04-17

### Added — CJK 한자 지원 폰트 가이드

풀팩 설치 후 한자 디자인이 필요한 사용자를 위한 가이드 섹션 추가. 어떤
폰트가 실제로 CJK 한자를 지원하는지 표로 정리. (v1.0.7에서 파일명 실측
일치 수정 수행.)

### Changed — Metadata (v1.0.6)

- `metadata.version`: 1.0.5 → 1.0.6
- `metadata.updated`: 2026-04-17

---

## [1.0.5] — 2026-04-17

### Fixed — 풀팩 설치 후에도 Claude가 폰트를 인식 못 함 (P0, 재발)

**문제**: v1.0.4에서 SKILL.md의 `find_skill_root()` 함수와 절대경로
변수(`FONT_DIR`)를 강제하도록 수정했음에도, 사용자가 풀팩을 설치하고
Claude를 완전히 재시작한 뒤에도 **여전히 폰트 인식 실패**. Claude가
"폰트를 다른데서 찾는다"고 보고.

**근본 원인**: SKILL.md에 코드를 적어두는 것만으로는 부족했음.

- 스킬 시스템은 progressive disclosure 방식 — `assets/`는 명시적으로
  접근하지 않으면 Claude의 컨텍스트에 들어오지 않는다
- Claude가 SKILL.md의 STEP 0 코드를 매 호출마다 실행하리라는 보장이 없다
- 코드를 실행해도 후속 폰트 사용에서 변수를 일관되게 적용하지 않을 수 있다
- `find_skill_root()` 함수 정의가 SKILL.md 본문 깊숙이 묻혀 있어
  Claude가 건너뛰기 쉬웠다

**해결 — 4중 안전장치**:

1. **⛔ RULE 0** — SKILL.md 본문 시작 직전에 가장 강한 시각적 경고 박스로
   "다른 어떤 작업보다 먼저 폰트 디렉터리를 확인하라" 강제. 박스 안에
   디스커버리 명령(스크립트 실행)과 인라인 코드(스크립트 실행 어려울 때)
   두 방식을 모두 제공.

2. **`scripts/discover_fonts.py` 신규 스크립트** — 단일 명령으로 SKILL_ROOT,
   FONT_DIR 절대경로와 사용 가능한 폰트 파일 목록 전체, Python 사용 예시까지
   출력. `--json`, `--paths`, `--check` 모드 지원. 스크립트 자기 위치를
   1순위 후보로 사용하므로 어떤 환경에서도 정확히 작동.

3. **코어 24종 인라인 매니페스트** — SKILL.md 본문에 코어 폰트 24종의
   정확한 파일명 표를 직접 임베드. Claude가 코드 실행 없이도 SKILL.md
   텍스트로부터 정확한 파일명을 알 수 있도록.

4. **`assets/fonts/MANIFEST.txt` 평문 매니페스트** — 폰트 디렉터리에
   동봉된 평문 파일 목록. 인스톨러가 풀팩 설치 후 자동 갱신하므로
   풀팩 설치 후 정확한 파일명 목록이 항상 디스크에 존재.

### Added — 스크립트 및 매니페스트 (v1.0.5)

- **`scripts/discover_fonts.py`** — 폰트 디스커버리 통합 스크립트
  - 6개 표준 경로 후보 자동 탐색 (스크립트 자체 위치 1순위)
  - 사람 친화적 / JSON / KEY=VALUE / Check 4가지 출력 모드
  - exit code로 검증: 0=정상, 1=루트 못 찾음, 2=폰트 부족
- **`assets/fonts/MANIFEST.txt`** — 폰트 파일 목록 평문 매니페스트
  - `core:filename` 또는 `full:filename` 형식
  - 인스톨러가 풀팩 설치 후 자동 갱신
- **SKILL.md 코어 24종 매니페스트 표** — 본문에 정확한 파일명 인라인 임베드

### Changed — 구조 및 인스톨러 (v1.0.5)

- **SKILL.md 구조**: 기존 STEP 0(긴 코드 블록)를 RULE 0(시각적 강제 박스)로
  격상. 폴백 매핑 표만 STEP 0 보강 섹션으로 분리.
- **DOWNLOAD AND USE FONTS 섹션 단순화** — 모든 폰트 사용은 RULE 0의
  `FONT_DIR`을 사용하라고 안내.
- **인스톨러 두 종**: 풀팩 설치 완료 후 `MANIFEST.txt` 자동 갱신 로직 추가
  (PowerShell · bash 동일 동작).
- `metadata.version`: 1.0.4 → 1.0.5
- `metadata.updated`: 2026-04-17
- `install_full_fonts.ps1` 기본 `$Version`: v1.0.4 → v1.0.5
- `install_full_fonts.sh` `DEFAULT_VERSION`: v1.0.4 → v1.0.5

### Migration from v1.0.4 to v1.0.5

1. 5개 파일 + 신규 2개 파일 덮어쓰기:
   - `SKILL.md` (재구성)
   - `changelog.md`, `README.md`
   - `scripts/install_full_fonts.ps1`, `scripts/install_full_fonts.sh`
   - **신규**: `scripts/discover_fonts.py`
   - **신규**: `assets/fonts/MANIFEST.txt`
2. Claude를 완전히 재시작 (Claude Desktop 종료 후 재실행)
3. 검증: 한국적 디자인 짧은 테스트 ("'無爲' 餘白 스타일")로 한글 정상 출력 확인
4. 풀팩 사용자는 인스톨러를 한 번 더 실행해 MANIFEST.txt 갱신
   (`-Check` 옵션으로는 갱신 안 됨, 실제 설치 필요)

---

## [1.0.4] — 2026-04-17

### Fixed — 폰트 인식 실패로 인한 한글 누락 (P0, 가장 심각)

**문제**: 코어 폰트 24종이 `assets/fonts/`에 정상 설치되어 있음에도
스킬이 실제 결과물을 만들 때 폰트를 인식하지 못해 시스템 기본 폰트로
**조용히 폴백**하고, 한글이 □ 또는 빈칸으로 출력됨.

**근본 원인**: SKILL.md가 잘못된 폰트 경로 패턴을 명시적으로 가르치고 있었음.

- **STEP 0** (`os.path.dirname(__file__)`):
  Claude가 SKILL.md의 코드 블록을 `exec()` 방식으로 실행할 때
  `__file__`이 정의되지 않거나 임의 경로(`<stdin>` 등)를 가리킴.
- **Vertical writing 코드 예시** (`./assets/fonts/NanumMyeongjo-Regular.ttf`):
  명시적 상대경로. Claude의 작업 디렉터리(`/home/claude` 또는 사용자 폴더)에
  `assets/fonts/`가 없으므로 100% 실패.
- **DOWNLOAD AND USE FONTS 섹션**: "Reference them by relative path" 라고
  명시적으로 잘못된 패턴을 권장하고 있었음. 이것이 가장 직접적 원인.

PIL의 `ImageFont.truetype()`은 파일이 없으면 `OSError`를 던지지만, 일부
환경에서는 경고 없이 시스템 기본 폰트로 폴백되어 사용자가 원인을 알기
어려움. 사용자 보고: 코어 폰트가 디스크에 분명히 존재하나 결과물에서
한글이 깨짐.

**해결**:

- **STEP 0 전면 재작성**: `find_skill_root()` 함수로 환경별 표준 경로
  후보(Claude.ai `/mnt/skills/user/`, Claude Desktop/Code `~/.claude/skills/`,
  Windows `%USERPROFILE%\.claude\skills\`, 프로젝트 `.claude/skills/`,
  환경변수 `CANVAS_DESIGN_KR_ROOT`)를 순회하여 최초 일치 경로 반환.
  `SKILL_ROOT`와 `FONT_DIR`을 절대경로 변수로 확정.
- **모든 폰트 사용 예시를 `os.path.join(FONT_DIR, "<filename>")` 형식으로 통일**.
- **상대경로 사용 명시적 금지** — STEP 0과 DOWNLOAD AND USE FONTS 섹션에
  ❌ 패턴과 그 결과(한글 누락)를 명시. "Use distinct fonts" 한 줄 안내도
  `FONT_DIR` 명시로 보강.

### Changed — Metadata (v1.0.4)

- `metadata.version`: 1.0.3 → 1.0.4
- `metadata.updated`: 2026-04-17
- `install_full_fonts.ps1` 기본 `$Version`: v1.0.3 → v1.0.4
- `install_full_fonts.sh` `DEFAULT_VERSION`: **v1.0.2 → v1.0.4**
  (v1.0.3에서 누락되었던 동기화 보완)

### Migration from v1.0.3 to v1.0.4

- SKILL.md 교체만으로 즉시 적용 가능 — 폰트 파일 변경 없음
- 인스톨러 두 종도 함께 갱신 (기본 버전 정렬)
- v1.0.3 이전 버전을 사용하던 사용자는 결과물에서 한글 누락이 사라짐을 확인

---

## [1.0.3] — 2026-04-17

### Fixed — `install_full_fonts.ps1` 침묵 실패 (P0)

**문제**: PowerShell 인스톨러가 `✓ 완료`를 보고하지만 실제로는 단 한 개의
폰트도 복사되지 않는 침묵 실패. 사용자 보고:

```text
현재 설치된 폰트: 0 개
...
✓ 완료
  새로 설치: 0 개 파일
  이미 존재(스킵): 0 개 파일
  현재 폰트 총 개수: 0 → 0
```

**원인**: `Get-ChildItem $dir -File -Include *.ttf,*.otf` 패턴은
PowerShell의 알려진 함정. **경로에 와일드카드(`\*`)나 `-Recurse`가 없으면
`-Include` 매개변수가 조용히 무시되어 항상 빈 결과를 반환한다.**
이로 인해:

- 설치 전 코어 폰트 카운트(40·47번 줄): 24종이 있어도 0으로 보고
- 복사 루프(117번 줄): **단 한 회도 실행되지 않음** — 풀팩 ZIP은
  정상 다운로드·압축 해제되었으나 `assets/fonts/`로 옮겨지지 않음
- 설치 후 카운트(128번 줄): 동일 함정으로 항상 0

bash 인스톨러는 `find` 기반이라 동일 버그 없음.

**해결**:

- 헬퍼 함수 `Get-FontFiles` 도입 — `Where-Object { $Extensions -contains $_.Extension }`
  패턴으로 `-Include` 함정을 완전히 우회
- 카운트·목록·복사 루프 4곳 모두 새 패턴으로 교체
- 압축 파일 내 폰트 탐색은 `-Recurse`가 동반되므로 `-Include` 그대로 사용 가능

### Added — 인스톨러 검증 강화

침묵 실패를 방지하기 위한 추가 검증:

- **다운로드 후 ZIP 크기 검증** — 1 MB 미만이면 GitHub Release 부재 또는
  HTML 리다이렉트 페이지로 간주하고 즉시 실패
- **압축 해제 후 폰트 카운트 검증** — 소스 디렉토리에 폰트가 0개면 실패
- **다운로드 예외 메시지 노출** — `$_.Exception.Message` 출력
- **복사 결과 0/0 경고** — 설치/스킵 모두 0이면 경고 메시지 출력
- **`-Check` 모드 0개 경고** — 코어조차 발견되지 않으면 스킬 설치 자체가
  불완전할 수 있음을 안내

### Changed — Metadata (v1.0.3)

- 인스톨러 기본 `$Version`: `v1.0.2` → `v1.0.3`
- `metadata.version`: 1.0.2 → 1.0.3
- `metadata.updated`: 2026-04-17

### Migration from v1.0.2 to v1.0.3

- v1.0.2의 `install_full_fonts.ps1`은 사용 불가 — v1.0.3 스크립트로 교체 후 재실행
- bash 사용자(Linux/macOS/NAS)는 영향 없음
- v1.0.2에서 풀팩 설치를 시도했던 Windows 사용자는 `assets/fonts/`에
  코어 24종만 있는 상태 — v1.0.3 인스톨러로 풀팩 재설치 필요

---

## [1.0.2] — 2026-04-17

### Fixed — Claude Desktop 30 MB Uncompressed Size Limit

**문제**: v1.0.1의 슬림 코어 ZIP은 압축 후 ~18 MB로 목표에 부합했으나,
**압축 해제 후 크기가 ~41.6 MB**로 Claude Desktop의 30 MB 비압축 스킬
한도를 초과하여 등록 불가.

**해결**: 코어 폰트를 28종(한글) + 7종(영문) = 35종에서
**17종(한글) + 7종(영문) = 24종**으로 축소. 압축 해제 크기 ~23.4 MB로
안전 마진 확보.

### Removed (Moved to Full Pack)

#### 중복 Weight 감축

- Pretendard: Light/Medium 제거 → Regular/Bold/Black 유지 (3종)
- NanumSquare: Light/ExtraBold 제거 → Regular/Bold 유지 (2종)
- NanumSquareRound: Light/ExtraBold 제거 → Regular/Bold 유지 (2종)
- NanumSquareNeo: ExtraBold 제거 → Regular/Bold 유지 (2종)

#### 특수 디스플레이·향토·캘리 폰트 → 풀팩 이동

- **NanumBrushScript** (붓글씨 캘리그래피) — 코어에 캘리 폰트 없음
- **Jua-Regular** (주아체) — BlackHanSans/DoHyeon으로 대체 가능
- **SongMyung-Regular** (송명) — NanumMyeongjo로 대체 가능
- **JejuGothic-Regular** (제주고딕) — NanumGothic-Light로 대체 가능

### Changed — SKILL.md (v1.0.2)

- **description**: "한글 28종 + 영문 7종" → "한글 17종 + 영문 7종",
  "풀팩 94종" → "풀팩 105종"
- **폴백 매핑 표**: 제거된 폰트에 대한 대체 안내 추가
  - Jua/YeonSung 등 → BlackHanSans/DoHyeon/Sunflower-Bold
  - SongMyung/JejuMyeongjo → NanumMyeongjo-Regular
  - NanumBrushScript/NanumPenScript → **풀팩 필수** 명시
  - Pretendard Light/Medium → Pretendard-Regular
  - NanumSquare/Round/Neo 추가 weight → R/B로 통합
- **Core font selection guide**: 24종 기준 재작성
- **Calligraphy 섹션**: 코어에 캘리 없음을 명시하고 풀팩 설치 유도

### Changed — Documentation (v1.0.2)

- `README.md`: 코어 폰트 목록 24종으로 재작성, ZIP 크기 ~22 MB → ~14 MB
- `NOTICE.txt`: v1.0.2 아키텍처 노트 추가, 코어 폰트 목록 재작성,
  풀팩 전용 폰트 항목 명시

### Migration from v1.0.1 to v1.0.2

기존 v1.0.1 사용자:

1. 기존 `canvas-design-kr/` 디렉토리 백업 또는 삭제
2. v1.0.2 슬림 코어 설치
3. **캘리그래피/디스플레이 다양성이 필요하면 풀팩 필수 설치**:
   `bash scripts/install_full_fonts.sh` (풀팩에 제거된 11종 모두 포함)
4. 기존 PIL 코드에서 제거된 폰트를 참조하는 부분은 풀팩 설치 또는 대체 폰트로 수정

### Architecture Change — Slim Core + Optional Full Font Pack

**문제**: 초기 상태의 ZIP은 ~116 MB로, Claude Desktop의 30 MB 스킬 등록 한도를 초과하여 등록 불가.

**해결**: 폰트를 두 단계로 분리.

- **슬림 코어** (~22 MB ZIP) — 35종 핵심 폰트만 번들 → Claude Desktop 직접 등록 가능
- **풀 폰트팩** (~110 MB ZIP) — 나머지 94종 → GitHub Release Asset, 자동 다운로드 스크립트로 설치

이로써 Claude Desktop·Claude.ai·Cowork·Claude Code 모든 환경에서 사용 가능.

### Added — 아키텍처 및 스크립트 (v1.0.2)

#### Slim Core (35 fonts)

**한글 코어 (28종)** — 가장 가볍고 다양한 조합:

- Pretendard (Light/Regular/Medium/Bold/Black) — 한·영 통합 만능 본문
- NanumSquare 4 weights — 한자 포함, 가벼움
- NanumSquareRound 4 weights — 친근한 라운드
- NanumSquareNeo Regular/Bold/ExtraBold — 가장 모던
- NanumHuman Light/Regular/Bold — 휴머니스트
- NanumGothic-Light, NanumMyeongjo-Regular — 클래식 본문
- BlackHanSans, DoHyeon, Jua — 디스플레이 임팩트
- NanumBrushScript — 캘리그래피
- JejuGothic, SongMyung, Sunflower-Bold — 디스플레이/향토

**영문 코어 (7종)** — Pretendard로 한·영 통합 가능하므로 진짜 디스플레이용만:

- WorkSans Regular/Bold, Lora Regular
- Italiana, BigShoulders Bold, InstrumentSerif, JetBrainsMono

#### Full Font Pack (94 additional fonts, separate distribution)

풀팩 ZIP에 포함:

- NanumGothic Regular/Bold/ExtraBold + Eco 시리즈 3종
- NanumMyeongjo Bold/ExtraBold + Eco 시리즈 3종 + OldHangul
- NanumBarunGothic 4 weights + OldHangul
- NanumBarunpen Regular/Bold + NanumPenScript
- NanumSquareNeo Light/Heavy + Variable
- NanumHuman ExtraLight/ExtraBold/Heavy
- NotoSansKR Variable + NotoSerifKR Variable
- GowunBatang Regular/Bold + GowunDodum
- JejuMyeongjo + JejuHallasan
- D2Coding Regular/Bold + 영문 30+ 종
- Gaegu/PoorStory/EastSeaDokdo/CuteFont/BlackAndWhitePicture/YeonSung/Hahmlet/Diphylleia
- 모든 폰트의 SIL OFL 라이선스 파일 50개

#### NAVER Nanum Full Family Integration

초기 Google Fonts 배포 서브셋을 NAVER 공식 나눔글꼴 패키지(한글한글 아름답게) 전체로 교체하여
NanumGothicEco, NanumMyeongjoEco, NanumBarunGothic/Barunpen, NanumSquare 4종, NanumSquareRound 4종,
NanumSquareNeo 5종, NanumHuman 6종 등 공식 바이너리로 확장.

#### Distribution Scripts

- `scripts/install_full_fonts.sh` — Linux/macOS/NAS bash installer
  - GitHub Release에서 풀팩 자동 다운로드
  - `--check` 옵션: 현재 설치된 폰트 확인만
  - `--version` 옵션: 특정 버전 강제 지정
  - 환경변수 `CANVAS_DESIGN_KR_FONT_PACK_URL` / `CANVAS_DESIGN_KR_INSTALL_DIR` 지원
  - 멱등성: 이미 설치된 풀팩 감지 후 재설치 확인
- `scripts/install_full_fonts.ps1` — Windows PowerShell installer
  - 동일 기능, Invoke-WebRequest + Expand-Archive 사용
  - PowerShell 5.1+ 호환

#### Distribution Infrastructure

- `.gitattributes`, `.gitignore`, `.github/workflows/release.yml`

### Changed — SKILL.md (v1.0.2 Slim Core)

- **STEP 0 (NEW)** — 동적 폰트 탐색 단계 추가 (코어 vs 풀팩 자동 인식)
- **코어 → 풀팩 폴백 매핑 표** — 요청 폰트가 코어에 없을 때 즉시 대체 폰트 안내
- **assets/fonts/** 경로로 통일 (skill-creator 표준 디렉토리 명칭 채택)
- 폰트 매핑 가이드를 코어 35종 기준으로 재작성, 풀팩 폰트는 폴백 표로 분리
- description에 "코어 즉시 사용 + 풀팩 확장" 명시

### Changed — Metadata/Structure (v1.0.2)

- 프론트매터 최상위 `version` → `metadata.version`으로 이동
  (Anthropic 공식 스킬 검증 스크립트 호환)
- `changelog.md` 위치를 `references/` 에서 루트로 이동
- `metadata.updated`: 2026-04-17

### Changed — Documentation (v1.0.2 Initial)

- `README.md` — 슬림/풀팩 아키텍처 설명, 설치 절차 두 단계로 분리
- `NOTICE.txt` — 아키텍처 변경 명시, 코어/풀팩 폰트 목록 분리
- `changelog.md` — 본 문서 (루트 배치)

---

## [1.0.0] — 2026-04-16

### Initial Release

Forked from `anthropic/canvas-design` (Apache License 2.0) and extended for
Korean aesthetics and Hangul typography.

#### Added — Initial Content

- 27 Korean OFL fonts (Pretendard, Nanum subset, Noto CJK, Gowun, Woowahan,
  Jeju, etc.)
- 5 Korean aesthetic philosophies: 餘白, 丹靑, 縫補, 古調, 餘湍
- Hangul typography rules + Korean color systems (오방색, 자연 염색)
- Apache 2.0 attribution, NOTICE.txt, README.md, changelog.md

#### Retained — From canvas-design

- All 35 original Latin typefaces from canvas-design
- Original 5 design philosophies (Concrete Poetry, Chromatic Language,
  Analog Meditation, Organic Systems, Geometric Silence)
- Two-step workflow (Philosophy → Canvas)
