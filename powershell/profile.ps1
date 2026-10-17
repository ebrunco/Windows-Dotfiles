# Shared PowerShell 7 profile. Loaded from the stub in
# ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 (see install.ps1).

$DotfilesRoot = Split-Path -Parent $PSScriptRoot

# Fish-style inline suggestions from history (right arrow accepts)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Ctrl+R history search is built into PSReadLine. The PSFzf module is not used:
# it probes `fzf --version` on import, and fzf.exe is blocked by an Application
# Control policy on this machine (slow startup plus an error on every launch).

# Prompt (config lives in the repo) and smarter cd (use "z foldername")
$env:STARSHIP_CONFIG = Join-Path $DotfilesRoot 'starship\starship.toml'
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Linux-style commands. Aliases win over functions, so drop the built-ins first.
foreach ($name in 'ls', 'cat') {
  if (Test-Path "Alias:$name") { Remove-Item "Alias:$name" -Force }
}
function ls { eza --icons --group-directories-first @args }
function ll { eza -l --icons --git --group-directories-first @args }
function la { eza -la --icons --git --group-directories-first @args }
function lt { eza --tree --level=2 --icons @args }
function cat { bat --paging=never @args }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function which { (Get-Command @args).Source }
function touch { foreach ($f in $args) { if (Test-Path $f) { (Get-Item $f).LastWriteTime = Get-Date } else { New-Item -ItemType File $f | Out-Null } } }
Set-Alias vim nvim
Set-Alias top btop
Set-Alias lg lazygit
Set-Alias g git
