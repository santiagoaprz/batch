@echo off
title Reporte Completo del Sistema
color 0E
setlocal enabledelayedexpansion

:: ================================
:: Obtener fecha y hora para nombre del reporte
:: ================================
for /f "tokens=1-3 delims=/ " %%a in ("%date%") do (
    set "dia=%%a"
    set "mes=%%b"
    set "anio=%%c"
)
for /f "tokens=1-2 delims=:." %%a in ("%time%") do (
    set "hora=%%a"
    set "minuto=%%b"
)
if %hora% lss 10 set "hora=0%hora%"
if %minuto% lss 10 set "minuto=0%minuto%"

set "fecha=%anio%-%mes%-%dia%"
set "hora=%hora%-%minuto%"
set "report_file=reporte_%fecha%_%hora%.txt"

echo Generando reporte completo del sistema...
echo.

:: ================================
:: Crear archivo de reporte
:: ================================
echo === INFORMACION DEL SISTEMA === > "%report_file%"
systeminfo >> "%report_file%"
echo. >> "%report_file%"

echo === HARDWARE === >> "%report_file%"
wmic cpu get Name,NumberOfCores,MaxClockSpeed >> "%report_file%"
echo. >> "%report_file%"

wmic memorychip get Capacity,Manufacturer,Speed >> "%report_file%"
echo. >> "%report_file%"

:: ================================
:: INFORMACION DE DISCOS (Unificada)
:: ================================
echo === DISCOS DETALLADOS === >> "%report_file%"
echo Letra - Modelo/Marca - Tamaño Total - Espacio Libre >> "%report_file%"
echo ==================================================== >> "%report_file%"

setlocal enabledelayedexpansion
set "disk_index=0"

:: Recorremos unidades lógicas
for /f "skip=1 tokens=1" %%d in ('wmic logicaldisk where "drivetype=3" get deviceid') do (
    if not "%%d"=="" (
        set /a "disk_index+=1"
        set "unidad=%%d"

        :: Tamaño y espacio libre
        for /f "tokens=2 delims==" %%s in ('wmic logicaldisk where "deviceid='%%d'" get size /value') do set "tamano_total=%%s"
        for /f "tokens=2 delims==" %%f in ('wmic logicaldisk where "deviceid='%%d'" get freespace /value') do set "espacio_libre=%%f"

        :: Buscar modelo físico correspondiente
        set "modelo="
        set "counter=0"
        for /f "skip=1 tokens=1,*" %%m in ('wmic diskdrive get model') do (
            set /a "counter+=1"
            if !counter! equ !disk_index! set "modelo=%%m %%n"
        )

        :: Convertir tamaños a GB
        call :ConvertirGB "!tamano_total!" totalGB
        call :ConvertirGB "!espacio_libre!" libreGB

        :: Escribir en el reporte en una sola línea
        echo !unidad! - !modelo! - Total: !totalGB! GB - Libre: !libreGB! GB >> "%report_file%"
    )
)
endlocal

:: ================================
:: SOFTWARE INSTALADO
:: ================================
echo. >> "%report_file%"
echo === SOFTWARE INSTALADO === >> "%report_file%"
wmic product get Name,Version >> "%report_file%"

:: ================================
:: ESPACIO EN DISCO DETALLADO (extra)
:: ================================
echo. >> "%report_file%"
echo === ESPACIO EN DISCO DETALLADO === >> "%report_file%"
wmic logicaldisk get DeviceID, Size, FreeSpace, FileSystem, VolumeName >> "%report_file%"

echo.
echo Reporte completo generado: %report_file%
pause
exit /b 0

:: ================================
:: FUNCIONES
:: ================================
:ConvertirGB
setlocal EnableDelayedExpansion
set "bytes=%~1"
if "%bytes%"=="" (
    endlocal & set "%~2=0"
    goto :eof
)
set /a "gb=%bytes%/1073741824"
endlocal & set "%~2=%gb%"
goto :eof
