# Google Play Store Screenshots Capture Script (Native 1080x2400 - No Distortion)
$adb = "C:\Users\user\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$dest = "docs\screenshots"

if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
}

# Auto-detect connected device
$devices = & $adb devices | Select-String "device$" | ForEach-Object { ($_ -split "`t")[0] }
$dev = $devices[0]

if (-not $dev) {
    Write-Error "No connected Android device or emulator found!"
    exit 1
}

Write-Host "Capturing Play Store screenshots on device: $dev"

function Capture-Screen($name) {
    Start-Sleep -Milliseconds 700
    & $adb -s $dev shell screencap -p /sdcard/s_tmp.png
    & $adb -s $dev pull /sdcard/s_tmp.png "$dest\$name"
    Write-Host "Captured $dest\$name"
}

# 1. Asosiy Dashboard
& $adb -s $dev shell input tap 135 2300
Capture-Screen "01_asosiy_dashboard.png"

# 2. Yangilangan Darslar va Vazifalar
& $adb -s $dev shell input tap 405 2300
Capture-Screen "02_darslar_va_vazifalar.png"

# 3. Dars va Vazifa Tafsilotlari Modal
& $adb -s $dev shell input tap 500 550
Capture-Screen "03_vazifa_va_dars_tafsilotlari.png"
& $adb -s $dev shell input keyevent 4
Start-Sleep -Milliseconds 400

# 4. To'lovlar Monitoringi
& $adb -s $dev shell input tap 675 2300
Capture-Screen "04_tolovlar_monitoringi.png"

# 5. Talaba Profili
& $adb -s $dev shell input tap 945 2300
Capture-Screen "05_talaba_profili.png"

Write-Host "Screenshots captured successfully without any aspect ratio distortion!"
