---
name: canvas-design-kr
description: 한국적 미학(餘白·단청·조각보·먹·민화)과 현대 K-디자인을 시각 철학으로 표현하는 .png/.pdf 디자인 스킬. 한·영 통합 본문 Pretendard + 나눔글꼴 시리즈 등 한글 17종 + 영문 핵심 7종이 코어에 번들되어 즉시 사용 가능. 풀 폰트팩(105종 추가) 설치 시 옛한글·에코·바른고딕·노토 시리즈까지 확장. 트리거 — 한글 포스터, 한국적 디자인, 한국 전통 디자인, 한지 느낌, 단청 색상, 조각보 디자인, 한글 타이포그래피, 캘리그래피, 공공기관 포스터, 한국 미학, 동양적 미학, 여백의 미, 먹 그림, 민화풍, 산수화, 조선 백자 느낌, 궁궐 패턴, 오방색, 한국 모던, K-디자인, K-미니멀, 옛한글, 중세 국어. Use this skill whenever the user asks to create a poster, design, or visual art with Korean aesthetic, Hangul typography, or Korean cultural references. Output only .md, .pdf, .png files. Create original visual designs, never copying existing artists' work to avoid copyright violations.
license: Apache License 2.0 (skill code) / SIL OFL 1.1 (fonts — see assets/fonts/*-OFL.txt)
metadata:
  version: 1.0.2
  author: Kwangho Kim
  created: 2026-04-16
  updated: 2026-04-17
  based_on: anthropic/canvas-design (Apache 2.0)
---

<!--
canvas-design-kr v1.0.2 (Slim Core + Optional Full Pack Architecture)
Copyright (c) 2026 Kwangho Kim
Created: 2026-04-16
Based on canvas-design (© Anthropic, Apache License 2.0)
See LICENSE-canvas-design.txt and NOTICE.txt for full attribution.
-->

This skill creates **museum-quality visual art** — posters, single-page compositions, PDFs — driven by a **design philosophy**, expressed through form, space, color, and minimal text. It extends the original `canvas-design` skill for Korean aesthetics:

- **24 fonts bundled in core** (Hangul 17 + Latin 7) — works immediately after install
- **105 additional fonts via optional Full Pack** — Old Hangul, Eco patterns, BarunGothic, Noto CJK variable, etc.
- **5 additional Korean-aesthetic philosophies** (餘白·丹靑·縫補·古調·餘湍) alongside the 5 original
- **Korean typesetting rules**: Hangul-Latin mixing, vertical writing, 오방색·자연염색 systems

Output only `.md`, `.pdf`, and `.png` files.

Complete the work in two steps:
1. **Design Philosophy Creation** (`.md` file)
2. **Canvas Expression** (`.pdf` or `.png` file)

---

## STEP 0 — FONT DISCOVERY (필수 사전 단계)

**Always run this before selecting fonts.** The skill ships with a slim core but the user may have installed the Full Pack — never assume which fonts are available.

```python
import os, glob

FONT_DIR = os.path.join(os.path.dirname(__file__), "assets", "fonts")
# Skill 루트 기준 경로. Claude Code에서 SKILL.md가 로드된 경우:
# SKILL_ROOT = "<skill-install-path>/canvas-design-kr"
# FONT_DIR = SKILL_ROOT + "/assets/fonts"

available = sorted(set(
    [os.path.basename(p) for p in glob.glob(f"{FONT_DIR}/*.ttf")] +
    [os.path.basename(p) for p in glob.glob(f"{FONT_DIR}/*.otf")]
))
print(f"사용 가능 폰트: {len(available)}개")
# 24개 → 코어만, 100개 이상 → 풀팩 설치됨
```

**의사결정:**
- **24개**: 코어 폰트만 사용. 본문은 Pretendard 우선.
- **129개+**: 풀팩 설치됨. NanumBarunGothic·NotoSansKR variable·옛한글 등 자유롭게 선택.

**원하는 폰트가 코어에 없는 경우** — 다음 안내 메시지를 사용자에게 출력:

> "이 디자인은 풀 폰트팩의 `<폰트명>`을 활용하면 더 좋습니다. 풀팩 설치는 `bash scripts/install_full_fonts.sh` (또는 Windows: `.\scripts\install_full_fonts.ps1`)로 진행할 수 있습니다. 일단 코어 폰트인 `<대체 폰트>`로 작업을 진행하겠습니다."

대체 폰트는 아래 폴백 표를 참고.

### 코어 → 풀팩 폴백 매핑 (요청 폰트가 코어에 없을 때 즉시 대체)

| 풀팩 폰트 (없을 때) | 코어 대체 폰트 | 비고 |
|---|---|---|
| NanumBarunGothic 시리즈 | **NanumGothic-Light** | 행정 본문 느낌 유지 |
| NotoSansKR variable | **Pretendard-Regular** | 한·영 통합 본문 |
| NotoSerifKR variable | **NanumMyeongjo-Regular** | 명조 본문 |
| GowunBatang Bold | **NanumMyeongjo-Regular** | 격조 명조 |
| GowunDodum | **Pretendard-Regular** | 단아한 산세리프 |
| Pretendard Light/Medium | **Pretendard-Regular** | 코어는 R/B/Black만 |
| NanumSquare Light/ExtraBold | **NanumSquare-Regular/Bold** | 코어는 R/B만 |
| NanumSquareRound Light/ExtraBold | **NanumSquareRound-Regular/Bold** | 코어는 R/B만 |
| NanumSquareNeo Light/ExtraBold/Heavy | **NanumSquareNeo-Regular/Bold** | 코어는 R/B만 |
| NanumGothic Bold/ExtraBold | **NanumGothic-Light + Pretendard-Bold** | |
| NanumMyeongjo Bold/ExtraBold | **NanumMyeongjo-Regular** + 굵게 처리 | |
| NanumGothicEco / NanumMyeongjoEco | **NanumGothic-Light** / **NanumMyeongjo-Regular** | 에코 패턴은 풀팩 전용 |
| NanumBrushScript / NanumPenScript / NanumBarunpen | (코어에 캘리 없음) | **캘리그래피는 풀팩 필수** |
| 옛한글 폰트 (NanumMyeongjo-OldHangul) | **NanumMyeongjo-Regular** | 옛한글은 풀팩 전용 — 표시 시 사용자에게 명시 |
| JejuGothic / JejuMyeongjo / JejuHallasan | **NanumGothic-Light** / **NanumMyeongjo-Regular** | 향토 디스플레이는 풀팩 전용 |
| SongMyung | **NanumMyeongjo-Regular** | 모던 명조 대체 |
| Jua / YeonSung / Gaegu / PoorStory | **BlackHanSans** / **DoHyeon** / **Sunflower-Bold** | 친근 디스플레이 대체 |
| Hahmlet / Diphylleia | **NanumMyeongjo-Regular** | 모던 명조 대체 |
| D2Coding | **JetBrainsMono-Regular** | 코딩 모노 대체 |
| EastSeaDokdo / CuteFont | **Sunflower-Bold** | 손글씨/귀여운 대체 |
| BlackAndWhitePicture | (대체 없음) | 이미지 폰트 — 풀팩 전용 |

---

## STEP 1 — DESIGN PHILOSOPHY CREATION

Create a **VISUAL PHILOSOPHY** (not a layout, not a template) that the canvas step will interpret through form, space, color, composition, images, graphics, shapes, patterns, and minimal text as visual accent.

### THE CRITICAL UNDERSTANDING
- **Received**: subtle input/instructions from the user, used as foundation, not as constraint.
- **Created**: a design philosophy, an aesthetic movement.
- **Next**: the same Claude expresses it visually — artifacts that are **90% visual design, 10% essential text**.

The philosophy must emphasize: **visual expression, spatial communication, artistic interpretation, minimal words.**

### HOW TO GENERATE A VISUAL PHILOSOPHY

**Name the movement** (1–2 words). Examples: "Brutalist Joy" / "Chromatic Silence" / "餘白 (Yeobaek)" / "조각보 (Jogakbo)".

**Articulate the philosophy** (4–6 concise paragraphs) covering:
- Space and form
- Color and material
- Scale and rhythm
- Composition and balance
- Visual hierarchy

**CRITICAL GUIDELINES:**
- **Avoid redundancy**: each design aspect mentioned once.
- **Emphasize craftsmanship REPEATEDLY**: stress that the final work should appear meticulously crafted, labored over, master-level. Repeat phrases like "meticulously crafted," "the product of deep expertise," "painstaking attention," "master-level execution."
- **Leave creative space**: be specific about aesthetic direction, but concise enough that the canvas step has interpretive room — also at extremely high craftsmanship.

The philosophy must guide the canvas step to express ideas VISUALLY, not through text. **Information lives in design, not paragraphs.**

### PHILOSOPHY EXAMPLES — GLOBAL/WESTERN (5)

**"Concrete Poetry"** — Communication through monumental form and bold geometry. Massive color blocks, sculptural typography, Brutalist spatial divisions, Polish poster energy meets Le Corbusier. Text as rare, powerful gesture.

**"Chromatic Language"** — Color as the primary information system. Geometric precision where color zones create meaning. Typography minimal — small sans-serif labels letting chromatic fields communicate. Josef Albers' interaction meets data visualization.

**"Analog Meditation"** — Quiet visual contemplation through texture and breathing room. Paper grain, ink bleeds, vast negative space. Photography and illustration dominate. Typography whispered. Japanese photobook aesthetic.

**"Organic Systems"** — Natural clustering and modular growth patterns. Rounded forms, organic arrangements, color from nature through architecture. Information shown through visual diagrams, spatial relationships, iconography.

**"Geometric Silence"** — Pure order and restraint. Grid-based precision, bold photography or stark graphics, dramatic negative space. Typography precise but minimal. Swiss formalism meets Brutalist material honesty.

### PHILOSOPHY EXAMPLES — KOREAN (5)

**"餘白 (Yeobaek) — Empty Fullness"**
Communication through what is *not* placed. The aesthetic of Joseon white porcelain (조선백자) and ink-wash landscape — where 7/10ths of the canvas remains untouched and the single placed mark gains immense weight. Vast cream/off-white expanses (paper-white #FAF6EE / 한지색), one or two restrained gestures placed with calligraphic intent, asymmetric balance leaning toward the corners. Typography whispered in NanumMyeongjo / SongMyung — small, often vertical, never centered. The composition must feel as if a master spent days deciding where the single brushstroke would fall.

**"丹靑 (Dancheong) — Sacred Geometry"**
The five-color (오방색 — 靑赤黃白黑) cosmology of palace eaves and temple beams, organized as ritual pattern. Tightly repeated geometric motifs (lotus, swastika, cloud, peony) in saturated cinnabar (#C8102E), cobalt (#003F87), chrome yellow (#FFD100), bone white, and lacquer black. Bold field divisions like a 단청 panel — never gradients, only flat planes meeting at sharp seams. Typography in BlackHanSans or DoHyeon, set as a single declarative word. The piece should look hand-painted by a master 단청장.

**"縫補 (Jogakbo) — Quilted Composition"**
The improvised geometry of Joseon wrapping cloth (조각보), where leftover silk scraps were stitched into accidentally-perfect color fields. Irregular rectangular blocks tiling the canvas in muted naturally-dyed palette (쪽빛 indigo, 치자 gardenia yellow, 홍화 safflower pink, 먹 ink, 모시 ramie cream). Visible "stitch lines" of 1–2 px between blocks. Tiny seal-script-like type marks placed inside one or two blocks with NanumMyeongjo. The result must feel like an heirloom: the labor of a thousand small decisions, each meticulously crafted.

**"古調 (Gojo) — Korean Quietude"**
Contemporary K-minimalism — the language of artists like Lee Ufan, Park Seo-bo, and the architecture of Seung H-Sang. Monochromatic stone, ash, raw linen, soot. One central form (a circle, a horizontal line, a single word) given the entire stage. Generous margins (15% minimum on all sides). Typography in Pretendard Light or NanumSquareRound Light, set incredibly small relative to the negative space. The piece communicates through the *quality of stillness*.

**"餘湍 (Yeotan) — Currents"**
The flow of ink in 한지 (Korean mulberry paper) — controlled bleeds, the moment when wet meets fiber. Organic ink-wash gradients, edges that diffuse rather than terminate, layered transparencies in sumi black, indigo, and tea brown. Underlying compositional grid (golden ratio or 3:5 division) anchors the chaos. Typography appears as if painted with the same brush — NanumBrushScript, set vertically along the right edge.

*These are condensed examples. Actual philosophies should be 4–6 substantial paragraphs.*

### ESSENTIAL PRINCIPLES
- **VISUAL PHILOSOPHY** — an aesthetic worldview to be expressed through design
- **MINIMAL TEXT** — sparse, essential-only, integrated as visual element
- **SPATIAL EXPRESSION** — ideas communicate through space, form, color, composition
- **ARTISTIC FREEDOM** — the canvas step interprets visually
- **EXPERT CRAFTSMANSHIP** — final work must look meticulously crafted by a master
- **CULTURAL INTEGRITY (Korean philosophies)** — when invoking Korean aesthetics, respect the underlying tradition. 단청 is not "Asian-looking colors"; 餘白 is not "minimal white space." Each carries centuries of meaning.

Output the design philosophy as a `.md` file (4–6 paragraphs).

---

## STEP 1.5 — DEDUCING THE SUBTLE REFERENCE

Before the canvas, identify the subtle conceptual thread from the original request. The topic is a **subtle, niche reference embedded within the art** — not literal, always sophisticated. Someone familiar with the subject feels it intuitively; others simply experience a masterful abstract composition. Think like a jazz musician quoting another song.

---

## STEP 2 — CANVAS CREATION

With philosophy established, express it on canvas. Use the philosophy as foundation. Create one single-page, highly visual, design-forward PDF or PNG output (unless more pages are requested).

Generally use repeating patterns and perfect shapes. Treat the abstract philosophy as if it were a scientific bible: dense accumulation of marks, repeated elements, layered patterns. Add sparse, clinical typography and systematic reference markers. Anchor with simple phrase(s) positioned subtly, using a limited color palette that feels intentional and cohesive.

**For Korean philosophies specifically:**
- Reach for **vertical composition** when 餘白 / 餘湍 is invoked.
- Use **flat color planes meeting at sharp seams** for 丹靑 / 縫補. Avoid gradients in these movements.
- For 古調, treat **negative space as the primary subject**.
- Avoid kitsch shortcuts: no hanbok silhouettes, no taegeuk mark, no obvious cherry blossoms unless the philosophy demands it. Korean aesthetic depth lives in *restraint and proportion*.

### TEXT AS A CONTEXTUAL ELEMENT

Text is always minimal and visual-first, but context guides scale. Most of the time, fonts should be **thin**. **Nothing falls off the page and nothing overlaps.** Every element must be contained within the canvas with proper margins.

**Use distinct fonts.** Reference them from `assets/fonts/` directory.

---

## HANGUL TYPOGRAPHY RULES

### Mandatory rule
**Any Hangul (한글) glyph in the composition MUST be rendered with a Hangul-supporting font.** Latin-only fonts (WorkSans, Lora, Italiana, BigShoulders, InstrumentSerif, JetBrainsMono) DO NOT contain Hangul glyphs and will fall back to system defaults — destroying design intent. Always pair the right font to the script.

### Core font selection guide (24 bundled fonts)

**Body sans-serif (한·영 통합)**

| Use case | Recommended font |
|---|---|
| All-purpose, modern body | **Pretendard** Regular/Bold/Black |
| Modern K-corporate | **NanumSquareNeo** Regular/Bold |
| Modern, clean (가벼움) | **NanumSquare** Regular/Bold |
| Friendly, rounded | **NanumSquareRound** Regular/Bold |
| Humanist warmth | **NanumHuman** Light/Regular/Bold |
| Classical Nanum baseline | **NanumGothic-Light** |

**Body serif (명조)**

| Use case | Recommended font |
|---|---|
| Classical, refined body | **NanumMyeongjo-Regular** |
| Display serif (餘白) | **NanumMyeongjo-Regular** + larger size |
| Modern serif display | **NanumMyeongjo-Regular** (SongMyung은 풀팩 전용) |

**Display / impact**

| Use case | Recommended font |
|---|---|
| Maximum impact (丹靑) | **BlackHanSans** / **DoHyeon** |
| Friendly display (民畵) | **Sunflower-Bold** (Jua/YeonSung은 풀팩 전용) |
| Pseudo-traditional | **NanumMyeongjo-Regular** + 큰 사이즈 (JejuGothic/SongMyung은 풀팩) |

**Calligraphy / handwriting**

| Use case | Recommended font |
|---|---|
| Brush stroke (餘湍, 발묵) | (코어에 없음 — 풀팩의 **NanumBrushScript** 필요) |
| Pen script | (코어에 없음 — 풀팩의 **NanumPenScript** / **NanumBarunpen** 필요) |

> **캘리그래피 작업 시**: 코어에는 캘리그래피 폰트가 포함되지 않습니다. 풀팩 설치(`bash scripts/install_full_fonts.sh`) 후 NanumBrushScript/NanumPenScript 등을 사용할 수 있습니다. 코어만으로는 BlackHanSans + 큰 사이즈 + 여백 처리로 유사한 임팩트를 내거나 사용자에게 풀팩 설치를 안내할 것.

**Latin / English (Pretendard로 한·영 통합 가능)**

| Use case | Recommended font |
|---|---|
| Sans-serif body | **Pretendard** (primary) / **WorkSans** Regular/Bold |
| Serif body/display | **Lora-Regular** |
| Editorial display serif | **Italiana-Regular** / **InstrumentSerif** |
| Bold display sans | **BigShoulders-Bold** |
| Monospace | **JetBrainsMono-Regular** |

### Hangul–Latin mixing (한·영 혼용)

**Option A — Single unified font (recommended):** Pretendard contains both Hangul and high-quality Latin glyphs — use it alone for clean mixed text.

**Option B — Paired fonts:** When pairing a Hangul font with a separate Latin font:
- Hangul 100% : Latin 95% (산세리프 — NanumGothic + WorkSans)
- Hangul 100% : Latin 90% (명조 — NanumMyeongjo + Lora)
- Vertical center alignment of Latin glyphs against Hangul body

**Hangul-friendly line-height:** 1.5–1.7 for body text (Hangul characters are visually heavier than Latin).

### Vertical writing (세로쓰기)

For 餘白 / 餘湍 / classical compositions:

```python
from PIL import Image, ImageDraw, ImageFont
img = Image.new("RGB", (800, 1200), "#FAF6EE")
draw = ImageDraw.Draw(img)
font = ImageFont.truetype("./assets/fonts/NanumMyeongjo-Regular.ttf", 56)
text = "餘白"
x, y = 700, 100   # right side, top
for ch in text:
    draw.text((x, y), ch, font=font, fill="#1a1a1a")
    bbox = font.getbbox(ch)
    y += (bbox[3] - bbox[1]) + 12
img.save("yeobaek.png")
```

Do NOT rotate Hangul glyphs — they are designed for both horizontal and vertical reading without rotation.

---

## KOREAN COLOR SYSTEMS

### 오방색 (Five Cardinal Colors)
靑(東) `#003F87` · 赤(南) `#C8102E` · 黃(中) `#FFD100` · 白(西) `#F5F2E8` · 黑(北) `#1A1A1A`

### 오간색 (Five Intermediate)
綠 `#4A7C59` · 紅 `#E8959A` · 碧 `#6B9BB8` · 紫 `#6B3F7C` · 硫黃 `#C9A85E`

### 자연 염색 팔레트 (縫補 / 古調)
쪽 `#1F3A5F` · 치자 `#E8C547` · 홍화 `#D9777A` · 먹 `#2B2926` · 모시 `#F2EBD8` · 황토 `#B07F4A` · 한지 `#FAF6EE`

### Pairing rules
- 오방색 within a single composition: **3 of 5 maximum**
- For 古調: stay within natural-dye palette + black/white only. Never mix saturated 오방색 into 古調.
- 단청: paired complementary blocks (靑↔赤, 黃↔黑) with 白 as separator.

---

## DOWNLOAD AND USE FONTS

The `assets/fonts/` directory contains 24 core fonts. Reference them by relative path:

```python
ImageFont.truetype("./assets/fonts/Pretendard-Bold.otf", 64)
```

Make typography PART of the art (brought into the composition, not just typeset digitally).

### Optional: Install Full Font Pack (105 additional fonts)

For 옛한글, 에코 패턴, NanumBarunGothic, NotoSansKR variable, GowunBatang, JejuMyeongjo, BlackAndWhitePicture 등을 사용하려면:

```bash
# Linux / macOS / Synology NAS
bash scripts/install_full_fonts.sh

# Windows (PowerShell)
.\scripts\install_full_fonts.ps1
```

설치 후 폰트 총 개수가 24 → 129개로 확장됩니다. 항상 STEP 0의 폰트 탐색을 통해 현재 사용 가능한 폰트를 확인하세요.

---

## CRAFTSMANSHIP — NON-NEGOTIABLE

Create work that looks like it took countless hours. Composition, spacing, color choices, typography — everything must scream expert-level craftsmanship. Double-check that nothing overlaps, formatting is flawless, every detail perfect.

Output the final result as a single `.pdf` or `.png` file, alongside the design philosophy `.md` file.

---

## FINAL STEP

The user has ALREADY said: *"It isn't perfect enough. It must be pristine, a masterpiece of craftsmanship, as if it were about to be displayed in a museum."*

To refine: **avoid adding more graphics**; instead refine what's there and make it crisp. If the instinct is to call a new function or draw a new shape — STOP and ask: **"How can I make what's already here more of a piece of art?"**

---

## MULTI-PAGE OPTION

Create more pages along the design philosophy but distinctly different. Bundle in the same PDF or many PNGs. Each subsequent page is a unique twist of the original. Tell a story tastefully.

---

## CULTURAL & LEGAL NOTES

- **Korean fonts**: All bundled fonts are SIL OFL 1.1 (see `assets/fonts/<font>-OFL.txt`). Free for commercial use, embedding, redistribution. Reserved Font Names must not be reused for derivatives.
- **Korean philosophies**: 餘白·丹靑·縫補·古調·餘湍 are aesthetic *concepts*, not trademarks. Use them as conceptual scaffolding, not as cultural cosplay.
- **Other Korean public-sector typefaces** (서울서체·이순신체·경기천년체 등 공공누리 1유형): can be added separately by copying TTF files into `assets/fonts/`.

---

*See `changelog.md` for version history. See `NOTICE.txt` for attribution to the original `canvas-design` (Anthropic, Apache 2.0).*
