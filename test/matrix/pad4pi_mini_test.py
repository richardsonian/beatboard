#!/usr/bin/python3

from pad4pi import rpi_gpio
import time

num_rows = 2
num_cols = 2

KEYPAD = [[(r, c) for c in range(1, num_cols + 1)] for r in range(1, num_rows + 1)]

COL_PINS = [13, 6] # BCM numbering
ROW_PINS = [26, 19] # BCM numbering

factory = rpi_gpio.KeypadFactory()

keypad = factory.create_keypad(keypad=KEYPAD, row_pins=ROW_PINS, col_pins=COL_PINS)

def printKey(key):
    print(key)

# printKey will be called each time a keypad button is pressed
keypad.registerKeyPressHandler(printKey)

print("Press a key (type exit to stop)")

while True:
    code = input()
    if code == "exit":
        keypad.cleanup() # Cleanup GPIO
        break