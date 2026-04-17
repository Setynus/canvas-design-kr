#!/bin/bash
# install_full_fonts.sh — canvas-design-kr 풀 폰트팩 자동 설치 (Linux/macOS/NAS)
#
# 사용법:
#   bash scripts/install_full_fonts.sh
#   bash scripts/install_full_fonts.sh --check    # 상태 확인만
#   bash scripts/install_full_fonts.sh --version v1.0.2
#
# 환경변수:
#   CANVAS_DESIGN_KR_FONT_PACK_URL   직접 URL 지정 (기본값 무시)
#   CANVAS_DESIGN_KR_INSTALL_DIR     설치 경로 (기본: 스크립트 기준 ../assets/fonts/)

set -euo pipefail

# ─────────────── 설정 ───────────────
DEFAULT_VERSION="v1.0.2"
GITHUB_REPO="Setynus/canvas-design-kr"
ASSET_NAME_TEMPLATE="canvas-design-kr-fonts-full-{version}.zip"

# ─────────────── 인자 파싱 ───────────────
CHECK_ONLY=0
VERSION="$DEFAULT_VERSION"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check) CHECK_ONLY=1; shift ;;
        --version) VERSION="$2"; shift 2 ;;
        --help|-h)
            sed -n '2,8p' "$0"; exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# ─────────────── 경로 결정 ───────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_DIR="${CANVAS_DESIGN_KR_INSTALL_DIR:-$SKILL_DIR/assets/fonts}"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "ERROR: 설치 디렉토리가 존재하지 않습니다: $INSTALL_DIR"
    echo "       canvas-design-kr 스킬이 올바르게 설치되었는지 확인하세요."
    exit 1
fi

# ─────────────── 상태 확인 ───────────────
COUNT_BEFORE=$(find "$INSTALL_DIR" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | wc -l)
echo "현재 설치된 폰트: $COUNT_BEFORE 개"
echo "설치 경로: $INSTALL_DIR"

if [ "$CHECK_ONLY" -eq 1 ]; then
    echo ""
    echo "── 코어 폰트 (이미 번들됨) ──"
    find "$INSTALL_DIR" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) -printf "  %f\n" | sort | head -40
    if [ "$COUNT_BEFORE" -gt 40 ]; then
        echo "  ... ($COUNT_BEFORE 개 중 40개 표시)"
    fi
    exit 0
fi

if [ "$COUNT_BEFORE" -ge 100 ]; then
    echo ""
    echo "✓ 이미 풀 폰트팩이 설치된 것으로 보입니다 ($COUNT_BEFORE 개 폰트)."
    read -p "다시 설치하시겠습니까? [y/N] " yn
    [[ "$yn" =~ ^[Yy]$ ]] || exit 0
fi

# ─────────────── 다운로드 URL 결정 ───────────────
if [ -n "${CANVAS_DESIGN_KR_FONT_PACK_URL:-}" ]; then
    URL="$CANVAS_DESIGN_KR_FONT_PACK_URL"
    echo "환경변수 URL 사용: $URL"
else
    ASSET_NAME="${ASSET_NAME_TEMPLATE//\{version\}/$VERSION}"
    URL="https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/${ASSET_NAME}"
    echo "다운로드 URL: $URL"
fi

# ─────────────── 도구 확인 ───────────────
DOWNLOADER=""
if command -v curl >/dev/null 2>&1; then DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then DOWNLOADER="wget"
else
    echo "ERROR: curl 또는 wget이 필요합니다."
    exit 1
fi
command -v unzip >/dev/null 2>&1 || { echo "ERROR: unzip이 필요합니다."; exit 1; }

# ─────────────── 다운로드 ───────────────
TMP_DIR="$(mktemp -d)"
trap "rm -rf '$TMP_DIR'" EXIT
ZIP_PATH="$TMP_DIR/font_pack.zip"

echo ""
echo "▶ 풀 폰트팩 다운로드 중 (약 110 MB)..."
if [ "$DOWNLOADER" = "curl" ]; then
    if ! curl -fL --progress-bar -o "$ZIP_PATH" "$URL"; then
        echo "ERROR: 다운로드 실패. URL을 확인하거나 네트워크를 점검하세요."
        echo "       수동 다운로드: $URL"
        exit 1
    fi
else
    if ! wget --show-progress -O "$ZIP_PATH" "$URL"; then
        echo "ERROR: 다운로드 실패."
        exit 1
    fi
fi

# ─────────────── 압축 해제 + 설치 ───────────────
echo ""
echo "▶ 압축 해제 중..."
unzip -q "$ZIP_PATH" -d "$TMP_DIR/unpacked"

# zip 내부 구조: fonts/*.ttf|*.otf|*.txt 또는 평탄
SRC_DIR=""
if [ -d "$TMP_DIR/unpacked/fonts" ]; then
    SRC_DIR="$TMP_DIR/unpacked/fonts"
elif find "$TMP_DIR/unpacked" -maxdepth 2 -name "*.ttf" -o -name "*.otf" | head -1 | grep -q .; then
    SRC_DIR=$(find "$TMP_DIR/unpacked" -name "*.ttf" -o -name "*.otf" | head -1 | xargs dirname)
else
    echo "ERROR: 압축 파일에서 폰트를 찾을 수 없습니다."
    exit 1
fi

echo "▶ 설치 중 → $INSTALL_DIR"
INSTALLED=0
SKIPPED=0
for f in "$SRC_DIR"/*.{ttf,otf,txt}; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    if [ -f "$INSTALL_DIR/$name" ]; then
        SKIPPED=$((SKIPPED+1))
    else
        cp "$f" "$INSTALL_DIR/$name" && INSTALLED=$((INSTALLED+1))
    fi
done

# ─────────────── 결과 ───────────────
COUNT_AFTER=$(find "$INSTALL_DIR" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | wc -l)
echo ""
echo "✓ 완료"
echo "  새로 설치: $INSTALLED 개 파일"
echo "  이미 존재(스킵): $SKIPPED 개 파일"
echo "  현재 폰트 총 개수: $COUNT_BEFORE → $COUNT_AFTER"
echo ""
echo "이제 canvas-design-kr이 모든 한글·영문 폰트를 사용할 수 있습니다."
