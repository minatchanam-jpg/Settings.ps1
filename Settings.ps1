#requires -Version 5.1
<#
    RANK1 INSTALLER v1.0
    Single-file PowerShell Console Installer UI

    Compatible:
      - Windows PowerShell 5.1
      - PowerShell 7+
      - Windows 10/11
      - ConHost / Windows Terminal

    Save this file as UTF-8 with BOM.
#>

#region =========================================================
# Config - Colors / Text / Speeds
#endregion =========================================================

$Config = @{
    Title              = "RANK1 INSTALLER"
    Version            = "v1.0"

    Width              = 90
    Height             = 32

    Purple             = @(124, 58, 237)    # #7C3AED
    Cyan               = @(6, 182, 212)     # #06B6D4
    Green              = @(34, 197, 94)
    Red                = @(239, 68, 68)
    Yellow             = @(250, 204, 21)

    White              = @(235, 235, 245)
    Gray               = @(145, 145, 160)
    DarkGray           = @(65, 65, 78)

    BootDelay          = 120
    RevealDelay        = 70
    FrameDelay         = 66       # ~15 FPS
    SpinnerDelay       = 80
    FlashDelay          = 70
    PulseDelay          = 150
    FadeDelay           = 35

    BannerWaveSpeed     = 0.12

    ProgressWidth       = 50

    FontName            = "Cascadia Mono"
    FontFallback        = "Consolas"
    FontSize            = 18

    FooterText          = "↑↓ navigate   ENTER select   ESC exit"

    MenuItems           = @(
        "INSTALL"
        "UNINSTALL"
        "EXIT"
    )

    BootLines           = @(
        "[ OK ] Loading modules..."
        "[ OK ] Checking permissions..."
        "[ OK ] Ready."
    )

    InstallSteps        = @(
        "Initializing installer..."
        "Copying files..."
        "Writing configuration..."
        "Registering components..."
        "Finalizing installation..."
    )

    UninstallSteps      = @(
        "Preparing uninstall..."
        "Removing files..."
        "Removing configuration..."
        "Unregistering components..."
        "Finalizing removal..."
    )
}

$e = [char]27

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

    $steps = $Config.InstallSteps

    $progress = @(10, 40, 62, 82, 100)

    for ($i = 0; $i -lt $steps.Count; $i++) {
        Start-Sleep -Milliseconds 500

        # Report current step + progress to UI
        & $Report $steps[$i] $progress[$i]
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

    $steps = $Config.UninstallSteps

    $progress = @(10, 40, 62, 82, 100)

    for ($i = 0; $i -lt $steps.Count; $i++) {
        Start-Sleep -Milliseconds 500

        # Report current step + progress to UI
        & $Report $steps[$i] $progress[$i]
    }

    return $true
}

#endregion


#region =========================================================
# Console Setup
#endregion

[Console]::OutputEncoding = [Text.Encoding]::UTF8

$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"

try {
    $Host.UI.RawUI.WindowTitle = $Config.Title
}
catch {}

# -------------------------------------------------------------
# Enable ANSI / VT processing on classic Windows console
# -------------------------------------------------------------

try {
    if (-not ("Rank1.NativeConsole" -as [type])) {

        Add-Type @"
using System;
using System.Runtime.InteropServices;

namespace Rank1
{
    public static class NativeConsole
    {
        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern IntPtr GetStdHandle(int nStdHandle);

        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern bool GetConsoleMode(
            IntPtr hConsoleHandle,
            out uint lpMode
        );

        [DllImport("kernel32.dll", SetLastError=true)]
        public static extern bool SetConsoleMode(
            IntPtr hConsoleHandle,
            uint dwMode
        );

        [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
        public struct COORD
        {
            public short X;
            public short Y;
        }

        [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
        public struct CONSOLE_FONT_INFOEX
        {
            public uint cbSize;
            public uint nFont;
            public COORD dwFontSize;
            public int FontFamily;
            public int FontWeight;

            [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)]
            public string FaceName;
        }

        [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
        public static extern bool SetCurrentConsoleFontEx(
            IntPtr hConsoleOutput,
            bool bMaximumWindow,
            ref CONSOLE_FONT_INFOEX lpConsoleCurrentFontEx
        );
    }
}
"@
    }
}
catch {}

# -------------------------------------------------------------
# Enable VT
# -------------------------------------------------------------

try {
    $stdout = [Rank1.NativeConsole]::GetStdHandle(-11)

    [uint32]$mode = 0

    if ([Rank1.NativeConsole]::GetConsoleMode($stdout, [ref]$mode)) {
        [void][Rank1.NativeConsole]::SetConsoleMode(
            $stdout,
            ($mode -bor 0x0004)
        )
    }
}
catch {}

# -------------------------------------------------------------
# Detect Windows Terminal
# -------------------------------------------------------------

$IsWindowsTerminal = $false

if ($env:WT_SESSION) {
    $IsWindowsTerminal = $true
}

# -------------------------------------------------------------
# Console Font
# Skip in Windows Terminal.
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
    }
    catch {
        # Ignore font errors.
    }
}

# -------------------------------------------------------------
# Console dimensions
# -------------------------------------------------------------

try {
    $raw = $Host.UI.RawUI

    $buffer = $raw.BufferSize

    if ($buffer.Width -lt $Config.Width) {
        $buffer.Width = $Config.Width
    }

    if ($buffer.Height -lt $Config.Height) {
        $buffer.Height = $Config.Height
    }

    $raw.BufferSize = $buffer

    $window = $raw.WindowSize
    $window.Width = [Math]::Min(
        $Config.Width,
        $raw.MaxPhysicalWindowSize.Width
    )
    $window.Height = [Math]::Min(
        $Config.Height,
        $raw.MaxPhysicalWindowSize.Height
    )

    $raw.WindowSize = $window
}
catch {
    # Some terminals manage their own size.
}

#endregion


#region =========================================================
# Helper Functions
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

function Write-At {
    param(
        [int]$X,
        [int]$Y,
        [string]$Text,
        [string]$Color = $null,
        [switch]$NoReset
    )

    if ($X -lt 0 -or $Y -lt 0) {
        return
    }

    try {
        [Console]::SetCursorPosition($X, $Y)
    }
    catch {
        return
    }

    if ($Color) {
        [Console]::Write($Color)
    }

    [Console]::Write($Text)

    if (-not $NoReset) {
        [Console]::Write("$e[0m")
    }
}

function Get-GradientColor {
    param(
        [double]$T,
        [double]$Wave = 0
    )

    $t = $T + $Wave

    while ($t -gt 1) { $t -= 1 }
    while ($t -lt 0) { $t += 1 }

    $p = $Config.Purple
    $c = $Config.Cyan

    $r = [int]($p[0] + (($c[0] - $p[0]) * $t))
    $g = [int]($p[1] + (($c[1] - $p[1]) * $t))
    $b = [int]($p[2] + (($c[2] - $p[2]) * $t))

    return @($r, $g, $b)
}

function Write-Gradient {
    param(
        [int]$X,
        [int]$Y,
        [string]$Text,
        [double]$Wave = 0
    )

    try {
        [Console]::SetCursorPosition($X, $Y)
    }
    catch {
        return
    }

    $length = $Text.Length

    if ($length -le 0) {
        return
    }

    for ($i = 0; $i -lt $length; $i++) {

        $t = if ($length -eq 1) {
            0
        }
        else {
            $i / ($length - 1)
        }

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

    if (-not $BorderColor) {
        $BorderColor = RgbEscape `
            $Config.Purple[0] `
            $Config.Purple[1] `
            $Config.Purple[2]
    }

    $top    = "╭" + ("─" * ($Width - 2)) + "╮"
    $bottom = "╰" + ("─" * ($Width - 2)) + "╯"

    Write-At $X $Y $top $BorderColor

    for ($i = 1; $i -lt ($Height - 1); $i++) {

        Write-At $X $($Y + $i) "│" $BorderColor

        Write-At `
            ($X + $Width - 1) `
            ($Y + $i) `
            "│" `
            $BorderColor
    }

    Write-At $X ($Y + $Height - 1) $bottom $BorderColor
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

    Write-At `
        $X `
        $Y `
        "[" `
        (RgbEscape $Config.Gray[0] $Config.Gray[1] $Config.Gray[2])

    if ($filled -gt 0) {

        $fill = "█" * $filled

        Write-Gradient `
            ($X + 1) `
            $Y `
            $fill `
            (($Percent / 100) * 0.5)
    }

    if ($empty -gt 0) {

        Write-At `
            ($X + 1 + $filled) `
            $Y `
            ("░" * $empty) `
            (RgbEscape $Config.DarkGray[0] $Config.DarkGray[1] $Config.DarkGray[2])
    }

    Write-At `
        ($X + 1 + $Config.ProgressWidth) `
        $Y `
        "] $($Percent.ToString().PadLeft(3))%" `
        (RgbEscape $Config.White[0] $Config.White[1] $Config.White[2])
}

function Center-X {
    param([string]$Text)

    return [int](($Config.Width - $Text.Length) / 2)
}

function Blank-Line {
    param([int]$Y)

    Write-At `
        0 `
        $Y `
        (" " * $Config.Width)
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
    }
    catch {
        return $false
    }
}

$IsAdmin = Test-IsAdministrator

function Get-OSName {

    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop

        return $os.Caption
    }
    catch {

        try {
            return [Environment]::OSVersion.VersionString
        }
        catch {
            return "Windows"
        }
    }
}

$OSName = Get-OSName
$UserName = [Environment]::UserName

#endregion


#region =========================================================
# Banner
#endregion

$Banner = @(
"▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄     ▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄   ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄   ▄▄▄▄▄▄▄"
"█       █       █ █ ▄ █ █       █   ▄  █ █       █       █       █   ▄  █ █       █"
"█    ▄  █   ▄   █ ██ ██ █    ▄▄▄█  █ █ █ █  ▄▄▄▄▄█▄     ▄█   ▄   █  █ █ █ █    ▄▄▄█"
"█   █▄█ █  █ █  █       █   █▄▄▄█   █▄▄█▄█ █▄▄▄▄▄  █   █ █  █ █  █   █▄▄█▄█   █▄▄▄"
"█    ▄▄▄█  █▄█  █       █    ▄▄▄█    ▄▄  █▄▄▄▄▄  █ █   █ █  █▄█  █    ▄▄  █    ▄▄▄█"
"█   █   █       █   ▄   █   █▄▄▄█   █  █ █▄▄▄▄▄█ █ █   █ █       █   █  █ █   █▄▄▄"
"█▄▄▄█   █▄▄▄▄▄▄▄█▄▄█ █▄▄█▄▄▄▄▄▄▄█▄▄▄█  █▄█▄▄▄▄▄▄▄█ █▄▄▄█ █▄▄▄▄▄▄▄█▄▄▄█  █▄█▄▄▄▄▄▄▄█"
)

function Draw-Banner {
    param(
        [double]$Wave = 0
    )

    $startY = 2

    for ($i = 0; $i -lt $Banner.Count; $i++) {

        $line = $Banner[$i]

        $x = Center-X $line

        Write-Gradient `
            $x `
            ($startY + $i) `
            $line `
            $Wave
    }

    $sub = "I N S T A L L E R   $($Config.Version)"

    $subColor = RgbEscape `
        $Config.Gray[0] `
        $Config.Gray[1] `
        $Config.Gray[2]

    Write-At `
        (Center-X $sub) `
        9 `
        $sub `
        $subColor
}

#endregion


#region =========================================================
# Boot Animation
#endregion

function Invoke-Boot {

    # Clear screen once at startup.
    [Console]::Write("$e[2J$e[H")

    $green = RgbEscape `
        $Config.Green[0] `
        $Config.Green[1] `
        $Config.Green[2]

    for ($i = 0; $i -lt $Config.BootLines.Count; $i++) {

        $line = $Config.BootLines[$i]

        Write-At `
            3 `
            (4 + $i) `
            $line `
            $green

        Start-Sleep -Milliseconds $Config.BootDelay
    }

    Start-Sleep -Milliseconds 250

    # Reveal banner line-by-line.
    for ($i = 0; $i -lt $Banner.Count; $i++) {

        $y = 2 + $i
        $line = $Banner[$i]
        $x = Center-X $line

        # Glitch characters.
        $glitchChars = "░▒▓"

        for ($g = 0; $g -lt 2; $g++) {

            $glitch = ""

            for ($c = 0; $c -lt $line.Length; $c++) {
                $glitch += $glitchChars[
                    (Get-Random -Minimum 0 -Maximum $glitchChars.Length)
                ]
            }

            $glitchColor = RgbEscape `
                $Config.Purple[0] `
                $Config.Purple[1] `
                $Config.Purple[2]

            Write-At $x $y $glitch $glitchColor

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
        (RgbEscape `
            $Config.Gray[0] `
            $Config.Gray[1] `
            $Config.Gray[2])

    Start-Sleep -Milliseconds 300
}

#endregion


#region =========================================================
# Admin Warning / Elevation
#endregion

function Draw-AdminWarning {

    if ($IsAdmin) {
        return
    }

    $x = 7
    $y = 12
    $w = $Config.Width - 14

    $yellow = RgbEscape `
        $Config.Yellow[0] `
        $Config.Yellow[1] `
        $Config.Yellow[2]

    Draw-Box $x $y $w 5 $yellow

    $msg = "WARNING: Administrator privileges are recommended."

    Write-At `
        (Center-X $msg) `
        ($y + 1) `
        $msg `
        $yellow

    $question = "Restart as Admin? [Y/N]"

    Write-At `
        (Center-X $question) `
        ($y + 3) `
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
        }

        Start-Sleep -Milliseconds 30
    }
}

function Restart-AsAdministrator {

    try {

        $scriptPath = $MyInvocation.ScriptName

        if (-not $scriptPath) {
            $scriptPath = $PSCommandPath
        }

        if (-not $scriptPath) {
            return $false
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo

        $psi.FileName = (Get-Process -Id $PID).Path

        if (-not $psi.FileName) {
            $psi.FileName = "powershell.exe"
        }

        $escaped = '"' + $scriptPath.Replace('"', '\"') + '"'

        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File $escaped"

        $psi.Verb = "runas"
        $psi.UseShellExecute = $true

        [void][Diagnostics.Process]::Start($psi)

        return $true
    }
    catch {
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

    $boxX = 19
    $boxY = 11
    $boxW = 52
    $boxH = 7

    Draw-Box $boxX $boxY $boxW $boxH

    for ($i = 0; $i -lt $Config.MenuItems.Count; $i++) {

        $item = $Config.MenuItems[$i]

        $y = $boxY + 1 + $i

        # Clear menu row.
        Write-At `
            ($boxX + 1) `
            $y `
            (" " * ($boxW - 2))

        if ($i -eq $Selected) {

            $rgb = Get-GradientColor `
                (($i + 1) / $Config.MenuItems.Count) `
                $Wave

            $bg = BgRgbEscape $rgb[0] $rgb[1] $rgb[2]

            $fg = "$e[38;2;255;255;255m"

            $text = "▶  $item"

            $padding = $boxW - 2 - $text.Length

            if ($padding -lt 0) {
                $padding = 0
            }

            Write-At `
                ($boxX + 1) `
                $y `
                ($text + (" " * $padding)) `
                ($bg + $fg)
        }
        else {

            $gray = RgbEscape `
                $Config.Gray[0] `
                $Config.Gray[1] `
                $Config.Gray[2]

            $text = "   $item"

            Write-At `
                ($boxX + 1) `
                $y `
                $text `
                $gray
        }
    }

    # Info line
    $adminText = if ($IsAdmin) { "YES" } else { "NO" }

    $info = "OS: $OSName  |  User: $UserName  |  Admin: $adminText"

    if ($IsAdmin) {

        $infoColor = RgbEscape `
            $Config.Gray[0] `
            $Config.Gray[1] `
            $Config.Gray[2]

        Write-At `
            (Center-X $info) `
            19 `
            $info `
            $infoColor
    }
    else {

        # Draw pieces so NO can be yellow.
        $prefix = "OS: $OSName  |  User: $UserName  |  Admin: "

        $prefixColor = RgbEscape `
            $Config.Gray[0] `
            $Config.Gray[1] `
            $Config.Gray[2]

        $yellow = RgbEscape `
            $Config.Yellow[0] `
            $Config.Yellow[1] `
            $Config.Yellow[2]

        $totalLength = $prefix.Length + 2

        $x = Center-X ("OS: $OSName  |  User: $UserName  |  Admin: NO")

        Write-At $x 19 $prefix $prefixColor

        Write-At ($x + $prefix.Length) 19 "NO" $yellow
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

    $selected = 0
    $wave = 0.0

    while ($true) {

        Draw-Banner $wave
        Draw-Menu $selected $wave

        $wave += $Config.BannerWaveSpeed

        while ($wave -gt 1) {
            $wave -= 1
        }

        # -----------------------------------------------------
        # Non-blocking keyboard handling
        # -----------------------------------------------------

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

                    # Flash selected item.
                    Draw-Menu $selected $wave

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

    [Console]::Write("$e[2J$e[H")

    $x = 12
    $y = 11
    $w = 66
    $h = 7

    $red = RgbEscape `
        $Config.Red[0] `
        $Config.Red[1] `
        $Config.Red[2]

    Draw-Box $x $y $w $h $red

    $title = "⚠  UNINSTALL CONFIRMATION"

    Write-At `
        (Center-X $title) `
        ($y + 1) `
        $title `
        $red

    $question = "Are you sure? [Y/N]"

    Write-At `
        (Center-X $question) `
        ($y + 3) `
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

    [Console]::Write("$e[2J$e[H")

    $title = if ($Action -eq "INSTALL") {
        "INSTALLING Powerstore"
    }
    else {
        "UNINSTALLING Powerstore"
    }

    Write-Gradient `
        (Center-X $title) `
        4 `
        $title `
        0

    $spinnerFrames = @(
        "⠋","⠙","⠹","⠸","⠼",
        "⠴","⠦","⠧","⠇","⠏"
    )

    $state = @{
        Step     = "Preparing..."
        Percent  = 0
        LogLines = New-Object System.Collections.ArrayList
    }

    $spinnerIndex = 0

    # ---------------------------------------------------------
    # Callback passed to Install / Uninstall
    # ---------------------------------------------------------

    $Report = {

        param(
            [string]$Step,
            [int]$Percent
        )

        $state.Step = $Step
        $state.Percent = Clamp $Percent 0 100

        [void]$state.LogLines.Add(
            @{
                Text = $Step
                Percent = $state.Percent
            }
        )
    }

    try {

        $workerResult = $null
        $workerError = $null

        try {

            if ($Action -eq "INSTALL") {
                $workerResult = Invoke-Install -Report $Report
            }
            else {
                $workerResult = Invoke-Uninstall -Report $Report
            }
        }
        catch {
            $workerError = $_
        }

        # -----------------------------------------------------
        # Render the final collected result
        # -----------------------------------------------------

        for ($frame = 0; $frame -lt 5; $frame++) {

            $spinner = $spinnerFrames[$spinnerIndex]

            $spinnerColor = Get-GradientColor `
                (($spinnerIndex % 10) / 10) `
                0

            Write-At `
                18 `
                7 `
                $spinner `
                (RgbEscape `
                    $spinnerColor[0] `
                    $spinnerColor[1] `
                    $spinnerColor[2])

            Write-At `
                22 `
                7 `
                (" " * 52)

            $stepColor = RgbEscape `
                $Config.White[0] `
                $Config.White[1] `
                $Config.White[2]

            Write-At `
                22 `
                7 `
                $state.Step `
                $stepColor

            Draw-Progress 19 9 $state.Percent

            $spinnerIndex++

            if ($spinnerIndex -ge $spinnerFrames.Count) {
                $spinnerIndex = 0
            }

            Start-Sleep -Milliseconds $Config.SpinnerDelay
        }

        # -----------------------------------------------------
        # Show logs
        # -----------------------------------------------------

        $logY = 12

        foreach ($entry in $state.LogLines) {

            if ($logY -ge 25) {
                break
            }

            $check = "✔"

            $green = RgbEscape `
                $Config.Green[0] `
                $Config.Green[1] `
                $Config.Green[2]

            Write-At `
                15 `
                $logY `
                $check `
                $green

            $logText = "  $($entry.Text)... done"

            Write-At `
                17 `
                $logY `
                $logText `
                $green

            $logY++
        }

        if ($workerError) {
            return @{
                Success = $false
                Error = $workerError.Exception.Message
            }
        }

        if ($workerResult -eq $false) {
            return @{
                Success = $false
                Error = "The operation returned FALSE."
            }
        }

        return @{
            Success = $true
            Error = $null
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

#endregion


#region =========================================================
# Result Screens
#endregion

function Show-Success {
    param(
        [string]$Action
    )

    [Console]::Write("$e[2J$e[H")

    $text = if ($Action -eq "INSTALL") {
        "✔ INSTALL COMPLETE"
    }
    else {
        "✔ UNINSTALL COMPLETE"
    }

    $boxX = 17
    $boxY = 10
    $boxW = 56
    $boxH = 8

    for ($pulse = 0; $pulse -lt 3; $pulse++) {

        [Console]::Write("$e[2J$e[H")

        if (($pulse % 2) -eq 0) {

            $green = RgbEscape `
                $Config.Green[0] `
                $Config.Green[1] `
                $Config.Green[2]
        }
        else {

            $green = RgbEscape `
                16 `
                100 `
                45
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
        (RgbEscape `
            $Config.DarkGray[0] `
            $Config.DarkGray[1] `
            $Config.DarkGray[2])

    [void][Console]::ReadKey($true)
}

function Show-Error {
    param(
        [string]$ErrorMessage
    )

    for ($shake = 0; $shake -lt 5; $shake++) {

        [Console]::Write("$e[2J$e[H")

        $offset = if (($shake % 2) -eq 0) {
            2
        }
        else {
            -2
        }

        $x = 20 + $offset
        $y = 10
        $w = 50
        $h = 8

        $red = RgbEscape `
            $Config.Red[0] `
            $Config.Red[1] `
            $Config.Red[2]

        Draw-Box $x $y $w $h $red

        $title = "✖ FAILED"

        Write-At `
            ($x + [int](($w - $title.Length) / 2)) `
            ($y + 2) `
            $title `
            $red

        Start-Sleep -Milliseconds 60
    }

    [Console]::Write("$e[2J$e[H")

    $red = RgbEscape `
        $Config.Red[0] `
        $Config.Red[1] `
        $Config.Red[2]

    Draw-Box 16 9 58 10 $red

    $title = "✖ FAILED"

    Write-At `
        (Center-X $title) `
        11 `
        $title `
        $red

    $errorText = $ErrorMessage

    if ($errorText.Length -gt 48) {
        $errorText = $errorText.Substring(0, 48)
    }

    Write-At `
        (Center-X $errorText) `
        14 `
        $errorText `
        $red

    $hint = "Press any key to return to menu..."

    Write-At `
        (Center-X $hint) `
        22 `
        $hint `
        (RgbEscape `
            $Config.DarkGray[0] `
            $Config.DarkGray[1] `
            $Config.DarkGray[2])

    [void][Console]::ReadKey($true)
}

#endregion


#region =========================================================
# Exit Animation
#endregion

function Invoke-Exit {

    [Console]::Write("$e[2J$e[H")

    for ($fade = 5; $fade -ge 0; $fade--) {

        [Console]::Write("$e[2J$e[H")

        $factor = $fade / 5

        $r = [int]($Config.Purple[0] * $factor)
        $g = [int]($Config.Purple[1] * $factor)
        $b = [int]($Config.Purple[2] * $factor)

        $color = RgbEscape $r $g $b

        $text = "POWERSTORE"

        Write-At `
            (Center-X $text) `
            13 `
            $text `
            $color

        Start-Sleep -Milliseconds $Config.FadeDelay
    }

    [Console]::Write("$e[2J$e[H")

    Write-At `
        (Center-X "Goodbye.") `
        15 `
        "Goodbye." `
        (RgbEscape `
            $Config.Gray[0] `
            $Config.Gray[1] `
            $Config.Gray[2])

    Start-Sleep -Milliseconds 400
}

#endregion


#region =========================================================
# Main
#endregion

# Hide cursor while application is running.
[Console]::Write("$e[?25l")

try {

    # ---------------------------------------------------------
    # Boot
    # ---------------------------------------------------------

    Invoke-Boot

    # ---------------------------------------------------------
    # Admin warning
    # ---------------------------------------------------------

    if (-not $IsAdmin) {

        $restart = Draw-AdminWarning

        if ($restart) {

            [Console]::Write("$e[?25h")

            if (Restart-AsAdministrator) {
                return
            }
        }

        # Redraw normal UI if user selected N.
        [Console]::Write("$e[2J$e[H")
    }

    # ---------------------------------------------------------
    # Main menu
    # ---------------------------------------------------------

    while ($true) {

        $selection = Invoke-Menu

        # ESC / EXIT
        if ($selection -eq 2) {
            break
        }

        # INSTALL
        if ($selection -eq 0) {

            $result = Invoke-WorkingScreen "INSTALL"

            if ($result.Success) {
                Show-Success "INSTALL"
            }
            else {
                Show-Error $result.Error
            }
        }

        # UNINSTALL
        elseif ($selection -eq 1) {

            $confirmed = Confirm-Uninstall

            if ($confirmed) {

                $result = Invoke-WorkingScreen "UNINSTALL"

                if ($result.Success) {
                    Show-Success "UNINSTALL"
                }
                else {
                    Show-Error $result.Error
                }
            }

            [Console]::Write("$e[2J$e[H")
        }
    }

    Invoke-Exit
}
finally {

    # Always restore cursor, even when Ctrl+C is pressed.
    [Console]::Write("$e[?25h")
    [Console]::Write("$e[0m")

    try {
        [Console]::CursorVisible = $true
    }
    catch {}

    try {
        [Console]::ResetColor()
    }
    catch {}
}

#endregion