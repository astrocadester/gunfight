@echo off
setlocal
cd /d "%~dp0"
rem Gun Fight original Intel 8080 ROM build - zmac v1.3; no Python.
if defined ZMAC (
    set "ZMAC_BIN=%ZMAC%"
) else if exist "tools\zmac.exe" (
    set "ZMAC_BIN=tools\zmac.exe"
) else (
    set "ZMAC_BIN=zmac"
)
where "%ZMAC_BIN%" >nul 2>&1
if errorlevel 1 if not exist "%ZMAC_BIN%" (
    echo ERROR: zmac v1.3 not found. Set ZMAC or use tools\zmac.exe.
    exit /b 1
)
if not exist "src\gunfight.asm" (
    echo ERROR: Missing src\gunfight.asm
    exit /b 1
)
if not exist "roms\original\gunfight.zip" (
    echo ERROR: Missing reference roms\original\gunfight.zip
    exit /b 1
)
echo Gun Fight original ROM build
echo [1/4] Prepare output
if not exist "build" mkdir "build"
if not exist "roms" mkdir "roms"
del /q "build\gunfight.bin" "build\gunfight.lst" "roms\gunfight.zip" >nul 2>&1
for %%F in (7609h.bin 7609g.bin 7609f.bin 7609e.bin) do if exist "build\%%F" del /q "build\%%F"
echo [2/4] Assemble native Intel 8080 source (zmac v1.3)
"%ZMAC_BIN%" -c -o "build\gunfight.bin" -x "build\gunfight.lst" "src\gunfight.asm"
if errorlevel 1 (echo ERROR: Assembly failed.& exit /b 1)
if not exist "build\gunfight.bin" (echo ERROR: Binary image missing.& exit /b 1)
echo [3/4] Split and verify four 1 KB ROMs
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference='Stop';" ^
    "$bytes=[IO.File]::ReadAllBytes('build\gunfight.bin');" ^
    "if($bytes.Length -ne 4096){throw 'Binary image must contain exactly 4096 bytes'};" ^
    "$names=@('7609h.bin','7609g.bin','7609f.bin','7609e.bin');" ^
    "$sha=@('99d01313e251818d336281700e206d9003c71dae','c177e3f72db9af17ab99b2481448ca26318184b9','215b068663e431582591001cbe028929fa96d49f','de3f2e6841122bbe6e2fda5b87d37842c072289a');" ^
    "for($i=0;$i -lt 4;$i++){ $part=[byte[]]::new(1024);[Array]::Copy($bytes,$i*1024,$part,0,1024);$file=Join-Path 'build' $names[$i];[IO.File]::WriteAllBytes($file,$part);$actual=(Get-FileHash $file -Algorithm SHA1).Hash.ToLowerInvariant();if($actual -ne $sha[$i]){throw ($names[$i]+' SHA1 mismatch: '+$actual)};Write-Host ($names[$i]+' OK '+$actual) }"
if errorlevel 1 (echo ERROR: ROM splitting or verification failed.& exit /b 1)
echo [4/4] Package roms\gunfight.zip
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference='Stop';" ^
    "Compress-Archive -LiteralPath @('build\7609h.bin','build\7609g.bin','build\7609f.bin','build\7609e.bin') -DestinationPath 'roms\gunfight.zip' -Force"
if errorlevel 1 (echo ERROR: ROM packaging failed.& exit /b 1)
if not exist "roms\gunfight.zip" (echo ERROR: ROM ZIP missing.& exit /b 1)
echo Build complete: roms\gunfight.zip
exit /b 0
