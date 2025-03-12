@echo off
setlocal enabledelayedexpansion

:: Session Statistics
set /a transaction_count=0
set "total_earned=0.00000000"
set "reward_per_payout=1.56250000"

:: Hash Rate Tracking (up to 4 timestamps)
set "time1="
set "time2="
set "time3="
set "time4="

echo Starting Strayacoin mining script...

for /l %%x in (1, 1, 999) do (
   set "start_time=%TIME%"
   set "timestamp=%DATE% %TIME:~0,8%"

   :: Print mining start without a new line
   <nul set /p="[!timestamp!] - Block %%x "

   :: Mine Block
   set "result="
   for /f "delims=" %%r in ('strayacoin-cli.exe generate 1') do (
      if not "%%r"=="[" if not "%%r"=="]" set result=%%r
   )

   set "end_time=%TIME%"

   :: Check if a transaction was found
   if not "!result!"=="" (
      set /a transaction_count+=1

      :: Fix decimal addition by using a floating-point trick
      for /f "tokens=1-2 delims=." %%a in ("!total_earned!") do (
         set /a whole_part=%%a
         set "decimal_part=%%b"
      )

      if not defined decimal_part set "decimal_part=00000000"

      set /a whole_reward=1
      set "decimal_reward=56250000"

      set /a "whole_part+=whole_reward"
      set /a "decimal_part+=decimal_reward"

      if !decimal_part! GEQ 100000000 (
         set /a "whole_part+=1"
         set /a "decimal_part-=100000000"
      )

      set "total_earned=!whole_part!.!decimal_part!"

      set "result_text=Transaction Found"
   ) else (
      set "result_text=Nothing"
   )

   :: Convert start time to total seconds
   for /f "tokens=1-4 delims=:.," %%a in ("%start_time%") do (
      set /a "current_time=(((%%a*60)+%%b)*60+%%c)"
   )

   :: Shift time variables (keep last 4 times)
   set "time4=!time3!"
   set "time3=!time2!"
   set "time2=!time1!"
   set "time1=!current_time!"

   :: Calculate Hash Rate (only if at least 2 timestamps exist)
   set /a "average_seconds=0"
   if defined time2 set /a "diff1=time2-time1"
   if defined time3 set /a "diff2=time3-time2"
   if defined time4 set /a "diff3=time4-time3"

   set /a count=0
   set /a sum=0
   if defined diff1 if !diff1! GTR 0 set /a sum+=diff1, count+=1
   if defined diff2 if !diff2! GTR 0 set /a sum+=diff2, count+=1
   if defined diff3 if !diff3! GTR 0 set /a sum+=diff3, count+=1
   if !count! GTR 0 set /a "average_seconds=sum / count"

   set /a "hash_rate=0"
   if !average_seconds! GTR 0 set /a "hash_rate=3600 / average_seconds"

   :: Display Compact One-Line Output
   echo | set /p="| Result: !result_text! | Hashrate: !hash_rate! blocks/hr | Tx: !transaction_count! | Earned: !total_earned! coins"
   echo.
)
