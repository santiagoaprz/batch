@echo off
title Mantenimiento Windows Multi-Disco - Express/Completo con Log y Resumen
color 0A
setlocal enabledelayedexpansion

:: =============================================
:: Crear carpeta de logs si no existe
:: =============================================
if not exist "%~dp0Logs" mkdir "%~dp0Logs"

:: Obtener fecha y hora para nombre de archivo
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set FechaLog=%%c-%%b-%%a
for /f "tokens=1-2 delims=:." %%a in ("%time%") do set HoraLog=%%a-%%b
set LOGFILE=%~dp0Logs\Mantenimiento_%FechaLog%_%HoraLog%.txt

:: Variable para resumen
set RESUMEN=

echo ===============================================>>"%LOGFILE%"
echo Mantenimiento iniciado el %date% a las %time%>>"%LOGFILE%"
echo ===============================================>>"%LOGFILE%"

:MENU
cls
echo ============================================
echo       SCRIPT DE MANTENIMIENTO WINDOWS
echo ============================================
echo.
echo  [1] Mantenimiento Express (SIN admin)
echo  [2] Mantenimiento Completo (CON admin)
echo  [3] Salir
echo.
set /p op="Seleccione una opcion: "

if "%op%"=="1" goto EXPRESS
if "%op%"=="2" goto ADMIN
if "%op%"=="3" exit
goto MENU

:: =============================================
:: OPCION 1: EXPRESS (SIN ADMIN)
:: =============================================
:EXPRESS
cls
echo ================================
echo   LIMPIEZA EXPRESS EN PROCESO...
echo ================================
echo [EXPRESS] Limpieza iniciada a las %time%>>"%LOGFILE%"
timeout /t 1 >nul

:: Limpiar TEMP del usuario
echo - Limpiando %TEMP% ...
echo [EXPRESS] Limpiando TEMP: %TEMP%>>"%LOGFILE%"
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%i in ("%TEMP%\*") do rd /s /q "%%i" >nul 2>&1
set RESUMEN=!RESUMEN!TEMP usuario actual limpiado^| 

:: Limpiar cache de navegadores para el usuario actual
for %%B in (Edge Chrome Brave Opera) do (
    if "%%B"=="Edge" rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" 2>nul
    if "%%B"=="Chrome" rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2>nul
    if "%%B"=="Brave" rd /s /q "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Cache" 2>nul
    if "%%B"=="Opera" rd /s /q "%APPDATA%\Opera Software\Opera Stable\Cache" 2>nul
    echo [EXPRESS] Limpiando cache %%B >>"%LOGFILE%"
    set RESUMEN=!RESUMEN!Cache %%B limpiada^| 
)

echo.
echo [✓] Limpieza EXPRESS completada.
echo [EXPRESS] Limpieza EXPRESS completada a las %time%>>"%LOGFILE%"
echo.
echo ============================
echo Resumen de limpieza EXPRESS:
echo ============================
echo !RESUMEN!
pause
goto MENU

:: =============================================
:: OPCION 2: ADMIN (COMPLETO)
:: =============================================
:ADMIN
:: Verificar si ya tiene admin
net session >nul 2>&1
if %errorlevel%==0 (
    goto COMPLETO
) else (
    echo.
    echo [!] Se requieren permisos de ADMINISTRADOR para esta opcion.
    echo [!] Presione "SI" en el cuadro de dialogo de UAC.
    timeout /t 2 >nul
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:COMPLETO
cls
echo ================================
echo   LIMPIEZA COMPLETA MULTI-DISCO
echo ================================
echo [COMPLETO] Limpieza completa iniciada a las %time%>>"%LOGFILE%"
timeout /t 1 >nul

set RESUMEN=

:: =================================================
:: Detectar todos los discos locales internos (tipo 3)
:: =================================================
for /f "skip=1 tokens=1,2" %%D in ('wmic logicaldisk where "drivetype=3" get deviceid^, volumename') do (
    set "drive=%%D"
    if defined drive (
        echo -------------------------------------------------
        echo Procesando disco !drive!...
        echo [COMPLETO] Procesando disco !drive!>>"%LOGFILE%"

        :: Detectar tipo de disco (SSD/HDD)
        set "media=Unknown"
        for /f "skip=1 tokens=2" %%M in ('wmic diskdrive get MediaType') do set "media=%%M"
        echo [COMPLETO] Tipo de disco !media!>>"%LOGFILE%"
        set RESUMEN=!RESUMEN!Disco !drive!: !media!^

        :: Limpiar TEMP
        if exist "!drive!\Temp" (
            del /f /s /q "!drive!\Temp\*" >nul 2>&1
            for /d %%i in ("!drive!\Temp\*") do rd /s /q "%%i" >nul 2>&1
            echo [COMPLETO] TEMP limpiado en !drive!>>"%LOGFILE%"
            set RESUMEN=!RESUMEN! | TEMP limpiado
        )

        :: Limpiar Recycle Bin
        if exist "!drive!\$Recycle.Bin" (
            rd /s /q "!drive!\$Recycle.Bin" >nul 2>&1
            echo [COMPLETO] Papelera limpiada en !drive!>>"%LOGFILE%"
            set RESUMEN=!RESUMEN! | Papelera limpiada
        )

        :: Limpiar Windows.old
        if exist "!drive!\Windows.old" (
            rd /s /q "!drive!\Windows.old" >nul 2>&1
            echo [COMPLETO] Windows.old eliminado en !drive!>>"%LOGFILE%"
            set RESUMEN=!RESUMEN! | Windows.old eliminado
        )

        :: Desfragmentar solo HDD
        echo !media! | find /i "Solid State" >nul
        if %errorlevel%==1 (
            defrag !drive! /O
            echo [COMPLETO] Desfragmentacion realizada en !drive!>>"%LOGFILE%"
            set RESUMEN=!RESUMEN! | Desfragmentacion realizada
        ) else (
            echo [COMPLETO] Disco SSD, desfragmentacion omitida>>"%LOGFILE%"
            set RESUMEN=!RESUMEN! | SSD, sin desfragmentar
        )
        set RESUMEN=!RESUMEN!^|
    )
)

:: =================================================
:: Limpieza de navegadores en todos los usuarios
:: =================================================
for /d %%U in ("%systemdrive%\Users\*") do (
    rd /s /q "%%U\AppData\Local\Microsoft\Edge\User Data\Default\Cache" 2>nul
    rd /s /q "%%U\AppData\Local\Google\Chrome\User Data\Default\Cache" 2>nul
    rd /s /q "%%U\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Cache" 2>nul
    rd /s /q "%%U\AppData\Roaming\Opera Software\Opera Stable\Cache" 2>nul
)
set RESUMEN=!RESUMEN!Cache navegadores limpiada^

:: =================================================
:: Reparaciones de sistema
:: =================================================
DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow
set RESUMEN=!RESUMEN! | Sistema reparado^

:: Limpieza de logs y cache adicional
del /f /s /q "%windir%\Logs\*" >nul 2>&1
del /f /s /q "%windir%\SoftwareDistribution\Download\*" >nul 2>&1
set RESUMEN=!RESUMEN! | Logs y cache adicional limpiados^

echo.
echo ============================
echo Resumen de limpieza COMPLETA:
echo ============================
echo !RESUMEN!
echo.
echo [COMPLETO] Limpieza completa finalizada a las %time%>>"%LOGFILE%"
echo ===============================================>>"%LOGFILE%"
pause
goto MENU

