Add-Type -AssemblyName System.Drawing

$srcDir = "d:\M-IT\m_it_student_platform\docs\screenshots"
$outDir = "d:\M-IT\m_it_student_platform\docs\showcase_1080x1920"

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

function Create-ShowcaseBanner {
    param(
        [string]$screenshotName,
        [string]$badgeText,
        [string]$titleText,
        [string]$subtitleText,
        [string]$outputName,
        [System.Drawing.Color]$accentColor,
        [System.Drawing.Color]$bgTop,
        [System.Drawing.Color]$bgBottom
    )

    $screenshotPath = Join-Path $srcDir $screenshotName
    $outputPath = Join-Path $outDir $outputName

    $width = 1080
    $height = 1920

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

    # 2. Glowing Accent Aura behind header
    $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $glowRect = New-Object System.Drawing.Rectangle(150, -80, 780, 520)
    $glowPath.AddEllipse($glowRect)
    $glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
    $glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(40, $accentColor.R, $accentColor.G, $accentColor.B)
    $glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $bgTop.R, $bgTop.G, $bgTop.B))
    $g.FillEllipse($glowBrush, $glowRect)
    $glowBrush.Dispose()
    $glowPath.Dispose()

    # 3. Top Badge Pill
    if ($badgeText) {
        $badgeFont = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
        $badgeSize = $g.MeasureString($badgeText, $badgeFont)
        $pillW = [int]$badgeSize.Width + 34
        $pillH = 42
        $pillX = [int](($width - $pillW) / 2)
        $pillY = 65

        $pillPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $pillH
        $pillPath.AddArc($pillX, $pillY, $d, $d, 90, 180)
        $pillPath.AddArc($pillX + $pillW - $d, $pillY, $d, $d, 270, 180)
        $pillPath.CloseFigure()

        $badgeBgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, $accentColor.R, $accentColor.G, $accentColor.B))
        $badgeBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, $accentColor.R, $accentColor.G, $accentColor.B), 1.8)
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
    $titleFont = New-Object System.Drawing.Font("Segoe UI", 42, [System.Drawing.FontStyle]::Bold)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Near
    $titleRect = New-Object System.Drawing.RectangleF(40, 122, ($width - 80), 90)
    $g.DrawString($titleText, $titleFont, $titleBrush, $titleRect, $sfCenter)
    $titleBrush.Dispose()
    $titleFont.Dispose()

    # 5. Header Subtitle
    $subFont = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Regular)
    $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(203, 213, 225)) # slate-300
    $subRect = New-Object System.Drawing.RectangleF(50, 214, ($width - 100), 75)
    $g.DrawString($subtitleText, $subFont, $subBrush, $subRect, $sfCenter)
    $subBrush.Dispose()
    $subFont.Dispose()

    # 6. Phone Dimensions (Aspect Ratio: 1080 / 2400 = 0.45)
    $phoneW = 690
    $phoneH = 1533 # 690 / 0.45 = 1533.3
    $phoneX = [int](($width - $phoneW) / 2)
    $phoneY = 320

    $bezel = 14
    $frameW = $phoneW + ($bezel * 2)
    $frameH = $phoneH + ($bezel * 2)
    $frameX = $phoneX - $bezel
    $frameY = $phoneY - $bezel
    $cornerRadius = 52

    # Draw Phone Outer Shadow
    for ($i = 1; $i -le 12; $i++) {
        $shadowAlpha = [int](18 - $i)
        if ($shadowAlpha -lt 1) { $shadowAlpha = 1 }
        $shadowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($shadowAlpha, 0, 0, 0), ($i * 2.8))
        $sRect = New-Object System.Drawing.Rectangle(($frameX - $i*2), ($frameY - $i*2), ($frameW + $i*4), ($frameH + $i*4))
        $sp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $sp.AddArc($sRect.X, $sRect.Y, $cornerRadius*2, $cornerRadius*2, 180, 90)
        $sp.AddArc($sRect.Right - $cornerRadius*2, $sRect.Y, $cornerRadius*2, $cornerRadius*2, 270, 90)
        $sp.AddArc($sRect.Right - $cornerRadius*2, $sRect.Bottom - $cornerRadius*2, $cornerRadius*2, $cornerRadius*2, 0, 90)
        $sp.AddArc($sRect.X, $sRect.Bottom - $cornerRadius*2, $cornerRadius*2, $cornerRadius*2, 90, 90)
        $sp.CloseFigure()
        $g.DrawPath($shadowPen, $sp)
        $sp.Dispose()
        $shadowPen.Dispose()
    }

    # Outer Frame Body
    $framePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $framePath.AddArc($frameX, $frameY, $cornerRadius*2, $cornerRadius*2, 180, 90)
    $framePath.AddArc($frameX + $frameW - $cornerRadius*2, $frameY, $cornerRadius*2, $cornerRadius*2, 270, 90)
    $framePath.AddArc($frameX + $frameW - $cornerRadius*2, $frameY + $frameH - $cornerRadius*2, $cornerRadius*2, $cornerRadius*2, 0, 90)
    $framePath.AddArc($frameX, $frameY + $frameH - $cornerRadius*2, $cornerRadius*2, $cornerRadius*2, 90, 90)
    $framePath.CloseFigure()

    $frameBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59)) # Slate-800
    $framePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 71, 85, 105), 3) # Slate-600
    $g.FillPath($frameBrush, $framePath)
    $g.DrawPath($framePen, $framePath)
    $frameBrush.Dispose()
    $framePen.Dispose()
    $framePath.Dispose()

    # Inner Screen Path (Clipped for app screenshot)
    $screenRadius = 42
    $screenPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $screenPath.AddArc($phoneX, $phoneY, $screenRadius*2, $screenRadius*2, 180, 90)
    $screenPath.AddArc($phoneX + $phoneW - $screenRadius*2, $phoneY, $screenRadius*2, $screenRadius*2, 270, 90)
    $screenPath.AddArc($phoneX + $phoneW - $screenRadius*2, $phoneY + $phoneH - $screenRadius*2, $screenRadius*2, $screenRadius*2, 0, 90)
    $screenPath.AddArc($phoneX, $phoneY + $phoneH - $screenRadius*2, $screenRadius*2, $screenRadius*2, 90, 90)
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
    $innerGlowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 2)
    $screenBorderPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $screenBorderPath.AddArc($phoneX, $phoneY, $screenRadius*2, $screenRadius*2, 180, 90)
    $screenBorderPath.AddArc($phoneX + $phoneW - $screenRadius*2, $phoneY, $screenRadius*2, $screenRadius*2, 270, 90)
    $screenBorderPath.AddArc($phoneX + $phoneW - $screenRadius*2, $phoneY + $phoneH - $screenRadius*2, $screenRadius*2, $screenRadius*2, 0, 90)
    $screenBorderPath.AddArc($phoneX, $phoneY + $phoneH - $screenRadius*2, $screenRadius*2, $screenRadius*2, 90, 90)
    $screenBorderPath.CloseFigure()
    $g.DrawPath($innerGlowPen, $screenBorderPath)
    $innerGlowPen.Dispose()
    $screenBorderPath.Dispose()

    # Camera punch hole
    $punchSize = 20
    $punchX = [int](($width - $punchSize) / 2)
    $punchY = $phoneY + 16
    $punchBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 15, 25))
    $punchPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 255, 255, 255), 1)
    $g.FillEllipse($punchBrush, $punchX, $punchY, $punchSize, $punchSize)
    $g.DrawEllipse($punchPen, $punchX, $punchY, $punchSize, $punchSize)
    $punchBrush.Dispose()
    $punchPen.Dispose()

    # Save final image
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()

    Write-Host "Created 1080x1920 Showcase Banner: $outputName"
}

# 1. Asosiy Dashboard
Create-ShowcaseBanner `
    -screenshotName "01_asosiy_dashboard.png" `
    -badgeText "M-IT TALABA PLATFORMASI" `
    -titleText "Asosiy Boshqaruv Paneli" `
    -subtitleText "O'quv jarayoni, guruh va muhim ko'rsatkichlar bir joyda" `
    -outputName "01_asosiy_dashboard_1080x1920.png" `
    -accentColor ([System.Drawing.Color]::FromArgb(211, 255, 50)) `
    -bgTop ([System.Drawing.Color]::FromArgb(11, 18, 32)) `
    -bgBottom ([System.Drawing.Color]::FromArgb(20, 32, 54))

# 2. Yangilangan Darslar va Vazifalar
Create-ShowcaseBanner `
    -screenshotName "02_darslar_va_vazifalar.png" `
    -badgeText "DARSLAR & VAZIFALAR" `
    -titleText "Mavzular & Uyga Vazifalar" `
    -subtitleText "Barcha dars mavzulari, muddatlar va bajarilgan vazifalar" `
    -outputName "02_darslar_va_vazifalar_1080x1920.png" `
    -accentColor ([System.Drawing.Color]::FromArgb(56, 189, 248)) `
    -bgTop ([System.Drawing.Color]::FromArgb(8, 28, 48)) `
    -bgBottom ([System.Drawing.Color]::FromArgb(15, 23, 42))

# 3. Dars va Vazifa Tafsilotlari
Create-ShowcaseBanner `
    -screenshotName "03_vazifa_va_dars_tafsilotlari.png" `
    -badgeText "BAHOLASH TIZIMI" `
    -titleText "Vazifa Tafsilotlari & Baholar" `
    -subtitleText "O'quv materiallari (PDF) va ustoz qo'ygan baholarni ko'rish" `
    -outputName "03_vazifa_va_dars_tafsilotlari_1080x1920.png" `
    -accentColor ([System.Drawing.Color]::FromArgb(211, 255, 50)) `
    -bgTop ([System.Drawing.Color]::FromArgb(15, 23, 42)) `
    -bgBottom ([System.Drawing.Color]::FromArgb(26, 36, 56))

# 4. To'lovlar Monitoringi
Create-ShowcaseBanner `
    -screenshotName "04_tolovlar_monitoringi.png" `
    -badgeText "MOLIYA & TO'LOVLAR" `
    -titleText "To'lovlar & Kvitansiyalar" `
    -subtitleText "Oylik to'lov holati va barcha cheklar tarixi" `
    -outputName "04_tolovlar_monitoringi_1080x1920.png" `
    -accentColor ([System.Drawing.Color]::FromArgb(16, 185, 129)) `
    -bgTop ([System.Drawing.Color]::FromArgb(6, 32, 28)) `
    -bgBottom ([System.Drawing.Color]::FromArgb(15, 23, 42))

# 5. Talaba Profili
Create-ShowcaseBanner `
    -screenshotName "05_talaba_profili.png" `
    -badgeText "SHAXSIY KABINET" `
    -titleText "Talaba Profili & Sozlamalar" `
    -subtitleText "Shaxsiy ma'lumotlar, 3 xil til va xavfsizlik sozlamalari" `
    -outputName "05_talaba_profili_1080x1920.png" `
    -accentColor ([System.Drawing.Color]::FromArgb(129, 140, 248)) `
    -bgTop ([System.Drawing.Color]::FromArgb(22, 20, 52)) `
    -bgBottom ([System.Drawing.Color]::FromArgb(15, 23, 42))

# 6. Davomat Monitoringi
Create-ShowcaseBanner `
    -screenshotName "06_davomat_monitoringi.png" `
    -badgeText "DAVOMAT NAZORATI" `
    -titleText "100% Shaffof Davomat" `
    -subtitleText "Darslarga qatnashish ko'rsatkichi va kirish-chiqish vaqtlari" `
    -outputName "06_davomat_monitoringi_1080x1920.png" `
    -accentColor ([System.Drawing.Color]::FromArgb(34, 197, 94)) `
    -bgTop ([System.Drawing.Color]::FromArgb(10, 30, 35)) `
    -bgBottom ([System.Drawing.Color]::FromArgb(15, 23, 42))

# 7. Baholar va Monitoring
Create-ShowcaseBanner `
    -screenshotName "07_baholar_va_monitoring.png" `
    -badgeText "AKADEMIK NATIJALAR" `
    -titleText "Baholar & Reyting Nazorati" `
    -subtitleText "Fanlar bo'yicha o'rtacha ball va topshiriqlar statistikasi" `
    -outputName "07_baholar_va_monitoring_1080x1920.png" `
    -accentColor ([System.Drawing.Color]::FromArgb(251, 191, 36)) `
    -bgTop ([System.Drawing.Color]::FromArgb(38, 28, 12)) `
    -bgBottom ([System.Drawing.Color]::FromArgb(15, 23, 42))

# 8. Kunduzgi Rejim Dashboard
Create-ShowcaseBanner `
    -screenshotName "08_kunduzgi_rejim_dashboard.png" `
    -badgeText "YORUG' & TUNGI MAVZU" `
    -titleText "Kunduzgi Yorug' Dizayn" `
    -subtitleText "Har qanday muhitda ko'zga qulay va chiroyli interfeys" `
    -outputName "08_kunduzgi_rejim_dashboard_1080x1920.png" `
    -accentColor ([System.Drawing.Color]::FromArgb(14, 165, 233)) `
    -bgTop ([System.Drawing.Color]::FromArgb(14, 25, 45)) `
    -bgBottom ([System.Drawing.Color]::FromArgb(24, 38, 65))

Write-Host "All 8 Showcase Banners created successfully in 1080x1920!"
