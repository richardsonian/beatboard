#!/bin/bash
# Run without arg for IDE mode, or pass file as argument (arg must be absolute path)
FILE=$(readlink -f $1)
pkill aplay
export QT_QPA_PLATFORM=offscreen
cd ~/supercolliderStandaloneRPI1
echo "Executing sc3 script: ${FILE}"
./sclang -a -l ~/supercolliderStandaloneRPI1/sclang.yaml $FILE