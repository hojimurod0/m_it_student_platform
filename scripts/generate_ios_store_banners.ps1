Add-Type -AssemblyName System.Drawing

$srcDir = "d:\M-IT\m_it_student_platform\docs\screenshots"
$outDir1242 = "d:\M-IT\m_it_student_platform\docs\ios_showcase_1242x2688"
$outDir1320 = "d:\M-IT\m_it_student_platform\docs\ios_showcase_1320x2868"
$iconSrc = "d:\M-IT\m_it_student_platform\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png"

if (-not (Test-Path $outDir1242)) {
    New-Item -ItemType Directory -Path $outDir1242 -Force | Out-Null
}
if (-not (Test-Path $outDir1320)) {
    New-Item -ItemType Directory -Path $outDir1320 -Force | Out-Null
}

function Create-IosShowcaseBanner {
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
        [System.Drawing.Color]$bgBottom
    )

    $screenshotPath = Join-Path $srcDir $screenshotName
    $outputPath = Join-Path $targetDir $outputFileName

    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # 1. Background Gradient
    $bgRect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($bgRect, $bgTop, $bgBottom, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    $g.FillRectangle($bgBrush, $bgRect)
    $bgBrush.Dispose()

    # Scale factor based on standard 1242 px width
    [float]$scale = [float]$width / 1242.0

    # 2. Glowing Accent Aura behind header
    $glowW = [int](900 * $scale)
    $glowH = [int](600 * $scale)
    $glowX = [int](($width - $glowW) / 2)
    $glowY = [int](-100 * $scale)

    $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $glowRect = New-Object System.Drawing.Rectangle($glowX, $glowY, $glowW, $glowH)
    $glowPath.AddEllipse($glowRect)
    $glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
    $glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(45, $accentColor.R, $accentColor.G, $accentColor.B)
    $glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $bgTop.R, $bgTop.G, $bgTop.B))
    $g.FillEllipse($glowBrush, $glowRect)
    $glowBrush.Dispose()
    $glowPath.Dispose()

    # 3. Top Badge Pill
    if ($badgeText) {
        $badgeFontSize = [float](18.0 * $scale)
        $badgeFont = New-Object System.Drawing.Font("Segoe UI", $badgeFontSize, [System.Drawing.FontStyle]::Bold)
        $badgeSize = $g.MeasureString($badgeText, $badgeFont)
        [float]$pillW = [float]($badgeSize.Width + (40.0 * $scale))
        [float]$pillH = [float](50.0 * $scale)
        [float]$pillX = [float](($width - $pillW) / 2.0)
        [float]$pillY = [float](85.0 * $scale)

        $pillPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $pillH
        $pillPath.AddArc($pillX, $pillY, $d, $d, 90, 180)
        $pillPath.AddArc(($pillX + $pillW - $d), $pillY, $d, $d, 270, 180)
        $pillPath.CloseFigure()

        $badgeBgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, $accentColor.R, $accentColor.G, $accentColor.B))
        $badgeBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, $accentColor.R, $accentColor.G, $accentColor.B), [float](2.2 * $scale))
        $badgeTextBrush = New-Object System.Drawing.SolidBrush($accentColor)

        $g.FillPath($badgeBgBrush, $pillPath)
        $g.DrawPath($badgeBorderPen, $pillPath)

        $sfBadge = New-Object System.Drawing.StringFormat
        $sfBadge.Alignment = [System.Drawing.StringAlignment]::Center
        $sfBadge.LineAlignment = [System.Drawing.StringAlignment]::Center
        $pillTextRect = New-Object System.Drawing.RectangleF($pillX, $pillY, $pillW, $pillH)
        $g.DrawString($badgeText, $badgeFont, $badgeTextBrush, $pillTextRect, $sfBadge)

        $badgeBgBrush.Dispose()
        $badgeBorderPen.Dispose()
        $badgeTextBrush.Dispose()
        $pillPath.Dispose()
        $badgeFont.Dispose()
    }

    # 4. Header Title
    $titleFontSize = [float](48.0 * $scale)
    $titleFont = New-Object System.Drawing.Font("Segoe UI", $titleFontSize, [System.Drawing.FontStyle]::Bold)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Near

    [float]$tX = [float](40.0 * $scale)
    [float]$tY = [float](155.0 * $scale)
    [float]$tW = [float]($width - (80.0 * $scale))
    [float]$tH = [float](120.0 * $scale)
    $titleRect = New-Object System.Drawing.RectangleF($tX, $tY, $tW, $tH)
    $g.DrawString($titleText, $titleFont, $titleBrush, $titleRect, $sfCenter)
    $titleBrush.Dispose()
    $titleFont.Dispose()

    # 5. Header Subtitle
    $subFontSize = [float](23.0 * $scale)
    $subFont = New-Object System.Drawing.Font("Segoe UI", $subFontSize, [System.Drawing.FontStyle]::Regular)
    $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(203, 213, 225)) # slate-300

    [float]$sX = [float](60.0 * $scale)
    [float]$sY = [float](280.0 * $scale)
    [float]$sW = [float]($width - (120.0 * $scale))
    [float]$sH = [float](100.0 * $scale)
    $subRect = New-Object System.Drawing.RectangleF($sX, $sY, $sW, $sH)
    $g.DrawString($subtitleText, $subFont, $subBrush, $subRect, $sfCenter)
    $subBrush.Dispose()
    $subFont.Dispose()

    # 6. iPhone Frame Dimensions
    $phoneW = [int](830 * $scale)
    $phoneH = [int](1840 * $scale)
    $phoneX = [int](($width - $phoneW) / 2)
    $phoneY = [int](420 * $scale)

    $bezel = [int](16 * $scale)
    $frameW = $phoneW + ($bezel * 2)
    $frameH = $phoneH + ($bezel * 2)
    $frameX = $phoneX - $bezel
    $frameY = $phoneY - $bezel
    $cornerRadius = [int](64 * $scale)

    # Draw Phone Outer Shadow (Multi-layered soft glow)
    for ($i = 1; $i -le 14; $i++) {
        $shadowAlpha = [int](22 - $i)
        if ($shadowAlpha -lt 1) { $shadowAlpha = 1 }
        $shadowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($shadowAlpha, 0, 0, 0), [float]($i * 3.2 * $scale))
        $sRect = New-Object System.Drawing.Rectangle(($frameX - $i*3), ($frameY - $i*3), ($frameW + $i*6), ($frameH + $i*6))
        $sp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $sp.AddArc($sRect.X, $sRect.Y, ($cornerRadius*2), ($cornerRadius*2), 180, 90)
        $sp.AddArc(($sRect.Right - $cornerRadius*2), $sRect.Y, ($cornerRadius*2), ($cornerRadius*2), 270, 90)
        $sp.AddArc(($sRect.Right - $cornerRadius*2), ($sRect.Bottom - $cornerRadius*2), ($cornerRadius*2), ($cornerRadius*2), 0, 90)
        $sp.AddArc($sRect.X, ($sRect.Bottom - $cornerRadius*2), ($cornerRadius*2), ($cornerRadius*2), 90, 90)
        $sp.CloseFigure()
        $g.DrawPath($shadowPen, $sp)
        $sp.Dispose()
        $shadowPen.Dispose()
    }

    # Outer iPhone Frame Titanium Body
    $framePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $framePath.AddArc($frameX, $frameY, ($cornerRadius*2), ($cornerRadius*2), 180, 90)
    $framePath.AddArc(($frameX + $frameW - $cornerRadius*2), $frameY, ($cornerRadius*2), ($cornerRadius*2), 270, 90)
    $framePath.AddArc(($frameX + $frameW - $cornerRadius*2), ($frameY + $frameH - $cornerRadius*2), ($cornerRadius*2), ($cornerRadius*2), 0, 90)
    $framePath.AddArc($frameX, ($frameY + $frameH - $cornerRadius*2), ($cornerRadius*2), ($cornerRadius*2), 90, 90)
    $framePath.CloseFigure()

    $frameBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 24, 32, 47)) # Dark Titanium
    $framePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 71, 85, 105), [float](3.5 * $scale))
    $g.FillPath($frameBrush, $framePath)
    $g.DrawPath($framePen, $framePath)
    $frameBrush.Dispose()
    $framePen.Dispose()
    $framePath.Dispose()

    # Inner Screen Path (Clipped for app screenshot)
    $screenRadius = [int](52 * $scale)
    $screenPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $screenPath.AddArc($phoneX, $phoneY, ($screenRadius*2), ($screenRadius*2), 180, 90)
    $screenPath.AddArc(($phoneX + $phoneW - $screenRadius*2), $phoneY, ($screenRadius*2), ($screenRadius*2), 270, 90)
    $screenPath.AddArc(($phoneX + $phoneW - $screenRadius*2), ($phoneY + $phoneH - $screenRadius*2), ($screenRadius*2), ($screenRadius*2), 0, 90)
    $screenPath.AddArc($phoneX, ($phoneY + $phoneH - $screenRadius*2), ($screenRadius*2), ($screenRadius*2), 90, 90)
    $screenPath.CloseFigure()

    $oldClip = $g.Clip
    $g.SetClip($screenPath)

    if (Test-Path $screenshotPath) {
        $screenImg = [System.Drawing.Image]::FromFile($screenshotPath)
        $destScreenRect = New-Object System.Drawing.Rectangle($phoneX, $phoneY, $phoneW, $phoneH)
        $g.DrawImage($screenImg, $destScreenRect)
        $screenImg.Dispose()
    } else {
        $placeholderBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
        $g.FillPath($placeholderBrush, $screenPath)
        $placeholderBrush.Dispose()
    }

    $g.Clip = $oldClip
    $screenPath.Dispose()

    # Screen Inner Glass Edge Highlight
    $innerGlowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 255, 255, 255), [float](2.0 * $scale))
    $screenBorderPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $screenBorderPath.AddArc($phoneX, $phoneY, ($screenRadius*2), ($screenRadius*2), 180, 90)
    $screenBorderPath.AddArc(($phoneX + $phoneW - $screenRadius*2), $phoneY, ($screenRadius*2), ($screenRadius*2), 270, 90)
    $screenBorderPath.AddArc(($phoneX + $phoneW - $screenRadius*2), ($phoneY + $phoneH - $screenRadius*2), ($screenRadius*2), ($screenRadius*2), 0, 90)
    $screenBorderPath.AddArc($phoneX, ($phoneY + $phoneH - $screenRadius*2), ($screenRadius*2), ($screenRadius*2), 90, 90)
    $screenBorderPath.CloseFigure()
    $g.DrawPath($innerGlowPen, $screenBorderPath)
    $innerGlowPen.Dispose()
    $screenBorderPath.Dispose()

    # iPhone Dynamic Island (Pill Cutout)
    $islandW = [int](150 * $scale)
    $islandH = [int](40 * $scale)
    $islandX = [int](($width - $islandW) / 2)
    $islandY = $phoneY + [int](18 * $scale)

    $islandPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $id = $islandH
    $islandPath.AddArc($islandX, $islandY, $id, $id, 90, 180)
    $islandPath.AddArc(($islandX + $islandW - $id), $islandY, $id, $id, 270, 180)
    $islandPath.CloseFigure()

    $islandBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 5, 5, 8))
    $islandPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), [float](1.2 * $scale))
    $g.FillPath($islandBrush, $islandPath)
    $g.DrawPath($islandPen, $islandPath)
    $islandBrush.Dispose()
    $islandPen.Dispose()
    $islandPath.Dispose()

    # Save Bitmap
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host " [OK] Generated: $outputFileName ($width x $height)"
}

# 6 Primary Banners Config
$banners = @(
    @{
        screenshot = "01_asosiy_dashboard.png"
        badge = "M-IT UNO • TALABA PORTALI"
        title = "Barcha darslaringiz bir joyda"
        sub = "Xonalar, vaqtlar va ustozlar haqida to'liq ma'lumot"
        out = "01_asosiy_dashboard"
        accent = [System.Drawing.Color]::FromArgb(211, 255, 50)     # Neon Lime #D3FF32
        bgTop = [System.Drawing.Color]::FromArgb(0, 33, 61)         # Midnight Tech Navy #00213D
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)       # Slate 950 #020617
    },
    @{
        screenshot = "02_darslar_va_vazifalar.png"
        badge = "DARSLAR VA VAZIFALAR"
        title = "Uyga vazifalarni onlayn topshiring"
        sub = "Mavzular, yuklangan fayllar va o'qituvchi bahosi"
        out = "02_darslar_va_vazifalar"
        accent = [System.Drawing.Color]::FromArgb(56, 189, 248)     # Sky Blue #38BDF8
        bgTop = [System.Drawing.Color]::FromArgb(10, 37, 64)        # Deep Steel Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    },
    @{
        screenshot = "06_davomat_monitoringi.png"
        badge = "QR ID VA DAVOMAT"
        title = "Shaffof va aniq davomat tizimi"
        sub = "Darsga kelish va ketish vaqtlari doimiy nazoratda"
        out = "03_davomat_monitoringi"
        accent = [System.Drawing.Color]::FromArgb(16, 185, 129)     # Emerald #10B981
        bgTop = [System.Drawing.Color]::FromArgb(6, 44, 40)         # Deep Emerald Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    },
    @{
        screenshot = "07_baholar_va_monitoring.png"
        badge = "AKADEMIK O'ZLASHTIRISH"
        title = "O'zlashtirish va imtihon ballari"
        sub = "Har bir mavzu bo'yicha baholar va ustoz izohlari"
        out = "04_baholar_va_monitoring"
        accent = [System.Drawing.Color]::FromArgb(168, 85, 247)     # Purple #A855F7
        bgTop = [System.Drawing.Color]::FromArgb(35, 15, 60)        # Deep Purple Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    },
    @{
        screenshot = "04_tolovlar_monitoringi.png"
        badge = "TO'LOVLAR VA CHEKLAR"
        title = "Qulay va xavfsiz to'lov nazorati"
        sub = "Oylik shartnoma, to'lovlar tarixi va cheklar arxivi"
        out = "05_tolovlar_monitoringi"
        accent = [System.Drawing.Color]::FromArgb(245, 158, 11)     # Amber #F59E0B
        bgTop = [System.Drawing.Color]::FromArgb(45, 26, 5)         # Deep Amber Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    },
    @{
        screenshot = "05_talaba_profili.png"
        badge = "TALABA PROFILI & COINLAR"
        title = "Shaxsiy profil va yutuqlar tizimi"
        sub = "IT Kvizlar, Coinlar, sertifikatlar va shaxsiy ma'lumotlar"
        out = "06_talaba_profili"
        accent = [System.Drawing.Color]::FromArgb(236, 72, 153)     # Rose #EC4899
        bgTop = [System.Drawing.Color]::FromArgb(40, 10, 30)        # Deep Rose Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    }
)

Write-Host "=========================================================="
Write-Host "🚀 Generating iPhone App Store Showcase Banners (1242x2688)..."
Write-Host "=========================================================="
foreach ($b in $banners) {
    Create-IosShowcaseBanner `
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
        -bgBottom $b.bgBottom
}

Write-Host "=========================================================="
Write-Host "🚀 Generating iPhone App Store Showcase Banners (1320x2868)..."
Write-Host "=========================================================="
foreach ($b in $banners) {
    Create-IosShowcaseBanner `
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
        -bgBottom $b.bgBottom
}

# Generate 1024x1024 App Store Icon
Write-Host "=========================================================="
Write-Host "🚀 Generating 1024x1024 App Store Icon..."
Write-Host "=========================================================="
if (Test-Path $iconSrc) {
    $iconImg = [System.Drawing.Image]::FromFile($iconSrc)
    $iconBmp = New-Object System.Drawing.Bitmap(1024, 1024)
    $ig = [System.Drawing.Graphics]::FromImage($iconBmp)
    $ig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $ig.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $ig.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    # Background opaque
    $ig.Clear([System.Drawing.Color]::FromArgb(255, 0, 33, 61)) # App Navy Brand
    $ig.DrawImage($iconImg, 0, 0, 1024, 1024)
    $iconImg.Dispose()
    $ig.Dispose()

    $iconPath1 = "d:\M-IT\m_it_student_platform\docs\app_store_icon_1024.png"
    $iconPath2 = Join-Path $outDir1242 "app_icon_1024.png"
    $iconPath3 = Join-Path $outDir1320 "app_icon_1024.png"

    $iconBmp.Save($iconPath1, [System.Drawing.Imaging.ImageFormat]::Png)
    $iconBmp.Save($iconPath2, [System.Drawing.Imaging.ImageFormat]::Png)
    $iconBmp.Save($iconPath3, [System.Drawing.Imaging.ImageFormat]::Png)
    $iconBmp.Dispose()
    Write-Host " [OK] 1024x1024 Icon Generated in docs/app_store_icon_1024.png"
}

Write-Host "🎉 ALL IPHONE GRAPHICS COMPLETED SUCCESSFULLY!"
