#requires -Version 5.1
<#
    SettingsPowerstore v1.0
    Single-file PowerShell Console Installer UI

    Compatible:
      - Windows PowerShell 5.1
      - PowerShell 7+
      - Windows 10/11
      - ConHost / Windows Terminal

    Save as UTF-8 with BOM.
#>

#region =========================================================
# Config - Colors / Text / Speeds
#endregion =========================================================

$Config = @{
    Title          = "RANK1 INSTALLER"
    Version        = "v1.1"

    Width          = 90
    Height         = 32

    Purple         = @(124, 58, 237)   # #7C3AED
    Cyan           = @(6, 182, 212)    # #06B6D4
    Green          = @(34, 197, 94)
    Red            = @(239, 68, 68)
    Yellow         = @(250, 204, 21)

    White          = @(235, 235, 245)
    Gray           = @(145, 145, 160)
    DarkGray       = @(65, 65, 78)
    Black          = @(0, 0, 0)

    BootDelay      = 120
    RevealDelay    = 70
    FrameDelay     = 66
    SpinnerDelay   = 80
    FlashDelay     = 90
    PulseDelay     = 150
    FadeDelay      = 45

    BannerWaveStep = 0.018
    ProgressWidth  = 50

    FontName       = "Cascadia Mono"
    FontFallback   = "Consolas"
    FontSize       = 18

    FooterText     = "NAVIGATE   ENTER select   ESC exit"

    MenuItems      = @(
        "INSTALL"
        "UNINSTALL"
        "EXIT"
    )

    BootLines      = @(
        "[ OK ] Loading modules..."
        "[ OK ] Checking permissions..."
        "[ OK ] Ready."
    )

    InstallSteps   = @(
        "Initializing installer..."
        "Copying files..."
        "Writing configuration..."
        "Registering components..."
        "Finalizing installation..."
    )

    UninstallSteps = @(
        "Preparing uninstall..."
        "Removing files..."
        "Removing configuration..."
        "Unregistering components..."
        "Finalizing removal..."
    )

    # Used only when the script is launched with irm | iex.
    ScriptUrl      = "https://raw.githubusercontent.com/minatchanam-jpg/Settings.ps1/main/Settings.ps1"
}

$e = [char]27

# ASCII-safe character table. The source stays ASCII-only so "irm | iex"
# works reliably in Windows PowerShell 5.1 even with legacy code pages.
$C = @{
    Up        = [char]0x2191
    Down      = [char]0x2193
    Arrow     = [char]0x25B6
    Check     = [char]0x2714
    Cross     = [char]0x2716
    Warn      = [char]0x26A0
    TL        = [char]0x256D
    TR        = [char]0x256E
    BL        = [char]0x2570
    BR        = [char]0x256F
    H         = [char]0x2500
    V         = [char]0x2502
    Full      = [char]0x2588
    Light     = [char]0x2591
    Spinner1  = [char]0x280B
    Spinner2  = [char]0x2819
    Spinner3  = [char]0x2839
    Spinner4  = [char]0x2838
    Spinner5  = [char]0x28FC
    Spinner6  = [char]0x28F4
    Spinner7  = [char]0x28E6
    Spinner8  = [char]0x28E7
    Spinner9  = [char]0x2847
    Spinner10 = [char]0x284F
}


#endregion


#region =========================================================
# Install / Uninstall Placeholder Functions
# Replace ONLY the TODO sections later.
#endregion

function Invoke-Install {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Report
    )

    # =========================================================
    # TODO: PUT YOUR REAL INSTALL CODE HERE
    # =========================================================

    $progress = @(10, 40, 62, 82, 100)

    for ($i = 0; $i -lt $Config.InstallSteps.Count; $i++) {
        Start-Sleep -Milliseconds 500
        & $Report $Config.InstallSteps[$i] $progress[$i]
    }

    return $true
}

function Invoke-Uninstall {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Report
    )

    # =========================================================
    # TODO: PUT YOUR REAL UNINSTALL CODE HERE
    # =========================================================

    $progress = @(10, 40, 62, 82, 100)

    for ($i = 0; $i -lt $Config.UninstallSteps.Count; $i++) {
        Start-Sleep -Milliseconds 500
        & $Report $Config.UninstallSteps[$i] $progress[$i]
    }

    return $true
}

#endregion


#region =========================================================
# Console Setup
#endregion

[Console]::OutputEncoding = [Text.Encoding]::UTF8

try {
    [Console]::Title = $Config.Title
} catch {}

try {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "White"
} catch {}

# -------------------------------------------------------------
# Enable ANSI / VT processing on classic Windows console.
# -------------------------------------------------------------

try {
    if (-not ("Rank1.NativeConsole" -as [type])) {
        $csharp = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("dXNpbmcgU3lzdGVtOwp1c2luZyBTeXN0ZW0uUnVudGltZS5JbnRlcm9wU2VydmljZXM7CgpuYW1lc3BhY2UgUmFuazEKewogICAgcHVibGljIHN0YXRpYyBjbGFzcyBOYXRpdmVDb25zb2xlCiAgICB7CiAgICAgICAgW0RsbEltcG9ydCgia2VybmVsMzIuZGxsIiwgU2V0TGFzdEVycm9yPXRydWUpXQogICAgICAgIHB1YmxpYyBzdGF0aWMgZXh0ZXJuIEludFB0ciBHZXRTdGRIYW5kbGUoaW50IG5TdGRIYW5kbGUpOwoKICAgICAgICBbRGxsSW1wb3J0KCJrZXJuZWwzMi5kbGwiLCBTZXRMYXN0RXJyb3I9dHJ1ZSldCiAgICAgICAgcHVibGljIHN0YXRpYyBleHRlcm4gYm9vbCBHZXRDb25zb2xlTW9kZSgKICAgICAgICAgICAgSW50UHRyIGhDb25zb2xlSGFuZGxlLAogICAgICAgICAgICBvdXQgdWludCBscE1vZGUKICAgICAgICApOwoKICAgICAgICBbRGxsSW1wb3J0KCJrZXJuZWwzMi5kbGwiLCBTZXRMYXN0RXJyb3I9dHJ1ZSldCiAgICAgICAgcHVibGljIHN0YXRpYyBleHRlcm4gYm9vbCBTZXRDb25zb2xlTW9kZSgKICAgICAgICAgICAgSW50UHRyIGhDb25zb2xlSGFuZGxlLAogICAgICAgICAgICB1aW50IGR3TW9kZQogICAgICAgICk7CgogICAgICAgIFtTdHJ1Y3RMYXlvdXQoTGF5b3V0S2luZC5TZXF1ZW50aWFsLCBDaGFyU2V0PUNoYXJTZXQuVW5pY29kZSldCiAgICAgICAgcHVibGljIHN0cnVjdCBDT09SRAogICAgICAgIHsKICAgICAgICAgICAgcHVibGljIHNob3J0IFg7CiAgICAgICAgICAgIHB1YmxpYyBzaG9ydCBZOwogICAgICAgIH0KCiAgICAgICAgW1N0cnVjdExheW91dChMYXlvdXRLaW5kLlNlcXVlbnRpYWwsIENoYXJTZXQ9Q2hhclNldC5Vbmljb2RlKV0KICAgICAgICBwdWJsaWMgc3RydWN0IENPTlNPTEVfRk9OVF9JTkZPRVgKICAgICAgICB7CiAgICAgICAgICAgIHB1YmxpYyB1aW50IGNiU2l6ZTsKICAgICAgICAgICAgcHVibGljIHVpbnQgbkZvbnQ7CiAgICAgICAgICAgIHB1YmxpYyBDT09SRCBkd0ZvbnRTaXplOwogICAgICAgICAgICBwdWJsaWMgaW50IEZvbnRGYW1pbHk7CiAgICAgICAgICAgIHB1YmxpYyBpbnQgRm9udFdlaWdodDsKCiAgICAgICAgICAgIFtNYXJzaGFsQXMoVW5tYW5hZ2VkVHlwZS5CeVZhbFRTdHIsIFNpemVDb25zdD0zMildCiAgICAgICAgICAgIHB1YmxpYyBzdHJpbmcgRmFjZU5hbWU7CiAgICAgICAgfQoKICAgICAgICBbRGxsSW1wb3J0KCJrZXJuZWwzMi5kbGwiLCBDaGFyU2V0PUNoYXJTZXQuVW5pY29kZSwgU2V0TGFzdEVycm9yPXRydWUpXQogICAgICAgIHB1YmxpYyBzdGF0aWMgZXh0ZXJuIGJvb2wgU2V0Q3VycmVudENvbnNvbGVGb250RXgoCiAgICAgICAgICAgIEludFB0ciBoQ29uc29sZU91dHB1dCwKICAgICAgICAgICAgYm9vbCBiTWF4aW11bVdpbmRvdywKICAgICAgICAgICAgcmVmIENPTlNPTEVfRk9OVF9JTkZPRVggbHBDb25zb2xlQ3VycmVudEZvbnRFeAogICAgICAgICk7CiAgICB9Cn0="))
        Add-Type -TypeDefinition $csharp
    }
} catch {}

try {
    $stdout = [Rank1.NativeConsole]::GetStdHandle(-11)
    [uint32]$mode = 0

    if ([Rank1.NativeConsole]::GetConsoleMode($stdout, [ref]$mode)) {
        [void][Rank1.NativeConsole]::SetConsoleMode(
            $stdout,
            ($mode -bor 0x0004)
        )
    }
} catch {}

# -------------------------------------------------------------
# Detect Windows Terminal.
# -------------------------------------------------------------

$IsWindowsTerminal = [bool]$env:WT_SESSION

# -------------------------------------------------------------
# Set console font in classic ConHost only.
# -------------------------------------------------------------

if (-not $IsWindowsTerminal) {
    try {
        $stdout = [Rank1.NativeConsole]::GetStdHandle(-11)
        $font = New-Object Rank1.NativeConsole+CONSOLE_FONT_INFOEX

        $font.cbSize = [Runtime.InteropServices.Marshal]::SizeOf(
            [type]$font
        )
        $font.nFont = 0
        $font.dwFontSize = New-Object Rank1.NativeConsole+COORD
        $font.dwFontSize.X = 0
        $font.dwFontSize.Y = [int16]$Config.FontSize
        $font.FontFamily = 54
        $font.FontWeight = 400
        $font.FaceName = $Config.FontName

        $ok = [Rank1.NativeConsole]::SetCurrentConsoleFontEx(
            $stdout,
            $false,
            [ref]$font
        )

        if (-not $ok) {
            $font.FaceName = $Config.FontFallback
            [void][Rank1.NativeConsole]::SetCurrentConsoleFontEx(
                $stdout,
                $false,
                [ref]$font
            )
        }
    } catch {}
}

# -------------------------------------------------------------
# Set window/buffer size where the host permits it.
# Windows Terminal normally controls its own dimensions.
# -------------------------------------------------------------

if (-not $IsWindowsTerminal) {
    try {
        $raw = $Host.UI.RawUI

        $max = $raw.MaxPhysicalWindowSize

        $targetW = [Math]::Min($Config.Width,  $max.Width)
        $targetH = [Math]::Min($Config.Height, $max.Height)

        $buffer = $raw.BufferSize
        $buffer.Width  = [Math]::Max($buffer.Width,  $targetW)
        $buffer.Height = [Math]::Max($buffer.Height, $targetH)
        $raw.BufferSize = $buffer

        $window = $raw.WindowSize
        $window.Width  = $targetW
        $window.Height = $targetH
        $raw.WindowSize = $window
    } catch {}
}

#endregion


#region =========================================================
# Draw Helpers
#endregion

function Clamp {
    param(
        [int]$Value,
        [int]$Min,
        [int]$Max
    )

    if ($Value -lt $Min) { return $Min }
    if ($Value -gt $Max) { return $Max }
    return $Value
}

function RgbEscape {
    param(
        [int]$R,
        [int]$G,
        [int]$B
    )

    return "$e[38;2;${R};${G};${B}m"
}

function BgRgbEscape {
    param(
        [int]$R,
        [int]$G,
        [int]$B
    )

    return "$e[48;2;${R};${G};${B}m"
}

function Reset-Terminal {
    [Console]::Write("$e[0m")
}

function Get-GradientColor {
    param(
        [double]$T,
        [double]$Wave = 0
    )

    $t = $T + $Wave

    while ($t -ge 1) { $t -= 1 }
    while ($t -lt 0)  { $t += 1 }

    # Smooth wave instead of hard wrapping.
    $t = (1 - [Math]::Cos($t * [Math]::PI * 2)) / 2

    $p = $Config.Purple
    $c = $Config.Cyan

    $r = [int]($p[0] + (($c[0] - $p[0]) * $t))
    $g = [int]($p[1] + (($c[1] - $p[1]) * $t))
    $b = [int]($p[2] + (($c[2] - $p[2]) * $t))

    return @($r, $g, $b)
}

function Get-VisibleLength {
    param([string]$Text)

    # The UI text is intentionally kept to single-width Unicode
    # console glyphs. This function exists so layout is centralized.
    return $Text.Length
}

function Center-X {
    param([string]$Text)

    $x = [int](($Config.Width - (Get-VisibleLength $Text)) / 2)

    if ($x -lt 0) { return 0 }
    return $x
}

function Write-At {
    param(
        [int]$X,
        [int]$Y,
        [string]$Text,
        [string]$Color = $null,
        [string]$Background = $null
    )

    if ($X -lt 0 -or $Y -lt 0 -or $Y -ge $Config.Height) {
        return
    }

    if ($X -ge $Config.Width) {
        return
    }

    $available = $Config.Width - $X

    if ($Text.Length -gt $available) {
        $Text = $Text.Substring(0, $available)
    }

    try {
        [Console]::SetCursorPosition($X, $Y)
    } catch {
        return
    }

    if ($Background) {
        [Console]::Write($Background)
    }

    if ($Color) {
        [Console]::Write($Color)
    }

    [Console]::Write($Text)
    [Console]::Write("$e[0m")
}

function Write-Gradient {
    param(
        [int]$X,
        [int]$Y,
        [string]$Text,
        [double]$Wave = 0
    )

    if ($X -lt 0) { $X = 0 }
    if ($Y -lt 0 -or $Y -ge $Config.Height) { return }
    if ($X -ge $Config.Width) { return }

    $max = [Math]::Min(
        $Text.Length,
        ($Config.Width - $X)
    )

    if ($max -le 0) { return }

    try {
        [Console]::SetCursorPosition($X, $Y)
    } catch {
        return
    }

    for ($i = 0; $i -lt $max; $i++) {
        $t = if ($max -eq 1) { 0 } else { $i / ($max - 1) }
        $rgb = Get-GradientColor $t $Wave

        [Console]::Write(
            "$(RgbEscape $rgb[0] $rgb[1] $rgb[2])$($Text[$i])"
        )
    }

    [Console]::Write("$e[0m")
}

function Draw-Box {
    param(
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [string]$BorderColor = $null
    )

    if ($Width -lt 3 -or $Height -lt 3) { return }

    if (-not $BorderColor) {
        $BorderColor = RgbEscape `
            $Config.Purple[0] `
            $Config.Purple[1] `
            $Config.Purple[2]
    }

    $top    = "$($C.TL)" + ($C.H * ($Width - 2)) + "$($C.TR)"
    $bottom = "$($C.BL)" + ($C.H * ($Width - 2)) + "$($C.BR)"

    Write-At $X $Y $top $BorderColor

    for ($i = 1; $i -lt ($Height - 1); $i++) {
        Write-At $X ($Y + $i) "$($C.V)" $BorderColor
        Write-At ($X + $Width - 1) ($Y + $i) "$($C.V)" $BorderColor
    }

    Write-At $X ($Y + $Height - 1) $bottom $BorderColor
}

function Clear-Canvas {
    # IMPORTANT:
    # Do not use Clear-Host and do not rely on ESC[2J for frames.
    # Use cursor positioning + Erase Line (EL) instead. This avoids
    # wrapping/scrolling when a row reaches the right edge and prevents
    # old PowerShell prompt/output from showing through.
    for ($y = 0; $y -lt $Config.Height; $y++) {
        try {
            [Console]::SetCursorPosition(0, $y)
            [Console]::Write("$e[2K")
        } catch {}
    }

    try {
        [Console]::SetCursorPosition(0, 0)
    } catch {}

    Reset-Terminal
}

function Draw-Progress {
    param(
        [int]$X,
        [int]$Y,
        [int]$Percent
    )

    $Percent = Clamp $Percent 0 100

    $filled = [int][Math]::Round(
        ($Config.ProgressWidth * $Percent) / 100
    )

    $empty = $Config.ProgressWidth - $filled

    Write-At $X $Y "[" (
        RgbEscape `
            $Config.Gray[0] `
            $Config.Gray[1] `
            $Config.Gray[2]
    )

    if ($filled -gt 0) {
        $fill = $C.Full * $filled
        Write-Gradient `
            ($X + 1) `
            $Y `
            $fill `
            (($Percent / 100) * 0.35)
    }

    if ($empty -gt 0) {
        Write-At `
            ($X + 1 + $filled) `
            $Y `
            ($C.Light * $empty) `
            (
                RgbEscape `
                    $Config.DarkGray[0] `
                    $Config.DarkGray[1] `
                    $Config.DarkGray[2]
            )
    }

    Write-At `
        ($X + 1 + $Config.ProgressWidth) `
        $Y `
        ("] $($Percent.ToString().PadLeft(3))%") `
        (
            RgbEscape `
                $Config.White[0] `
                $Config.White[1] `
                $Config.White[2]
        )
}

#endregion


#region =========================================================
# System Information
#endregion

function Test-IsAdministrator {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)

        return $principal.IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
        )
    } catch {
        return $false
    }
}

function Get-OSName {
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        return $os.Caption
    } catch {
        try {
            return [Environment]::OSVersion.VersionString
        } catch {
            return "Windows"
        }
    }
}

$IsAdmin  = Test-IsAdministrator
$OSName   = Get-OSName
$UserName = [Environment]::UserName

#endregion


#region =========================================================
# Banner
#endregion

$BannerB64 = @(
    "4paE4paE4paE4paE4paE4paE4paEIOKWhOKWhOKWhOKWhOKWhOKWhOKWhCDiloQgICAgIOKWhCDiloTiloTiloTiloTiloTiloTiloQg4paE4paE4paE4paE4paE4paEICAg4paE4paE4paE4paE4paE4paE4paEIOKWhOKWhOKWhOKWhOKWhOKWhOKWhCDiloTiloTiloTiloTiloTiloTiloQg4paE4paE4paE4paE4paE4paEICAg4paE4paE4paE4paE4paE4paE4paE"
    "4paIICAgICAgIOKWiCAgICAgICDilogg4paIIOKWhCDilogg4paIICAgICAgIOKWiCAgIOKWhCAg4paIIOKWiCAgICAgICDiloggICAgICAg4paIICAgICAgIOKWiCAgIOKWhCAg4paIIOKWiCAgICAgICDilog="
    "4paIICAgIOKWhCAg4paIICAg4paEICAg4paIIOKWiOKWiCDilojilogg4paIICAgIOKWhOKWhOKWhOKWiCAg4paIIOKWiCDilogg4paIICDiloTiloTiloTiloTiloTilojiloQgICAgIOKWhOKWiCAgIOKWhCAgIOKWiCAg4paIIOKWiCDilogg4paIICAgIOKWhOKWhOKWhOKWiA=="
    "4paIICAg4paI4paE4paIIOKWiCAg4paIIOKWiCAg4paIICAgICAgIOKWiCAgIOKWiOKWhOKWhOKWhOKWiCAgIOKWiOKWhOKWhOKWiOKWhOKWiCDilojiloTiloTiloTiloTiloQgIOKWiCAgIOKWiCDiloggIOKWiCDiloggIOKWiCAgIOKWiOKWhOKWhOKWiOKWhOKWiCAgIOKWiOKWhOKWhOKWhA=="
    "4paIICAgIOKWhOKWhOKWhOKWiCAg4paI4paE4paIICDiloggICAgICAg4paIICAgIOKWhOKWhOKWhOKWiCAgICDiloTiloQgIOKWiOKWhOKWhOKWhOKWhOKWhCAg4paIIOKWiCAgIOKWiCDiloggIOKWiOKWhOKWiCAg4paIICAgIOKWhOKWhCAg4paIICAgIOKWhOKWhOKWhOKWiA=="
    "4paIICAg4paIICAg4paIICAgICAgIOKWiCAgIOKWhCAgIOKWiCAgIOKWiOKWhOKWhOKWhOKWiCAgIOKWiCAg4paIIOKWiOKWhOKWhOKWhOKWhOKWhOKWiCDilogg4paIICAg4paIIOKWiCAgICAgICDiloggICDiloggIOKWiCDiloggICDilojiloTiloTiloQ="
    "4paI4paE4paE4paE4paIICAg4paI4paE4paE4paE4paE4paE4paE4paE4paI4paE4paE4paIIOKWiOKWhOKWhOKWiOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWiOKWhOKWhOKWhOKWiCAg4paI4paE4paI4paE4paE4paE4paE4paE4paE4paE4paIIOKWiOKWhOKWhOKWhOKWiCDilojiloTiloTiloTiloTiloTiloTiloTilojiloTiloTiloTiloggIOKWiOKWhOKWiOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWiA=="
)

$Banner = foreach ($line in $BannerB64) {
    [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($line))
}

function Draw-Banner {
    param([double]$Wave = 0)

    # Banner occupies rows 1-7. Subtitle is row 9.
    $startY = 1

    for ($i = 0; $i -lt $Banner.Count; $i++) {
        $line = $Banner[$i]
        $x = Center-X $line
        Write-Gradient $x ($startY + $i) $line $Wave
    }

    $sub = "I N S T A L L E R   $($Config.Version)"

    Write-At `
        (Center-X $sub) `
        9 `
        $sub `
        (
            RgbEscape `
                $Config.Gray[0] `
                $Config.Gray[1] `
                $Config.Gray[2]
        )
}

#endregion


#region =========================================================
# Boot Animation
#endregion

function Invoke-Boot {
    Clear-Canvas

    $green = RgbEscape `
        $Config.Green[0] `
        $Config.Green[1] `
        $Config.Green[2]

    for ($i = 0; $i -lt $Config.BootLines.Count; $i++) {
        Write-At 3 (4 + $i) $Config.BootLines[$i] $green
        Start-Sleep -Milliseconds $Config.BootDelay
    }

    Start-Sleep -Milliseconds 200

    for ($i = 0; $i -lt $Banner.Count; $i++) {
        $y = 1 + $i
        $line = $Banner[$i]
        $x = Center-X $line

        $glitchChars = @($C.Light, [char]0x2592, [char]0x2593)

        for ($g = 0; $g -lt 2; $g++) {
            $glitch = ""

            for ($c = 0; $c -lt $line.Length; $c++) {
                $glitch += $glitchChars[
                    (Get-Random -Minimum 0 -Maximum $glitchChars.Count)
                ]
            }

            Write-At `
                $x `
                $y `
                $glitch `
                (
                    RgbEscape `
                        $Config.Purple[0] `
                        $Config.Purple[1] `
                        $Config.Purple[2]
                )

            Start-Sleep -Milliseconds 25
        }

        Write-Gradient $x $y $line 0
        Start-Sleep -Milliseconds $Config.RevealDelay
    }

    $sub = "I N S T A L L E R   $($Config.Version)"

    Write-At `
        (Center-X $sub) `
        9 `
        $sub `
        (
            RgbEscape `
                $Config.Gray[0] `
                $Config.Gray[1] `
                $Config.Gray[2]
        )

    Start-Sleep -Milliseconds 250
}

#endregion


#region =========================================================
# Admin Warning / Elevation
#endregion

function Draw-AdminWarning {
    if ($IsAdmin) {
        return $false
    }

    Clear-Canvas

    $x = 7
    $y = 11
    $w = $Config.Width - 14

    $yellow = RgbEscape `
        $Config.Yellow[0] `
        $Config.Yellow[1] `
        $Config.Yellow[2]

    Draw-Box $x $y $w 7 $yellow

    $msg = "WARNING: Administrator privileges are recommended."

    Write-At `
        (Center-X $msg) `
        ($y + 1) `
        $msg `
        $yellow

    $question = "Restart as Admin? [Y/N]"

    Write-At `
        (Center-X $question) `
        ($y + 4) `
        $question `
        $yellow

    while ($true) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)

            if ($key.Key -eq [ConsoleKey]::Y) {
                return $true
            }

            if ($key.Key -eq [ConsoleKey]::N) {
                return $false
            }

            if ($key.Key -eq [ConsoleKey]::Escape) {
                return $false
            }
        }

        Start-Sleep -Milliseconds 30
    }
}

function Restart-AsAdministrator {
    try {
        # When launched with irm | iex there is no local script path.
        # Re-run the remote command elevated in that case.
        $scriptPath = $PSCommandPath

        if ($scriptPath -and (Test-Path -LiteralPath $scriptPath)) {
            $powershellExe = (Get-Process -Id $PID).Path

            if (-not $powershellExe) {
                $powershellExe = "powershell.exe"
            }

            $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

            Start-Process `
                -FilePath $powershellExe `
                -ArgumentList $arg `
                -Verb RunAs

            return $true
        }

        $command = "irm '$($Config.ScriptUrl)' | iex"
        $powershellExe = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"

        Start-Process `
            -FilePath $powershellExe `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`"" `
            -Verb RunAs

        return $true
    } catch {
        return $false
    }
}

#endregion


#region =========================================================
# Menu Drawing
#endregion

function Draw-Menu {
    param(
        [int]$Selected,
        [double]$Wave
    )

    # All menu elements are placed in one fixed region.
    $boxX = 18
    $boxY = 11
    $boxW = 54
    $boxH = 7

    Draw-Box $boxX $boxY $boxW $boxH

    for ($i = 0; $i -lt $Config.MenuItems.Count; $i++) {
        $item = $Config.MenuItems[$i]
        $y = $boxY + 1 + $i
        $rowWidth = $boxW - 2

        # Always erase the complete row before drawing it.
        Write-At `
            ($boxX + 1) `
            $y `
            (" " * $rowWidth) `
            $null

        if ($i -eq $Selected) {
            $rgb = Get-GradientColor `
                (($i + 1) / $Config.MenuItems.Count) `
                $Wave

            $bg = BgRgbEscape $rgb[0] $rgb[1] $rgb[2]
            $fg = "$e[38;2;255;255;255m"

            $text = "$($C.Arrow)  $item"
            $padding = $rowWidth - $text.Length

            if ($padding -lt 0) {
                $padding = 0
            }

            Write-At `
                ($boxX + 1) `
                $y `
                ($text + (" " * $padding)) `
                $fg `
                $bg
        } else {
            $gray = RgbEscape `
                $Config.Gray[0] `
                $Config.Gray[1] `
                $Config.Gray[2]

            Write-At `
                ($boxX + 1) `
                $y `
                ("   " + $item) `
                $gray
        }
    }

    # Info line.
    $adminText = if ($IsAdmin) { "YES" } else { "NO" }
    $info = "OS: $OSName  |  User: $UserName  |  Admin: $adminText"

    $infoX = Center-X $info

    $gray = RgbEscape `
        $Config.Gray[0] `
        $Config.Gray[1] `
        $Config.Gray[2]

    if ($IsAdmin) {
        Write-At $infoX 19 $info $gray
    } else {
        $prefix = "OS: $OSName  |  User: $UserName  |  Admin: "
        $yellow = RgbEscape `
            $Config.Yellow[0] `
            $Config.Yellow[1] `
            $Config.Yellow[2]

        Write-At $infoX 19 $prefix $gray
        Write-At ($infoX + $prefix.Length) 19 "NO" $yellow
    }

    $footerColor = RgbEscape `
        $Config.DarkGray[0] `
        $Config.DarkGray[1] `
        $Config.DarkGray[2]

    Write-At `
        (Center-X $Config.FooterText) `
        28 `
        $Config.FooterText `
        $footerColor
}

#endregion


#region =========================================================
# Menu Loop
#endregion

function Invoke-Menu {
    param([int]$StartSelection = 0)

    $selected = $StartSelection
    $wave = 0.0

    while ($true) {
        # Clear only once per complete frame.
        Clear-Canvas
        Draw-Banner $wave
        Draw-Menu $selected $wave

        $wave += $Config.BannerWaveStep
        if ($wave -ge 1) { $wave -= 1 }

        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)

            switch ($key.Key) {
                ([ConsoleKey]::UpArrow) {
                    $selected--

                    if ($selected -lt 0) {
                        $selected = $Config.MenuItems.Count - 1
                    }
                }

                ([ConsoleKey]::DownArrow) {
                    $selected++

                    if ($selected -ge $Config.MenuItems.Count) {
                        $selected = 0
                    }
                }

                ([ConsoleKey]::Escape) {
                    return 2
                }

                ([ConsoleKey]::Enter) {
                    # Short selection flash.
                    $rgb = Get-GradientColor `
                        (($selected + 1) / $Config.MenuItems.Count) `
                        $wave

                    $boxX = 18
                    $boxY = 11
                    $boxW = 54
                    $rowY = $boxY + 1 + $selected
                    $rowW = $boxW - 2

                    Write-At `
                        ($boxX + 1) `
                        $rowY `
                        (" " * $rowW) `
                        $null `
                        (BgRgbEscape $rgb[0] $rgb[1] $rgb[2])

                    Start-Sleep -Milliseconds $Config.FlashDelay
                    return $selected
                }
            }
        }

        Start-Sleep -Milliseconds $Config.FrameDelay
    }
}

#endregion


#region =========================================================
# Confirmation
#endregion

function Confirm-Uninstall {
    Clear-Canvas

    $w = 66
    $h = 7
    $x = [int](($Config.Width - $w) / 2)
    $y = 11

    $red = RgbEscape `
        $Config.Red[0] `
        $Config.Red[1] `
        $Config.Red[2]

    Draw-Box $x $y $w $h $red

    $title = "$($C.Warn)  UNINSTALL CONFIRMATION"
    $question = "Are you sure? [Y/N]"

    Write-At `
        (Center-X $title) `
        ($y + 1) `
        $title `
        $red

    Write-At `
        (Center-X $question) `
        ($y + 4) `
        $question `
        $red

    while ($true) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)

            if ($key.Key -eq [ConsoleKey]::Y) {
                return $true
            }

            if ($key.Key -eq [ConsoleKey]::N) {
                return $false
            }

            if ($key.Key -eq [ConsoleKey]::Escape) {
                return $false
            }
        }

        Start-Sleep -Milliseconds 30
    }
}

#endregion


#region =========================================================
# Working Screen
#endregion

function Invoke-WorkingScreen {
    param(
        [ValidateSet("INSTALL", "UNINSTALL")]
        [string]$Action
    )

    Clear-Canvas

    $title = if ($Action -eq "INSTALL") {
        "INSTALLING RANK1"
    } else {
        "UNINSTALLING RANK1"
    }

    Write-Gradient `
        (Center-X $title) `
        3 `
        $title `
        0

    $spinnerFrames = @($C.Spinner1,$C.Spinner2,$C.Spinner3,$C.Spinner4,$C.Spinner5,$C.Spinner6,$C.Spinner7,$C.Spinner8,$C.Spinner9,$C.Spinner10)

    $state = @{
        Step     = "Preparing..."
        Percent  = 0
        LogLines = New-Object System.Collections.ArrayList
    }

    $Report = {
        param(
            [string]$Step,
            [int]$Percent
        )

        $state.Step = $Step
        $state.Percent = Clamp $Percent 0 100

        [void]$state.LogLines.Add($Step)

        # Render immediately so the UI does not wait until the
        # entire placeholder function has finished.
        $spinner = $spinnerFrames[($state.LogLines.Count - 1) % $spinnerFrames.Count]

        $spinnerColor = Get-GradientColor `
            ((($state.LogLines.Count - 1) % 10) / 10) `
            0

        Write-At `
            17 `
            7 `
            $spinner `
            (RgbEscape `
                $spinnerColor[0] `
                $spinnerColor[1] `
                $spinnerColor[2])

        Write-At `
            21 `
            7 `
            (" " * 52) `
            $null

        $stepColor = RgbEscape `
            $Config.White[0] `
            $Config.White[1] `
            $Config.White[2]

        $shownStep = $Step

        if ($shownStep.Length -gt 50) {
            $shownStep = $shownStep.Substring(0, 50)
        }

        Write-At 21 7 $shownStep $stepColor

        Draw-Progress 18 9 $state.Percent

        # Finished log line.
        $logY = 12 + ($state.LogLines.Count - 1)

        if ($logY -lt 26) {
            $green = RgbEscape `
                $Config.Green[0] `
                $Config.Green[1] `
                $Config.Green[2]

            Write-At $Config.Width 0 "" $green

            Write-At `
                16 `
                $logY `
                "$($C.Check)" `
                $green

            Write-At `
                19 `
                $logY `
                ("-> $Step... done") `
                $green
        }
    }

    try {
        if ($Action -eq "INSTALL") {
            $result = Invoke-Install -Report $Report
        } else {
            $result = Invoke-Uninstall -Report $Report
        }

        # Keep the completed state visible briefly.
        Start-Sleep -Milliseconds 250

        if ($result -eq $false) {
            return @{
                Success = $false
                Error   = "The operation returned FALSE."
            }
        }

        return @{
            Success = $true
            Error   = $null
        }
    } catch {
        return @{
            Success = $false
            Error   = $_.Exception.Message
        }
    }
}

#endregion


#region =========================================================
# Result Screens
#endregion

function Show-Success {
    param([string]$Action)

    $text = if ($Action -eq "INSTALL") {
        "$($C.Check) INSTALL COMPLETE"
    } else {
        "$($C.Check) UNINSTALL COMPLETE"
    }

    $boxW = 60
    $boxH = 8
    $boxX = [int](($Config.Width - $boxW) / 2)
    $boxY = 10

    for ($pulse = 0; $pulse -lt 3; $pulse++) {
        Clear-Canvas

        $green = if (($pulse % 2) -eq 0) {
            RgbEscape `
                $Config.Green[0] `
                $Config.Green[1] `
                $Config.Green[2]
        } else {
            RgbEscape 15 100 45
        }

        Draw-Box $boxX $boxY $boxW $boxH $green

        Write-At `
            (Center-X $text) `
            ($boxY + 3) `
            $text `
            $green

        Start-Sleep -Milliseconds $Config.PulseDelay
    }

    $hint = "Press any key to return to menu..."

    Write-At `
        (Center-X $hint) `
        22 `
        $hint `
        (
            RgbEscape `
                $Config.DarkGray[0] `
                $Config.DarkGray[1] `
                $Config.DarkGray[2]
        )

    [void][Console]::ReadKey($true)
}

function Show-Error {
    param([string]$ErrorMessage)

    $boxW = 58
    $boxH = 10
    $baseX = [int](($Config.Width - $boxW) / 2)
    $y = 9

    $red = RgbEscape `
        $Config.Red[0] `
        $Config.Red[1] `
        $Config.Red[2]

    for ($shake = 0; $shake -lt 6; $shake++) {
        Clear-Canvas

        $offset = if (($shake % 2) -eq 0) { 2 } else { -2 }
        $x = $baseX + $offset

        Draw-Box $x $y $boxW $boxH $red

        $title = "$($C.Cross) FAILED"

        Write-At `
            ($x + [int](($boxW - $title.Length) / 2)) `
            ($y + 2) `
            $title `
            $red

        Start-Sleep -Milliseconds 55
    }

    Clear-Canvas
    Draw-Box $baseX $y $boxW $boxH $red

    $title = "$($C.Cross) FAILED"

    Write-At `
        (Center-X $title) `
        ($y + 2) `
        $title `
        $red

    $errorText = if ($ErrorMessage) {
        [string]$ErrorMessage
    } else {
        "Unknown error."
    }

    if ($errorText.Length -gt 50) {
        $errorText = $errorText.Substring(0, 47) + "..."
    }

    Write-At `
        (Center-X $errorText) `
        ($y + 5) `
        $errorText `
        $red

    $hint = "Press any key to return to menu..."

    Write-At `
        (Center-X $hint) `
        22 `
        $hint `
        (
            RgbEscape `
                $Config.DarkGray[0] `
                $Config.DarkGray[1] `
                $Config.DarkGray[2]
        )

    [void][Console]::ReadKey($true)
}

#endregion


#region =========================================================
# Exit Animation
#endregion

function Invoke-Exit {
    Clear-Canvas

    $text = "RANK1"

    for ($fade = 5; $fade -ge 0; $fade--) {
        Clear-Canvas

        $factor = $fade / 5

        $r = [int]($Config.Purple[0] * $factor)
        $g = [int]($Config.Purple[1] * $factor)
        $b = [int]($Config.Purple[2] * $factor)

        Write-At `
            (Center-X $text) `
            13 `
            $text `
            (RgbEscape $r $g $b)

        Start-Sleep -Milliseconds $Config.FadeDelay
    }

    Clear-Canvas

    Write-At `
        (Center-X "Goodbye.") `
        15 `
        "Goodbye." `
        (
            RgbEscape `
                $Config.Gray[0] `
                $Config.Gray[1] `
                $Config.Gray[2]
        )

    Start-Sleep -Milliseconds 450
}

#endregion


#region =========================================================
# Main
#endregion

# Hide cursor while the UI is running.
[Console]::Write("$e[?25l")

try {
    Invoke-Boot

    if (-not $IsAdmin) {
        $restart = Draw-AdminWarning

        if ($restart) {
            [Console]::Write("$e[?25h")

            if (Restart-AsAdministrator) {
                exit
            }

            # If elevation failed/cancelled, continue normally.
            [Console]::Write("$e[?25l")
        }
    }

    $selection = 0

    while ($true) {
        $selection = Invoke-Menu $selection

        # ESC or EXIT.
        if ($selection -eq 2) {
            break
        }

        # INSTALL.
        if ($selection -eq 0) {
            $result = Invoke-WorkingScreen "INSTALL"

            if ($result.Success) {
                Show-Success "INSTALL"
            } else {
                Show-Error $result.Error
            }
        }

        # UNINSTALL.
        if ($selection -eq 1) {
            $confirmed = Confirm-Uninstall

            if ($confirmed) {
                $result = Invoke-WorkingScreen "UNINSTALL"

                if ($result.Success) {
                    Show-Success "UNINSTALL"
                } else {
                    Show-Error $result.Error
                }
            }
        }
    }

    Invoke-Exit
}
finally {
    # Always restore cursor and terminal colors, including Ctrl+C.
    [Console]::Write("$e[?25h")
    [Console]::Write("$e[0m")

    try {
        [Console]::CursorVisible = $true
    } catch {}

    try {
        [Console]::ResetColor()
    } catch {}
}

#endregion
