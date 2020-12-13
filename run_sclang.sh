#!/bin/bash
# Run without arg for IDE mode, or pass file as argument
pkill aplay
export QT_QPA_PLATFORM=offscreen
cd ~/supercolliderStandaloneRPI1
./sclang -a -l ~/supercolliderStandaloneRPI1/sclang.yaml $1