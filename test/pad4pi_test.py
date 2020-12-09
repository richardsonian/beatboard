#!/usr/bin/python3

from pad4pi import rpi_gpio
import time

KEYPAD = [
    [1, 2, 3, 4, 5],
    [6, 7, 8, 9, 10],
    [11, 12, 13, 14, 15]
]

ROW_PINS = [14, 15, 18] # BCM numbering
COL_PINS = [5, 6, 13, 19, 26] # BCM numbering

factory = rpi_gpio.KeypadFactory()

# Try factory.create_4_by_3_keypad
# and factory.create_4_by_4_keypad for reasonable defaults
keypad = factory.create_keypad(keypad=KEYPAD, row_pins=ROW_PINS, col_pins=COL_PINS)

def printKey(key):
    print(key)

# printKey will be called each time a keypad button is pressed
keypad.registerKeyPressHandler(printKey)

print("Press a key")
while True:
    time.sleep(0.2)