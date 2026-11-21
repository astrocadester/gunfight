@echo off
setlocal
cd /d "%~dp0"
rem Gun Fight original Intel 8080 ROM build; project zmac v1.3, no Python.
if defined ZMAC (
    set "ZMAC_BIN=%ZMAC%"
) else (
    set "ZMAC_BIN=tools\zmac.exe"
)
if not exist "%ZMAC_BIN%" (
    where "%ZMAC_BIN%" >nul 2>&1
    if errorlevel 1 (echo ERROR: Missing zmac v1.3 assembler.& exit /b 1)
)
if not exist "src\gunfight.asm" (echo ERROR: Missing RE source src\gunfight.asm& exit /b 1)
if not exist "roms\original\gunfight.zip" (echo ERROR: Missing original ROM archive.& exit /b 1)
if not exist build mkdir build
del /q "build\gunfight.bin" "build\gunfight.lst" "roms\gunfight.zip" >nul 2>&1
echo [1/3] Assemble Gun Fight
"%ZMAC_BIN%" -c -o "build\gunfight.bin" -x "build\gunfight.lst" "src\gunfight.asm"
if errorlevel 1 (echo ERROR: Assembly failed.& exit /b 1)
if not exist "build\gunfight.bin" (echo ERROR: Missing ROM output.& exit /b 1)
echo [2/3] Split and SHA-1 verify four 1 KB devices
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop';" ^
 "$b=[IO.File]::ReadAllBytes('build\gunfight.bin');if($b.Length -ne 4096){throw 'Expected 4096 bytes'};" ^
 "$n=@('7609h.bin','7609g.bin','7609f.bin','7609e.bin');" ^
 "$s=@('99d01313e251818d336281700e206d9003c71dae','c177e3f72db9af17ab99b2481448ca26318184b9','215b068663e431582591001cbe028929fa96d49f','de3f2e6841122bbe6e2fda5b87d37842c072289a');" ^
 "for($i=0;$i -lt 4;$i++){ $part=[byte[]]::new(1024);[Array]::Copy($b,$i*1024,$part,0,1024);$path=Join-Path build $n[$i];[IO.File]::WriteAllBytes($path,$part);$h=(Get-FileHash $path -Algorithm SHA1).Hash.ToLowerInvariant();if($h -ne $s[$i]){throw ($n[$i]+' SHA1 mismatch '+$h)};Write-Host ('PASS '+$n[$i]) }"
if errorlevel 1 (echo ERROR: ROM verification failed.& exit /b 1)
echo [3/3] Package roms\gunfight.zip
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop';Compress-Archive -LiteralPath @('build\7609h.bin','build\7609g.bin','build\7609f.bin','build\7609e.bin') -DestinationPath 'roms\gunfight.zip' -Force"
if errorlevel 1 (echo ERROR: ROM packaging failed.& exit /b 1)
echo PASS: roms\gunfight.zip
exit /b 0
