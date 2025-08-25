@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: -------------------------------
:: Archivo de reporte con fecha/hora
:: -------------------------------
set fecha=%date:~-4%-%date:~3,2%-%date:~0,2%
set hora=%time:~0,2%-%time:~3,2%-%time:~6,2%
set report_file=Reporte_Completo_%fecha%_%hora%.txt

:: -------------------------------
:: Listas de IPs y URLs
:: -------------------------------
set ip_list=10.16.1.3 10.16.8.16 10.16.1.7 10.16.0.5 10.16.0.127 10.16.0.7 172.16.1.1 172.16.1.2 10.16.8.249 10.16.8.2 10.16.8.5 10.16.8.40 10.16.8.4 10.16.8.10 10.16.8.7 10.16.8.20 10.16.8.25 10.16.8.9 10.16.8.61 10.16.8.6 10.16.8.11 10.16.8.254 10.16.1.8 189.202.180.34 189.202.180.40
set web_hosts=sips.tlalpan.gob.mx tlalpan.cdmx.gob.mx correo2.cdmx.gob.mx
set critical_services=10.16.8.16 10.16.8.4 10.16.8.2 10.16.1.3 8.8.8.8

:: -------------------------------
:: Inicializar contadores y fallos
:: -------------------------------
set /a total_ips=0, online_ips=0, offline_ips=0
set /a total_web=0, online_web=0, offline_web=0
set /a total_services=0, online_services=0, offline_services=0
set fallos_servidores=
set fallos_web=
set fallos_servicios=

:: -------------------------------
:: Encabezado del reporte
:: -------------------------------
(
echo ===============================================
echo        REPORTE COMPLETO - ALCALDIA TLALPAN
echo ===============================================
echo Fecha: %date%   Hora: %time%
echo.
) > "%report_file%"

:: -------------------------------
:: VERIFICACION DE SERVIDORES
:: -------------------------------
echo ================= SERVIDORES =================
for %%i in (%ip_list%) do (
    set /a total_ips+=1
    ping -n 2 -w 1000 %%i >nul
    if !errorlevel! equ 0 (
        echo [OK]      %%i
        echo [OK] %%i >> "%report_file%"
        set /a online_ips+=1
    ) else (
        echo [FALLA]  %%i
        echo [FALLA] %%i >> "%report_file%"
        set /a offline_ips+=1
        set fallos_servidores=!fallos_servidores! %%i
    )
)
echo. >> "%report_file%"

:: -------------------------------
:: VERIFICACION DE SITIOS WEB
:: -------------------------------
echo ================= SITIOS WEB =================
for %%h in (%web_hosts%) do (
    set /a total_web+=1
    curl -Is --max-time 5 https://%%h >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK]      %%h
        echo [OK] %%h >> "%report_file%"
        set /a online_web+=1
    ) else (
        echo [FALLA]  %%h
        echo [FALLA] %%h >> "%report_file%"
        set /a offline_web+=1
        set fallos_web=!fallos_web! %%h
    )
)
echo. >> "%report_file%"

:: -------------------------------
:: VERIFICACION DE SERVICIOS CRITICOS
:: -------------------------------
echo ============= SERVICIOS CRITICOS =============
for %%s in (%critical_services%) do (
    set /a total_services+=1
    ping -n 2 -w 1000 %%s >nul
    if !errorlevel! equ 0 (
        echo [OK]      %%s
        echo [OK] %%s >> "%report_file%"
        set /a online_services+=1
    ) else (
        echo [FALLA]  %%s
        echo [FALLA] %%s >> "%report_file%"
        set /a offline_services+=1
        set fallos_servicios=!fallos_servicios! %%s
    )
)
echo. >> "%report_file%"

:: -------------------------------
:: RESUMEN FINAL
:: -------------------------------
(
echo ================= RESUMEN FINAL =================
echo SERVIDORES: !online_ips!/!total_ips! operativos
if not "!fallos_servidores!"=="" echo SERVIDORES CON FALLA: !fallos_servidores!
echo.
echo SITIOS WEB: !online_web!/!total_web! accesibles
if not "!fallos_web!"=="" echo SITIOS WEB CON FALLA: !fallos_web!
echo.
echo SERVICIOS CRITICOS: !online_services!/!total_services! activos
if not "!fallos_servicios!"=="" echo SERVICIOS CRITICOS CON FALLA: !fallos_servicios!
echo ==================================================
echo Fecha de finalizacion: %date% %time%
) >> "%report_file%"

echo.
echo ===============================================
echo REPORTE COMPLETO GENERADO: %report_file%
echo ===============================================
pause >nul
