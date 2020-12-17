#!/bin/bash

# SuperCollider Startup Script
# Run without arg for IDE mode, or pass file as argument (arg may be relative path)
# Run "sudo pkill aplay" before running this script

# CONFIG:
# The directory containing sclang
SC3_PATH="/home/pi/supercolliderStandaloneRPI1"
# Path to config file sclang.yaml
SC3_CONFIG_PATH="~/supercolliderStandaloneRPI1/sclang.yaml"
# Port for sclang to start on
PORT=57120

# SCRIPT
CODE_PATH=$(readlink -f $1)
export QT_QPA_PLATFORM=offscreen
cd $SC3_PATH
echo "Executing SC3 script: ${CODE_PATH}"
./sclang -u $PORT -a -l $SC3_CONFIG_PATH $CODE_PATH
