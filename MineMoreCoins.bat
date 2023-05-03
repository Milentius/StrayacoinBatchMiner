@echo off
cd /d "%~dp0"

:: Check current directory for strayacoin-qt.exe file
if not exist "%~dp0strayacoin-qt.exe" (
    echo "%~dp0"
    echo Please move this script to the folder with strayacoin-qt.exe
    pause
    exit
)

:start
:: Check if strayacoin-qt.exe is running
tasklist /FI "IMAGENAME eq strayacoin-qt.exe" | find /i "strayacoin-qt.exe" && goto :continue || goto :open_wallet

:open_wallet
:: Open strayacoin-qt.exe
start "" "%~dp0strayacoin-qt.exe" -rpcthreads=32 -printtoconsole -debug=rpc
echo Waiting for the wallet to open, if it opens before the time counts down press a key to move on
timeout 30

:continue
:: Ask user how many cores to use for mining
set /p cores=Enter number of cores to use (default is 1): 
if not defined cores set "cores=1"
if %cores%==0 set "cores=1"

:: Start mine.bat for each core selected
for /L %%i in (1,1,%cores%) do (
    start "" cmd /k Call mine.bat
)

:: Continuously show CPU temperature using WMIC every 60 seconds until the user exits the script or the temperature exceeds 85 degrees
:show_temp
wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature > nul
set /a temp=(%ERRORLEVEL% - 2732) / 10

if %errorlevel% equ 0 (
    echo CPU temperature: %temp%°C
) else (
    echo Unable to check CPU temperature using WMIC command.
    echo Please install Core Temp or Open Hardware Monitor to monitor your CPU temperature and press any key to continue...
    pause > nul
    exit
)

if %temp% gtr 85 (
    echo WARNING: The CPU temperature has exceeded 85°C. It is recommended to stop mining and check your cooling system.
)

timeout 60 > nul
goto :show_temp
