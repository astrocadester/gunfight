@echo off
setlocal
cd /d "%~dp0"
if not exist "src\gunfight.asm" (
  echo RE incomplete: src\gunfight.asm has not yet been recovered from the original ROM. 1>&2
  exit /b 2
)
if not exist build mkdir build
tools\zmac.exe -o "build\gunfight.bin" "src\gunfight.asm"
if errorlevel 1 exit /b 1
echo Assembled build\gunfight.bin; chip-by-chip ROM identity is not yet verified.
