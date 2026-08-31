@echo off
chcp 65001 > nul
echo ========================================================
echo   M-IT ERP - Google Play Release AppBundle (.aab) Build
echo ========================================================
echo.

cd /d "%~dp0\.."

if not exist "android\key.properties" (
    echo [OGOHLANTIRISH] 'android\key.properties' fayli topilmadi!
    echo Ilova debug kaliti bilan yig'iladi yoki imzosiz qoladi.
    echo Google Play ga chiqarishdan oldin 'scripts\generate_keystore.bat' ni ishga tushiring.
    echo.
    set /p CONTINUE="Davom etishni xohlaysizmi? (h/y): "
    if /i not "%CONTINUE%"=="h" if /i not "%CONTINUE%"=="y" exit /b 0
)

echo [1/3] Loyiha tozalanmoqda (flutter clean)...
call flutter clean

echo.
echo [2/3] Paketlar yangilanmoqda (flutter pub get)...
call flutter pub get

echo.
echo [3/3] Release AppBundle (.aab) yig'ilmoqda...
call flutter build appbundle --release

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================================
    echo [MUVAFFAQIN!] Release AAB tayyor!
    echo Fayl joylashuvi:
    echo %CD%\build\app\outputs\bundle\release\app-release.aab
    echo ========================================================
    echo.
    explorer "%CD%\build\app\outputs\bundle\release"
) else (
    echo.
    echo [XATOLIK] AAB yig'ishda xatolik yuz berdi!
)

pause
