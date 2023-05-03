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
    start "Strayacoin Miner %%i" cmd /k Call mine.bat
)
exit
