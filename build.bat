@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo Gun Fight original ROM reconstruction
echo Source: src\gunfight.asm
if not exist src\zout mkdir src\zout
if not exist roms\build mkdir roms\build
echo [1/3] Assemble original 4 KB Intel 8080 image
tools\zmac.exe -c -o roms\build\gunfight.bin -x src\zout\gunfight.lst src\gunfight.asm
if errorlevel 1 exit /b 1
echo [2/3] Split and verify four original ROM devices
powershell -NoProfile -Command "$ErrorActionPreference='Stop'; $raw=[IO.File]::ReadAllBytes('roms/build/gunfight.bin'); if($raw.Length -ne 4096){throw 'Incorrect ROM size'}; $names=@('7609h.bin','7609g.bin','7609f.bin','7609e.bin'); $hashes=@('99d01313e251818d336281700e206d9003c71dae','c177e3f72db9af17ab99b2481448ca26318184b9','215b068663e431582591001cbe028929fa96d49f','de3f2e6841122bbe6e2fda5b87d37842c072289a'); for($i=0;$i -lt 4;$i++){ $part=New-Object byte[] 1024; [Array]::Copy($raw,$i*1024,$part,0,1024); $file=Join-Path 'roms/build' $names[$i]; [IO.File]::WriteAllBytes($file,$part); $actual=(Get-FileHash -Algorithm SHA1 -LiteralPath $file).Hash.ToLowerInvariant(); Write-Host $actual $names[$i]; if($actual -ne $hashes[$i]){throw ('ROM mismatch '+$names[$i])} }"
if errorlevel 1 exit /b 1
echo PASS: Four original ROM devices match
echo [3/3] Package MAME ROM set
powershell -NoProfile -Command "$ErrorActionPreference='Stop'; $zip='roms/build/gunfight.zip'; if(Test-Path $zip){Remove-Item $zip}; Compress-Archive -Path 'roms/build/7609h.bin','roms/build/7609g.bin','roms/build/7609f.bin','roms/build/7609e.bin' -DestinationPath $zip"
if errorlevel 1 exit /b 1
echo PASS: roms\build\gunfight.zip
exit /b 0
