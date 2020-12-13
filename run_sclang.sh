#!/bin/bash
# Run without arg for IDE mode, or pass file as argument (arg must be absolute path)
# Run "sudo pkill aplay before running this script"
FILE=$(readlink -f $1)
export QT_QPA_PLATFORM=offscreen
cd /home/pi/supercolliderStandaloneRPI1
echo "Executing sc3 script: ${FILE}"
./sclang -a -l ~/supercolliderStandaloneRPI1/sclang.yaml $FILE