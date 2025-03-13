@echo off
mode con: cols=130 lines=30
setlocal enabledelayedexpansion

:: Session Statistics
set /a transaction_count=0
set "total_earned=0.00000000"
set "reward_per_payout=1.56250000"

:: Payout Tracking (for last 4 hours)
set /a payouts_hour1=0
set /a payouts_hour2=0
set /a payouts_hour3=0
set /a payouts_hour4=0
set "last_payout_time="

echo Starting Strayacoin mining script...

for /l %%x in (1, 1, 999) do (
   :: Corrected timestamp update
   for /f "tokens=1-2 delims= " %%t in ('echo %TIME%') do set "timestamp=%DATE% %%t"

   :: Print mining start without a new line
   <nul set /p="[!timestamp!] - Block %%x "

   :: Mine Block
   set "result="
   for /f "delims=" %%r in ('strayacoin-cli.exe generate 1') do (
      if not "%%r"=="[" if not "%%r"=="]" set result=%%r
   )

   :: Check if a transaction was found
   if not "!result!"=="" (
      set /a transaction_count+=1

      :: Fix decimal addition
      for /f "tokens=1-2 delims=." %%a in ("!total_earned!") do (
         set /a whole_part=%%a
         set "decimal_part=%%b"
      )

      if not defined decimal_part set "decimal_part=00000000"

      set /a "whole_part+=1"
      set /a "decimal_part+=56250000"

      if !decimal_part! GEQ 100000000 (
         set /a "whole_part+=1"
         set /a "decimal_part-=100000000"
      )

      set "total_earned=!whole_part!.!decimal_part!"

      set "result_text=Tx Found"

      :: Convert current time to total seconds
      for /f "tokens=1-4 delims=:.," %%a in ("%TIME%") do (
         set /a "current_time=(((%%a*60)+%%b)*60+%%c)"
      )

      :: Shift hourly payout counts (rolling 4-hour window)
      set /a payouts_hour4=payouts_hour3
      set /a payouts_hour3=payouts_hour2
      set /a payouts_hour2=payouts_hour1
      set /a payouts_hour1=1

      set "last_payout_time=!current_time!"
   ) else (
      set "result_text=No Tx"
   )

   :: Calculate Approximate Earnings Per Hour
   set /a total_payouts=!payouts_hour1!+!payouts_hour2!+!payouts_hour3!+!payouts_hour4!
   set /a estimated_hourly_income=!total_payouts! * 156250000
   set "estimated_hourly=0.00000000"

   :: Convert earnings to floating-point format
   for /f "tokens=1-2 delims=." %%a in ("!estimated_hourly_income!") do (
      set /a whole_earn=%%a
      set "decimal_earn=%%b"
   )

   if not defined decimal_earn set "decimal_earn=00000000"

   set "estimated_hourly=!whole_earn!.!decimal_earn!"

   :: Display Compact One-Line Output
   echo | set /p="| Result: !result_text! | Tx/Hr: !total_payouts! | Earned: !total_earned! coins | Est/Hr: !estimated_hourly! coins"
   echo.
)
