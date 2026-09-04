Add-Type -AssemblyName System.Drawing

$srcDir = "d:\M-IT\m_it_student_platform\docs\screenshots"
$rawDir1242 = "d:\M-IT\m_it_student_platform\docs\iphone_raw_1242x2688"
$rawDir1320 = "d:\M-IT\m_it_student_platform\docs\iphone_raw_1320x2868"

if (-not (Test-Path $rawDir1242)) {
    New-Item -ItemType Directory -Path $rawDir1242 -Force | Out-Null
}
if (-not (Test-Path $rawDir1320)) {
    New-Item -ItemType Directory -Path $rawDir1320 -Force | Out-Null
}

function Create-RawIphoneScreen {
    param(
        [string]$sourceFile,
        [string]$outputFile,
        [int]$targetWidth,
        [int]$targetHeight,
        [string]$outDirectory
    )

    $srcPath = Join-Path $srcDir $sourceFile
    $outPath = Join-Path $outDirectory $outputFile

    if (-not (Test-Path $srcPath)) {
        Write-Warning "Source not found: $srcPath"
        return
    }

    $srcImg = [System.Drawing.Image]::FromFile($srcPath)

    $destBmp = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
    $g = [System.Drawing.Graphics]::FromImage($destBmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    # Draw pure UI scaled to fill the entire target phone screen
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $targetWidth, $targetHeight)
    $g.DrawImage($srcImg, $destRect)

    $srcImg.Dispose()
    $g.Dispose()

    $destBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $destBmp.Dispose()

    Write-Host " [OK] Pure Screen Generated: $outputFile ($targetWidth x $targetHeight)"
}

$screens = @(
    @{ src = "01_asosiy_dashboard.png"; out = "01_asosiy_dashboard.png" },
    @{ src = "02_darslar_va_vazifalar.png"; out = "02_darslar_va_vazifalar.png" },
    @{ src = "06_davomat_monitoringi.png"; out = "03_davomat_monitoringi.png" },
    @{ src = "07_baholar_va_monitoring.png"; out = "04_baholar_va_monitoring.png" },
    @{ src = "04_tolovlar_monitoringi.png"; out = "05_tolovlar_monitoringi.png" },
    @{ src = "05_talaba_profili.png"; out = "06_talaba_profili.png" }
)

Write-Host "=========================================================="
Write-Host "Generating Pure iPhone 6.5 (1242x2688) Full Screens..."
Write-Host "=========================================================="
foreach ($s in $screens) {
    Create-RawIphoneScreen -sourceFile $s.src -outputFile $s.out -targetWidth 1242 -targetHeight 2688 -outDirectory $rawDir1242
}

Write-Host "=========================================================="
Write-Host "Generating Pure iPhone 6.9 (1320x2868) Full Screens..."
Write-Host "=========================================================="
foreach ($s in $screens) {
    Create-RawIphoneScreen -sourceFile $s.src -outputFile $s.out -targetWidth 1320 -targetHeight 2868 -outDirectory $rawDir1320
}

Write-Host "ALL PURE IPHONE SCREENS COMPLETED SUCCESSFULLY!"
