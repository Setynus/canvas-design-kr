---
name: canvas-design-kr
description: 한국적 미학(餘白·丹靑·縫補·古調·餘湍)과 현대 K-디자인을 시각 철학으로 표현하는 .png/.pdf 디자인 스킬. 코어 5종(NotoSansKR·NanumMyeongjo-OldHangul·NanumBrushScript·NanumPenScript·JejuGothic) 모두 CJK 한자 완전 지원 — 스킬의 철학명 그 자체(餘白·丹靑·縫補·古調·餘湍)를 즉시 렌더링 가능. 풀 폰트팩(124종 추가) 설치 시 Pretendard·NanumSquare·NanumGothic 서브셋, 에코 패턴, 고운글꼴, 제주글꼴 등으로 확장. 트리거 — 한글 포스터, 한국적 디자인, 한국 전통 디자인, 한지 느낌, 단청 색상, 조각보 디자인, 한글 타이포그래피, 캘리그래피, 공공기관 포스터, 한국 미학, 동양적 미학, 여백의 미, 먹 그림, 민화풍, 산수화, 조선 백자 느낌, 궁궐 패턴, 오방색, 한국 모던, K-디자인, K-미니멀, 옛한글, 한자 혼용, 한문 서예. Use this skill whenever the user asks to create a poster, design, or visual art with Korean aesthetic, Hangul typography, or Korean cultural references. Output only .md, .pdf, .png files. Create original visual designs, never copying existing artists' work to avoid copyright violations.
license: Apache License 2.0 (skill code) / SIL OFL 1.1 (fonts — see assets/fonts/*-OFL.txt)
metadata:
  version: 1.1.0
  author: Kwangho Kim
  created: 2026-04-16
  updated: 2026-04-19
  based_on: anthropic/canvas-design (Apache 2.0)
---

<!--
canvas-design-kr v1.1.0 (CJK-Complete Core Architecture)
Copyright (c) 2026 Kwangho Kim
Created: 2026-04-16
Based on canvas-design (© Anthropic, Apache License 2.0)
See LICENSE-canvas-design.txt and NOTICE.txt for full attribution.
-->

# canvas-design-kr

This skill creates **museum-quality visual art** — posters, single-page compositions, PDFs — driven by a **design philosophy**, expressed through form, space, color, and minimal text. It extends the original `canvas-design` skill for Korean aesthetics:

- **5 CJK-complete core fonts** (~28.5 MB, Desktop 30 MB 한도 내) — 한글·영문·한자 모두 즉시 지원
- **124 additional fonts via optional Full Pack** — Pretendard, NanumSquare 서브셋, 에코 패턴, 고운글꼴 등
- **5 Korean-aesthetic philosophies** (餘白·丹靑·縫補·古調·餘湍) alongside the 5 original Western ones
- **Korean typesetting rules**: Hangul-Latin-CJK mixing, 세로쓰기, 오방색·자연염색 팔레트

Output only `.md`, `.pdf`, and `.png` files.

---

## ⛔ RULE 0 — 환경 감지와 폰트 디렉터리 확인

이 스킬을 사용할 때 **다른 어떤 작업보다도 먼저** 실행 환경을 판정하고 폰트 디렉터리의 실제 위치를 확인해야 한다. 이 단계를 건너뛰면 PIL이 시스템 기본 폰트로 조용히 폴백하여 한글이 □로 출력된다.

### 환경 감지 — 3가지 실행 환경

| 환경 | 특징 | 스크립트 실행 |
| --- | --- | --- |
| **Claude Code (CLI)** | `~/.claude/skills/`에 디렉터리 배치, bash/PowerShell 가능 | ✅ `discover_fonts.py` 사용 |
| **Claude Desktop** | ZIP 업로드, 샌드박스 내부 스냅샷 사용 | ⚠️ 제한적, 인라인 코드 권장 |
| **claude.ai 웹** | ZIP 업로드, 샌드박스 내부 스냅샷 사용 | ⚠️ 제한적, 인라인 코드 권장 |

### 방법 A — 디스커버리 스크립트 (Claude Code 환경)

```bash
# Linux / macOS / WSL
python3 ~/.claude/skills/canvas-design-kr/scripts/discover_fonts.py

# Claude.ai 샌드박스
python3 /mnt/skills/user/canvas-design-kr/scripts/discover_fonts.py
```

```powershell
# Windows PowerShell
python "$env:USERPROFILE\.claude\skills\canvas-design-kr\scripts\discover_fonts.py"
```

스크립트는 `SKILL_ROOT`, `FONT_DIR` 절대경로와 폰트 파일명 전체 목록을 출력한다.

### 방법 B — 인라인 코드 (Desktop / claude.ai 웹 권장)

Desktop과 claude.ai 웹은 스크립트 실행이 제한적이므로 다음 인라인 패턴을 사용한다:

```python
import os, glob

# 표준 경로 후보를 순회하여 폰트 디렉터리가 존재하는 첫 경로 채택
for root in [
    os.environ.get("CANVAS_DESIGN_KR_ROOT", ""),
    "/mnt/skills/user/canvas-design-kr",
    os.path.expanduser("~/.claude/skills/canvas-design-kr"),
    os.path.expandvars("%USERPROFILE%\\.claude\\skills\\canvas-design-kr"),
    os.path.join(os.getcwd(), ".claude", "skills", "canvas-design-kr"),
]:
    if root and os.path.isdir(os.path.join(root, "assets", "fonts")):
        SKILL_ROOT = os.path.abspath(root)
        FONT_DIR = os.path.join(SKILL_ROOT, "assets", "fonts")
        break
else:
    raise RuntimeError("canvas-design-kr 스킬 폰트 디렉터리를 찾을 수 없습니다.")

FONTS = sorted(
    [os.path.basename(p) for p in glob.glob(os.path.join(FONT_DIR, "*.ttf"))] +
    [os.path.basename(p) for p in glob.glob(os.path.join(FONT_DIR, "*.otf"))]
)
```

### 패키지 판정

| `len(FONTS)` | 상태 | 행동 |
| --- | --- | --- |
| 0 | 스킬 설치 불완전 | 즉시 중단, 사용자에게 재설치 안내 |
| 1–4 | 코어 일부 누락 | 누락 파일을 사용자에게 보고, 가용 폰트로 진행 |
| 5 (정확) | **코어 패키지 (v1.1.0)** | [코어 5종 매니페스트](#코어-5종-매니페스트-v110) 참고 |
| 100+ | **풀팩 설치됨** | Pretendard·NanumSquare·NanumGothic 시리즈 등 자유 선택 |

---

## ⛔ RULE 1 — 코어는 CJK 한자를 완전 지원한다

**v1.1.0부터 코어 5종 모두 CJK 한자를 완전 지원한다.** 이전 버전의 "한자 사용 시 풀팩 설치 필수" 경고는 **더 이상 유효하지 않다**.

- `餘白`, `丹靑`, `縫補`, `古調`, `餘湍` 등 스킬의 철학명과 한자 모티프는 **코어에서 즉시 렌더링된다**
- 한자 혼용이 필요하면 `NotoSansKR-VF.ttf`(산세리프) 또는 `NanumMyeongjo-OldHangul.ttf`(명조 + 옛한글)을 기본 선택
- `NanumBrushScript`, `NanumPenScript`는 캘리그래피·한자 서예 모두 지원
- `JejuGothic`은 향토 디스플레이 + CJK 지원

### 코어 5종 매니페스트 (v1.1.0)

| 파일명 | 분류 | CJK | 크기 | 용도 |
| --- | --- | --- | --- | --- |
| `NotoSansKR-VF.ttf` | 가변 산세리프 | ✅ 8,566자 | 9.93 MB | **기본 본문**(한·영·한자 통합) |
| `NanumMyeongjo-OldHangul.ttf` | 명조 + 옛한글 | ✅ 5,005자 | 9.25 MB | 고전 명조, 옛한글, 한문 |
| `NanumBrushScript-Regular.ttf` | 붓글씨 캘리 | ✅ 4,888자 | 3.66 MB | 餘湍·발묵·한자 서예 |
| `NanumPenScript-Regular.ttf` | 펜글씨 | ✅ 4,888자 | 3.47 MB | 손글씨, 편지, 메모 |
| `JejuGothic-Regular.ttf` | 향토 디스플레이 | ✅ 4,888자 | 2.42 MB | 제주 향토, CJK 디스플레이 |

**총 ~28.5 MB** — Claude Desktop의 30 MB 비압축 한도 내에 안전하게 수납.

### pick_cjk_font() — CJK 폰트 자동 선택

한자가 포함된 텍스트를 렌더링할 때 다음 우선순위로 폰트를 선택한다:

```python
def pick_cjk_font(style="sans", weight="regular"):
    """
    style: "sans" | "serif" | "brush" | "pen" | "display"
    weight: "regular" | "bold" | "light"
    Returns: 폰트 파일명 (FONT_DIR 기준 상대 파일명)
    """
    if style == "brush":
        return "NanumBrushScript-Regular.ttf"
    if style == "pen":
        return "NanumPenScript-Regular.ttf"
    if style == "serif":
        return "NanumMyeongjo-OldHangul.ttf"
    if style == "display":
        return "JejuGothic-Regular.ttf"
    # 기본: 산세리프 — NotoSansKR 가변 폰트 (모든 weight 커버)
    return "NotoSansKR-VF.ttf"
```

NotoSansKR은 **가변 폰트**이므로 `font_variation_settings`로 굵기를 조절한다 (PIL 10.x+):

```python
from PIL import ImageFont
font = ImageFont.truetype(os.path.join(FONT_DIR, "NotoSansKR-VF.ttf"), 64)
# PIL 10.1+ 에서 가변 축 설정 (400=Regular, 700=Bold, 900=Black)
try:
    font.set_variation_by_axes([700])
except AttributeError:
    pass  # 하위 PIL에서는 기본 weight(400)로 진행
```

### 강제 패턴 — 모든 후속 코드

```python
# ✅ 유일하게 허용되는 패턴
font = ImageFont.truetype(os.path.join(FONT_DIR, "NotoSansKR-VF.ttf"), 64)

# ❌ 절대 금지 — 상대경로 / 파일명만
font = ImageFont.truetype("NotoSansKR-VF.ttf", 64)
font = ImageFont.truetype("./assets/fonts/NotoSansKR-VF.ttf", 64)

# ❌ 절대 금지 — 시스템 폰트 폴백
font = ImageFont.truetype("Pretendard", 64)
font = ImageFont.truetype("malgun.ttf", 64)

# ❌ 절대 금지 — 코어에 없는 파일명 추측 (v1.0.x 코드 호환 실패)
font = ImageFont.truetype(os.path.join(FONT_DIR, "Pretendard-Bold.otf"), 64)
# v1.1.0 코어에는 Pretendard 없음. 풀팩 설치 필요.
```

**파일명을 추측하지 말 것.** 항상 디스커버리 결과의 `FONTS` 목록 또는 코어 5종 매니페스트에 있는 정확한 파일명을 사용한다. v1.0.x 코드를 v1.1.0에서 실행하면 `Pretendard`, `NanumSquare`, `BlackHanSans`, `DoHyeon` 등이 모두 없어 실패한다.

---

Complete the work in two steps:

1. **Design Philosophy Creation** (`.md` file)
2. **Canvas Expression** (`.pdf` or `.png` file)

---

## STEP 0 보강 — 풀팩 폰트 폴백 매핑

⛔ RULE 0에서 결정한 `FONTS` 목록에 원하는 풀팩 폰트가 없으면, 아래 표에 따라 코어 폰트로 즉시 대체하고 사용자에게 풀팩 설치를 안내한다:

> "이 디자인은 풀 폰트팩의 `<폰트명>`을 활용하면 더 좋습니다. 풀팩 설치는 Claude Code 환경에서 `bash scripts/install_full_fonts.sh` (또는 Windows: `.\scripts\install_full_fonts.ps1`)로 진행할 수 있습니다. Claude Desktop/claude.ai 웹 환경은 풀팩 자동 설치를 지원하지 않습니다. 일단 코어 폰트인 `<대체 폰트>`로 작업을 진행하겠습니다."

### 코어 5종 → 풀팩 폴백 매핑

v1.1.0 코어는 의도적으로 슬림하므로, **대부분의 폰트가 풀팩 전용**이다. 요청 폰트가 코어에 없으면:

| 요청 폰트 (풀팩 전용) | 코어 대체 폰트 | 비고 |
| --- | --- | --- |
| **Pretendard** (Light/Regular/Medium/Bold/Black) | **NotoSansKR-VF** | 가변 축으로 굵기 조절, 한·영·한자 통합 |
| **NanumGothic** (Light/Regular/Bold/ExtraBold) | **NotoSansKR-VF** | 서브셋 → 가변 산세리프 대체 |
| **NanumSquare/Round/Neo** 시리즈 | **NotoSansKR-VF** | 모던 산세리프는 NotoSansKR로 통합 |
| **NanumMyeongjo-Regular/Bold** | **NanumMyeongjo-OldHangul** | 옛한글 포함 명조 대체 |
| **NanumBarunGothic** 시리즈 | **NotoSansKR-VF** | 행정 본문도 NotoSansKR로 |
| **BlackHanSans / DoHyeon / Jua** | **NotoSansKR-VF weight=900** | 임팩트는 NotoSansKR 900 활용 |
| **Sunflower-Bold** | **JejuGothic-Regular** | 향토 디스플레이 대체 |
| **NanumGothicEco / NanumMyeongjoEco** | **NotoSansKR-VF** / **NanumMyeongjo-OldHangul** | 에코 패턴은 풀팩 전용 |
| **NanumBarunpen / NanumPenScript 풀버전** | **NanumPenScript-Regular** (이미 코어) | 코어에 기본 포함 |
| **GowunBatang / GowunDodum** | **NanumMyeongjo-OldHangul** / **NotoSansKR-VF** | 단아한 대체 |
| **SongMyung / Hahmlet / Diphylleia** | **NanumMyeongjo-OldHangul** | 모던 명조 대체 |
| **JejuMyeongjo / JejuHallasan** | **JejuGothic-Regular** | 제주 시리즈는 JejuGothic 대체 |
| **NotoSerifKR** | **NanumMyeongjo-OldHangul** | 명조 본문 대체 |
| **WorkSans / Lora / Italiana / BigShoulders / InstrumentSerif / JetBrainsMono** | (영문 전용 없음) | **NotoSansKR-VF** 영문 지원 활용, 또는 풀팩 설치 |
| **NanumMyeongjo-OldHangul** | (이미 코어) | 코어에 기본 포함 |
| **D2Coding** | (코어에 모노스페이스 없음) | **풀팩 필수** |
| **BlackAndWhitePicture / EastSeaDokdo / CuteFont** | (이미지/친근 폰트) | **풀팩 필수**, 대체 불가 |

**중요**: v1.0.x와 달리 v1.1.0 코어에는 영문 전용 폰트가 없다. 영문 전용 디자인이 필요하면 `NotoSansKR-VF.ttf`의 라틴 글리프를 사용하거나 풀팩을 설치한다.

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
Communication through what is *not* placed. The aesthetic of Joseon white porcelain (조선백자) and ink-wash landscape — where 7/10ths of the canvas remains untouched and the single placed mark gains immense weight. Vast cream/off-white expanses (paper-white #FAF6EE / 한지색), one or two restrained gestures placed with calligraphic intent, asymmetric balance leaning toward the corners. Typography whispered in NanumMyeongjo-OldHangul — small, often vertical, never centered. The composition must feel as if a master spent days deciding where the single brushstroke would fall.

**"丹靑 (Dancheong) — Sacred Geometry"**
The five-color (오방색 — 靑赤黃白黑) cosmology of palace eaves and temple beams, organized as ritual pattern. Tightly repeated geometric motifs (lotus, swastika, cloud, peony) in saturated cinnabar (#C8102E), cobalt (#003F87), chrome yellow (#FFD100), bone white, and lacquer black. Bold field divisions like a 단청 panel — never gradients, only flat planes meeting at sharp seams. Typography in NotoSansKR with weight 900 (via variation axis), set as a single declarative word. The piece should look hand-painted by a master 단청장.

**"縫補 (Jogakbo) — Quilted Composition"**
The improvised geometry of Joseon wrapping cloth (조각보), where leftover silk scraps were stitched into accidentally-perfect color fields. Irregular rectangular blocks tiling the canvas in muted naturally-dyed palette (쪽빛 indigo, 치자 gardenia yellow, 홍화 safflower pink, 먹 ink, 모시 ramie cream). Visible "stitch lines" of 1–2 px between blocks. Tiny seal-script-like type marks placed inside one or two blocks with NanumMyeongjo-OldHangul. The result must feel like an heirloom: the labor of a thousand small decisions, each meticulously crafted.

**"古調 (Gojo) — Korean Quietude"**
Contemporary K-minimalism — the language of artists like Lee Ufan, Park Seo-bo, and the architecture of Seung H-Sang. Monochromatic stone, ash, raw linen, soot. One central form (a circle, a horizontal line, a single word) given the entire stage. Generous margins (15% minimum on all sides). Typography in NotoSansKR at light weight (variation axis 300), set incredibly small relative to the negative space. The piece communicates through the *quality of stillness*.

**"餘湍 (Yeotan) — Currents"**
The flow of ink in 한지 (Korean mulberry paper) — controlled bleeds, the moment when wet meets fiber. Organic ink-wash gradients, edges that diffuse rather than terminate, layered transparencies in sumi black, indigo, and tea brown. Underlying compositional grid (golden ratio or 3:5 division) anchors the chaos. Typography appears as if painted with the same brush — NanumBrushScript-Regular, set vertically along the right edge.

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

**Use distinct fonts.** Reference them via `os.path.join(FONT_DIR, "<filename>")` — never with relative paths.

---

## HANGUL + CJK TYPOGRAPHY RULES

### Mandatory rule

**Any Hangul (한글) or CJK (한자/漢字) glyph in the composition MUST be rendered with a CJK-capable font.** v1.1.0 코어 5종은 모두 CJK 완전 지원 — 이 문제는 코어에서 근본적으로 해결되었다.

### Core font selection guide (v1.1.0, 5 fonts)

#### Body sans-serif (한·영·한자 통합)

| Use case | Font | Variation weight |
| --- | --- | --- |
| All-purpose body | **NotoSansKR-VF.ttf** | 400 (Regular) |
| Light display | **NotoSansKR-VF.ttf** | 300 (Light) |
| Bold impact | **NotoSansKR-VF.ttf** | 700 (Bold) |
| Maximum impact (丹靑) | **NotoSansKR-VF.ttf** | 900 (Black) |

#### Body serif / 옛한글 / 한문

| Use case | Font |
| --- | --- |
| Classical body serif | **NanumMyeongjo-OldHangul.ttf** |
| Display serif (餘白) | **NanumMyeongjo-OldHangul.ttf** + larger size |
| 옛한글 (중세 국어) | **NanumMyeongjo-OldHangul.ttf** |
| 한문 서예 (활자) | **NanumMyeongjo-OldHangul.ttf** |

#### Calligraphy / handwriting / 붓글씨

| Use case | Font |
| --- | --- |
| Brush stroke (餘湍, 발묵) | **NanumBrushScript-Regular.ttf** |
| Pen script (손글씨) | **NanumPenScript-Regular.ttf** |
| 한자 서예 | **NanumBrushScript-Regular.ttf** |

#### Display / 향토 / 지역성

| Use case | Font |
| --- | --- |
| 제주 향토 디스플레이 | **JejuGothic-Regular.ttf** |
| 지역 특화 포스터 | **JejuGothic-Regular.ttf** |

> **Latin 전용 폰트가 필요하면**: 코어 v1.1.0은 Latin 전용 폰트를 포함하지 않음. NotoSansKR의 라틴 글리프로 대체하거나, Claude Code 환경에서 풀팩 설치(`bash scripts/install_full_fonts.sh`) 후 WorkSans/Lora/Italiana 등을 사용.

### Hangul–Latin–CJK mixing (한·영·한자 혼용)

**Option A — Single unified font (strongly recommended for v1.1.0):** `NotoSansKR-VF.ttf` contains high-quality Hangul, Latin, AND CJK glyphs — use it alone for clean mixed text.

**Option B — Paired fonts:** 명조 본문과 산세리프 혼용 시:

- 본문 명조: `NanumMyeongjo-OldHangul.ttf`
- 헤더 산세리프: `NotoSansKR-VF.ttf` (weight 700)

**Hangul-friendly line-height:** 1.5–1.7 for body text (Hangul characters are visually heavier than Latin).

### Vertical writing (세로쓰기)

For 餘白 / 餘湍 / classical compositions:

```python
import os
from PIL import Image, ImageDraw, ImageFont
# SKILL_ROOT, FONT_DIR는 STEP 0에서 결정된 절대경로 변수
img = Image.new("RGB", (800, 1200), "#FAF6EE")
draw = ImageDraw.Draw(img)
font = ImageFont.truetype(os.path.join(FONT_DIR, "NanumMyeongjo-OldHangul.ttf"), 56)
text = "餘白"  # 코어에서 즉시 렌더링 — 한자 완전 지원
x, y = 700, 100   # right side, top
for ch in text:
    draw.text((x, y), ch, font=font, fill="#1a1a1a")
    bbox = font.getbbox(ch)
    y += (bbox[3] - bbox[1]) + 12
img.save("yeobaek.png")
```

Do NOT rotate Hangul or CJK glyphs — they are designed for both horizontal and vertical reading without rotation.

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

폰트 파일 위치는 ⛔ RULE 0의 디스커버리로 결정된 `FONT_DIR` 절대경로 변수를 항상 사용한다. 코어 5종은 즉시 사용 가능, 풀팩 124종은 Claude Code 환경에서 별도 설치.

### Optional: Install Full Font Pack (124 additional fonts) — Claude Code 전용

Pretendard, NanumSquare 시리즈, NanumGothic, 에코 패턴, 고운글꼴, 제주글꼴 풀세트 등이 필요하면:

```bash
# Linux / macOS / Synology NAS / WSL (Claude Code 환경)
bash scripts/install_full_fonts.sh

# Windows (PowerShell, Claude Code 환경)
.\scripts\install_full_fonts.ps1
```

설치 후 폰트 총 개수가 5 → 129개로 확장된다. 인스톨러는 설치 완료 시 `assets/fonts/MANIFEST.txt`를 자동 갱신하므로, 풀팩 설치 후에는 RULE 0의 디스커버리를 다시 실행하여 새 `FONTS` 목록을 반영한다.

> **풀팩 ZIP 빌드 (유지보수자용)**: GitHub Release에 올릴 풀팩 ZIP은 로컬에 129종이 설치된 상태에서 `scripts/build_full_pack.sh` 또는 `scripts/build_full_pack.ps1`로 생성한다. 결과물은 코어 5종을 제외한 124종 + OFL 라이선스를 담은 `canvas-design-kr-fonts-full-v1.1.0.zip`.
> **Claude Desktop / claude.ai 웹 사용자**: 이 환경은 ZIP 업로드만 지원하며 스크립트 실행이 불가능하다. 풀팩이 필요하면 Claude Code 환경에서 설치 후 NAS·로컬 디렉터리를 공유하거나, 필요한 풀팩 폰트가 번들된 별도 ZIP을 제작해 업로드한다.

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
