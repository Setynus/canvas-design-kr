# build_full_pack.ps1 — 로컬 전체 폰트에서 v1.1.0 풀팩 ZIP 빌드 (Windows)
#
# 유지보수자 전용: 풀팩이 설치된 assets\fonts\ (총 129종)에서 v1.1.0 코어 5종을
# 제외한 124종 + 모든 OFL 라이선스 파일을 추출해 풀팩 ZIP을 생성한다.
#
# 결과물은 install_full_fonts.ps1이 다운로드하는 ZIP과 동일한 구조:
#   canvas-design-kr-fonts-full-v1.1.0.zip
#     └── fonts\
#         ├── Pretendard-Regular.otf
#         ├── NanumGothic-Bold.ttf
#         ├── ... (총 124종)
#         └── *-OFL.txt
#
# 사용법:
#   PowerShell> .\scripts\build_full_pack.ps1
#   PowerShell> .\scripts\build_full_pack.ps1 -Output my-fullpack.zip
#   PowerShell> .\scripts\build_full_pack.ps1 -Source "C:\path\to\fonts"
#
# 전제조건:
#   - 이 스크립트는 canvas-design-kr 스킬 디렉터리 내 scripts\에 있어야 함
#   - -Source 미지정 시 ..\assets\fonts\에서 129종을 찾음
#   - install_full_fonts.ps1을 먼저 실행해 풀팩이 병합된 상태여야 함

[CmdletBinding()]
param(
    [string]$Output = "canvas-design-kr-fonts-full-v1.1.0.zip",
    [string]$Source = "",
    [int]$MinCount = 100
)

$ErrorActionPreference = "Stop"
$Version = "v1.1.0"

# ─────────────── v1.1.0 코어 5종 — 풀팩에서 제외 ───────────────
# 주의: NotoSansKR은 소스(로컬 풀팩)에 Google Fonts 원본 이름 NotoSansKR[wght].ttf 또는
#       v1.1.0에서 리네임된 NotoSansKR-VF.ttf 중 하나로 존재할 수 있다. 양쪽 모두 제외.
$CoreFonts = @(
    "NotoSansKR-VF.ttf",
    "NotoSansKR[wght].ttf",
    "NotoSansKR-Variable.ttf",
    "NanumMyeongjo-OldHangul.ttf",
    "NanumBrushScript-Regular.ttf",
    "NanumPenScript-Regular.ttf",
    "JejuGothic-Regular.ttf"
)

# ─────────────── 폰트 파일 수집 헬퍼 (대괄호 안전) ───────────────
function Get-FontFiles {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    Get-ChildItem -LiteralPath $Path -File -ErrorAction SilentlyContinue |
        Where-Object { @('.ttf', '.otf') -contains $_.Extension.ToLower() }
}

function Get-LicenseFiles {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    Get-ChildItem -LiteralPath $Path -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension.ToLower() -eq '.txt' -and
            ($_.Name -match 'OFL' -or $_.Name -match 'LICENSE' -or $_.Name -match 'license')
        }
}

# ─────────────── 경로 결정 ───────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir  = Split-Path -Parent $ScriptDir
if (-not $Source) {
    $Source = Join-Path $SkillDir "assets\fonts"
}

if (-not (Test-Path -LiteralPath $Source)) {
    Write-Host "ERROR: 소스 폰트 디렉터리가 존재하지 않습니다: $Source" -ForegroundColor Red
    exit 1
}

Write-Host "── canvas-design-kr 풀팩 ZIP 빌드 ($Version) ──"
Write-Host "  소스 폰트: $Source"
Write-Host "  출력 파일: $Output"
Write-Host ""

# ─────────────── 풀팩 설치 상태 검증 ───────────────
$AllFonts = @(Get-FontFiles -Path $Source)
$TotalFonts = $AllFonts.Count
Write-Host "소스 폰트 총 개수: $TotalFonts 종"

if ($TotalFonts -lt $MinCount) {
    Write-Host ""
    Write-Host "ERROR: 폰트가 $TotalFonts 개밖에 없습니다 (최소 $MinCount 개 필요)." -ForegroundColor Red
    Write-Host "       풀팩이 제대로 설치되지 않은 상태입니다."
    Write-Host "       먼저 다음을 실행하세요:"
    Write-Host "         .\scripts\install_full_fonts.ps1"
    Write-Host ""
    Write-Host "       이미 풀팩 ZIP을 가지고 계신 경우 압축 해제하여 폰트를"
    Write-Host "       $Source 에 복사한 뒤 이 스크립트를 다시 실행하세요."
    exit 1
}

Write-Host "✓ 풀팩 설치 상태 확인됨 ($TotalFonts ≥ $MinCount)" -ForegroundColor Green

# ─────────────── 코어 폰트 존재 검증 ───────────────
$CoreMissing = @()
foreach ($f in $CoreFonts) {
    $path = Join-Path $Source $f
    if (-not (Test-Path -LiteralPath $path)) {
        $CoreMissing += $f
    }
}
if ($CoreMissing.Count -gt 0) {
    Write-Host ""
    Write-Host "WARN: 다음 v1.1.0 코어 폰트가 소스에 없습니다 (풀팩에 자연스럽게 제외):" -ForegroundColor Yellow
    $CoreMissing | ForEach-Object { Write-Host "  - $_" }
}

# ─────────────── 임시 스테이징 디렉터리 준비 ───────────────
$Stage = Join-Path $env:TEMP "canvas-design-kr-fullpack-build-$(Get-Random)"
$Pkg = Join-Path $Stage "fonts"   # install_full_fonts.ps1이 기대하는 내부 구조: fonts\

try {
    New-Item -ItemType Directory -Path $Pkg -Force | Out-Null

    # ─────────────── 폰트 복사 (코어 5종 제외) ───────────────
    Write-Host ""
    Write-Host "▶ 풀팩 폰트 복사 중 (코어 5종 제외)..."
    $Copied = 0
    $Skipped = 0

    foreach ($f in $AllFonts) {
        if ($CoreFonts -contains $f.Name) {
            $Skipped++
        } else {
            $dest = Join-Path $Pkg $f.Name
            Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
            $Copied++
        }
    }

    Write-Host "  복사: $Copied 종 폰트"
    Write-Host "  제외(코어 별칭 매칭): $Skipped 종"
    if ($Skipped -gt 5) {
        Write-Host "    (NotoSansKR 원본·리네임 판본이 동시에 존재해 5보다 많을 수 있음)"
    }

    # ─────────────── OFL 라이선스 파일 전부 복사 ───────────────
    Write-Host "▶ OFL 라이선스 파일 복사 중..."
    $Licenses = @(Get-LicenseFiles -Path $Source)
    foreach ($f in $Licenses) {
        $dest = Join-Path $Pkg $f.Name
        Copy-Item -LiteralPath $f.FullName -Destination $dest -Force
    }
    Write-Host "  복사: $($Licenses.Count) 개 라이선스 파일"

    # ─────────────── 빌드 검증 ───────────────
    Write-Host ""
    Write-Host "▶ 빌드 검증..."
    $FinalFonts = @(Get-FontFiles -Path $Pkg).Count
    $TotalSize = (Get-ChildItem -LiteralPath $Pkg -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $TotalMB = [Math]::Round($TotalSize / 1MB, 1)

    Write-Host "  풀팩 폰트: $FinalFonts 종"
    Write-Host "  비압축 크기: $TotalMB MB"

    if ($FinalFonts -lt 100) {
        Write-Host "  WARN: 풀팩 폰트 수가 100 미만입니다. 구성을 확인하세요." -ForegroundColor Yellow
    }

    # ─────────────── ZIP 생성 ───────────────
    Write-Host ""
    Write-Host "▶ ZIP 압축 중..."

    # 절대경로 변환
    if (-not [System.IO.Path]::IsPathRooted($Output)) {
        $OutputAbs = Join-Path (Get-Location).Path $Output
    } else {
        $OutputAbs = $Output
    }

    if (Test-Path -LiteralPath $OutputAbs) {
        Remove-Item -LiteralPath $OutputAbs -Force
    }

    $ProgressPreference = 'SilentlyContinue'
    Compress-Archive -Path $Pkg -DestinationPath $OutputAbs -CompressionLevel Optimal
    $ProgressPreference = 'Continue'

    $ZipSize = (Get-Item -LiteralPath $OutputAbs).Length
    $ZipMB = [Math]::Round($ZipSize / 1MB, 1)

    Write-Host ""
    Write-Host "✓ 빌드 완료" -ForegroundColor Green
    Write-Host "  출력: $OutputAbs"
    Write-Host "  압축 크기: $ZipMB MB"
    Write-Host "  비압축 크기: $TotalMB MB"
    Write-Host "  수록 폰트: $FinalFonts 종 + $($Licenses.Count) 라이선스 파일"
    Write-Host ""
    Write-Host "다음 단계:"
    Write-Host "  1. GitHub Release 페이지에서 $Version 태그 Release 편집"
    Write-Host "  2. '$OutputAbs' 파일을 Release Asset으로 첨부 업로드"
    Write-Host "  3. 파일명은 반드시 'canvas-design-kr-fonts-full-$Version.zip' 유지"
    Write-Host "     (install_full_fonts.sh/ps1 스크립트가 이 파일명으로 다운로드)"
    Write-Host ""
    Write-Host "URL: https://github.com/Setynus/canvas-design-kr/releases/tag/$Version"

} finally {
    if (Test-Path -LiteralPath $Stage) {
        Remove-Item -Recurse -Force $Stage -ErrorAction SilentlyContinue
    }
}
