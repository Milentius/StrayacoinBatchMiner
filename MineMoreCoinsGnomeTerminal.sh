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

# Start the miner
for ((i = 1; i <= cores; i++)); do
  gnome-terminal --title="Strayacoin Miner $i" -- ./mine.sh
done
