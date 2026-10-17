# Sets up this machine from the dotfiles repo. Safe to re-run.
#   git clone https://github.com/ebrunco/Windows-Dotfiles.git $HOME\.glzr
#   powershell -ExecutionPolicy Bypass -File $HOME\.glzr\install.ps1
#
# GlazeWM and Zebar read ~\.glzr directly, so they need no linking.

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# 1. Scoop and the apps in scoopfile.json.
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
  Invoke-RestMethod get.scoop.sh | Invoke-Expression
}
scoop import "$root\scoopfile.json"

# 2. PowerShell 7 profile: a stub that loads the one in this repo.
$profileDir = Join-Path $HOME 'Documents\PowerShell'
New-Item -ItemType Directory -Force $profileDir | Out-Null
$stub = Join-Path $profileDir 'Microsoft.PowerShell_profile.ps1'
$noBom = New-Object System.Text.UTF8Encoding $false
[IO.File]::WriteAllText($stub, ". '$root\powershell\profile.ps1'`r`n", $noBom)

# 3. Windows Terminal settings (copied, since Terminal rewrites the file).
# The saved file has the original username in the pwsh path; swap in this one.
$wt = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
if (Test-Path $wt) {
  $settings = [IO.File]::ReadAllText("$root\windows-terminal\settings.json")
  $settings = $settings.Replace('C:\\Users\\ericb', $HOME.Replace('\', '\\'))
  [IO.File]::WriteAllText("$wt\settings.json", $settings, $noBom)
} else {
  Write-Warning 'Windows Terminal not found; skipped its settings.'
}

# 4. Start GlazeWM at login.
$glaze = Join-Path $HOME 'scoop\apps\glazewm\current\glazewm.exe'
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name GlazeWM -Value "`"$glaze`" start"

Write-Host @'
Done. Manual step: to use Win+L as a keybind, disable Windows lock from an
elevated terminal, then sign out and back in:
  reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableLockWorkstation /t REG_DWORD /d 1 /f
'@
