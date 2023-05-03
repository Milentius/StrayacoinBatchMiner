#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check current directory for strayacoin-qt executable file
if [ ! -f "$DIR/strayacoin-qt" ]; then
  echo 'Please move this script to the folder with strayacoin-qt executable file'
  read -n1 -r -p 'Press any key to continue...'
  exit 1
fi

# Check if strayacoind is running
if ps ax | grep -v grep | grep "strayacoind" >/dev/null; then
  echo 'Strayacoind is already running. Continuing with mining.'
else
  echo 'Strayacoind is not running. Starting it now...'
  $DIR/strayacoind &
  echo 'Waiting 30 seconds for Strayacoind to start...'
  sleep 30
  if ps ax | grep -v grep | grep "strayacoind" >/dev/null; then
    echo 'Strayacoind started successfully!'
  else
    echo 'Failed to start Strayacoind. Exiting...'
    exit 1
  fi
fi

# Ask user how many cores to use for mining
read -rp 'Enter number of cores to use (default is 1): ' cores
cores=${cores:-1}
if [ "$cores" -eq 0 ]; then
  cores=1
fi

# Get the name of the terminal emulator
term_emulator=$TERM_PROGRAM
# Check which terminal emulator is being used and Start the miner in the relevent terminal emulator
if [[ "$term_emulator" == "gnome-terminal" ]]; then
  # If using gnome-terminal, open a new tab for each core
  for ((i = 1; i <= cores; i++)); do
    gnome-terminal --title="Strayacoin Miner $i" -- ./mine.sh
  done

elif [[ "$term_emulator" == "konsole" ]]; then
  # If using konsole, open a new tab for each core
  for ((i = 1; i <= cores; i++)); do
    konsole --new-tab --title="Strayacoin Miner $i" --execute "./mine.sh"
  done

elif [[ "$term_emulator" == "terminator" ]]; then
  # If using terminator, generate and execute a command string for the desired number of cores
  layout="splitv"
  command="\"./mine.sh\""
  for ((i = 2; i <= cores; i++)); do
      command+=",\"./mine.sh\""
      layout+=",$layout"
  done
  terminator --layout="$layout" -e "bash -c 'echo -e \"\\033]0;Strayacoin Miner\\007$command\"'"

elif [[ "$term_emulator" == "xterm" || "$term_emulator" == "xterm-256color" || "$term_emulator" == "rxvt-unicode" ]]; then
  # If using xterm, xterm-256color or rxvt-unicode, open a new window for each core
  for ((i = 1; i <= cores; i++)); do
    xterm -title "Strayacoin Miner $i" -e ./mine.sh &
  done

else
  # Handle other terminal emulators here
  echo "Unsupported terminal emulator: $term_emulator"
fi
