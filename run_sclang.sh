#!/bin/bash
# Run without arg for IDE mode, or pass file as argument (arg must be absolute path)
if [ "$EUID" -ne 0 ]
  then echo "Script must be run as root."
  exit
fi

FILE=$(readlink -f $1)
pkill aplay
export QT_QPA_PLATFORM=offscreen
cd /home/pi/supercolliderStandaloneRPI1
echo "Executing sc3 script: ${FILE}"
./sclang -a -l ~/supercolliderStandaloneRPI1/sclang.yaml $FILE