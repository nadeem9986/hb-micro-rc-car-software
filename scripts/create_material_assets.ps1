Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$static = Join-Path $root "apktool_out\assets\apps\__UNI__FB0AA52\www\static"

function New-Bitmap($width, $height) {
    $bitmap = New-Object System.Drawing.Bitmap $width, $height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return @($bitmap, $graphics)
}

function New-Color($hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Save-Png($bitmap, $graphics, $path) {
    $graphics.Dispose()
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

function Draw-CenteredText($graphics, $text, $font, $brush, $rect) {
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $graphics.DrawString($text, $font, $brush, $rect, $format)
    $format.Dispose()
}

function Draw-RoundRect($graphics, $brush, $pen, $rect, $radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $radius * 2
    $path.AddArc($rect.X, $rect.Y, $diameter, $diameter, 180, 90)
    $path.AddArc($rect.Right - $diameter, $rect.Y, $diameter, $diameter, 270, 90)
    $path.AddArc($rect.Right - $diameter, $rect.Bottom - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    if ($brush) { $graphics.FillPath($brush, $path) }
    if ($pen) { $graphics.DrawPath($pen, $path) }
    $path.Dispose()
}

function New-SpeedBadge($file, $label, $mode, $accent) {
    $pair = New-Bitmap 220 220
    $bitmap = $pair[0]
    $graphics = $pair[1]
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle 0, 0, 220, 220),
        (New-Color "#111827"),
        (New-Color "#05070b"),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $graphics.FillEllipse($bg, 6, 6, 208, 208)
    $bg.Dispose()
    $ring = New-Object System.Drawing.Pen (New-Color $accent), 10
    $graphics.DrawEllipse($ring, 15, 15, 190, 190)
    $ring.Dispose()
    $shine = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(40, 255, 255, 255))
    $graphics.FillEllipse($shine, 46, 28, 82, 44)
    $shine.Dispose()
    $white = New-Object System.Drawing.SolidBrush (New-Color "#f8fbff")
    $muted = New-Object System.Drawing.SolidBrush (New-Color "#9fb0c4")
    $f1 = New-Object System.Drawing.Font "Segoe UI", 24, ([System.Drawing.FontStyle]::Bold)
    $f2 = New-Object System.Drawing.Font "Segoe UI", 48, ([System.Drawing.FontStyle]::Bold)
    Draw-CenteredText $graphics $label $f1 $white (New-Object System.Drawing.RectangleF 0, 52, 220, 36)
    Draw-CenteredText $graphics $mode $f2 $white (New-Object System.Drawing.RectangleF 0, 84, 220, 70)
    Draw-CenteredText $graphics "MODE" (New-Object System.Drawing.Font "Segoe UI", 16, ([System.Drawing.FontStyle]::Regular)) $muted (New-Object System.Drawing.RectangleF 0, 152, 220, 30)
    $white.Dispose()
    $muted.Dispose()
    $f1.Dispose()
    $f2.Dispose()
    Save-Png $bitmap $graphics (Join-Path $static $file)
}

function New-Logo {
    $pair = New-Bitmap 420 180
    $bitmap = $pair[0]
    $graphics = $pair[1]
    $clear = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Transparent)
    $graphics.FillRectangle($clear, 0, 0, 420, 180)
    $clear.Dispose()
    $panel = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(216, 9, 14, 22))
    $line = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(80, 255, 255, 255)), 2
    Draw-RoundRect $graphics $panel $line (New-Object System.Drawing.Rectangle 8, 8, 404, 164) 44
    $accentPen = New-Object System.Drawing.Pen (New-Color "#4cc9f0"), 8
    $graphics.DrawLine($accentPen, 70, 118, 152, 118)
    $graphics.DrawLine($accentPen, 250, 118, 350, 118)
    $accentPen.Dispose()
    $wheelPen = New-Object System.Drawing.Pen (New-Color "#52d273"), 7
    $graphics.DrawEllipse($wheelPen, 76, 108, 28, 28)
    $graphics.DrawEllipse($wheelPen, 300, 108, 28, 28)
    $wheelPen.Dispose()
    $white = New-Object System.Drawing.SolidBrush (New-Color "#f8fbff")
    $muted = New-Object System.Drawing.SolidBrush (New-Color "#9fb0c4")
    Draw-CenteredText $graphics "HB MICRO RC" (New-Object System.Drawing.Font "Segoe UI", 34, ([System.Drawing.FontStyle]::Bold)) $white (New-Object System.Drawing.RectangleF 0, 38, 420, 48)
    Draw-CenteredText $graphics "BLE DRIVE" (New-Object System.Drawing.Font "Segoe UI", 16, ([System.Drawing.FontStyle]::Regular)) $muted (New-Object System.Drawing.RectangleF 0, 88, 420, 28)
    $white.Dispose()
    $muted.Dispose()
    $panel.Dispose()
    $line.Dispose()
    Save-Png $bitmap $graphics (Join-Path $static "logo.png")
    Copy-Item -LiteralPath (Join-Path $static "logo.png") -Destination (Join-Path $static "logo.jpg") -Force
}

function New-JoystickBackground($file, $horizontal) {
    if ($horizontal) {
        $w = 560
        $h = 260
    } else {
        $w = 260
        $h = 560
    }
    $pair = New-Bitmap $w $h
    $bitmap = $pair[0]
    $graphics = $pair[1]
    $clear = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Transparent)
    $graphics.FillRectangle($clear, 0, 0, $w, $h)
    $clear.Dispose()
    $panel = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(34, 255, 255, 255))
    $outline = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(46, 255, 255, 255)), 3
    Draw-RoundRect $graphics $panel $outline (New-Object System.Drawing.Rectangle 8, 8, ($w - 16), ($h - 16)) 118
    $line = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(74, 76, 201, 240)), 6
    if ($horizontal) {
        $graphics.DrawLine($line, 88, ($h / 2), ($w - 88), ($h / 2))
    } else {
        $graphics.DrawLine($line, ($w / 2), 88, ($w / 2), ($h - 88))
    }
    $line.Dispose()
    $arrow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(160, 248, 251, 255))
    if ($horizontal) {
        $graphics.FillPolygon($arrow, @(
            (New-Object System.Drawing.Point 62, ($h / 2)),
            (New-Object System.Drawing.Point 102, (($h / 2) - 32)),
            (New-Object System.Drawing.Point 102, (($h / 2) + 32))
        ))
        $graphics.FillPolygon($arrow, @(
            (New-Object System.Drawing.Point ($w - 62), ($h / 2)),
            (New-Object System.Drawing.Point ($w - 102), (($h / 2) - 32)),
            (New-Object System.Drawing.Point ($w - 102), (($h / 2) + 32))
        ))
    } else {
        $graphics.FillPolygon($arrow, @(
            (New-Object System.Drawing.Point ($w / 2), 62),
            (New-Object System.Drawing.Point (($w / 2) - 32), 102),
            (New-Object System.Drawing.Point (($w / 2) + 32), 102)
        ))
        $graphics.FillPolygon($arrow, @(
            (New-Object System.Drawing.Point ($w / 2), ($h - 62)),
            (New-Object System.Drawing.Point (($w / 2) - 32), ($h - 102)),
            (New-Object System.Drawing.Point (($w / 2) + 32), ($h - 102))
        ))
    }
    $arrow.Dispose()
    $panel.Dispose()
    $outline.Dispose()
    Save-Png $bitmap $graphics (Join-Path $static $file)
}

function Draw-ArrowHead($graphics, $brush, $x, $y, $dir) {
    function Pt($px, $py) {
        return New-Object -TypeName System.Drawing.Point -ArgumentList ([int]$px), ([int]$py)
    }
    if ($dir -eq "left") {
        $points = @((Pt ($x - 22) $y), (Pt ($x + 12) ($y - 18)), (Pt ($x + 12) ($y + 18)))
    } elseif ($dir -eq "right") {
        $points = @((Pt ($x + 22) $y), (Pt ($x - 12) ($y - 18)), (Pt ($x - 12) ($y + 18)))
    } elseif ($dir -eq "up") {
        $points = @((Pt $x ($y - 22)), (Pt ($x - 18) ($y + 12)), (Pt ($x + 18) ($y + 12)))
    } else {
        $points = @((Pt $x ($y + 22)), (Pt ($x - 18) ($y - 12)), (Pt ($x + 18) ($y - 12)))
    }
    $graphics.FillPolygon($brush, $points)
}

function New-ControlIcon($file, $kind, $accent) {
    $pair = New-Bitmap 180 180
    $bitmap = $pair[0]
    $graphics = $pair[1]
    $clear = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Transparent)
    $graphics.FillRectangle($clear, 0, 0, 180, 180)
    $clear.Dispose()
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle 0, 0, 180, 180),
        ([System.Drawing.Color]::FromArgb(80, 255, 255, 255)),
        ([System.Drawing.Color]::FromArgb(18, 255, 255, 255)),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $edge = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(75, 255, 255, 255)), 3
    $graphics.FillEllipse($bg, 13, 13, 154, 154)
    $graphics.DrawEllipse($edge, 13, 13, 154, 154)
    $bg.Dispose()
    $edge.Dispose()
    $pen = New-Object System.Drawing.Pen (New-Color $accent), 9
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $thin = New-Object System.Drawing.Pen (New-Color $accent), 6
    $thin.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $thin.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $brush = New-Object System.Drawing.SolidBrush (New-Color $accent)
    if ($kind -eq "light") {
        $graphics.DrawEllipse($pen, 66, 50, 48, 58)
        $graphics.DrawLine($pen, 72, 116, 108, 116)
        $graphics.DrawLine($thin, 78, 132, 102, 132)
        $graphics.DrawLine($thin, 90, 28, 90, 38)
        $graphics.DrawLine($thin, 45, 49, 55, 59)
        $graphics.DrawLine($thin, 135, 49, 125, 59)
    } elseif ($kind -eq "gauge") {
        $graphics.DrawArc($pen, 44, 52, 92, 92, 200, 140)
        $graphics.DrawLine($pen, 90, 102, 118, 72)
        $graphics.FillEllipse($brush, 84, 96, 12, 12)
        $graphics.DrawLine($thin, 58, 109, 48, 119)
        $graphics.DrawLine($thin, 132, 109, 142, 119)
    } elseif ($kind -eq "bluetooth") {
        $graphics.DrawLine($pen, 82, 36, 82, 144)
        $graphics.DrawLine($pen, 82, 36, 122, 70)
        $graphics.DrawLine($pen, 122, 70, 62, 112)
        $graphics.DrawLine($pen, 82, 144, 122, 110)
        $graphics.DrawLine($pen, 122, 110, 62, 68)
    } elseif ($kind -eq "privacy") {
        Draw-RoundRect $graphics $null $pen (New-Object System.Drawing.Rectangle 55, 34, 70, 106) 12
        $graphics.DrawLine($thin, 72, 62, 108, 62)
        $graphics.DrawLine($thin, 72, 84, 100, 84)
        $graphics.DrawLine($thin, 72, 106, 98, 106)
        $graphics.DrawLines($thin, @((New-Object System.Drawing.Point 108, 98), (New-Object System.Drawing.Point 122, 112), (New-Object System.Drawing.Point 148, 76)))
    } elseif ($kind -eq "power") {
        $graphics.DrawLine($pen, 90, 42, 90, 82)
        $graphics.DrawArc($pen, 50, 58, 80, 80, 138, 264)
        $graphics.DrawEllipse($thin, 69, 77, 42, 42)
    } elseif ($kind -eq "exchange") {
        $graphics.DrawLine($pen, 48, 66, 128, 66)
        Draw-ArrowHead $graphics $brush 132 66 "right"
        $graphics.DrawLine($pen, 132, 114, 52, 114)
        Draw-ArrowHead $graphics $brush 48 114 "left"
    } elseif ($kind -eq "remote") {
        Draw-RoundRect $graphics $null $pen (New-Object System.Drawing.Rectangle 42, 64, 96, 56) 24
        $graphics.DrawLine($thin, 64, 92, 86, 92)
        $graphics.DrawLine($thin, 75, 81, 75, 103)
        $graphics.FillEllipse($brush, 108, 83, 10, 10)
        $graphics.FillEllipse($brush, 124, 96, 10, 10)
    } elseif ($kind -eq "path") {
        $graphics.DrawBezier($pen, 44, 118, 64, 48, 116, 134, 138, 58)
        $graphics.FillEllipse($brush, 38, 112, 14, 14)
        $graphics.FillEllipse($brush, 132, 52, 14, 14)
    } else {
        $graphics.DrawArc($pen, 48, 48, 84, 84, 210, 120)
        $graphics.DrawLine($pen, 90, 104, 126, 68)
        Draw-ArrowHead $graphics $brush 130 64 "up"
    }
    $pen.Dispose()
    $thin.Dispose()
    $brush.Dispose()
    Save-Png $bitmap $graphics (Join-Path $static $file)
}

New-SpeedBadge "btn_speed1.png" "LOW" "1" "#52d273"
New-SpeedBadge "btn_speed2.png" "MID" "2" "#4cc9f0"
New-SpeedBadge "btn_speed3.png" "HIGH" "3" "#ffb703"
New-Logo
New-JoystickBackground "bg_lr.png" $true
New-JoystickBackground "bg_ud.png" $false
New-ControlIcon "btn_light.png" "light" "#f8fbff"
New-ControlIcon "btn_light-1.png" "light" "#ffb703"
New-ControlIcon "btn_gg.png" "gauge" "#4cc9f0"
New-ControlIcon "btn_gg-1.png" "gauge" "#f8fbff"
New-ControlIcon "btn_blue.png" "bluetooth" "#4cc9f0"
New-ControlIcon "btn_blue-1.png" "bluetooth" "#52d273"
New-ControlIcon "privacy.png" "privacy" "#f8fbff"
New-ControlIcon "btn_exchange.png" "exchange" "#f8fbff"
New-ControlIcon "btn_exchange-1.png" "exchange" "#52d273"
New-ControlIcon "btn_remote.png" "remote" "#f8fbff"
New-ControlIcon "btn_remote-1.png" "remote" "#4cc9f0"
New-ControlIcon "btn_guiji.png" "path" "#f8fbff"
New-ControlIcon "btn_guiji-1.png" "path" "#4cc9f0"
New-ControlIcon "btn_cruise.png" "cruise" "#f8fbff"
New-ControlIcon "btn_cruise-1.png" "cruise" "#52d273"
New-ControlIcon "back.png" "power" "#4cc9f0"

Write-Host "Material image assets refreshed."
