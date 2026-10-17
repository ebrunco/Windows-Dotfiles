# Windows dotfiles

GlazeWM + Zebar tiling setup, PowerShell 7 with a fish-like shell, and the
Linux-style tools I use, managed with Scoop.

| Path | What it is |
|---|---|
| `glazewm/config.yaml` | GlazeWM keybindings and window rules (Win-key based, hjkl) |
| `zebar/` | Zebar settings and the custom `rice` pill bar |
| `powershell/profile.ps1` | PowerShell 7 profile: suggestions, fzf, zoxide, starship, aliases |
| `starship/starship.toml` | Catppuccin powerline prompt |
| `windows-terminal/settings.json` | Windows Terminal profile and font |
| `scoopfile.json` | Apps installed with Scoop (`scoop export`) |
| `install.ps1` | Sets up a new machine from this repo |

## New machine

```powershell
git clone https://github.com/ebrunco/Windows-Dotfiles.git $HOME\.glzr
powershell -ExecutionPolicy Bypass -File $HOME\.glzr\install.ps1
```

Run it from Windows PowerShell; PowerShell 7 isn't installed yet on a new machine
(the script installs it).

The folder must be `~\.glzr`, since GlazeWM and Zebar read their config from there.

## Updating the Scoop list

After installing or removing apps: `scoop export > scoopfile.json`, then commit.
