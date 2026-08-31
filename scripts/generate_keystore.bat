@echo off
chcp 65001 > nul
echo ========================================================
echo   M-IT ERP - Google Play Release Keystore Yaratuvchi
echo ========================================================
echo.

cd /d "%~dp0\..\android"

if exist "upload-keystore.jks" (
    echo [OGOHLANTIRISH] 'android\upload-keystore.jks' fayli allaqachon mavjud!
    echo Yangisini yaratish eskisi ustiga yozilmasligi uchun to'xtatildi.
    echo Agar yangi yaratmoqchi bo'lsangiz, avval eskisini boshqa joyga ko'chiring.
    pause
    exit /b 0
)

echo Kalit yaratish boshlanmoqda...
echo Iltimos, so'ralgan parollar va tashkilot ma'lumotlarini kiriting:
echo.

set "KEYTOOL_CMD=keytool"
where keytool >nul 2>&1
if %ERRORLEVEL% neq 0 (
    if exist "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" (
        set "KEYTOOL_CMD=C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    )
)

"%KEYTOOL_CMD%" -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================================
    echo [MUVAFFAQIN!] 'android\upload-keystore.jks' yaratildi!
    echo ========================================================
    echo.
    echo Endi 'android\key.properties' faylini ochib, quyidagi ko'rinishda to'ldiring:
    echo.
    echo keyAlias=upload
    echo keyPassword=SIZ_KIRITGAN_PAROL
    echo storeFile=upload-keystore.jks
    echo storePassword=SIZ_KIRITGAN_PAROL
    echo.
) else (
    echo.
    echo [XATOLIK] Keystore yaratishda xatolik yuz berdi. Java (JDK) o'rnatilganligiga ishonch hosil qiling.
)

pause
