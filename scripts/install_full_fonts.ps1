# install_full_fonts.ps1 — canvas-design-kr 풀 폰트팩 자동 설치 (Windows)
#
# 사용법:
#   PowerShell> .\scripts\install_full_fonts.ps1
#   PowerShell> .\scripts\install_full_fonts.ps1 -Check
#   PowerShell> .\scripts\install_full_fonts.ps1 -Version v1.0.2
#
# 환경변수:
#   $env:CANVAS_DESIGN_KR_FONT_PACK_URL   직접 URL 지정 (기본값 무시)
#   $env:CANVAS_DESIGN_KR_INSTALL_DIR     설치 경로

[CmdletBinding()]
param(
    [switch]$Check,
    [string]$Version = "v1.0.2"
)

$ErrorActionPreference = "Stop"

# ─────────────── 설정 ───────────────
$GithubRepo = "Setynus/canvas-design-kr"
$AssetTemplate = "canvas-design-kr-fonts-full-{version}.zip"

# ─────────────── 경로 결정 ───────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir  = Split-Path -Parent $ScriptDir
$InstallDir = if ($env:CANVAS_DESIGN_KR_INSTALL_DIR) {
    $env:CANVAS_DESIGN_KR_INSTALL_DIR
} else {
    Join-Path $SkillDir "assets\fonts"
}

if (-not (Test-Path $InstallDir)) {
    Write-Host "ERROR: 설치 디렉토리가 존재하지 않습니다: $InstallDir" -ForegroundColor Red
    Write-Host "       canvas-design-kr 스킬이 올바르게 설치되었는지 확인하세요."
    exit 1
}

# ─────────────── 상태 확인 ───────────────
$CountBefore = (Get-ChildItem $InstallDir -File -Include *.ttf,*.otf -ErrorAction SilentlyContinue).Count
Write-Host "현재 설치된 폰트: $CountBefore 개"
Write-Host "설치 경로: $InstallDir"

if ($Check) {
    Write-Host ""
    Write-Host "── 코어 폰트 (이미 번들됨) ──"
    Get-ChildItem $InstallDir -File -Include *.ttf,*.otf |
        Sort-Object Name | Select-Object -First 40 |
        ForEach-Object { Write-Host "  $($_.Name)" }
    if ($CountBefore -gt 40) {
        Write-Host "  ... ($CountBefore 개 중 40개 표시)"
    }
    exit 0
}

if ($CountBefore -ge 100) {
    Write-Host ""
    Write-Host "✓ 이미 풀 폰트팩이 설치된 것으로 보입니다 ($CountBefore 개 폰트)." -ForegroundColor Green
    $yn = Read-Host "다시 설치하시겠습니까? [y/N]"
    if ($yn -notmatch '^[Yy]$') { exit 0 }
}

# ─────────────── 다운로드 URL 결정 ───────────────
if ($env:CANVAS_DESIGN_KR_FONT_PACK_URL) {
    $Url = $env:CANVAS_DESIGN_KR_FONT_PACK_URL
    Write-Host "환경변수 URL 사용: $Url"
} else {
    $AssetName = $AssetTemplate -replace '\{version\}', $Version
    $Url = "https://github.com/$GithubRepo/releases/download/$Version/$AssetName"
    Write-Host "다운로드 URL: $Url"
}

# ─────────────── 다운로드 ───────────────
$TmpDir = Join-Path $env:TEMP "canvas-design-kr-fontpack-$(Get-Random)"
New-Item -ItemType Directory -Path $TmpDir | Out-Null
$ZipPath = Join-Path $TmpDir "font_pack.zip"

Write-Host ""
Write-Host "▶ 풀 폰트팩 다운로드 중 (약 110 MB)..."
try {
    # PowerShell의 진행 표시는 매우 느리므로 비활성화
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Url -OutFile $ZipPath -UseBasicParsing
    $ProgressPreference = 'Continue'
} catch {
    Write-Host "ERROR: 다운로드 실패. URL을 확인하거나 네트워크를 점검하세요." -ForegroundColor Red
    Write-Host "       수동 다운로드: $Url"
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
    exit 1
}

# ─────────────── 압축 해제 ───────────────
Write-Host ""
Write-Host "▶ 압축 해제 중..."
$UnpackDir = Join-Path $TmpDir "unpacked"
Expand-Archive -Path $ZipPath -DestinationPath $UnpackDir -Force

# 폰트 위치 결정 (fonts/ 하위 또는 평탄)
$SrcDir = $null
if (Test-Path (Join-Path $UnpackDir "fonts")) {
    $SrcDir = Join-Path $UnpackDir "fonts"
} else {
    $firstFont = Get-ChildItem $UnpackDir -Recurse -Include *.ttf,*.otf | Select-Object -First 1
    if ($firstFont) {
        $SrcDir = $firstFont.DirectoryName
    } else {
        Write-Host "ERROR: 압축 파일에서 폰트를 찾을 수 없습니다." -ForegroundColor Red
        Remove-Item -Recurse -Force $TmpDir
        exit 1
    }
}

# ─────────────── 설치 ───────────────
Write-Host "▶ 설치 중 → $InstallDir"
$Installed = 0
$Skipped = 0
Get-ChildItem $SrcDir -File -Include *.ttf,*.otf,*.txt | ForEach-Object {
    $dest = Join-Path $InstallDir $_.Name
    if (Test-Path $dest) {
        $Skipped++
    } else {
        Copy-Item $_.FullName $dest
        $Installed++
    }
}

# ─────────────── 결과 ───────────────
$CountAfter = (Get-ChildItem $InstallDir -File -Include *.ttf,*.otf).Count
Write-Host ""
Write-Host "✓ 완료" -ForegroundColor Green
Write-Host "  새로 설치: $Installed 개 파일"
Write-Host "  이미 존재(스킵): $Skipped 개 파일"
Write-Host "  현재 폰트 총 개수: $CountBefore → $CountAfter"
Write-Host ""
Write-Host "이제 canvas-design-kr이 모든 한글·영문 폰트를 사용할 수 있습니다."

Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
