Add-Type -AssemblyName System.Drawing
$destDir = 'd:\M-IT\m_it_student_platform\docs\ios_showcase_3d_iphone'
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

$brainDir = 'C:\Users\user\.gemini\antigravity-ide\brain\53858858-da35-4b54-9e7a-51094be78408'
$mapping = @(
    @{ src = 'iphone_dashboard_showcase_1788505643181.jpg'; out = '01_asosiy_dashboard_iphone.png' },
    @{ src = 'iphone_lessons_showcase_1788505659607.jpg'; out = '02_darslar_va_vazifalar_iphone.png' },
    @{ src = 'iphone_attendance_showcase_1788505672171.jpg'; out = '03_davomat_monitoringi_iphone.png' },
    @{ src = 'iphone_grades_showcase_1788505691804.jpg'; out = '04_baholar_va_monitoring_iphone.png' },
    @{ src = 'iphone_payments_showcase_1788505712044.jpg'; out = '05_tolovlar_monitoringi_iphone.png' },
    @{ src = 'iphone_profile_showcase_1788505724442.jpg'; out = '06_talaba_profili_iphone.png' }
)

foreach ($m in $mapping) {
    $srcFile = Join-Path $brainDir $m.src
    $outFile = Join-Path $destDir $m.out
    if (Test-Path $srcFile) {
        $srcImg = [System.Drawing.Image]::FromFile($srcFile)
        $bmp = New-Object System.Drawing.Bitmap(1242, 2688)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.DrawImage($srcImg, 0, 0, 1242, 2688)
        $srcImg.Dispose()
        $g.Dispose()
        $bmp.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        Write-Host "Saved 1242x2688: $($m.out)"
    }
}
Write-Host "EXPORT COMPLETED!"
