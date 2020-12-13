#!/bin/bash
# Run without arg for IDE mode, or pass file as argument (arg must be absolute path)
FILE=$(readlink -f $1)
echo $FILE
pkill aplay
export QT_QPA_PLATFORM=offscreen
cd ~/supercolliderStandaloneRPI1
./sclang -a -l ~/supercolliderStandaloneRPI1/sclang.yaml $FILE