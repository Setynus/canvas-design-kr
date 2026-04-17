# Changelog — canvas-design-kr

All notable changes to this skill are documented here.

Versioning follows the convention of this author's skill suite:
**increment by 0.0.1 per modification**, with `Created` date fixed to
the original creation date and `metadata.updated` refreshed per change.

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

### Changed — SKILL.md
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

### Changed — Documentation
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

### Added

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

### Changed — SKILL.md
- **STEP 0 (NEW)** — 동적 폰트 탐색 단계 추가 (코어 vs 풀팩 자동 인식)
- **코어 → 풀팩 폴백 매핑 표** — 요청 폰트가 코어에 없을 때 즉시 대체 폰트 안내
- **assets/fonts/** 경로로 통일 (skill-creator 표준 디렉토리 명칭 채택)
- 폰트 매핑 가이드를 코어 35종 기준으로 재작성, 풀팩 폰트는 폴백 표로 분리
- description에 "코어 즉시 사용 + 풀팩 확장" 명시

### Changed — Metadata/Structure
- 프론트매터 최상위 `version` → `metadata.version`으로 이동
  (Anthropic 공식 스킬 검증 스크립트 호환)
- `changelog.md` 위치를 `references/` 에서 루트로 이동
- `metadata.updated`: 2026-04-17

### Changed — Documentation
- `README.md` — 슬림/풀팩 아키텍처 설명, 설치 절차 두 단계로 분리
- `NOTICE.txt` — 아키텍처 변경 명시, 코어/풀팩 폰트 목록 분리
- `changelog.md` — 본 문서 (루트 배치)

---

## [1.0.0] — 2026-04-16

### Initial Release

Forked from `anthropic/canvas-design` (Apache License 2.0) and extended for
Korean aesthetics and Hangul typography.

#### Added
- 27 Korean OFL fonts (Pretendard, Nanum subset, Noto CJK, Gowun, Woowahan,
  Jeju, etc.)
- 5 Korean aesthetic philosophies: 餘白, 丹靑, 縫補, 古調, 餘湍
- Hangul typography rules + Korean color systems (오방색, 자연 염색)
- Apache 2.0 attribution, NOTICE.txt, README.md, changelog.md

#### Retained
- All 35 original Latin typefaces from canvas-design
- Original 5 design philosophies (Concrete Poetry, Chromatic Language,
  Analog Meditation, Organic Systems, Geometric Silence)
- Two-step workflow (Philosophy → Canvas)
