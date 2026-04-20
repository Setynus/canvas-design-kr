# canvas-design-kr

한국적 미학(餘白·丹靑·縫補·古調·餘湍)과 현대 K-디자인을 시각 철학으로 표현하는 Claude Skill.

**Version**: 1.1.0 (CJK-Complete Core + Optional Full Pack)
**Created**: 2026-04-16
**Updated**: 2026-04-19
**Author**: Kwangho Kim
**License**: Apache License 2.0 (skill code) / SIL OFL 1.1 (fonts)
**Based on**: [anthropics/skills — canvas-design](https://github.com/anthropics/skills) (Apache 2.0)

---

## v1.1.0 — 코어 재설계 (Breaking Change)

**v1.1.0은 코어 폰트 구성을 파괴적으로 변경한 마이너 버전 업그레이드입니다.** 이전 코어 24종은 모두 Google Fonts 서브셋 바이너리라 CJK 한자를 원천 미지원이었으며, 스킬의 철학 이름(`餘白·丹靑·縫補·古調·餘湍`)조차 □로 출력되는 아이러니가 있었습니다.

### 구 v1.0.x 코어 (24종) → 신 v1.1.0 코어 (5종)

| 구분 | v1.0.x | v1.1.0 |
|---|---|---|
| 코어 폰트 수 | 24종 | 5종 |
| 코어 용량 | ~23 MB | ~28.5 MB |
| CJK 한자 지원 | ❌ 0/24 | ✅ 5/5 |
| Desktop 30MB 한도 | ✅ | ✅ |
| `餘白` 즉시 렌더링 | ❌ (풀팩 설치 필요) | ✅ |

### 새 코어 5종

| 파일명 | 크기 | 용도 | CJK |
|---|---|---|---|
| `NotoSansKR-VF.ttf` | 9.93 MB | 가변 산세리프 (모든 weight) | ✅ 8,566자 |
| `NanumMyeongjo-OldHangul.ttf` | 9.25 MB | 명조 + 옛한글 + 한문 | ✅ 5,005자 |
| `NanumBrushScript-Regular.ttf` | 3.66 MB | 붓글씨 캘리그래피 | ✅ 4,888자 |
| `NanumPenScript-Regular.ttf` | 3.47 MB | 펜글씨 | ✅ 4,888자 |
| `JejuGothic-Regular.ttf` | 2.42 MB | 향토 디스플레이 | ✅ 4,888자 |

**합계 ~28.5 MB** — Claude Desktop의 30 MB 비압축 스킬 한도 내에 안전 수납.

### 제거된 폰트 (풀팩으로 이동)

Pretendard(3종), NanumSquare(2종), NanumSquareRound(2종), NanumSquareNeo(2종), NanumGothic-Light, NanumMyeongjo-Regular, NanumHuman(3종), BlackHanSans, DoHyeon, Sunflower-Bold, WorkSans(2종), Lora, Italiana, BigShoulders, InstrumentSerif, JetBrainsMono — 총 24종.

모두 **풀 폰트팩(124종)에서 계속 사용 가능**. Claude Code 환경에서 `bash scripts/install_full_fonts.sh`로 설치.

---

## 환경별 설치 방법 (3가지 환경)

Claude 스킬은 실행 환경에 따라 설치 방법이 다릅니다. Claude Desktop↔CLI 스킬 폴더 공유는 공식 지원되지 않으므로, 각 환경별로 별도 설치해야 합니다.

### 1. Claude Code (CLI) — 디렉터리 배치

```bash
# Linux / macOS / WSL
unzip canvas-design-kr-v1.1.0.zip -d ~/.claude/skills/
# 또는 NAS 환경
unzip canvas-design-kr-v1.1.0.zip -d /volume1/claude/skills/
```

```powershell
# Windows PowerShell
Expand-Archive canvas-design-kr-v1.1.0.zip -DestinationPath "$env:USERPROFILE\.claude\skills\"
```

Claude Code는 `~/.claude/skills/` 하위 디렉터리를 자동 감시하므로 별도 등록 절차가 없습니다.

### 2. Claude Desktop — ZIP 업로드

```
설정 → Skills → "Add Skill" 또는 "Upload Skill"
→ canvas-design-kr-v1.1.0.zip 파일 선택
```

Claude Desktop은 업로드된 ZIP을 내부 저장소로 복사하여 **스냅샷**만 사용합니다. 업로드 후 원본 ZIP을 수정해도 반영되지 않으며, 업데이트하려면 새 ZIP을 다시 업로드해야 합니다.

> **참고**: `claude_desktop_config.json`은 MCP 서버 설정용이며, 스킬 경로를 여기에 추가한다고 인식되지 않습니다. 공식 지원 방법은 ZIP 업로드뿐입니다.

### 3. claude.ai 웹 — ZIP 업로드

```
설정 → Skills → "Add Skill" 또는 "Upload Skill"
→ canvas-design-kr-v1.1.0.zip 파일 선택
```

Desktop과 동일하게 내부 저장소 스냅샷을 사용합니다.

---

## 풀 폰트팩 설치 (선택, Claude Code 전용)

Pretendard, NanumSquare 시리즈, NanumGothic 풀세트, 에코 패턴, 고운글꼴, 제주글꼴 풀세트, Noto CJK Variable, WorkSans·Lora 등 영문 코어 등 **124종 추가 폰트**가 필요하면 풀팩을 설치합니다.

```bash
# Linux / macOS / Synology NAS / WSL
cd ~/.claude/skills/canvas-design-kr/
bash scripts/install_full_fonts.sh

# Windows (PowerShell)
cd "$env:USERPROFILE\.claude\skills\canvas-design-kr"
.\scripts\install_full_fonts.ps1
```

**상태 확인:**
```bash
bash scripts/install_full_fonts.sh --check       # Linux/macOS
.\scripts\install_full_fonts.ps1 -Check          # Windows
```

**폰트 디스커버리 (Claude가 폰트를 못 찾을 때 디버깅용):**
```bash
python3 scripts/discover_fonts.py
python3 scripts/discover_fonts.py --json     # JSON 출력
python3 scripts/discover_fonts.py --paths    # KEY=VALUE 출력
```

**CJK 한자 지원 실측 (폰트 추가·교체 시 검증):**
```bash
pip install fonttools --break-system-packages   # 최초 1회
python3 scripts/verify_cjk_support.py                     # 스킬 디렉터리 자동 탐색
python3 scripts/verify_cjk_support.py <font_dir>          # 경로 명시
python3 scripts/verify_cjk_support.py --json              # 빌드 스크립트용
python3 scripts/verify_cjk_support.py --strict            # 실패 시 exit 2
```

이 스크립트는 `fontTools`로 각 폰트의 cmap 테이블을 직접 읽어 스킬 철학 한자(`餘白丹靑縫補古調湍` 9자)와 CJK 유니코드 범위의 글리프 수를 실측합니다. 영문 문서의 "Hangeul only" 기술에 의존하지 않고 실제 폰트 바이너리를 검증합니다. `build_core_from_fullpack` 스크립트가 기본적으로 이 검증을 빌드 전에 실행합니다.

> **Claude Desktop / claude.ai 웹 사용자는 풀팩 자동 설치 불가.** 스크립트 실행 권한이 없으므로, 필요하면 Claude Code 환경에서 풀팩을 설치해 NAS·공유 디렉터리로 접근하거나, 필요한 폰트를 포함한 별도 ZIP을 제작해 업로드해야 합니다.

---

## 코어 · 풀팩 ZIP 직접 빌드 (유지보수자용)

로컬에 풀팩이 설치된 Claude Code 환경(`assets/fonts/`에 129종)에서 v1.1.0 배포용 ZIP 두 종류를 직접 빌드할 수 있습니다.

### 1) 코어 ZIP (Claude Desktop 업로드용, ~28.5 MB)

```bash
# Linux / macOS
bash scripts/build_core_from_fullpack.sh --output canvas-design-kr-v1.1.0.zip

# Windows PowerShell
.\scripts\build_core_from_fullpack.ps1 -Output canvas-design-kr-v1.1.0.zip
```

로컬 `assets/fonts/`에서 **CJK 완전 지원 5종만** 추출하여 Desktop 업로드용 ZIP 생성.

### 2) 풀팩 ZIP (GitHub Release Asset용, ~110 MB)

```bash
# Linux / macOS
bash scripts/build_full_pack.sh --output canvas-design-kr-fonts-full-v1.1.0.zip

# Windows PowerShell
.\scripts\build_full_pack.ps1 -Output canvas-design-kr-fonts-full-v1.1.0.zip
```

로컬 `assets/fonts/`에서 **코어 5종을 제외한 124종 + OFL 라이선스 파일 전체**를 추출하여 `install_full_fonts.sh/.ps1`이 기대하는 구조(`fonts/` 하위)로 ZIP 생성. 생성된 ZIP은 GitHub Release의 Asset으로 업로드해야 `install_full_fonts` 스크립트가 다운로드할 수 있습니다.

> **중요**: 두 ZIP 모두 로컬에 129종 풀팩이 설치되어 있어야 빌드됩니다. 먼저 `install_full_fonts.sh` 또는 이전 버전에서 생성해둔 풀팩 ZIP을 사용해 `assets/fonts/`를 채워 놓은 상태에서 빌드 스크립트를 실행합니다.

---

## 디렉토리 구조

```
canvas-design-kr/
├── SKILL.md                       # 스킬 본문 (RULE 0 + RULE 1 + 5종 매니페스트)
├── LICENSE.txt                    # Apache License 2.0
├── LICENSE-canvas-design.txt      # 원본 Anthropic 라이선스 보존
├── NOTICE.txt                     # 변경 이력 + 라이선스 속성
├── README.md                      # 이 파일
├── changelog.md                   # 버전 히스토리
├── assets/
│   └── fonts/                     # 코어 5종 (CJK 완전 지원, 즉시 사용 가능)
│       ├── MANIFEST.txt           # ★ 폰트 파일 목록 평문 (인스톨러가 자동 갱신)
│       ├── NotoSansKR-VF.ttf          # 9.93 MB
│       ├── NanumMyeongjo-OldHangul.ttf   # 9.25 MB
│       ├── NanumBrushScript-Regular.ttf  # 3.66 MB
│       ├── NanumPenScript-Regular.ttf    # 3.47 MB
│       ├── JejuGothic-Regular.ttf        # 2.42 MB
│       └── *-OFL.txt              # 라이선스 파일
└── scripts/
    ├── discover_fonts.py                 # ★ 폰트 디스커버리 (RULE 0 권장)
    ├── verify_cjk_support.py             # ★ CJK 한자 지원 실측 (fontTools cmap 파싱)
    ├── build_core_from_fullpack.sh       # ★ 코어 ZIP 빌드 (Linux/macOS)
    ├── build_core_from_fullpack.ps1      # ★ 코어 ZIP 빌드 (Windows)
    ├── build_full_pack.sh                # ★ 풀팩 ZIP 빌드 (Linux/macOS)
    ├── build_full_pack.ps1                # ★ 풀팩 ZIP 빌드 (Windows)
    ├── install_full_fonts.sh             # 풀팩 설치 (Linux/macOS)
    └── install_full_fonts.ps1            # 풀팩 설치 (Windows)
```

---

## 한국 미학 디자인 철학 (Korean Aesthetic Philosophies)

| 명칭 | 영문 | 미학적 뿌리 | 시각 어휘 |
|---|---|---|---|
| **餘白** Yeobaek | Empty Fullness | 조선백자, 수묵 산수 | 광대한 여백, 단일 요소 배치, 비대칭 |
| **丹靑** Dancheong | Sacred Geometry | 궁궐 처마, 사찰 단청 | 오방색, 평면 색면, 기하 패턴 반복 |
| **縫補** Jogakbo | Quilted Composition | 조선 조각보, 자연 염색 | 비대칭 색 블록, 자투리 미감 |
| **古調** Gojo | Korean Quietude | Lee Ufan, 승효상, K-미니멀 | 모노톤, 절제, 거대한 마진 |
| **餘湍** Yeotan | Currents | 한지·먹·발묵 | 그라데이션, 유기적 흐름, 텍스처 |

원본 5종(Concrete Poetry, Chromatic Language, Analog Meditation, Organic Systems, Geometric Silence)도 그대로 유지됩니다.

---

## 코어 폰트 선택 가이드 (v1.1.0 — 5종)

| 용도 | 폰트 | 비고 |
|---|---|---|
| 기본 본문 (한·영·한자) | **NotoSansKR-VF.ttf** | 가변 폰트, weight 100–900 |
| 명조 본문 / 옛한글 / 한문 | **NanumMyeongjo-OldHangul.ttf** | 餘白, 縫補 |
| 붓글씨 캘리그래피 / 발묵 | **NanumBrushScript-Regular.ttf** | 餘湍 |
| 펜글씨 / 손글씨 | **NanumPenScript-Regular.ttf** | 편지, 메모 |
| 향토 디스플레이 | **JejuGothic-Regular.ttf** | 지역 특화 |

### 가변 폰트 사용 예 (NotoSansKR)

```python
from PIL import ImageFont
font = ImageFont.truetype(os.path.join(FONT_DIR, "NotoSansKR-VF.ttf"), 64)
# PIL 10.1+ 에서 weight 축 조절 (400=Regular, 700=Bold, 900=Black)
try:
    font.set_variation_by_axes([900])
except AttributeError:
    pass  # 하위 PIL은 기본 weight(400)
```

---

## 풀팩 폰트 (124종 추가, 풀팩 설치 시)

풀팩 설치 시 다음 폰트가 추가됩니다:

- **Pretendard** Light/Regular/Medium/Bold/Black (한·영 통합 서브셋)
- **NanumGothic** Regular/Bold/ExtraBold/Light (+ Eco 시리즈 3종)
- **NanumMyeongjo** Regular/Bold/ExtraBold (+ Eco 3종)
- **NanumBarunGothic** 4 weights + OldHangul
- **NanumBarunpen** Regular/Bold + NanumPenScript 풀버전
- **NanumSquare/NanumSquareRound/NanumSquareNeo** 4 weights + Variable
- **NanumHuman** Light/Regular/Bold/ExtraBold/Heavy
- **NotoSansKR / NotoSerifKR** Variable (static)
- **GowunBatang** Regular/Bold, **GowunDodum**
- **JejuMyeongjo**, **JejuHallasan**
- **YeonSung-Regular**, **Hahmlet** Variable, **Diphylleia**
- **BlackHanSans / DoHyeon / Jua / Sunflower-Bold**
- **D2Coding** Regular/Bold (모노스페이스)
- **Gaegu / PoorStory / EastSeaDokdo / CuteFont** (친근·캐주얼)
- **BlackAndWhitePicture** (이미지 폰트)
- **WorkSans / Lora / Italiana / BigShoulders / InstrumentSerif / JetBrainsMono** (영문 디스플레이·모노)

---

## 한국 색채 시스템

### 오방색 (Five Cardinal Colors)
靑 `#003F87` · 赤 `#C8102E` · 黃 `#FFD100` · 白 `#F5F2E8` · 黑 `#1A1A1A`

### 자연 염색 팔레트
쪽 `#1F3A5F` · 치자 `#E8C547` · 홍화 `#D9777A` · 먹 `#2B2926` · 모시 `#F2EBD8` · 황토 `#B07F4A` · 한지 `#FAF6EE`

---

## 사용 예시

```
"한국적인 느낌의 포스터 한 장 만들어줘. 주제는 '봄비'."
"단청 색상으로 워크숍 안내 포스터를 디자인해 줘."
"여백의 미를 살린 미니멀한 PDF 한 장."
"조각보 스타일로 4월 행사 일정표를 PNG로."
"한지에 먹으로 쓴 듯한 캘리그래피, '無爲' 두 글자."  # ← v1.1.0부터 코어에서 즉시 렌더링
"'餘白' 세로쓰기 명조로 포스터."                    # ← 한자 코어 지원
```

---

## v1.0.x 코드 마이그레이션 가이드

v1.0.x 디자인 코드를 v1.1.0에서 실행하면 폰트 파일명이 바뀌어 실패합니다. 다음 치환이 필요합니다:

| v1.0.x 폰트 | v1.1.0 치환 | 비고 |
|---|---|---|
| `Pretendard-Regular.otf` | `NotoSansKR-VF.ttf` (weight=400) | 가변 폰트로 통합 |
| `Pretendard-Bold.otf` | `NotoSansKR-VF.ttf` (weight=700) | 가변 weight |
| `Pretendard-Black.otf` | `NotoSansKR-VF.ttf` (weight=900) | 가변 weight |
| `NanumSquare-Regular/Bold.ttf` | `NotoSansKR-VF.ttf` | 모던 산세리프 통합 |
| `NanumSquareRound/Neo-*.ttf` | `NotoSansKR-VF.ttf` | 모던 산세리프 통합 |
| `NanumGothic-Light.ttf` | `NotoSansKR-VF.ttf` (weight=300) | |
| `NanumMyeongjo-Regular.ttf` | `NanumMyeongjo-OldHangul.ttf` | 옛한글 포함 판본 |
| `BlackHanSans-Regular.ttf` | `NotoSansKR-VF.ttf` (weight=900) | |
| `DoHyeon-Regular.ttf` | `NotoSansKR-VF.ttf` (weight=900) | |
| `Sunflower-Bold.ttf` | `JejuGothic-Regular.ttf` | 친근 디스플레이 대체 |
| `NanumHuman-*.ttf` | `NotoSansKR-VF.ttf` | 가변 weight 활용 |
| `WorkSans/Lora/Italiana/BigShoulders/InstrumentSerif` | (풀팩 필요) | 또는 `NotoSansKR` 라틴 활용 |
| `JetBrainsMono-Regular.ttf` | (풀팩 필요, 대체 없음) | D2Coding도 풀팩 |

---

## 라이선스

### 스킬 코드
**Apache License, Version 2.0** — `LICENSE.txt`

### 번들 폰트 (코어 + 풀팩)
모두 **SIL Open Font License 1.1** — `assets/fonts/<폰트>-OFL.txt`
- 상업 사용·임베딩·재배포 가능
- Reserved Font Name 변경 사용 금지

---

## 변경 이력

`changelog.md` 참조.

---

## 출처 및 감사

- **canvas-design** — Anthropic ([github.com/anthropics/skills](https://github.com/anthropics/skills)), Apache 2.0
- **Noto Sans KR** — Google + Adobe ([fonts.google.com/noto/specimen/Noto+Sans+KR](https://fonts.google.com/noto/specimen/Noto+Sans+KR)), SIL OFL 1.1
- **나눔글꼴** — NAVER Corp. ([hangeul.naver.com](https://hangeul.naver.com/font)), SIL OFL 1.1
- **제주서체** — 제주특별자치도, SIL OFL 1.1
- **Pretendard** — Kil Hyung-jin ([github.com/orioncactus/pretendard](https://github.com/orioncactus/pretendard)), SIL OFL 1.1 (풀팩)
- **검은고딕·도현·주아** — 우아한형제들, SIL OFL 1.1 (풀팩)
- **고운바탕·고운돋움** — Gowun Project, SIL OFL 1.1 (풀팩)
- **D2Coding** — NAVER Corp. ([github.com/naver/d2codingfont](https://github.com/naver/d2codingfont)), SIL OFL 1.1 (풀팩)

---

## GitHub 배포 (Maintainer Notes)

태그 푸시 시 자동으로 코어 ZIP과 풀 폰트팩 ZIP이 GitHub Release에 첨부됩니다 (`.github/workflows/release.yml` 참조).

```bash
git tag v1.1.0
git push origin v1.1.0
# Actions가 자동으로:
#   1) canvas-design-kr-v1.1.0.zip 빌드 (코어 5종, ~30MB)
#   2) canvas-design-kr-fonts-full-v1.1.0.zip 빌드 (풀팩 124종, ~110MB)
#   3) 두 ZIP을 Release Asset으로 첨부
```
