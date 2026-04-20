#!/bin/bash
# build_core_from_fullpack.sh — 로컬 풀팩에서 v1.1.0 코어 ZIP 빌드 (Linux/macOS)
#
# 유지보수자 전용: 사용자 풀팩(assets/fonts/ 129종)에서 CJK 완전 지원
# 5종만 추출해 Claude Desktop 업로드용 v1.1.0 코어 ZIP을 생성한다.
#
# 사용법:
#   bash scripts/build_core_from_fullpack.sh
#   bash scripts/build_core_from_fullpack.sh --output mypath.zip
#   bash scripts/build_core_from_fullpack.sh --source /path/to/fonts
#
# 전제조건:
#   - 이 스크립트는 canvas-design-kr 스킬 디렉터리 내 scripts/에 있어야 함
#   - --source 미지정 시 ../assets/fonts/ 에서 5종을 찾음
#   - 풀팩이 설치되어 있지 않으면 해당 파일이 없어 실패

set -euo pipefail

# ─────────────── 설정 ───────────────
VERSION="v1.1.0"
DEFAULT_OUTPUT="canvas-design-kr-${VERSION}.zip"

# CJK 완전 지원 코어 5종 (출력 ZIP 기준 파일명)
# 주의: NotoSansKR은 Google Fonts 원본에서 NotoSansKR[wght].ttf로 배포되나,
#       Claude Desktop ZIP 검증기가 대괄호를 거부하므로 NotoSansKR-VF.ttf로 리네임.
CORE_FONTS=(
    "NotoSansKR-VF.ttf"
    "NanumMyeongjo-OldHangul.ttf"
    "NanumBrushScript-Regular.ttf"
    "NanumPenScript-Regular.ttf"
    "JejuGothic-Regular.ttf"
)

# NotoSansKR의 원본 파일명 대안 (build 시 이쪽이 있어도 복사)
NOTO_SANS_KR_ALIASES=(
    "NotoSansKR-VF.ttf"
    "NotoSansKR[wght].ttf"
    "NotoSansKR-Variable.ttf"
)

# 대응하는 OFL 라이선스 파일 (존재하는 것만 복사)
OFL_FILES=(
    "Noto-CJK-OFL.txt"
    "NotoSansKR-OFL.txt"
    "Nanum-NAVER-OFL.txt"
    "JejuGothic-OFL.txt"
)

# NotoSansKR 실제 소스 파일 경로 찾기
find_noto_sans_kr() {
    local src="$1"
    for alias in "${NOTO_SANS_KR_ALIASES[@]}"; do
        if [ -f "$src/$alias" ]; then
            echo "$src/$alias"
            return 0
        fi
    done
    return 1
}

# ─────────────── 인자 파싱 ───────────────
OUTPUT="$DEFAULT_OUTPUT"
SOURCE_DIR=""
VERIFY_CJK=1   # 기본: CJK 검증 활성
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --source|-s) SOURCE_DIR="$2"; shift 2 ;;
        --no-verify-cjk) VERIFY_CJK=0; shift ;;
        --verify-cjk) VERIFY_CJK=1; shift ;;
        --help|-h)
            sed -n '2,16p' "$0"; exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ─────────────── 경로 결정 ───────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
if [ -z "$SOURCE_DIR" ]; then
    SOURCE_DIR="$SKILL_DIR/assets/fonts"
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: 소스 폰트 디렉터리가 존재하지 않습니다: $SOURCE_DIR"
    exit 1
fi

echo "── canvas-design-kr 코어 ZIP 빌드 ($VERSION) ──"
echo "  소스 폰트: $SOURCE_DIR"
echo "  출력 파일: $OUTPUT"
echo ""

# ─────────────── 코어 폰트 존재 검증 ───────────────
MISSING=()
NOTO_SRC=""
for f in "${CORE_FONTS[@]}"; do
    if [ "$f" = "NotoSansKR-VF.ttf" ]; then
        # NotoSansKR은 별칭 중 하나가 있으면 OK
        NOTO_SRC=$(find_noto_sans_kr "$SOURCE_DIR" || true)
        if [ -z "$NOTO_SRC" ]; then
            MISSING+=("NotoSansKR-VF.ttf (or NotoSansKR[wght].ttf, NotoSansKR-Variable.ttf)")
        fi
    else
        if [ ! -f "$SOURCE_DIR/$f" ]; then
            MISSING+=("$f")
        fi
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "ERROR: 다음 코어 폰트가 소스 디렉터리에 없습니다:"
    for f in "${MISSING[@]}"; do
        echo "  - $f"
    done
    echo ""
    echo "풀팩이 설치되어 있어야 합니다. 먼저 실행:"
    echo "  bash scripts/install_full_fonts.sh"
    exit 1
fi

echo "✓ 코어 폰트 5종 모두 확인됨"
if [ -n "$NOTO_SRC" ] && [ "$(basename "$NOTO_SRC")" != "NotoSansKR-VF.ttf" ]; then
    echo "  ℹ NotoSansKR 원본 파일명: $(basename "$NOTO_SRC") → 출력시 NotoSansKR-VF.ttf로 리네임"
fi

# ─────────────── CJK 한자 지원 실측 (빌드 전 검증) ───────────────
if [ "$VERIFY_CJK" -eq 1 ]; then
    echo ""
    echo "▶ CJK 한자 지원 실측 중..."
    if ! command -v python3 >/dev/null 2>&1; then
        echo "  ⚠ python3 미설치 — CJK 검증 생략 (--no-verify-cjk로 경고 끄기 가능)"
    elif ! python3 -c "import fontTools" >/dev/null 2>&1; then
        echo "  ⚠ fontTools 미설치 — CJK 검증 생략"
        echo "    설치: pip install fonttools --break-system-packages"
    elif [ ! -f "$SCRIPT_DIR/verify_cjk_support.py" ]; then
        echo "  ⚠ scripts/verify_cjk_support.py 없음 — CJK 검증 생략"
    else
        if python3 "$SCRIPT_DIR/verify_cjk_support.py" "$SOURCE_DIR" --strict >/dev/null 2>&1; then
            echo "  ✓ 코어 5종 모두 스킬 철학 한자(餘白丹靑縫補古調餘湍) 완전 지원"
        else
            echo ""
            echo "ERROR: CJK 검증 실패 — 일부 코어 폰트가 철학 한자를 지원하지 않습니다."
            echo "       상세 결과:"
            python3 "$SCRIPT_DIR/verify_cjk_support.py" "$SOURCE_DIR" 2>&1 | tail -10 | sed 's/^/         /'
            echo ""
            echo "       빌드를 강제로 진행하려면 --no-verify-cjk 옵션 사용"
            exit 1
        fi
    fi
fi

# ─────────────── 필수 메타 파일 검증 ───────────────
META_FILES=(
    "SKILL.md"
    "README.md"
    "changelog.md"
    "LICENSE.txt"
    "LICENSE-canvas-design.txt"
    "NOTICE.txt"
    "scripts/discover_fonts.py"
    "scripts/verify_cjk_support.py"
    "scripts/install_full_fonts.sh"
    "scripts/install_full_fonts.ps1"
    "scripts/build_core_from_fullpack.sh"
    "scripts/build_core_from_fullpack.ps1"
    "scripts/build_full_pack.sh"
    "scripts/build_full_pack.ps1"
)

META_MISSING=()
for f in "${META_FILES[@]}"; do
    if [ ! -f "$SKILL_DIR/$f" ]; then
        META_MISSING+=("$f")
    fi
done

if [ ${#META_MISSING[@]} -gt 0 ]; then
    echo "ERROR: 다음 필수 파일이 누락되었습니다:"
    for f in "${META_MISSING[@]}"; do
        echo "  - $f"
    done
    exit 1
fi

echo "✓ 필수 메타 파일 확인됨"

# ─────────────── 임시 스테이징 디렉터리 준비 ───────────────
STAGE="$(mktemp -d)"
trap "rm -rf '$STAGE'" EXIT
PKG="$STAGE/canvas-design-kr"
mkdir -p "$PKG/assets/fonts" "$PKG/scripts"

# ─────────────── 메타 파일 복사 ───────────────
echo ""
echo "▶ 메타 파일 복사 중..."
for f in "${META_FILES[@]}"; do
    dest="$PKG/$f"
    mkdir -p "$(dirname "$dest")"
    cp "$SKILL_DIR/$f" "$dest"
done

# ─────────────── 코어 폰트 5종 복사 ───────────────
echo "▶ 코어 폰트 5종 복사 중..."
for f in "${CORE_FONTS[@]}"; do
    if [ "$f" = "NotoSansKR-VF.ttf" ]; then
        # NotoSansKR은 소스에서 찾은 실제 파일을 VF 이름으로 복사
        src_path="$NOTO_SRC"
    else
        src_path="$SOURCE_DIR/$f"
    fi
    cp "$src_path" "$PKG/assets/fonts/$f"
    size=$(stat -c%s "$PKG/assets/fonts/$f" 2>/dev/null || stat -f%z "$PKG/assets/fonts/$f" 2>/dev/null || echo 0)
    size_mb=$(echo "scale=2; $size / 1048576" | bc 2>/dev/null || echo "$size B")
    echo "    $f  (${size_mb} MB)"
done

# ─────────────── OFL 라이선스 파일 복사 (있는 것만) ───────────────
echo "▶ OFL 라이선스 복사 중..."
for f in "${OFL_FILES[@]}"; do
    if [ -f "$SOURCE_DIR/$f" ]; then
        cp "$SOURCE_DIR/$f" "$PKG/assets/fonts/$f"
        echo "    $f"
    fi
done

# 혹시 누락된 경우 풀팩의 라이선스 파일 전체 복사 (백업)
if ! ls "$PKG/assets/fonts/"*-OFL.txt >/dev/null 2>&1; then
    echo "  경고: 정확한 OFL 파일명 매칭 실패. 풀팩의 모든 OFL 파일을 복사."
    for f in "$SOURCE_DIR"/*-OFL.txt; do
        [ -f "$f" ] || continue
        cp "$f" "$PKG/assets/fonts/$(basename "$f")"
    done
fi

# ─────────────── MANIFEST.txt 재생성 ───────────────
echo "▶ MANIFEST.txt 생성 중..."
{
    echo "# canvas-design-kr — Font Manifest"
    echo "# 이 파일은 assets/fonts/에 실제로 존재해야 하는 폰트 파일 목록의 표준 참조다."
    echo "# 풀팩 설치 시 인스톨러가 자동으로 갱신한다."
    echo "#"
    echo "# Format: <pack>:<filename>  (한 줄에 하나)"
    echo "#   pack = core | full"
    echo "#"
    echo "# 마지막 갱신: $(date '+%Y-%m-%d') (${VERSION} 코어 패키지)"
    echo "# Pack: core (5 files, ~28.5 MB, CJK-complete)"
    echo ""
    for f in "${CORE_FONTS[@]}"; do
        echo "core:$f"
    done
} | sort | uniq > "$PKG/assets/fonts/MANIFEST.txt"

# ─────────────── 빌드 검증 ───────────────
echo ""
echo "▶ 빌드 검증..."
TOTAL_SIZE=$(du -sb "$PKG" 2>/dev/null | cut -f1 || du -sk "$PKG" | awk '{print $1*1024}')
TOTAL_MB=$(echo "scale=2; $TOTAL_SIZE / 1048576" | bc 2>/dev/null || echo "?")
echo "  비압축 크기: ${TOTAL_MB} MB (Desktop 30 MB 한도 대비)"

if (( $(echo "$TOTAL_MB > 30" | bc -l 2>/dev/null || echo 0) )); then
    echo "  WARN: 30 MB를 초과합니다! Claude Desktop에서 거부될 수 있습니다."
fi

FILE_COUNT=$(find "$PKG" -type f | wc -l)
echo "  전체 파일 수: $FILE_COUNT"

# ─────────────── ZIP 생성 ───────────────
echo ""
echo "▶ ZIP 압축 중..."

# 절대경로 변환
if [[ "$OUTPUT" = /* ]]; then
    OUTPUT_ABS="$OUTPUT"
else
    OUTPUT_ABS="$(pwd)/$OUTPUT"
fi

# 기존 ZIP 제거
rm -f "$OUTPUT_ABS"

command -v zip >/dev/null 2>&1 || { echo "ERROR: zip 명령이 필요합니다."; exit 1; }

(cd "$STAGE" && zip -qr "$OUTPUT_ABS" "canvas-design-kr")

ZIP_SIZE=$(stat -c%s "$OUTPUT_ABS" 2>/dev/null || stat -f%z "$OUTPUT_ABS" 2>/dev/null || echo 0)
ZIP_MB=$(echo "scale=2; $ZIP_SIZE / 1048576" | bc 2>/dev/null || echo "?")

echo ""
echo "✓ 빌드 완료"
echo "  출력: $OUTPUT_ABS"
echo "  압축 크기: ${ZIP_MB} MB"
echo "  비압축 크기: ${TOTAL_MB} MB"
echo ""
echo "다음 단계:"
echo "  1. Claude Desktop/claude.ai 웹: 이 ZIP을 설정 → Skills → Add Skill로 업로드"
echo "  2. Claude Code: unzip $OUTPUT_ABS -d ~/.claude/skills/"
echo "  3. GitHub Release: 태그 $VERSION 푸시 시 Actions가 자동 빌드"
