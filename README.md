# canvas-design-kr

한국적 미학(餘白·丹靑·縫補·古調·餘湍)과 현대 K-디자인을 시각 철학으로 표현하는 Claude Skill.

**Version**: 1.0.2 (Slim Core + Optional Full Pack)
**Created**: 2026-04-16
**Author**: Kwangho Kim
**License**: Apache License 2.0 (skill code) / SIL OFL 1.1 (fonts)
**Based on**: [anthropics/skills — canvas-design](https://github.com/anthropics/skills) (Apache 2.0)

---

## 아키텍처 — 슬림 코어 + 풀 폰트팩

v1.0.2부터 Claude Desktop의 30 MB 스킬 등록 한도에 맞추어 **두 단계 배포** 방식으로 전환되었습니다.

| 구분 | 폰트 수 | 크기 | 배포 |
|---|---|---|---|
| **슬림 코어** | 24 (한글 17 + 영문 7) | ZIP ~14 MB | 스킬 ZIP에 직접 번들 |
| **풀 폰트팩** | +105 추가 | ZIP ~110 MB | GitHub Release Asset, 자동 다운로드 스크립트 |
| **합계** | 129 | ~124 MB | 풀팩 설치 시 |

스킬 자체는 **24개 핵심 폰트**로 즉시 작동하며, 옛한글·노토 시리즈·NanumBarunGothic 등이 필요하면 한 줄 명령으로 풀팩을 추가합니다.

---

## 설치 방법

### 1) 슬림 코어 설치 (필수)

**Claude Desktop:**
```
설정 → Skills → "Add Skill" → canvas-design-kr-v1.0.2.zip 업로드
```

**Claude Code / NAS / 로컬:**
```bash
unzip canvas-design-kr-v1.0.2.zip -d ~/.claude/skills/
# Synology NAS 환경:
unzip canvas-design-kr-v1.0.2.zip -d /volume1/claude/skills/
```

이 시점에서 한글 디자인 작업이 완전히 가능합니다. (Pretendard·NanumSquare 시리즈·BlackHanSans 등 24종)

### 2) 풀 폰트팩 설치 (선택)

옛한글, 에코 패턴, NanumBarunGothic, NotoSansKR variable, GowunBatang, JejuMyeongjo 등이 필요하면:

```bash
# Linux / macOS / Synology NAS
cd ~/.claude/skills/canvas-design-kr/
bash scripts/install_full_fonts.sh

# Windows (PowerShell, Claude Desktop 환경)
cd "$env:USERPROFILE\.claude\skills\canvas-design-kr"
.\scripts\install_full_fonts.ps1
```

스크립트는 GitHub Release(`v1.0.2`)에서 풀팩 ZIP을 다운로드하여 `assets/fonts/`에 자동 추가합니다.

**검증:**
```bash
bash scripts/install_full_fonts.sh --check       # Linux/macOS
.\scripts\install_full_fonts.ps1 -Check          # Windows
```

### 3) 직접 다운로드 (오프라인 환경)

스크립트가 동작하지 않는 환경:
```
https://github.com/Setynus/canvas-design-kr/releases/download/v1.0.2/canvas-design-kr-fonts-full-v1.0.2.zip
```
다운로드 후 압축 해제하여 내부 `fonts/` 폴더의 모든 파일을 스킬의 `assets/fonts/`에 복사합니다.

---

## 디렉토리 구조

```
canvas-design-kr/
├── SKILL.md                       # 스킬 본문 (동적 폰트 탐색 로직 포함)
├── LICENSE.txt                    # Apache License 2.0
├── LICENSE-canvas-design.txt      # 원본 Anthropic 라이선스 보존
├── NOTICE.txt                     # 변경 이력 + 라이선스 속성
├── README.md                      # 이 파일
├── changelog.md                   # 버전 히스토리
├── assets/
│   └── fonts/                     # 코어 24종 (즉시 사용 가능)
│       ├── Pretendard-*.otf       (5)
│       ├── NanumSquare-*.ttf      (4)
│       ├── NanumSquareRound-*.ttf (4)
│       ├── NanumSquareNeo-*.ttf   (3)
│       ├── NanumHuman-*.ttf       (3)
│       ├── 기타 한글 디스플레이·캘리·향토 (9)
│       ├── 영문 핵심 (7)
│       └── *-OFL.txt              # 라이선스 14개
└── scripts/
    ├── install_full_fonts.sh      # Linux/macOS/NAS 풀팩 설치
    └── install_full_fonts.ps1     # Windows 풀팩 설치
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

## 코어 폰트 목록 (24종)

### 한글 (17종)

**산세리프 본문**
- **Pretendard** Regular/Bold/Black — 한·영 통합 만능
- **NanumGothic-Light** — 클래식 산세리프

**모던 K-corp 산세리프**
- **NanumSquare** Regular/Bold — 한자 포함, 가벼움
- **NanumSquareRound** Regular/Bold — 친근한 라운드
- **NanumSquareNeo** Regular/Bold — 가장 모던

**휴머니스트**
- **NanumHuman** Light/Regular/Bold

**명조**
- **NanumMyeongjo-Regular** — 본문 명조

**디스플레이 임팩트**
- **BlackHanSans-Regular** (검은고딕)
- **DoHyeon-Regular** (도현체)
- **Sunflower-Bold**

> **풀팩 전용**: SongMyung(명조 디스플레이), Jua(주아체), JejuGothic(제주고딕), NanumBrushScript(붓글씨), NanumPenScript, NanumBarunpen, Pretendard Light/Medium, NanumSquare/Round/Neo 추가 weight 등은 풀팩 설치 시 사용 가능합니다.

### 영문 (7종)
WorkSans Regular/Bold · Lora Regular · Italiana Regular · BigShoulders Bold · InstrumentSerif Regular · JetBrainsMono Regular

---

## 풀팩에 포함된 추가 폰트 (105종)

풀팩 설치 시 다음 패밀리 풀세트가 추가됩니다:

- **NanumGothic** Regular/Bold/ExtraBold (Light는 코어)
- **NanumGothicEco** Regular/Bold/ExtraBold (친환경 패턴)
- **NanumMyeongjo** Bold/ExtraBold (Regular는 코어)
- **NanumMyeongjoEco** Regular/Bold/ExtraBold
- **NanumMyeongjo-OldHangul** (옛한글)
- **NanumBarunGothic** UltraLight/Light/Regular/Bold (행정·본문)
- **NanumBarunGothic-OldHangul**
- **NanumBarunpen** Regular/Bold (현대 펜글씨)
- **NanumPenScript** (펜글씨)
- **NanumSquareNeo** Light/Heavy + Variable
- **NanumHuman** ExtraLight/ExtraBold/Heavy
- **NotoSansKR** Variable
- **NotoSerifKR** Variable
- **GowunBatang** Regular/Bold (격조 명조)
- **GowunDodum** (단아한 산세리프)
- **JejuMyeongjo**, **JejuHallasan** (제주 향토)
- **YeonSung-Regular**, **Hahmlet** Variable, **Diphylleia**
- **D2Coding** Regular/Bold (모노스페이스)
- **Gaegu** Light/Regular/Bold, **PoorStory**, **EastSeaDokdo**, **CuteFont**
- **BlackAndWhitePicture** (이미지 폰트)
- **NanumSquare/NanumSquareRound** OTF 버전, 영문 30여 종 추가

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
"한지에 먹으로 쓴 듯한 캘리그래피, '無爲' 두 글자."
```

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
- **Pretendard** — Kil Hyung-jin ([github.com/orioncactus/pretendard](https://github.com/orioncactus/pretendard)), SIL OFL 1.1
- **나눔글꼴** — NAVER Corp. ([hangeul.naver.com](https://hangeul.naver.com/font)), SIL OFL 1.1
- **D2Coding** — NAVER Corp. ([github.com/naver/d2codingfont](https://github.com/naver/d2codingfont)), SIL OFL 1.1
- **검은고딕·도현·주아** — 우아한형제들, SIL OFL 1.1
- **고운바탕·고운돋움** — Gowun Project, SIL OFL 1.1
- **제주서체** — 제주특별자치도, SIL OFL 1.1
- **Noto CJK** — Google + Adobe, SIL OFL 1.1

---

## GitHub 배포 (Maintainer Notes)

태그 푸시 시 자동으로 슬림 코어 ZIP과 풀 폰트팩 ZIP 두 개가 GitHub Release에 첨부됩니다 (`.github/workflows/release.yml` 참조).

```bash
git tag v1.0.2
git push origin v1.0.2
# Actions가 자동으로:
#   1) canvas-design-kr-v1.0.2.zip 빌드 (슬림 코어, ~22MB)
#   2) canvas-design-kr-fonts-full-v1.0.2.zip 빌드 (풀팩, ~110MB)
#   3) 두 ZIP을 Release Asset으로 첨부
```
