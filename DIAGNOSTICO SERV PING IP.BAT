@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: Verificar si se ejecuta como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ADVERTENCIA] Este script requiere permisos de administrador
    echo Ejecute como administrador para mejores resultados
    echo.
    timeout /t 3 /nobreak >nul
)

echo ===============================================
echo    VERIFICACION DE SERVIDORES - ALCALDIA TLALPAN
echo ===============================================
echo Fecha: %date% %time%
echo.

:: Lista de direcciones IP a verificar
set ip_list=10.16.1.3 10.16.8.16 10.16.1.7 10.16.0.5 10.16.0.127 10.16.0.7 172.16.1.1 172.16.1.2 10.16.8.249 10.16.8.2 10.16.8.5 10.16.8.40 10.16.8.4 10.16.8.10 10.16.8.7 10.16.8.20 10.16.8.25 10.16.8.9 10.16.8.61 10.16.8.6 10.16.8.11 10.16.8.254 10.16.1.8 189.202.180.34 189.202.180.40

echo.
echo ============ VERIFICACION POR PING ============
echo.

set /a total_ips=0
set /a online_ips=0
set /a offline_ips=0

for %%i in (%ip_list%) do (
    set /a total_ips+=1
    echo Probando: %%i
    ping -n 2 %%i > nul
    if !errorlevel! equ 0 (
        echo [OK]      %%i - Servidor en linea
        set /a online_ips+=1
    ) else (
        echo [FALLA]  %%i - Servidor fuera de linea
        set /a offline_ips+=1
    )
    echo.
)

echo ============ ESTADISTICAS PING ============
echo Total de servidores: !total_ips!
echo En linea: !online_ips!
echo Fuera de linea: !offline_ips!
echo.

echo ============ VERIFICACION DE URLs ============
echo.
echo [NOTA] La verificacion de URLs requiere PowerShell
echo        Se esta verificando solo disponibilidad por ping
echo.

set /a total_urls=0
set /a online_urls=0
set /a offline_urls=0

:: Extraer dominios de URLs para verificar por ping
for %%u in (
10.16.1.7
sips.tlalpan.gob.mx
189.202.180.40
10.16.1.3
tlalpan.cdmx.gob.mx
correo2.cdmx.gob.mx
) do (
    set /a total_urls+=1
    echo Probando: %%u
    ping -n 2 %%u > nul
    if !errorlevel! equ 0 (
        echo [OK]      %%u - Disponible por ping
        set /a online_urls+=1
    ) else (
        echo [FALLA]  %%u - No disponible por ping
        set /a offline_urls+=1
    )
    echo.
)

echo ============ ESTADISTICAS URLs ============
echo Total de URLs: !total_urls!
echo Disponibles: !online_urls!
echo No disponibles: !offline_urls!
echo.

echo ============ RESUMEN GENERAL ============
echo Fecha de verificacion: %date% %time%
echo Total de servidores verificados: !total_ips!
echo Servidores en linea: !online_ips!
echo Servidores fuera de linea: !offline_ips!
echo.
echo URLs verificadas por ping: !total_urls!
echo URLs disponibles: !online_urls!
echo URLs no disponibles: !offline_urls!
echo.

:: Generar archivo de reporte
set fecha=%date:~-4,4%%date:~-10,2%%date:~-7,2%
set hora=%time:~0,2%%time:~3,2%
set report_file=reporte_servidores_%fecha%_%hora%.txt

echo Generando reporte: !report_file!

(
echo ===============================================
echo    REPORTE DE VERIFICACION - ALCALDIA TLALPAN
echo ===============================================
echo Fecha: %date% %time%
echo.
echo SERVIDORES VERIFICADOS:
for %%i in (%ip_list%) do (
    ping -n 2 %%i > nul
    if !errorlevel! equ 0 (
        echo OK - %%i
    ) else (
        echo FALLA - %%i
    )
)
echo.
echo URLs VERIFICADAS POR PING:
for %%u in (10.16.1.7 sips.tlalpan.gob.mx 189.202.180.40 10.16.1.3 tlalpan.cdmx.gob.mx correo2.cdmx.gob.mx) do (
    ping -n 2 %%u > nul
    if !errorlevel! equ 0 (
        echo OK - %%u
    ) else (
        echo FALLA - %%u
    )
)
) > "!report_file!"

echo.
echo Reporte guardado en: !report_file!
echo Verificacion completada.

:: Pausa final para evitar que la ventana se cierre
echo.
echo Presione cualquier tecla para cerrar esta ventana...
pause >nul