Add-Type -AssemblyName System.Drawing

$srcDir = "d:\M-IT\m_it_student_platform\docs\screenshots"
$outDir1242 = "d:\M-IT\m_it_student_platform\docs\ios_showcase_1242x2688"
$outDir1320 = "d:\M-IT\m_it_student_platform\docs\ios_showcase_1320x2868"

if (-not (Test-Path $outDir1242)) {
    New-Item -ItemType Directory -Path $outDir1242 -Force | Out-Null
}
if (-not (Test-Path $outDir1320)) {
    New-Item -ItemType Directory -Path $outDir1320 -Force | Out-Null
}

function Draw-RoundedRect {
    param(
        [System.Drawing.Graphics]$g,
        [System.Drawing.Brush]$brush,
        [System.Drawing.Pen]$pen,
        [float]$x,
        [float]$y,
        [float]$w,
        [float]$h,
        [float]$r
    )
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2.0
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
    $path.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
    $path.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
    $path.CloseFigure()

    if ($brush -ne $null) { $g.FillPath($brush, $path) }
    if ($pen -ne $null) { $g.DrawPath($pen, $path) }
    $path.Dispose()
}

function Create-Iphone16Banner {
    param(
        [string]$screenshotName,
        [string]$badgeText,
        [string]$titleText,
        [string]$subtitleText,
        [string]$outputFileName,
        [int]$width,
        [int]$height,
        [string]$targetDir,
        [System.Drawing.Color]$accentColor,
        [System.Drawing.Color]$bgTop,
        [System.Drawing.Color]$bgBottom,
        [bool]$isLightMode = $false
    )

    $screenshotPath = Join-Path $srcDir $screenshotName
    $outputPath = Join-Path $targetDir $outputFileName

    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    [float]$scale = [float]$width / 1242.0

    # 1. Background Gradient
    $bgRect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($bgRect, $bgTop, $bgBottom, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    $g.FillRectangle($bgBrush, $bgRect)
    $bgBrush.Dispose()

    # 2. Glowing Accent Aura behind Header
    $glowW = [int](940 * $scale)
    $glowH = [int](640 * $scale)
    $glowX = [int](($width - $glowW) / 2)
    $glowY = [int](-140 * $scale)

    $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $glowRect = New-Object System.Drawing.Rectangle($glowX, $glowY, $glowW, $glowH)
    $glowPath.AddEllipse($glowRect)
    $glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
    $glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(40, $accentColor.R, $accentColor.G, $accentColor.B)
    $glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $bgTop.R, $bgTop.G, $bgTop.B))
    $g.FillEllipse($glowBrush, $glowRect)
    $glowBrush.Dispose()
    $glowPath.Dispose()

    # 3. Top Category Badge Pill
    if ($badgeText) {
        $badgeFontSize = [float](16.0 * $scale)
        $badgeFont = New-Object System.Drawing.Font("Segoe UI", $badgeFontSize, [System.Drawing.FontStyle]::Bold)
        $badgeSize = $g.MeasureString($badgeText, $badgeFont)
        [float]$pillW = [float]($badgeSize.Width + (36.0 * $scale))
        [float]$pillH = [float](44.0 * $scale)
        [float]$pillX = [float](($width - $pillW) / 2.0)
        [float]$pillY = [float](70.0 * $scale)

        $badgeBgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, $accentColor.R, $accentColor.G, $accentColor.B))
        $badgeBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, $accentColor.R, $accentColor.G, $accentColor.B), [float](1.6 * $scale))
        $badgeTextBrush = New-Object System.Drawing.SolidBrush($accentColor)

        Draw-RoundedRect -g $g -brush $badgeBgBrush -pen $badgeBorderPen -x $pillX -y $pillY -w $pillW -h $pillH -r ($pillH / 2.0)

        $sfBadge = New-Object System.Drawing.StringFormat
        $sfBadge.Alignment = [System.Drawing.StringAlignment]::Center
        $sfBadge.LineAlignment = [System.Drawing.StringAlignment]::Center
        $pillTextRect = New-Object System.Drawing.RectangleF($pillX, $pillY, $pillW, $pillH)
        $g.DrawString($badgeText, $badgeFont, $badgeTextBrush, $pillTextRect, $sfBadge)

        $badgeBgBrush.Dispose()
        $badgeBorderPen.Dispose()
        $badgeTextBrush.Dispose()
        $badgeFont.Dispose()
    }

    # 4. Big Bold Title
    $titleFontSize = [float](46.0 * $scale)
    $titleFont = New-Object System.Drawing.Font("Segoe UI", $titleFontSize, [System.Drawing.FontStyle]::Bold)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Near

    [float]$tX = [float](40.0 * $scale)
    [float]$tY = [float](138.0 * $scale)
    [float]$tW = [float]($width - (80.0 * $scale))
    [float]$tH = [float](130.0 * $scale)
    $titleRect = New-Object System.Drawing.RectangleF($tX, $tY, $tW, $tH)
    $g.DrawString($titleText, $titleFont, $titleBrush, $titleRect, $sfCenter)
    $titleBrush.Dispose()
    $titleFont.Dispose()

    # 5. Subtitle
    $subFontSize = [float](21.0 * $scale)
    $subFont = New-Object System.Drawing.Font("Segoe UI", $subFontSize, [System.Drawing.FontStyle]::Regular)
    $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(203, 213, 225)) # slate-300

    [float]$sX = [float](60.0 * $scale)
    [float]$sY = [float](278.0 * $scale)
    [float]$sW = [float]($width - (120.0 * $scale))
    [float]$sH = [float](80.0 * $scale)
    $subRect = New-Object System.Drawing.RectangleF($sX, $sY, $sW, $sH)
    $g.DrawString($subtitleText, $subFont, $subBrush, $subRect, $sfCenter)
    $subBrush.Dispose()
    $subFont.Dispose()

    # 6. iPhone 16 Pro Dimensions & Frame
    $phoneW = [int](890 * $scale)
    $phoneH = [int](1930 * $scale)
    $phoneX = [int](($width - $phoneW) / 2)
    $phoneY = [int](380 * $scale)

    $bezel = [int](14 * $scale) # Ultra-thin titanium bezel
    $frameW = $phoneW + ($bezel * 2)
    $frameH = $phoneH + ($bezel * 2)
    $frameX = $phoneX - $bezel
    $frameY = $phoneY - $bezel
    $outerRadius = [float](78.0 * $scale)
    $innerRadius = [float](64.0 * $scale)

    # 6.1 Multi-layer Realistic Ambient Shadow
    for ($i = 1; $i -le 16; $i++) {
        $shadowAlpha = [int](26 - $i)
        if ($shadowAlpha -lt 1) { $shadowAlpha = 1 }
        $shadowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($shadowAlpha, 0, 0, 0), [float]($i * 3.6 * $scale))
        Draw-RoundedRect -g $g -brush $null -pen $shadowPen -x ($frameX - $i*3) -y ($frameY - $i*3) -w ($frameW + $i*6) -h ($frameH + $i*6) -r ($outerRadius + $i*2)
        $shadowPen.Dispose()
    }

    # 6.2 Outer Space Black / Natural Titanium Chassis
    $chassisBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 18, 22, 32))
    $chassisPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 80, 95, 115), [float](3.0 * $scale))
    Draw-RoundedRect -g $g -brush $chassisBrush -pen $chassisPen -x $frameX -y $frameY -w $frameW -h $frameH -r $outerRadius
    $chassisBrush.Dispose()
    $chassisPen.Dispose()

    # 6.3 Screen Area (Clipped by inner curved screen radius)
    $screenPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $innerRadius * 2.0
    $screenPath.AddArc($phoneX, $phoneY, $d, $d, 180, 90)
    $screenPath.AddArc(($phoneX + $phoneW - $d), $phoneY, $d, $d, 270, 90)
    $screenPath.AddArc(($phoneX + $phoneW - $d), ($phoneY + $phoneH - $d), $d, $d, 0, 90)
    $screenPath.AddArc($phoneX, ($phoneY + $phoneH - $d), $d, $d, 90, 90)
    $screenPath.CloseFigure()

    $oldClip = $g.Clip
    $g.SetClip($screenPath)

    # Screen Background
    $screenBgColor = if ($isLightMode) { [System.Drawing.Color]::FromArgb(255, 248, 250, 252) } else { [System.Drawing.Color]::FromArgb(255, 10, 15, 29) }
    $screenBgBrush = New-Object System.Drawing.SolidBrush($screenBgColor)
    $g.FillRectangle($screenBgBrush, $phoneX, $phoneY, $phoneW, $phoneH)
    $screenBgBrush.Dispose()

    # Draw REAL App Screen Content (Cropping off old Android status bar)
    if (Test-Path $screenshotPath) {
        $screenImg = [System.Drawing.Image]::FromFile($screenshotPath)

        # Source image is 1080x2400. Crop top 100px (Android status bar) and bottom 40px
        $srcCropTop = 100
        $srcCropBottom = 40
        $srcW = $screenImg.Width
        $srcH = $screenImg.Height - $srcCropTop - $srcCropBottom
        $srcRect = New-Object System.Drawing.Rectangle(0, $srcCropTop, $srcW, $srcH)

        # Destination inside iPhone: start below iOS status bar (height ~115px scaled)
        $iosTopInset = [int](110 * $scale)
        $destScreenRect = New-Object System.Drawing.Rectangle($phoneX, ($phoneY + $iosTopInset), $phoneW, ($phoneH - $iosTopInset))

        $g.DrawImage($screenImg, $destScreenRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        $screenImg.Dispose()
    }

    # 6.4 Pixel-Perfect Authentic iPhone 16 Pro Status Bar
    $statusTextColor = if ($isLightMode) { [System.Drawing.Color]::FromArgb(255, 15, 23, 42) } else { [System.Drawing.Color]::White }
    $statusTextBrush = New-Object System.Drawing.SolidBrush($statusTextColor)

    # Left: iOS Time "9:41"
    $timeFont = New-Object System.Drawing.Font("Segoe UI", [float](22.0 * $scale), [System.Drawing.FontStyle]::Bold)
    [float]$timeX = [float]($phoneX + (46.0 * $scale))
    [float]$timeY = [float]($phoneY + (26.0 * $scale))
    $g.DrawString("9:41", $timeFont, $statusTextBrush, $timeX, $timeY)
    $timeFont.Dispose()

    # Center: Dynamic Island (Floating Pill)
    $islandW = [float](225.0 * $scale)
    $islandH = [float](54.0 * $scale)
    $islandX = [float]($phoneX + ($phoneW - $islandW) / 2.0)
    $islandY = [float]($phoneY + (20.0 * $scale))

    $islandBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 0, 0))
    Draw-RoundedRect -g $g -brush $islandBrush -pen $null -x $islandX -y $islandY -w $islandW -h $islandH -r ($islandH / 2.0)
    $islandBrush.Dispose()

    # Camera Lens & Sensor inside Dynamic Island
    $lensSize = [float](17.0 * $scale)
    $lensX = [float]($islandX + $islandW - $lensSize - (18.0 * $scale))
    $lensY = [float]($islandY + ($islandH - $lensSize) / 2.0)
    $lensBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 12, 16, 28))
    $lensPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 255, 255, 255), 1.0)
    $g.FillEllipse($lensBrush, $lensX, $lensY, $lensSize, $lensSize)
    $g.DrawEllipse($lensPen, $lensX, $lensY, $lensSize, $lensSize)
    $lensBrush.Dispose()
    $lensPen.Dispose()

    # Right: iOS Cellular Signal Bars (4 vertical bars)
    [float]$sigX = [float]($phoneX + $phoneW - (150.0 * $scale))
    [float]$sigY = [float]($phoneY + (36.0 * $scale))
    $sigHeights = @([float](6.0 * $scale), [float](9.5 * $scale), [float](13.0 * $scale), [float](16.5 * $scale))
    for ($b = 0; $b -lt 4; $b++) {
        [float]$barW = [float](4.0 * $scale)
        [float]$barH = [float]$sigHeights[$b]
        [float]$bx = [float]($sigX + ($b * (7.0 * $scale)))
        [float]$by = [float]($sigY + (16.5 * $scale) - $barH)
        Draw-RoundedRect -g $g -brush $statusTextBrush -pen $null -x $bx -y $by -w $barW -h $barH -r ($barW / 2.0)
    }

    # Right: iOS Wi-Fi Icon (Arcs)
    [float]$wifiX = [float]($phoneX + $phoneW - (108.0 * $scale))
    [float]$wifiY = [float]($phoneY + (33.0 * $scale))
    $wifiPen = New-Object System.Drawing.Pen($statusTextColor, [float](2.2 * $scale))
    $wifiPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $wifiPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($wifiPen, ($wifiX - 10 * $scale), $wifiY, (20 * $scale), (20 * $scale), 225, 90)
    $g.DrawArc($wifiPen, ($wifiX - 6 * $scale), ($wifiY + 4 * $scale), (12 * $scale), (12 * $scale), 225, 90)
    $g.FillEllipse($statusTextBrush, ($wifiX - 2.5 * $scale), ($wifiY + 11.5 * $scale), (5 * $scale), (5 * $scale))
    $wifiPen.Dispose()

    # Right: iOS Battery Capsule
    [float]$batX = [float]($phoneX + $phoneW - (72.0 * $scale))
    [float]$batY = [float]($phoneY + (34.0 * $scale))
    [float]$batW = [float](30.0 * $scale)
    [float]$batH = [float](15.0 * $scale)
    [float]$batR = [float](4.5 * $scale)

    $batPen = New-Object System.Drawing.Pen($statusTextColor, [float](1.6 * $scale))
    Draw-RoundedRect -g $g -brush $null -pen $batPen -x $batX -y $batY -w $batW -h $batH -r $batR
    $batPen.Dispose()

    # Battery Fill (90% charge level)
    [float]$fillPad = 2.5 * $scale
    Draw-RoundedRect -g $g -brush $statusTextBrush -pen $null -x ($batX + $fillPad) -y ($batY + $fillPad) -w ($batW * 0.8) -h ($batH - ($fillPad * 2)) -r 2.0

    # Battery Terminal Nipple Cap
    [float]$nipW = 2.2 * $scale
    [float]$nipH = 6.0 * $scale
    Draw-RoundedRect -g $g -brush $statusTextBrush -pen $null -x ($batX + $batW + 1.2 * $scale) -y ($batY + ($batH - $nipH) / 2.0) -w $nipW -h $nipH -r 1.0

    $statusTextBrush.Dispose()

    # 6.5 Authentic iPhone Bottom Home Indicator Bar
    [float]$barW = [float](240.0 * $scale)
    [float]$barH = [float](7.0 * $scale)
    [float]$barX = [float]($phoneX + ($phoneW - $barW) / 2.0)
    [float]$barY = [float]($phoneY + $phoneH - (18.0 * $scale))

    $barColor = if ($isLightMode) { [System.Drawing.Color]::FromArgb(160, 0, 0, 0) } else { [System.Drawing.Color]::FromArgb(200, 255, 255, 255) }
    $homeBarBrush = New-Object System.Drawing.SolidBrush($barColor)
    Draw-RoundedRect -g $g -brush $homeBarBrush -pen $null -x $barX -y $barY -w $barW -h $barH -r ($barH / 2.0)
    $homeBarBrush.Dispose()

    $g.Clip = $oldClip
    $screenPath.Dispose()

    # 6.6 Titanium Screen Inner Border Highlight
    $innerGlowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(75, 255, 255, 255), [float](2.0 * $scale))
    Draw-RoundedRect -g $g -brush $null -pen $innerGlowPen -x $phoneX -y $phoneY -w $phoneW -h $phoneH -r $innerRadius
    $innerGlowPen.Dispose()

    # Save output
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host " [OK] iPhone 16 Banner: $outputFileName ($width x $height)"
}

$banners = @(
    @{
        screenshot = "01_asosiy_dashboard.png"
        badge = "M-IT TALABA PLATFORMASI"
        title = "Asosiy Boshqaruv Paneli"
        sub = "O'quv jarayoni, guruh va muhim ko'rsatkichlar bir joyda"
        out = "01_asosiy_dashboard"
        accent = [System.Drawing.Color]::FromArgb(211, 255, 50)     # Neon Lime
        bgTop = [System.Drawing.Color]::FromArgb(10, 26, 42)
        bgBottom = [System.Drawing.Color]::FromArgb(15, 23, 42)
        isLight = $false
    },
    @{
        screenshot = "02_darslar_va_vazifalar.png"
        badge = "DARSLAR & VAZIFALAR"
        title = "Dars Jadvali va Uy Vazifalari"
        sub = "Haftalik darslar jadvali va amaliy topshiriqlar ro'yxati"
        out = "02_darslar_va_vazifalar"
        accent = [System.Drawing.Color]::FromArgb(56, 189, 248)     # Sky Cyan
        bgTop = [System.Drawing.Color]::FromArgb(8, 28, 48)
        bgBottom = [System.Drawing.Color]::FromArgb(15, 23, 42)
        isLight = $false
    },
    @{
        screenshot = "03_vazifa_va_dars_tafsilotlari.png"
        badge = "TAFSIATLI MATERIALLAR"
        title = "Vazifa & Materiallar Tafsiloti"
        sub = "Dars taqdimotlari, video qo'llanmalar va topshiriq yuborish"
        out = "03_vazifa_va_dars_tafsilotlari"
        accent = [System.Drawing.Color]::FromArgb(168, 85, 247)     # Purple
        bgTop = [System.Drawing.Color]::FromArgb(25, 16, 44)
        bgBottom = [System.Drawing.Color]::FromArgb(15, 23, 42)
        isLight = $false
    },
    @{
        screenshot = "04_tolovlar_monitoringi.png"
        badge = "MOLIYAVIY MONITORING"
        title = "To'lovlar & Tranzaksiyalar"
        sub = "Oylik to'lov holati, cheklar va barcha to'lovlar tarixi"
        out = "04_tolovlar_monitoringi"
        accent = [System.Drawing.Color]::FromArgb(16, 185, 129)     # Emerald
        bgTop = [System.Drawing.Color]::FromArgb(8, 32, 28)
        bgBottom = [System.Drawing.Color]::FromArgb(15, 23, 42)
        isLight = $false
    },
    @{
        screenshot = "05_talaba_profili.png"
        badge = "SHAXSIY PROFIL"
        title = "Talaba Shaxsiy Profili"
        sub = "Shaxsiy ma'lumotlar, sozlamalar va xavfsizlik boshqaruvi"
        out = "05_talaba_profili"
        accent = [System.Drawing.Color]::FromArgb(244, 63, 94)      # Rose
        bgTop = [System.Drawing.Color]::FromArgb(38, 14, 26)
        bgBottom = [System.Drawing.Color]::FromArgb(15, 23, 42)
        isLight = $false
    },
    @{
        screenshot = "06_davomat_monitoringi.png"
        badge = "DAVOMAT NAZORATI"
        title = "100% Shaffof Davomat"
        sub = "Darslarga qatnashish ko'rsatkichi va kirish-chiqish vaqtlari"
        out = "06_davomat_monitoringi"
        accent = [System.Drawing.Color]::FromArgb(34, 197, 94)      # Green
        bgTop = [System.Drawing.Color]::FromArgb(10, 30, 35)
        bgBottom = [System.Drawing.Color]::FromArgb(15, 23, 42)
        isLight = $false
    },
    @{
        screenshot = "07_baholar_va_monitoring.png"
        badge = "AKADEMIK NATIJALAR"
        title = "Baholar & Reyting Nazorati"
        sub = "Fanlar bo'yicha o'rtacha ball va topshiriqlar statistikasi"
        out = "07_baholar_va_monitoring"
        accent = [System.Drawing.Color]::FromArgb(251, 191, 36)     # Amber
        bgTop = [System.Drawing.Color]::FromArgb(38, 28, 12)
        bgBottom = [System.Drawing.Color]::FromArgb(15, 23, 42)
        isLight = $false
    },
    @{
        screenshot = "08_kunduzgi_rejim_dashboard.png"
        badge = "YORUG' & TUNGI MAVZU"
        title = "Kunduzgi Yorug' Dizayn"
        sub = "Har qanday muhitda ko'zga qulay va chiroyli interfeys"
        out = "08_kunduzgi_rejim_dashboard"
        accent = [System.Drawing.Color]::FromArgb(14, 165, 233)     # Cyan
        bgTop = [System.Drawing.Color]::FromArgb(14, 25, 45)
        bgBottom = [System.Drawing.Color]::FromArgb(24, 38, 65)
        isLight = $true
    }
)

$outDirIpad = "d:\M-IT\m_it_student_platform\docs\ipad_showcase_2048x2732"
if (-not (Test-Path $outDirIpad)) {
    New-Item -ItemType Directory -Path $outDirIpad -Force | Out-Null
}

Write-Host '=========================================================='
Write-Host 'Generating iPhone 6.5 (1242x2688) Banners...'
Write-Host '=========================================================='
foreach ($b in $banners) {
    Create-Iphone16Banner `
        -screenshotName $b.screenshot `
        -badgeText $b.badge `
        -titleText $b.title `
        -subtitleText $b.sub `
        -outputFileName "$($b.out)_1242x2688.png" `
        -width 1242 `
        -height 2688 `
        -targetDir $outDir1242 `
        -accentColor $b.accent `
        -bgTop $b.bgTop `
        -bgBottom $b.bgBottom `
        -isLightMode $b.isLight
}

Write-Host '=========================================================='
Write-Host 'Generating iPhone 6.9 (1320x2868) Banners...'
Write-Host '=========================================================='
foreach ($b in $banners) {
    Create-Iphone16Banner `
        -screenshotName $b.screenshot `
        -badgeText $b.badge `
        -titleText $b.title `
        -subtitleText $b.sub `
        -outputFileName "$($b.out)_1320x2868.png" `
        -width 1320 `
        -height 2868 `
        -targetDir $outDir1320 `
        -accentColor $b.accent `
        -bgTop $b.bgTop `
        -bgBottom $b.bgBottom `
        -isLightMode $b.isLight
}

Write-Host '=========================================================='
Write-Host 'Generating iPad 12.9 (2048x2732) Banners...'
Write-Host '=========================================================='
foreach ($b in $banners) {
    Create-Iphone16Banner `
        -screenshotName $b.screenshot `
        -badgeText $b.badge `
        -titleText $b.title `
        -subtitleText $b.sub `
        -outputFileName "$($b.out)_2048x2732.png" `
        -width 2048 `
        -height 2732 `
        -targetDir $outDirIpad `
        -accentColor $b.accent `
        -bgTop $b.bgTop `
        -bgBottom $b.bgBottom `
        -isLightMode $b.isLight
}

Write-Host 'ALL IPHONE 16 AND IPAD BANNERS GENERATED SUCCESSFULLY!'
