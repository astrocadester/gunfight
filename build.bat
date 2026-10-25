@echo off
setlocal
cd /d "%~dp0"
if not exist "src\zout" mkdir "src\zout"
if not exist "roms\build" mkdir "roms\build"
if not exist docs mkdir docs
py -3 tools\recover_8080.py gunfight
if errorlevel 1 exit /b 1
py -3 tools\interpreter_lineage.py
if errorlevel 1 exit /b 1
py -3 tools\memory_map.py
if errorlevel 1 exit /b 1
tools\zmac.exe -c -o roms\build\gunfight.bin -x src\zout\gunfight.lst src\gunfight.asm
if errorlevel 1 exit /b 1
py -3 tools\verify_rom.py
if errorlevel 1 exit /b 1
