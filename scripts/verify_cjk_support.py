#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
verify_cjk_support.py — canvas-design-kr 코어 폰트의 CJK 한자 지원 실측

로컬 폰트 파일의 cmap 테이블을 직접 파싱하여 실제로 어떤 한자 글리프가
존재하는지 확인한다. 공식 문서의 기술적 설명보다 실측 결과가 우선.

사용법:
    python verify_cjk_support.py                   # 스킬 디렉터리 자동 탐색
    python verify_cjk_support.py <font_dir>        # 특정 경로 지정
    python verify_cjk_support.py --json            # JSON 출력 (CI/빌드 스크립트용)
    python verify_cjk_support.py --strict          # 실패 시 exit code != 0

전제:
    pip install fonttools --break-system-packages

종료 코드:
    0  모든 코어 폰트가 철학 한자 9/9 지원
    1  fontTools 미설치 또는 경로 문제
    2  --strict 모드에서 미지원 폰트 발견
"""

import os
import sys
import json
from collections import OrderedDict

try:
    from fontTools.ttLib import TTFont
except ImportError:
    print("ERROR: fontTools가 설치되지 않았습니다.", file=sys.stderr)
    print("       설치: pip install fonttools --break-system-packages", file=sys.stderr)
    sys.exit(1)

# ─────────────── 검증 대상 ───────────────
# v1.1.0 코어 5종 + NotoSansKR 원본 파일명(있는 경우 둘 다 검증)
CORE_FONTS = [
    "NotoSansKR-VF.ttf",
    "NotoSansKR[wght].ttf",
    "NanumMyeongjo-OldHangul.ttf",
    "NanumBrushScript-Regular.ttf",
    "NanumPenScript-Regular.ttf",
    "JejuGothic-Regular.ttf",
]

# 스킬 철학 이름에 쓰이는 한자 (중복 제거 후 9자: 白丹靑縫補古調餘湍)
PHILOSOPHY_CHARS = "餘白丹靑縫補古調餘湍"

# 일상·행정 한자 (13자)
COMMON_CHARS = "韓國人民日月天地山川文字書"

# CJK 유니코드 범위 (한자 글리프가 존재해야 하는 영역)
CJK_RANGES = [
    ("CJK Unified Ideographs",        0x4E00, 0x9FFF),
    ("CJK Ext-A",                     0x3400, 0x4DBF),
    ("CJK Compatibility Ideographs",  0xF900, 0xFAFF),
]

# 한글 음절 (참고용)
HANGUL_SYLLABLES = (0xAC00, 0xD7A3)

# 판정 임계값
CJK_COMPLETE_THRESHOLD = 4000   # 이 이상이면 "완전 지원"
CJK_LIMITED_THRESHOLD = 500     # 이 이상 4000 미만이면 "제한 지원"


def count_in_range(cmap, start, end):
    return sum(1 for cp in range(start, end + 1) if cp in cmap)


def verify_font(font_path):
    try:
        font = TTFont(font_path, lazy=True)
    except Exception as e:
        return {"error": str(e)}

    cmap = font.getBestCmap()

    philo_unique = sorted(set(PHILOSOPHY_CHARS))
    philo_supported = [c for c in philo_unique if ord(c) in cmap]
    philo_missing = [c for c in philo_unique if ord(c) not in cmap]

    common_unique = sorted(set(COMMON_CHARS))
    common_supported = [c for c in common_unique if ord(c) in cmap]
    common_missing = [c for c in common_unique if ord(c) not in cmap]

    cjk_counts = OrderedDict()
    cjk_total = 0
    for name, start, end in CJK_RANGES:
        n = count_in_range(cmap, start, end)
        cjk_counts[name] = n
        cjk_total += n

    hangul_count = count_in_range(cmap, *HANGUL_SYLLABLES)

    font.close()
    return {
        "total_glyphs": len(cmap),
        "philo_supported": philo_supported,
        "philo_missing": philo_missing,
        "philo_total": len(philo_unique),
        "philo_rate": f"{len(philo_supported)}/{len(philo_unique)}",
        "common_supported": common_supported,
        "common_missing": common_missing,
        "common_total": len(common_unique),
        "common_rate": f"{len(common_supported)}/{len(common_unique)}",
        "cjk_counts": cjk_counts,
        "cjk_total": cjk_total,
        "hangul_count": hangul_count,
    }


def classify(result):
    if "error" in result:
        return "ERROR"
    philo_full = len(result["philo_supported"]) == result["philo_total"]
    if philo_full and result["cjk_total"] >= CJK_COMPLETE_THRESHOLD:
        return "✅ 완전 지원"
    if philo_full and result["cjk_total"] >= CJK_LIMITED_THRESHOLD:
        return "⚠ 제한 지원"
    if result["cjk_total"] == 0:
        return "❌ 한자 없음"
    if result["cjk_total"] < CJK_LIMITED_THRESHOLD:
        return "❌ 사실상 미지원"
    return "⚠ 부분 지원"


def format_chars(chars):
    return " ".join(chars) if chars else "(없음)"


def find_font_dir():
    """스킬 디렉터리 자동 탐색"""
    # 이 스크립트가 scripts/에 있다고 가정
    script_dir = os.path.dirname(os.path.abspath(__file__))
    candidates = [
        os.path.join(os.path.dirname(script_dir), "assets", "fonts"),
        os.path.expanduser("~/.claude/skills/canvas-design-kr/assets/fonts"),
        os.path.expandvars("%USERPROFILE%\\.claude\\skills\\canvas-design-kr\\assets\\fonts"),
        "/mnt/skills/user/canvas-design-kr/assets/fonts",
    ]
    for c in candidates:
        if os.path.isdir(c):
            return c
    return None


def main():
    args = sys.argv[1:]
    json_mode = "--json" in args
    strict = "--strict" in args
    # 경로 인자 (옵션 플래그가 아닌 첫 인자)
    path_arg = next((a for a in args if not a.startswith("--")), None)

    if path_arg:
        font_dir = path_arg
    else:
        font_dir = find_font_dir()

    if not font_dir or not os.path.isdir(font_dir):
        msg = f"ERROR: 폰트 디렉터리를 찾을 수 없습니다 (경로: {font_dir})"
        if json_mode:
            print(json.dumps({"ok": False, "error": msg}, ensure_ascii=False, indent=2))
        else:
            print(msg, file=sys.stderr)
            print(f"       사용법: python {os.path.basename(sys.argv[0])} <font_dir>", file=sys.stderr)
        sys.exit(1)

    # 각 폰트 검증
    results = OrderedDict()
    for font_name in CORE_FONTS:
        font_path = os.path.join(font_dir, font_name)
        if not os.path.exists(font_path):
            continue
        results[font_name] = verify_font(font_path)

    # 전체 판정
    all_ok = True
    for font_name, r in results.items():
        if "error" in r:
            all_ok = False
            continue
        if len(r["philo_supported"]) != r["philo_total"]:
            all_ok = False

    if json_mode:
        # JSON 출력 (cjk_counts를 평범한 dict로)
        out = {
            "ok": all_ok,
            "font_dir": font_dir,
            "fonts": {},
        }
        for font_name, r in results.items():
            if "error" in r:
                out["fonts"][font_name] = {"error": r["error"]}
                continue
            out["fonts"][font_name] = {
                "verdict": classify(r),
                "philo_rate": r["philo_rate"],
                "common_rate": r["common_rate"],
                "cjk_total": r["cjk_total"],
                "hangul_count": r["hangul_count"],
                "total_glyphs": r["total_glyphs"],
                "philo_missing": r["philo_missing"],
            }
        print(json.dumps(out, ensure_ascii=False, indent=2))
    else:
        # 사람 친화적 상세 리포트
        print(f"폰트 디렉터리: {font_dir}")
        print("=" * 78)

        if not results:
            print("ERROR: 지정된 디렉터리에 코어 폰트가 하나도 없습니다.")
            sys.exit(1)

        for font_name, r in results.items():
            print(f"\n▶ {font_name}")
            print("-" * 78)
            if "error" in r:
                print(f"  ERROR: {r['error']}")
                continue
            print(f"  판정: {classify(r)}")
            print(f"  전체 글리프: {r['total_glyphs']:,}자")
            print(f"  한글 음절: {r['hangul_count']:,}/11,172자")
            print()
            print(f"  [테스트 1] 스킬 철학 한자 {r['philo_rate']}")
            print(f"    ✅ 지원: {format_chars(r['philo_supported'])}")
            print(f"    ❌ 누락: {format_chars(r['philo_missing'])}")
            print()
            print(f"  [테스트 2] 일상 한자 {r['common_rate']}")
            print(f"    ✅ 지원: {format_chars(r['common_supported'])}")
            print(f"    ❌ 누락: {format_chars(r['common_missing'])}")
            print()
            print(f"  [테스트 3] CJK 유니코드 범위")
            for name, n in r["cjk_counts"].items():
                print(f"    {name}: {n:,}자")
            print(f"    합계: {r['cjk_total']:,}자")

        # 최종 요약 테이블
        print("\n" + "=" * 78)
        print("최종 요약")
        print("=" * 78)
        print(f"{'폰트':<40} {'철학':<10} {'일상':<10} {'CJK계':<10} {'판정'}")
        print("-" * 78)
        for font_name, r in results.items():
            if "error" in r:
                print(f"{font_name:<40} ERROR")
                continue
            print(f"{font_name:<40} {r['philo_rate']:<10} {r['common_rate']:<10} {r['cjk_total']:<10,} {classify(r)}")

    # Strict 모드 종료 코드
    if strict and not all_ok:
        sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
