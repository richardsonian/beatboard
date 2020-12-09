#!/usr/bin/python3

import time
import digitalio
import board
import adafruit_matrixkeypad
    
rows = [digitalio.DigitalInOut(x) for x in (board.D26, board.D20, board.D21)]
cols = [digitalio.DigitalInOut(x) for x in (board.D5, board.D6, board.D13, board.D19, board.D26)]
    
# 3x4 matrix keypad on Raspberry Pi -
# rows and columns are mixed up for https://www.adafruit.com/product/3845
# cols = [digitalio.DigitalInOut(x) for x in (board.D13, board.D5, board.D26)]
# rows = [digitalio.DigitalInOut(x) for x in (board.D6, board.D21, board.D20, board.D19)]
    
keys = (("V/I", "V/ii", "V/iii", "V/IV", "V/V"), ("IM7", "iihdim7", "iii7", "IV7", "V7"), ("I", "ii", "iii", "IV", "V"))
    
keypad = adafruit_matrixkeypad.Matrix_Keypad(rows, cols, keys)
    
while True:
    keys = keypad.pressed_keys
    if keys:
        print("Pressed: ", keys)
    time.sleep(0.1)
