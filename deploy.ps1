# 엄마 영어 단어장 - 한 번에 올리기
# 사용법 (이 폴더에서):
#   powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Message "바꾼 내용"
#   powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Message "바꾼 내용" -Level minor
# Level: patch = 작은 수정 (1.5.5 -> 1.5.6, 기본값)
#        minor = 기능·화면 변경 (1.5.5 -> 1.6)
#        major = 큰 개편 (1.5.5 -> 2.0)
# -DryRun 을 붙이면 아무것도 바꾸지 않고 무엇을 할지만 보여줍니다.

param(
  [Parameter(Mandatory = $true)][string]$Message,
  [ValidateSet("patch", "minor", "major")][string]$Level = "patch",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding $false
function Run-Git { $out = & git @args 2>&1 | Out-String; if ($LASTEXITCODE -ne 0) { throw "git $($args -join ' ') 실패:`n$out" }; return $out }
function Say($t, $c = "Gray") { Write-Host $t -ForegroundColor $c }

# 1) 바뀐 파일 확인
$changes = Run-Git status --short
if (-not $changes.Trim()) { Say "바뀐 파일이 없어요. 편집기에서 저장(Ctrl+S) 했는지 확인해 주세요." Yellow; exit 1 }
Say "`n[1/6] 바뀐 파일:" Cyan; Say $changes
Say (Run-Git diff --stat)

# 2) GitHub 최신 내용 받아오기 (내 변경은 그대로 유지)
Say "[2/6] GitHub 최신 내용 받아오기..." Cyan
if (-not $DryRun) { Say (Run-Git pull --rebase --autostash) }

# 3) 버전 올리기
$verPath = Join-Path $PSScriptRoot "version.js"
$verText = [System.IO.File]::ReadAllText($verPath, $utf8)
$m = [regex]::Match($verText, 'APP_VERSION = "(\d+)\.(\d+)(?:\.(\d+))?"')
if (-not $m.Success) { throw "version.js 에서 버전을 찾지 못했어요." }
$maj = [int]$m.Groups[1].Value; $min = [int]$m.Groups[2].Value; $pat = if ($m.Groups[3].Success) { [int]$m.Groups[3].Value } else { 0 }
$old = if ($m.Groups[3].Success) { "$maj.$min.$pat" } else { "$maj.$min" }
switch ($Level) {
  "patch" { $new = "$maj.$min." + ($pat + 1) }
  "minor" { $new = "$maj." + ($min + 1) }
  "major" { $new = "" + ($maj + 1) + ".0" }
}
Say "[3/6] 버전: V$old -> V$new" Cyan

# 4) 변경 기록(CHANGELOG.md) 맨 위에 추가
$date = Get-Date -Format "yyyy-MM-dd"
$entry = "## V$new ($date)`n`n- $Message`n`n"
Say "[4/6] 변경 기록에 추가:" Cyan; Say $entry

if ($DryRun) { Say "(연습 모드라서 여기서 멈춰요. 실제로는 아무것도 바뀌지 않았어요.)" Yellow; exit 0 }

$answer = Read-Host "이대로 올릴까요? (y/n)"
if ($answer -notmatch '^(y|Y|yes|ㅇ|응|네)$') { Say "취소했어요. 바뀐 파일은 그대로 있어요." Yellow; exit 0 }

[System.IO.File]::WriteAllText($verPath, $verText.Replace($m.Value, "APP_VERSION = `"$new`""), $utf8)
$logPath = Join-Path $PSScriptRoot "CHANGELOG.md"
$log = [System.IO.File]::ReadAllText($logPath, $utf8) -replace "`r`n", "`n"
$at = $log.IndexOf("`n## V")
if ($at -lt 0) { $log = $log + "`n" + $entry } else { $log = $log.Insert($at + 1, $entry) }
[System.IO.File]::WriteAllText($logPath, $log, $utf8)

# 5) 커밋 + 버전 표시(태그) + 올리기
Say "[5/6] 커밋하고 GitHub에 올리는 중..." Cyan
Run-Git add -A | Out-Null
Run-Git commit -q -m "V${new}: $Message" | Out-Null
Run-Git tag -a "v$new" -m "V$new" | Out-Null
Say (Run-Git push)
Say (Run-Git push origin "refs/tags/v$new")

# 6) 사이트에 반영됐는지 확인 (최대 약 5분)
Say "[6/6] 사이트 반영 기다리는 중 (1~2분)..." Cyan
$url = "https://forkrain.github.io/MomEnglish/version.js"
for ($i = 0; $i -lt 40; $i++) {
  try { $live = (Invoke-WebRequest "$url`?x=$(Get-Random)" -UseBasicParsing).Content } catch { $live = "" }
  if ($live -match [regex]::Escape("`"$new`"")) { Say "`n완료! 사이트가 V$new 로 바뀌었어요: https://forkrain.github.io/MomEnglish/" Green; exit 0 }
  Start-Sleep 8
}
Say "올리기는 끝났지만 사이트 반영이 아직이에요. 몇 분 뒤 사이트 맨 위 버전을 확인해 주세요." Yellow
