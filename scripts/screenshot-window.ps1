# Screenshot the focused window: saves a PNG to Pictures\Screenshots, copies it
# to the clipboard and plays a sound. Run with -STA (clipboard needs it);
# GlazeWM launches it through screenshot-window.vbs from win+shift+d.

# Sound played after the capture. Try e.g. 'chord.wav', 'Windows Ding.wav' or
# 'Windows Notify System Generic.wav' from C:\Windows\Media.
$SoundFile = 'C:\Windows\Media\ding.wav'

# Debug trail shared with the .vbs launcher (screenshot.log is git-ignored).
$LogFile = Join-Path $PSScriptRoot 'screenshot.log'
function Write-Log($message) {
  "{0}  {1}" -f (Get-Date), $message | Add-Content -Path $LogFile
}

try {
  Write-Log 'ps1 started'

  Add-Type -AssemblyName System.Windows.Forms, System.Drawing
  Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class WinShot {
  [StructLayout(LayoutKind.Sequential)]
  public struct RECT { public int Left, Top, Right, Bottom; }
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr h, int attr, out RECT r, int size);
}
"@

  # Use real pixels, not DPI-scaled ones, so the capture area matches the window.
  [void][WinShot]::SetProcessDPIAware()

  # Ask GlazeWM which window it has focused (the one with the colored border).
  # Windows' own "foreground window" can differ from it, so only fall back to
  # that if GlazeWM can't answer.
  $hwnd = [IntPtr]::Zero
  try {
    $glazewm = Join-Path $HOME 'scoop\apps\glazewm\current\cli\glazewm.exe'
    $focused = (& $glazewm query focused | ConvertFrom-Json).data.focused
    if ($focused.type -eq 'window' -and $focused.handle) {
      $hwnd = [IntPtr][int64]$focused.handle
      Write-Log "glazewm focused: $($focused.processName) '$($focused.title)'"
    }
  } catch {
    Write-Log "glazewm query failed: $($_.Exception.Message)"
  }
  if ($hwnd -eq [IntPtr]::Zero) {
    $hwnd = [WinShot]::GetForegroundWindow()
    Write-Log 'using foreground window fallback'
  }
  if ($hwnd -eq [IntPtr]::Zero) { Write-Log 'no window to capture'; exit 1 }

  # Extended frame bounds excludes the invisible resize border and shadow.
  $rect = New-Object WinShot+RECT
  $DWMWA_EXTENDED_FRAME_BOUNDS = 9
  if ([WinShot]::DwmGetWindowAttribute($hwnd, $DWMWA_EXTENDED_FRAME_BOUNDS, [ref]$rect, 16) -ne 0) {
    [void][WinShot]::GetWindowRect($hwnd, [ref]$rect)
  }

  $width = $rect.Right - $rect.Left
  $height = $rect.Bottom - $rect.Top
  if ($width -le 0 -or $height -le 0) { Write-Log "bad window size ${width}x${height}"; exit 1 }

  $bitmap = New-Object System.Drawing.Bitmap $width, $height
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  $graphics.Dispose()

  $dir = Join-Path ([Environment]::GetFolderPath('MyPictures')) 'Screenshots'
  New-Item -ItemType Directory -Force $dir | Out-Null
  $path = Join-Path $dir ("window-{0:yyyyMMdd-HHmmss}.png" -f (Get-Date))
  $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  [System.Windows.Forms.Clipboard]::SetImage($bitmap)
  $bitmap.Dispose()
  Write-Log "saved $path"

  # Confirmation sound. PlaySync keeps the script alive until it finishes.
  if (Test-Path $SoundFile) {
    (New-Object System.Media.SoundPlayer $SoundFile).PlaySync()
    Write-Log 'sound played'
  } else {
    Write-Log "sound file missing: $SoundFile"
  }
} catch {
  Write-Log "ERROR: $($_.Exception.Message)"
  exit 1
}
