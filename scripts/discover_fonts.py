#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
discover_fonts.py — canvas-design-kr 폰트 디스커버리 (v1.1.0)

이 스크립트는 canvas-design-kr 스킬의 절대경로를 자동 탐색하여
사용 가능한 폰트 목록을 출력한다. SKILL.md를 사용하기 전에 반드시
실행하여 결과를 후속 코드의 변수로 사용한다.

v1.1.0 변경사항:
- 코어 폰트 수 24종 → 5종 (CJK 완전 지원)
- PACK 판정 기준: core = 5, incomplete = 1-4, full >= 100

사용법:
    python discover_fonts.py             # 사람 친화적 출력 (기본)
    python discover_fonts.py --json      # JSON 출력 (LLM 파싱용)
    python discover_fonts.py --paths     # 경로만 KEY=VALUE 출력 (셸 eval용)
    python discover_fonts.py --check     # 검증만 수행 (exit code로 판정)

종료 코드:
    0  정상 (코어 5개 이상 발견)
    1  스킬 루트를 찾을 수 없음
    2  스킬 루트는 있으나 폰트가 부족 (코어 5개 미만)
"""

import os
import sys
import glob
import json

# ─────────────── v1.1.0 코어 폰트 매니페스트 ───────────────
CORE_FONTS_V1_1_0 = [
    "NotoSansKR-VF.ttf",
    "NanumMyeongjo-OldHangul.ttf",
    "NanumBrushScript-Regular.ttf",
    "NanumPenScript-Regular.ttf",
    "JejuGothic-Regular.ttf",
]
CORE_COUNT = len(CORE_FONTS_V1_1_0)   # 5
FULL_THRESHOLD = 100                   # 풀팩 설치 판정 기준

# ─────────────── 표준 경로 후보 ───────────────
def candidate_roots():
    cands = []
    env = os.environ.get("CANVAS_DESIGN_KR_ROOT", "").strip()
    if env:
        cands.append(env)
    cands.extend([
        "/mnt/skills/user/canvas-design-kr",
        os.path.expanduser("~/.claude/skills/canvas-design-kr"),
        os.path.expandvars("%USERPROFILE%\\.claude\\skills\\canvas-design-kr"),
        os.path.join(os.getcwd(), ".claude", "skills", "canvas-design-kr"),
    ])
    # 스크립트 자신의 위치에서 역추적 (가장 신뢰할 수 있음)
    try:
        script_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        cands.insert(0, script_root)
    except NameError:
        pass
    # 중복 제거 (순서 보존)
    seen = set()
    return [c for c in cands if c and not (c in seen or seen.add(c))]


def find_skill_root():
    """폰트 디렉터리가 존재하는 첫 번째 후보를 반환."""
    for path in candidate_roots():
        if os.path.isdir(os.path.join(path, "assets", "fonts")):
            return os.path.abspath(path)
    return None


def list_fonts(font_dir):
    """폰트 파일 목록(.ttf, .otf)을 정렬하여 반환."""
    files = sorted(set(
        [os.path.basename(p) for p in glob.glob(os.path.join(font_dir, "*.ttf"))] +
        [os.path.basename(p) for p in glob.glob(os.path.join(font_dir, "*.otf"))]
    ))
    return files


def classify_pack(count):
    """폰트 개수에 따라 패키지 종류를 판정 (v1.1.0: core=5, full>=100)."""
    if count == 0:
        return "empty"
    if count < CORE_COUNT:
        return "incomplete"
    if count < FULL_THRESHOLD:
        return "core"
    return "full"


def check_core_fonts(fonts):
    """코어 5종 중 누락된 폰트 목록 반환."""
    return [f for f in CORE_FONTS_V1_1_0 if f not in fonts]


def main():
    args = set(sys.argv[1:])
    mode_json = "--json" in args
    mode_paths = "--paths" in args
    mode_check = "--check" in args

    skill_root = find_skill_root()
    if not skill_root:
        msg = "ERROR: canvas-design-kr 스킬 루트를 찾을 수 없습니다."
        if mode_json:
            print(json.dumps({"ok": False, "error": msg, "candidates": candidate_roots()}, ensure_ascii=False, indent=2))
        else:
            print(msg, file=sys.stderr)
            print("탐색한 경로:", file=sys.stderr)
            for c in candidate_roots():
                print(f"  - {c}", file=sys.stderr)
            print("\n환경변수 CANVAS_DESIGN_KR_ROOT를 명시적으로 설정하거나, 스킬을 재설치하세요.", file=sys.stderr)
        sys.exit(1)

    font_dir = os.path.join(skill_root, "assets", "fonts")
    fonts = list_fonts(font_dir)
    count = len(fonts)
    pack = classify_pack(count)
    missing_core = check_core_fonts(fonts)

    if mode_json:
        print(json.dumps({
            "ok": pack not in ("empty", "incomplete"),
            "skill_root": skill_root,
            "font_dir": font_dir,
            "font_count": count,
            "pack": pack,
            "core_required": CORE_FONTS_V1_1_0,
            "core_missing": missing_core,
            "fonts": fonts,
        }, ensure_ascii=False, indent=2))
    elif mode_paths:
        print(f"SKILL_ROOT={skill_root}")
        print(f"FONT_DIR={font_dir}")
        print(f"FONT_COUNT={count}")
        print(f"PACK={pack}")
        print(f"CORE_MISSING={len(missing_core)}")
    else:
        # 사람 친화적 출력 (Claude도 이걸 파싱 가능)
        marker = "✓" if pack not in ("empty", "incomplete") else "✗"
        pack_label = {
            "empty": "비어 있음 (스킬 설치 불완전)",
            "incomplete": f"불완전 ({count}/{CORE_COUNT})",
            "core": f"코어 패키지 v1.1.0 ({count}종)",
            "full": f"풀팩 설치됨 ({count}종)",
        }[pack]
        print(f"{marker} canvas-design-kr 발견")
        print(f"  SKILL_ROOT: {skill_root}")
        print(f"  FONT_DIR  : {font_dir}")
        print(f"  폰트 개수 : {count}개 ({pack_label})")
        print()
        if count == 0:
            print("⚠ 폰트가 한 개도 없습니다. 스킬 설치 자체가 불완전합니다.")
            print("  README.md의 설치 섹션을 따라 재설치하세요.")
        elif count < CORE_COUNT:
            print(f"⚠ 코어 폰트 {CORE_COUNT}종 중 {CORE_COUNT - count}종이 누락되었습니다.")
            print("  누락 파일:")
            for f in missing_core:
                print(f"    - {f}")
        else:
            if missing_core:
                print(f"⚠ 코어 {CORE_COUNT}종 중 누락:")
                for f in missing_core:
                    print(f"    - {f}")
                print()
            print("폰트 파일 목록:")
            for f in fonts[:60]:
                mark = "  "
                if f in CORE_FONTS_V1_1_0:
                    mark = "★ "
                print(f"  {mark}{f}")
            if count > 60:
                print(f"  ... ({count}개 중 60개 표시)")
            print()
            print("Python 사용 예 (반드시 절대경로 사용):")
            print("  import os")
            print("  from PIL import ImageFont")
            print(f'  FONT_DIR = r"{font_dir}"')
            print('  font = ImageFont.truetype(os.path.join(FONT_DIR, "NotoSansKR-VF.ttf"), 64)')
            print('  # 가변 weight 조절 (PIL 10.1+):')
            print('  try: font.set_variation_by_axes([700])  # Bold')
            print('  except AttributeError: pass')

    if mode_check:
        sys.exit(0 if pack not in ("empty", "incomplete") else 2)
    sys.exit(0 if pack not in ("empty", "incomplete") else 2)


if __name__ == "__main__":
    main()
