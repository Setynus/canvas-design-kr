#!/bin/bash
# build_full_pack.sh — 로컬 전체 폰트에서 v1.1.0 풀팩 ZIP 빌드 (Linux/macOS)
#
# 유지보수자 전용: 풀팩이 설치된 assets/fonts/ (총 129종)에서 v1.1.0 코어 5종을
# 제외한 124종 + 모든 OFL 라이선스 파일을 추출해 풀팩 ZIP을 생성한다.
#
# 결과물은 install_full_fonts.sh가 다운로드하는 ZIP과 동일한 구조를 가진다:
#   canvas-design-kr-fonts-full-v1.1.0.zip
#     └── fonts/
#         ├── Pretendard-Regular.otf
#         ├── NanumGothic-Bold.ttf
#         ├── ... (총 124종)
#         └── *-OFL.txt
#
# 사용법:
#   bash scripts/build_full_pack.sh
#   bash scripts/build_full_pack.sh --output my-fullpack.zip
#   bash scripts/build_full_pack.sh --source /path/to/fonts
#
# 전제조건:
#   - 이 스크립트는 canvas-design-kr 스킬 디렉터리 내 scripts/에 있어야 함
#   - --source 미지정 시 ../assets/fonts/에서 129종을 찾음
#   - install_full_fonts.sh를 먼저 실행해 풀팩이 병합된 상태여야 함

set -euo pipefail

# ─────────────── 설정 ───────────────
VERSION="v1.1.0"
DEFAULT_OUTPUT="canvas-design-kr-fonts-full-${VERSION}.zip"

# v1.1.0 코어 5종 — 풀팩에서 제외
# 주의: NotoSansKR은 소스(로컬 풀팩)에 Google Fonts 원본 이름 NotoSansKR[wght].ttf 또는
#       v1.1.0에서 리네임된 NotoSansKR-VF.ttf 중 하나로 존재할 수 있다. 양쪽 모두 제외.
CORE_FONTS=(
    "NotoSansKR-VF.ttf"
    "NotoSansKR[wght].ttf"
    "NotoSansKR-Variable.ttf"
    "NanumMyeongjo-OldHangul.ttf"
    "NanumBrushScript-Regular.ttf"
    "NanumPenScript-Regular.ttf"
    "JejuGothic-Regular.ttf"
)

# ─────────────── 인자 파싱 ───────────────
OUTPUT="$DEFAULT_OUTPUT"
SOURCE_DIR=""
MIN_COUNT=100  # 최소 기대 폰트 수 (풀팩 검증용)
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output|-o) OUTPUT="$2"; shift 2 ;;
        --source|-s) SOURCE_DIR="$2"; shift 2 ;;
        --min-count) MIN_COUNT="$2"; shift 2 ;;
        --help|-h)
            sed -n '2,20p' "$0"; exit 0 ;;
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

echo "── canvas-design-kr 풀팩 ZIP 빌드 ($VERSION) ──"
echo "  소스 폰트: $SOURCE_DIR"
echo "  출력 파일: $OUTPUT"
echo ""

# ─────────────── 풀팩 설치 상태 검증 ───────────────
TOTAL_FONTS=$(find "$SOURCE_DIR" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | wc -l)
echo "소스 폰트 총 개수: $TOTAL_FONTS 종"

if [ "$TOTAL_FONTS" -lt "$MIN_COUNT" ]; then
    echo ""
    echo "ERROR: 폰트가 $TOTAL_FONTS 개밖에 없습니다 (최소 $MIN_COUNT 개 필요)."
    echo "       풀팩이 제대로 설치되지 않은 상태입니다."
    echo "       먼저 다음을 실행하세요:"
    echo "         bash scripts/install_full_fonts.sh"
    echo ""
    echo "       이미 풀팩 ZIP을 가지고 계신 경우 압축 해제하여 폰트를"
    echo "       $SOURCE_DIR 에 복사한 뒤 이 스크립트를 다시 실행하세요."
    exit 1
fi

echo "✓ 풀팩 설치 상태 확인됨 ($TOTAL_FONTS ≥ $MIN_COUNT)"

# ─────────────── 코어 폰트 존재 검증 ───────────────
CORE_MISSING=()
for f in "${CORE_FONTS[@]}"; do
    if [ ! -f "$SOURCE_DIR/$f" ]; then
        CORE_MISSING+=("$f")
    fi
done
if [ ${#CORE_MISSING[@]} -gt 0 ]; then
    echo ""
    echo "WARN: 다음 v1.1.0 코어 폰트가 소스에 없습니다 (풀팩에 자연스럽게 제외):"
    for f in "${CORE_MISSING[@]}"; do
        echo "  - $f"
    done
fi

# ─────────────── 임시 스테이징 디렉터리 준비 ───────────────
STAGE="$(mktemp -d)"
trap "rm -rf '$STAGE'" EXIT
PKG="$STAGE/fonts"   # install_full_fonts.sh가 기대하는 내부 구조: fonts/
mkdir -p "$PKG"

# ─────────────── 폰트 복사 (코어 5종 제외) ───────────────
echo ""
echo "▶ 풀팩 폰트 복사 중 (코어 5종 제외)..."
COPIED=0
SKIPPED=0

# NUL 구분자로 안전하게 파일명 처리 (대괄호 포함)
while IFS= read -r -d '' f; do
    name=$(basename "$f")
    is_core=0
    for c in "${CORE_FONTS[@]}"; do
        if [ "$name" = "$c" ]; then
            is_core=1
            break
        fi
    done
    if [ "$is_core" -eq 1 ]; then
        SKIPPED=$((SKIPPED + 1))
    else
        cp "$f" "$PKG/$name"
        COPIED=$((COPIED + 1))
    fi
done < <(find "$SOURCE_DIR" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) -print0)

echo "  복사: $COPIED 종 폰트"
echo "  제외(코어 별칭 매칭): $SKIPPED 종"
if [ "$SKIPPED" -gt 5 ]; then
    echo "    (NotoSansKR 원본·리네임 판본이 동시에 존재해 5보다 많을 수 있음)"
fi

# ─────────────── OFL 라이선스 파일 전부 복사 ───────────────
echo "▶ OFL 라이선스 파일 복사 중..."
OFL_COUNT=0
for f in "$SOURCE_DIR"/*.txt; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    # MANIFEST.txt 등은 제외, OFL/LICENSE 관련만 포함
    if [[ "$name" == *OFL* ]] || [[ "$name" == *LICENSE* ]] || [[ "$name" == *license* ]]; then
        cp "$f" "$PKG/$name"
        OFL_COUNT=$((OFL_COUNT + 1))
    fi
done
echo "  복사: $OFL_COUNT 개 라이선스 파일"

# ─────────────── 빌드 검증 ───────────────
echo ""
echo "▶ 빌드 검증..."
FINAL_FONTS=$(find "$PKG" -type f \( -name "*.ttf" -o -name "*.otf" \) | wc -l)
TOTAL_SIZE=$(du -sb "$PKG" 2>/dev/null | cut -f1 || du -sk "$PKG" | awk '{print $1*1024}')
TOTAL_MB=$(echo "scale=1; $TOTAL_SIZE / 1048576" | bc 2>/dev/null || echo "?")

echo "  풀팩 폰트: $FINAL_FONTS 종"
echo "  비압축 크기: ${TOTAL_MB} MB"

if [ "$FINAL_FONTS" -lt 100 ]; then
    echo "  WARN: 풀팩 폰트 수가 100 미만입니다. 구성을 확인하세요."
fi

# ─────────────── ZIP 생성 ───────────────
echo ""
echo "▶ ZIP 압축 중..."

# 절대경로 변환
if [[ "$OUTPUT" = /* ]]; then
    OUTPUT_ABS="$OUTPUT"
else
    OUTPUT_ABS="$(pwd)/$OUTPUT"
fi
rm -f "$OUTPUT_ABS"

command -v zip >/dev/null 2>&1 || { echo "ERROR: zip 명령이 필요합니다."; exit 1; }

(cd "$STAGE" && zip -qr "$OUTPUT_ABS" "fonts")

ZIP_SIZE=$(stat -c%s "$OUTPUT_ABS" 2>/dev/null || stat -f%z "$OUTPUT_ABS" 2>/dev/null || echo 0)
ZIP_MB=$(echo "scale=1; $ZIP_SIZE / 1048576" | bc 2>/dev/null || echo "?")

echo ""
echo "✓ 빌드 완료"
echo "  출력: $OUTPUT_ABS"
echo "  압축 크기: ${ZIP_MB} MB"
echo "  비압축 크기: ${TOTAL_MB} MB"
echo "  수록 폰트: $FINAL_FONTS 종 + $OFL_COUNT 라이선스 파일"
echo ""
echo "다음 단계:"
echo "  1. GitHub Release 페이지에서 $VERSION 태그 Release 편집"
echo "  2. '$OUTPUT_ABS' 파일을 Release Asset으로 첨부 업로드"
echo "  3. 파일명은 반드시 'canvas-design-kr-fonts-full-$VERSION.zip' 유지"
echo "     (install_full_fonts.sh/ps1 스크립트가 이 파일명으로 다운로드)"
echo ""
echo "URL: https://github.com/Setynus/canvas-design-kr/releases/tag/$VERSION"
