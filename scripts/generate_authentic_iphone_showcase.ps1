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

function Create-AuthenticIphoneBanner {
    param(
        [string]$screenshotName,
        [string]$badgeText,
        [string]$titleMain,
        [string]$titleHighlight,
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

    [float]$scale = [float]$width / 1242.0

    # 1. Background Radiant Gradient
    $bgRect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($bgRect, $bgTop, $bgBottom, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    $g.FillRectangle($bgBrush, $bgRect)
    $bgBrush.Dispose()

    # 2. Glowing Accent Aura behind Header
    $glowW = [int](920 * $scale)
    $glowH = [int](620 * $scale)
    $glowX = [int](($width - $glowW) / 2)
    $glowY = [int](-120 * $scale)

    $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $glowRect = New-Object System.Drawing.Rectangle($glowX, $glowY, $glowW, $glowH)
    $glowPath.AddEllipse($glowRect)
    $glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
    $glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(45, $accentColor.R, $accentColor.G, $accentColor.B)
    $glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $bgTop.R, $bgTop.G, $bgTop.B))
    $g.FillEllipse($glowBrush, $glowRect)
    $glowBrush.Dispose()
    $glowPath.Dispose()

    # 3. Top Category Badge Pill
    if ($badgeText) {
        $badgeFontSize = [float](17.0 * $scale)
        $badgeFont = New-Object System.Drawing.Font("Segoe UI", $badgeFontSize, [System.Drawing.FontStyle]::Bold)
        $badgeSize = $g.MeasureString($badgeText, $badgeFont)
        [float]$pillW = [float]($badgeSize.Width + (36.0 * $scale))
        [float]$pillH = [float](46.0 * $scale)
        [float]$pillX = [float](($width - $pillW) / 2.0)
        [float]$pillY = [float](75.0 * $scale)

        $pillPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $pillH
        $pillPath.AddArc($pillX, $pillY, $d, $d, 90, 180)
        $pillPath.AddArc(($pillX + $pillW - $d), $pillY, $d, $d, 270, 180)
        $pillPath.CloseFigure()

        $badgeBgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, $accentColor.R, $accentColor.G, $accentColor.B))
        $badgeBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, $accentColor.R, $accentColor.G, $accentColor.B), [float](2.0 * $scale))
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

    # 4. Big Bold Title with Highlight Pill
    $titleFontSize = [float](46.0 * $scale)
    $titleFont = New-Object System.Drawing.Font("Segoe UI", $titleFontSize, [System.Drawing.FontStyle]::Bold)

    $fullTitle = "$titleMain $titleHighlight"
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Near

    [float]$tX = [float](40.0 * $scale)
    [float]$tY = [float](145.0 * $scale)
    [float]$tW = [float]($width - (80.0 * $scale))
    [float]$tH = [float](130.0 * $scale)
    $titleRect = New-Object System.Drawing.RectangleF($tX, $tY, $tW, $tH)
    $g.DrawString($fullTitle, $titleFont, $titleBrush, $titleRect, $sfCenter)
    $titleBrush.Dispose()
    $titleFont.Dispose()

    # 5. Subtitle
    $subFontSize = [float](22.0 * $scale)
    $subFont = New-Object System.Drawing.Font("Segoe UI", $subFontSize, [System.Drawing.FontStyle]::Regular)
    $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(203, 213, 225)) # slate-300

    [float]$sX = [float](60.0 * $scale)
    [float]$sY = [float](285.0 * $scale)
    [float]$sW = [float]($width - (120.0 * $scale))
    [float]$sH = [float](80.0 * $scale)
    $subRect = New-Object System.Drawing.RectangleF($sX, $sY, $sW, $sH)
    $g.DrawString($subtitleText, $subFont, $subBrush, $subRect, $sfCenter)
    $subBrush.Dispose()
    $subFont.Dispose()

    # 6. Authentic iPhone Frame Parameters
    $phoneW = [int](880 * $scale)
    $phoneH = [int](1920 * $scale)
    $phoneX = [int](($width - $phoneW) / 2)
    $phoneY = [int](390 * $scale)

    $bezel = [int](18 * $scale)
    $frameW = $phoneW + ($bezel * 2)
    $frameH = $phoneH + ($bezel * 2)
    $frameX = $phoneX - $bezel
    $frameY = $phoneY - $bezel
    $outerCornerRadius = [int](72 * $scale)
    $innerCornerRadius = [int](56 * $scale)

    # 6.1 Multi-tier Realistic Drop Shadow
    for ($i = 1; $i -le 16; $i++) {
        $shadowAlpha = [int](25 - $i)
        if ($shadowAlpha -lt 1) { $shadowAlpha = 1 }
        $shadowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($shadowAlpha, 0, 0, 0), [float]($i * 3.4 * $scale))
        $sRect = New-Object System.Drawing.Rectangle(($frameX - $i*3), ($frameY - $i*3), ($frameW + $i*6), ($frameH + $i*6))
        $sp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $sp.AddArc($sRect.X, $sRect.Y, ($outerCornerRadius*2), ($outerCornerRadius*2), 180, 90)
        $sp.AddArc(($sRect.Right - $outerCornerRadius*2), $sRect.Y, ($outerCornerRadius*2), ($outerCornerRadius*2), 270, 90)
        $sp.AddArc(($sRect.Right - $outerCornerRadius*2), ($sRect.Bottom - $outerCornerRadius*2), ($outerCornerRadius*2), ($outerCornerRadius*2), 0, 90)
        $sp.AddArc($sRect.X, ($sRect.Bottom - $outerCornerRadius*2), ($outerCornerRadius*2), ($outerCornerRadius*2), 90, 90)
        $sp.CloseFigure()
        $g.DrawPath($shadowPen, $sp)
        $sp.Dispose()
        $shadowPen.Dispose()
    }

    # 6.2 Outer Titanium iPhone Frame Body
    $framePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $framePath.AddArc($frameX, $frameY, ($outerCornerRadius*2), ($outerCornerRadius*2), 180, 90)
    $framePath.AddArc(($frameX + $frameW - $outerCornerRadius*2), $frameY, ($outerCornerRadius*2), ($outerCornerRadius*2), 270, 90)
    $framePath.AddArc(($frameX + $frameW - $outerCornerRadius*2), ($frameY + $frameH - $outerCornerRadius*2), ($outerCornerRadius*2), ($outerCornerRadius*2), 0, 90)
    $framePath.AddArc($frameX, ($frameY + $frameH - $outerCornerRadius*2), ($outerCornerRadius*2), ($outerCornerRadius*2), 90, 90)
    $framePath.CloseFigure()

    $frameBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 20, 26, 38)) # Space Black Titanium
    $framePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 71, 85, 105), [float](4.0 * $scale))
    $g.FillPath($frameBrush, $framePath)
    $g.DrawPath($framePen, $framePath)
    $frameBrush.Dispose()
    $framePen.Dispose()
    $framePath.Dispose()

    # 6.3 Inner Screen Clipping Path with Curved iPhone Screen Corners
    $screenPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $screenPath.AddArc($phoneX, $phoneY, ($innerCornerRadius*2), ($innerCornerRadius*2), 180, 90)
    $screenPath.AddArc(($phoneX + $phoneW - $innerCornerRadius*2), $phoneY, ($innerCornerRadius*2), ($innerCornerRadius*2), 270, 90)
    $screenPath.AddArc(($phoneX + $phoneW - $innerCornerRadius*2), ($phoneY + $phoneH - $innerCornerRadius*2), ($innerCornerRadius*2), ($innerCornerRadius*2), 0, 90)
    $screenPath.AddArc($phoneX, ($phoneY + $phoneH - $innerCornerRadius*2), ($innerCornerRadius*2), ($innerCornerRadius*2), 90, 90)
    $screenPath.CloseFigure()

    $oldClip = $g.Clip
    $g.SetClip($screenPath)

    if (Test-Path $screenshotPath) {
        $screenImg = [System.Drawing.Image]::FromFile($screenshotPath)
        $destScreenRect = New-Object System.Drawing.Rectangle($phoneX, $phoneY, $phoneW, $phoneH)
        $g.DrawImage($screenImg, $destScreenRect)
        $screenImg.Dispose()
    } else {
        $placeholderBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 23, 42))
        $g.FillPath($placeholderBrush, $screenPath)
        $placeholderBrush.Dispose()
    }

    # 6.4 Authentic iPhone Notch / Island at Top of Display
    $notchW = [int](260 * $scale)
    $notchH = [int](46 * $scale)
    $notchX = [int](($width - $notchW) / 2)
    $notchY = $phoneY

    $notchPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $nr = [int](18 * $scale)
    $notchPath.AddLine($notchX, $notchY, ($notchX + $notchW), $notchY)
    $notchPath.AddArc(($notchX + $notchW - $nr*2), ($notchY + $notchH - $nr*2), ($nr*2), ($nr*2), 0, 90)
    $notchPath.AddLine(($notchX + $notchW - $nr), ($notchY + $notchH), ($notchX + $nr), ($notchY + $notchH))
    $notchPath.AddArc($notchX, ($notchY + $notchH - $nr*2), ($nr*2), ($nr*2), 90, 90)
    $notchPath.CloseFigure()

    $notchBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 12, 16, 26))
    $g.FillPath($notchBrush, $notchPath)
    $notchBrush.Dispose()
    $notchPath.Dispose()

    # Camera lens inside notch
    $lensX = [int](($width + 70 * $scale) / 2)
    $lensY = $phoneY + [int](14 * $scale)
    $lensSize = [int](14 * $scale)
    $lensBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 25, 30, 48))
    $lensPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 255, 255, 255), 1)
    $g.FillEllipse($lensBrush, $lensX, $lensY, $lensSize, $lensSize)
    $g.DrawEllipse($lensPen, $lensX, $lensY, $lensSize, $lensSize)
    $lensBrush.Dispose()
    $lensPen.Dispose()

    # Speaker Grill inside notch
    $spkW = [int](70 * $scale)
    $spkH = [int](6 * $scale)
    $spkX = [int](($width - $spkW) / 2)
    $spkY = $phoneY + [int](18 * $scale)
    $spkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 35, 42, 58))
    $g.FillRectangle($spkBrush, $spkX, $spkY, $spkW, $spkH)
    $spkBrush.Dispose()

    # iPhone Home Swipe Bar at Bottom
    $barW = [int](220 * $scale)
    $barH = [int](8 * $scale)
    $barX = [int](($width - $barW) / 2)
    $barY = ($phoneY + $phoneH) - [int](20 * $scale)
    $barPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $barPath.AddArc($barX, $barY, $barH, $barH, 90, 180)
    $barPath.AddArc(($barX + $barW - $barH), $barY, $barH, $barH, 270, 180)
    $barPath.CloseFigure()
    $barBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 255, 255, 255))
    $g.FillPath($barBrush, $barPath)
    $barBrush.Dispose()
    $barPath.Dispose()

    $g.Clip = $oldClip
    $screenPath.Dispose()

    # Screen Inner Glass Edge Highlight (Gleam)
    $innerGlowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(75, 255, 255, 255), [float](2.2 * $scale))
    $screenBorderPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $screenBorderPath.AddArc($phoneX, $phoneY, ($innerCornerRadius*2), ($innerCornerRadius*2), 180, 90)
    $screenBorderPath.AddArc(($phoneX + $phoneW - $innerCornerRadius*2), $phoneY, ($innerCornerRadius*2), ($innerCornerRadius*2), 270, 90)
    $screenBorderPath.AddArc(($phoneX + $phoneW - $innerCornerRadius*2), ($phoneY + $phoneH - $innerCornerRadius*2), ($innerCornerRadius*2), ($innerCornerRadius*2), 0, 90)
    $screenBorderPath.AddArc($phoneX, ($phoneY + $phoneH - $innerCornerRadius*2), ($innerCornerRadius*2), ($innerCornerRadius*2), 90, 90)
    $screenBorderPath.CloseFigure()
    $g.DrawPath($innerGlowPen, $screenBorderPath)
    $innerGlowPen.Dispose()
    $screenBorderPath.Dispose()

    # Save Output PNG
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host " [OK] Authentic iPhone Banner: $outputFileName ($width x $height)"
}

$banners = @(
    @{
        screenshot = "01_asosiy_dashboard.png"
        badge = "M-IT UNO TALABA PORTALI"
        titleMain = "Barcha IT Darslaringiz"
        titleHighlight = "Bir Joyda"
        sub = "Jonli dars jadvali, xonalar va ustozlar monitoringi"
        out = "01_asosiy_dashboard"
        accent = [System.Drawing.Color]::FromArgb(211, 255, 50)     # Neon Lime #D3FF32
        bgTop = [System.Drawing.Color]::FromArgb(0, 33, 61)         # Midnight Tech Navy #00213D
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)       # Slate 950 #020617
    },
    @{
        screenshot = "02_darslar_va_vazifalar.png"
        badge = "DARSLAR VA VAZIFALAR"
        titleMain = "Uyga Vazifalarni"
        titleHighlight = "Onlayn Topshiring"
        sub = "Fayllar, mavzular va o'qituvchi bahosi"
        out = "02_darslar_va_vazifalar"
        accent = [System.Drawing.Color]::FromArgb(56, 189, 248)     # Sky Blue #38BDF8
        bgTop = [System.Drawing.Color]::FromArgb(10, 37, 64)        # Deep Steel Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    },
    @{
        screenshot = "06_davomat_monitoringi.png"
        badge = "QR TURNIKET VA ID"
        titleMain = "Shaffof va Aniq"
        titleHighlight = "Davomat Tizimi"
        sub = "Darsga kelish va ketish vaqtlari nazoratda"
        out = "03_davomat_monitoringi"
        accent = [System.Drawing.Color]::FromArgb(16, 185, 129)     # Emerald #10B981
        bgTop = [System.Drawing.Color]::FromArgb(6, 44, 40)         # Deep Emerald Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    },
    @{
        screenshot = "07_baholar_va_monitoring.png"
        badge = "BAHOLAR & STATISTIKA"
        titleMain = "Akademik O'zlashtirish"
        titleHighlight = "Reytingi"
        sub = "Imtihon natijalari va ustoz izohlari"
        out = "04_baholar_va_monitoring"
        accent = [System.Drawing.Color]::FromArgb(168, 85, 247)     # Purple #A855F7
        bgTop = [System.Drawing.Color]::FromArgb(35, 15, 60)        # Deep Purple Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    },
    @{
        screenshot = "04_tolovlar_monitoringi.png"
        badge = "MOLIYA VA CHEKLAR"
        titleMain = "Xavfsiz va Qulay"
        titleHighlight = "To'lov Nazorati"
        sub = "Oylik to'lovlar tarixi va kvitansiyalar arxivi"
        out = "05_tolovlar_monitoringi"
        accent = [System.Drawing.Color]::FromArgb(245, 158, 11)     # Amber #F59E0B
        bgTop = [System.Drawing.Color]::FromArgb(45, 26, 5)         # Deep Amber Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    },
    @{
        screenshot = "05_talaba_profili.png"
        badge = "PROFIL & YUTUQLAR"
        titleMain = "Shaxsiy Profil va"
        titleHighlight = "IT Kvizlar"
        sub = "Coinlar, sovg'alar va sertifikatlar platformasi"
        out = "06_talaba_profili"
        accent = [System.Drawing.Color]::FromArgb(236, 72, 153)     # Rose #EC4899
        bgTop = [System.Drawing.Color]::FromArgb(40, 10, 30)        # Deep Rose Navy
        bgBottom = [System.Drawing.Color]::FromArgb(2, 6, 23)
    }
)

Write-Host "=========================================================="
Write-Host "Generating iPhone 6.5 (1242x2688) Banners with iPhone Frame & Notch..."
Write-Host "=========================================================="
foreach ($b in $banners) {
    Create-AuthenticIphoneBanner `
        -screenshotName $b.screenshot `
        -badgeText $b.badge `
        -titleMain $b.titleMain `
        -titleHighlight $b.titleHighlight `
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
Write-Host "Generating iPhone 6.9 (1320x2868) Banners with iPhone Frame & Notch..."
Write-Host "=========================================================="
foreach ($b in $banners) {
    Create-AuthenticIphoneBanner `
        -screenshotName $b.screenshot `
        -badgeText $b.badge `
        -titleMain $b.titleMain `
        -titleHighlight $b.titleHighlight `
        -subtitleText $b.sub `
        -outputFileName "$($b.out)_1320x2868.png" `
        -width 1320 `
        -height 2868 `
        -targetDir $outDir1320 `
        -accentColor $b.accent `
        -bgTop $b.bgTop `
        -bgBottom $b.bgBottom
}

Write-Host "ALL IPHONE BANNERS COMPLETED!"
