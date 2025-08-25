@echo off
title Informacion del Sistema - Windows 10/11
color 0A
echo ===============================================
echo    INFORMACION CRUCIAL DEL SISTEMA
echo ===============================================
echo.

echo Fecha y Hora: %date% %time%
echo.

echo === INFORMACION DEL SISTEMA OPERATIVO ===
systeminfo | findstr /C:"Nombre del sistema operativo" /C:"Version del sistema operativo" /C:"Fabricante del sistema operativo" /C:"Idioma" /C:"Tipo del sistema"
echo.

echo === INFORMACION DEL PROCESADOR ===
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed
echo.

echo === MEMORIA RAM ===
wmic memorychip get Capacity, Speed, Manufacturer, PartNumber
wmic ComputerSystem get TotalPhysicalMemory
echo.

echo === DISCOS DUROS ===
wmic diskdrive get Model, Size, InterfaceType
echo Particiones:
wmic partition get BlockSize, StartingOffset, Name
echo.

echo === TARJETA DE RED ===
wmic nic get Name, ProductName, MACAddress, Speed
echo.

echo === TARJETA DE VIDEO ===
wmic path win32_VideoController get Name, AdapterRAM, DriverVersion
echo.

echo === INFORMACION DE LA BIOS ===
wmic bios get Name, Version, SerialNumber
echo.

echo === ESPACIO EN DISCO ===
wmic logicaldisk get DeviceID, Size, FreeSpace
echo.

echo === PROCESOS EN EJECUCION ===
tasklist | more
echo.

echo === SERVICIOS INSTALADOS ===
sc query | find "SERVICE_NAME"
echo.

echo === PROGRAMAS INSTALADOS ===
wmic product get Name, Version
echo.

echo Informacion guardada en info_sistema.txt
systeminfo > info_sistema.txt
wmic product get Name, Version >> info_sistema.txt
wmic diskdrive get Model, Size >> info_sistema.txt

pause