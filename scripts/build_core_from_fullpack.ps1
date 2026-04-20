# build_core_from_fullpack.ps1 — 로컬 풀팩에서 v1.1.0 코어 ZIP 빌드 (Windows)
#
# 유지보수자 전용: 사용자 풀팩(assets/fonts/ 129종)에서 CJK 완전 지원
# 5종만 추출해 Claude Desktop 업로드용 v1.1.0 코어 ZIP을 생성한다.
#
# 사용법:
#   PowerShell> .\scripts\build_core_from_fullpack.ps1
#   PowerShell> .\scripts\build_core_from_fullpack.ps1 -Output canvas-design-kr-v1.1.0.zip
#   PowerShell> .\scripts\build_core_from_fullpack.ps1 -Source "C:\path\to\fonts"
#
# 전제조건:
#   - 이 스크립트는 canvas-design-kr 스킬 디렉터리 내 scripts\에 있어야 함
#   - -Source 미지정 시 ..\assets\fonts\ 에서 5종을 찾음
#   - 풀팩이 설치되어 있지 않으면 해당 파일이 없어 실패

[CmdletBinding()]
param(
    [string]$Output = "canvas-design-kr-v1.1.0.zip",
    [string]$Source = "",
    [switch]$NoVerifyCjk
)

$ErrorActionPreference = "Stop"
$Version = "v1.1.0"

# ─────────────── CJK 완전 지원 코어 5종 (출력 파일명) ───────────────
# 주의: NotoSansKR은 Google Fonts 원본에서 NotoSansKR[wght].ttf로 배포되나,
#       Claude Desktop ZIP 검증기가 대괄호를 거부하므로 NotoSansKR-VF.ttf로 리네임.
$CoreFonts = @(
    "NotoSansKR-VF.ttf",
    "NanumMyeongjo-OldHangul.ttf",
    "NanumBrushScript-Regular.ttf",
    "NanumPenScript-Regular.ttf",
    "JejuGothic-Regular.ttf"
)

# NotoSansKR 입력 파일명 대안 (build 시 이쪽이 있어도 VF로 리네임 복사)
$NotoSansKRAliases = @(
    "NotoSansKR-VF.ttf",
    "NotoSansKR[wght].ttf",
    "NotoSansKR-Variable.ttf"
)

# 대응하는 OFL 라이선스 파일 (존재하는 것만 복사)
$OflFiles = @(
    "Noto-CJK-OFL.txt",
    "NotoSansKR-OFL.txt",
    "Nanum-NAVER-OFL.txt",
    "JejuGothic-OFL.txt"
)

# NotoSansKR 소스 파일 실제 경로 찾기 (대괄호 문자 대비 -LiteralPath 사용)
function Find-NotoSansKR {
    param([string]$SrcDir)
    foreach ($alias in $NotoSansKRAliases) {
        $p = Join-Path $SrcDir $alias
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

# ─────────────── 경로 결정 ───────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir  = Split-Path -Parent $ScriptDir
if (-not $Source) {
    $Source = Join-Path $SkillDir "assets\fonts"
}

if (-not (Test-Path $Source)) {
    Write-Host "ERROR: 소스 폰트 디렉터리가 존재하지 않습니다: $Source" -ForegroundColor Red
    exit 1
}

Write-Host "── canvas-design-kr 코어 ZIP 빌드 ($Version) ──"
Write-Host "  소스 폰트: $Source"
Write-Host "  출력 파일: $Output"
Write-Host ""

# ─────────────── 코어 폰트 존재 검증 ───────────────
$Missing = @()
$NotoSrc = $null
foreach ($f in $CoreFonts) {
    if ($f -eq "NotoSansKR-VF.ttf") {
        # NotoSansKR은 별칭 중 하나가 있으면 OK
        $NotoSrc = Find-NotoSansKR -SrcDir $Source
        if (-not $NotoSrc) {
            $Missing += "NotoSansKR-VF.ttf (or NotoSansKR[wght].ttf, NotoSansKR-Variable.ttf)"
        }
    } else {
        $path = Join-Path $Source $f
        if (-not (Test-Path -LiteralPath $path)) {
            $Missing += $f
        }
    }
}

if ($Missing.Count -gt 0) {
    Write-Host "ERROR: 다음 코어 폰트가 소스 디렉터리에 없습니다:" -ForegroundColor Red
    $Missing | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
    Write-Host "풀팩이 설치되어 있어야 합니다. 먼저 실행:"
    Write-Host "  .\scripts\install_full_fonts.ps1"
    exit 1
}

Write-Host "✓ 코어 폰트 5종 모두 확인됨" -ForegroundColor Green
if ($NotoSrc -and (Split-Path -Leaf $NotoSrc) -ne "NotoSansKR-VF.ttf") {
    Write-Host "  i NotoSansKR 원본 파일명: $(Split-Path -Leaf $NotoSrc) → 출력시 NotoSansKR-VF.ttf로 리네임" -ForegroundColor Cyan
}

# ─────────────── CJK 한자 지원 실측 (빌드 전 검증) ───────────────
if (-not $NoVerifyCjk) {
    Write-Host ""
    Write-Host "▶ CJK 한자 지원 실측 중..."
    $verifyScript = Join-Path $ScriptDir "verify_cjk_support.py"
    $pyCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pyCmd) { $pyCmd = Get-Command python3 -ErrorAction SilentlyContinue }

    if (-not $pyCmd) {
        Write-Host "  ⚠ python 미설치 — CJK 검증 생략 (-NoVerifyCjk 로 경고 끄기 가능)" -ForegroundColor Yellow
    } elseif (-not (Test-Path -LiteralPath $verifyScript)) {
        Write-Host "  ⚠ scripts\verify_cjk_support.py 없음 — CJK 검증 생략" -ForegroundColor Yellow
    } else {
        # fontTools 설치 여부
        $ftCheck = & $pyCmd.Source -c "import fontTools" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ⚠ fontTools 미설치 — CJK 검증 생략" -ForegroundColor Yellow
            Write-Host "    설치: pip install fonttools --break-system-packages"
        } else {
            $null = & $pyCmd.Source $verifyScript $Source --strict 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ 코어 5종 모두 스킬 철학 한자(餘白丹靑縫補古調餘湍) 완전 지원" -ForegroundColor Green
            } else {
                Write-Host ""
                Write-Host "ERROR: CJK 검증 실패 — 일부 코어 폰트가 철학 한자를 지원하지 않습니다." -ForegroundColor Red
                Write-Host "       상세 결과:"
                & $pyCmd.Source $verifyScript $Source 2>&1 | Select-Object -Last 10 | ForEach-Object { Write-Host "         $_" }
                Write-Host ""
                Write-Host "       빌드를 강제로 진행하려면 -NoVerifyCjk 옵션 사용"
                exit 1
            }
        }
    }
}

# ─────────────── 필수 메타 파일 검증 ───────────────
$MetaFiles = @(
    "SKILL.md",
    "README.md",
    "changelog.md",
    "LICENSE.txt",
    "LICENSE-canvas-design.txt",
    "NOTICE.txt",
    "scripts\discover_fonts.py",
    "scripts\verify_cjk_support.py",
    "scripts\install_full_fonts.sh",
    "scripts\install_full_fonts.ps1",
    "scripts\build_core_from_fullpack.sh",
    "scripts\build_core_from_fullpack.ps1",
    "scripts\build_full_pack.sh",
    "scripts\build_full_pack.ps1"
)

$MetaMissing = @()
foreach ($f in $MetaFiles) {
    $path = Join-Path $SkillDir $f
    if (-not (Test-Path -LiteralPath $path)) {
        $MetaMissing += $f
    }
}

if ($MetaMissing.Count -gt 0) {
    Write-Host "ERROR: 다음 필수 파일이 누락되었습니다:" -ForegroundColor Red
    $MetaMissing | ForEach-Object { Write-Host "  - $_" }
    exit 1
}

Write-Host "✓ 필수 메타 파일 확인됨" -ForegroundColor Green

# ─────────────── 임시 스테이징 디렉터리 준비 ───────────────
$Stage = Join-Path $env:TEMP "canvas-design-kr-build-$(Get-Random)"
$Pkg = Join-Path $Stage "canvas-design-kr"
try {
    New-Item -ItemType Directory -Path $Pkg -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $Pkg "assets\fonts") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $Pkg "scripts") -Force | Out-Null

    # ─────────────── 메타 파일 복사 ───────────────
    Write-Host ""
    Write-Host "▶ 메타 파일 복사 중..."
    foreach ($f in $MetaFiles) {
        $src = Join-Path $SkillDir $f
        $dest = Join-Path $Pkg $f
        $destDir = Split-Path -Parent $dest
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -LiteralPath $src -Destination $dest -Force
    }

    # ─────────────── 코어 폰트 5종 복사 ───────────────
    Write-Host "▶ 코어 폰트 5종 복사 중..."
    foreach ($f in $CoreFonts) {
        if ($f -eq "NotoSansKR-VF.ttf") {
            # NotoSansKR은 소스에서 찾은 실제 파일을 VF 이름으로 복사
            $src = $NotoSrc
        } else {
            $src = Join-Path $Source $f
        }
        $dest = Join-Path (Join-Path $Pkg "assets\fonts") $f
        Copy-Item -LiteralPath $src -Destination $dest -Force
        $sizeMB = [Math]::Round((Get-Item -LiteralPath $dest).Length / 1MB, 2)
        Write-Host "    $f  ($sizeMB MB)"
    }

    # ─────────────── OFL 라이선스 파일 복사 ───────────────
    Write-Host "▶ OFL 라이선스 복사 중..."
    $OflCopied = 0
    foreach ($f in $OflFiles) {
        $src = Join-Path $Source $f
        if (Test-Path -LiteralPath $src) {
            $dest = Join-Path (Join-Path $Pkg "assets\fonts") $f
            Copy-Item -LiteralPath $src -Destination $dest -Force
            Write-Host "    $f"
            $OflCopied++
        }
    }
    # 매칭 실패 시 풀팩의 모든 OFL 복사 (백업)
    if ($OflCopied -eq 0) {
        Write-Host "  경고: 정확한 OFL 파일명 매칭 실패. 풀팩의 모든 OFL 파일을 복사."
        Get-ChildItem -Path $Source -File -Filter "*-OFL.txt" |
            ForEach-Object {
                $dest = Join-Path (Join-Path $Pkg "assets\fonts") $_.Name
                Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
            }
    }

    # ─────────────── MANIFEST.txt 재생성 ───────────────
    Write-Host "▶ MANIFEST.txt 생성 중..."
    $ManifestPath = Join-Path (Join-Path $Pkg "assets\fonts") "MANIFEST.txt"
    $ManifestLines = @(
        "# canvas-design-kr — Font Manifest"
        "# 이 파일은 assets/fonts/에 실제로 존재해야 하는 폰트 파일 목록의 표준 참조다."
        "# 풀팩 설치 시 인스톨러가 자동으로 갱신한다."
        "#"
        "# Format: <pack>:<filename>  (한 줄에 하나)"
        "#   pack = core | full"
        "#"
        "# 마지막 갱신: $(Get-Date -Format 'yyyy-MM-dd') ($Version 코어 패키지)"
        "# Pack: core (5 files, ~28.5 MB, CJK-complete)"
        ""
    )
    foreach ($f in ($CoreFonts | Sort-Object)) {
        $ManifestLines += "core:$f"
    }
    $ManifestLines | Set-Content -LiteralPath $ManifestPath -Encoding UTF8

    # ─────────────── 빌드 검증 ───────────────
    Write-Host ""
    Write-Host "▶ 빌드 검증..."
    $TotalSize = (Get-ChildItem -Path $Pkg -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $TotalMB = [Math]::Round($TotalSize / 1MB, 2)
    Write-Host "  비압축 크기: $TotalMB MB (Desktop 30 MB 한도 대비)"

    if ($TotalMB -gt 30) {
        Write-Host "  WARN: 30 MB를 초과합니다! Claude Desktop에서 거부될 수 있습니다." -ForegroundColor Yellow
    }

    $FileCount = (Get-ChildItem -Path $Pkg -Recurse -File).Count
    Write-Host "  전체 파일 수: $FileCount"

    # ─────────────── ZIP 생성 ───────────────
    Write-Host ""
    Write-Host "▶ ZIP 압축 중..."

    # 절대경로 변환
    if (-not [System.IO.Path]::IsPathRooted($Output)) {
        $OutputAbs = Join-Path (Get-Location).Path $Output
    } else {
        $OutputAbs = $Output
    }

    # 기존 ZIP 제거
    if (Test-Path -LiteralPath $OutputAbs) {
        Remove-Item -LiteralPath $OutputAbs -Force
    }

    # Compress-Archive 사용 (내장 cmdlet)
    $ProgressPreference = 'SilentlyContinue'
    Compress-Archive -Path (Join-Path $Stage "canvas-design-kr") -DestinationPath $OutputAbs -CompressionLevel Optimal
    $ProgressPreference = 'Continue'

    $ZipSize = (Get-Item -LiteralPath $OutputAbs).Length
    $ZipMB = [Math]::Round($ZipSize / 1MB, 2)

    Write-Host ""
    Write-Host "✓ 빌드 완료" -ForegroundColor Green
    Write-Host "  출력: $OutputAbs"
    Write-Host "  압축 크기: $ZipMB MB"
    Write-Host "  비압축 크기: $TotalMB MB"
    Write-Host ""
    Write-Host "다음 단계:"
    Write-Host "  1. Claude Desktop/claude.ai 웹: 이 ZIP을 설정 → Skills → Add Skill로 업로드"
    Write-Host "  2. Claude Code: Expand-Archive $OutputAbs -DestinationPath `"`$env:USERPROFILE\.claude\skills\`""
    Write-Host "  3. GitHub Release: 태그 $Version 푸시 시 Actions가 자동 빌드"

} finally {
    # 임시 디렉터리 정리
    if (Test-Path $Stage) {
        Remove-Item -Recurse -Force $Stage -ErrorAction SilentlyContinue
    }
}
