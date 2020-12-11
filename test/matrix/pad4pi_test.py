#!/usr/bin/python3

from pad4pi import rpi_gpio
import time

num_rows = 3
num_cols = 7

KEYPAD = [[(r, c) for c in range(0, num_cols)] for r in range(0, num_rows)]

ROW_PINS = [23, 24, 25] # BCM numbering
COL_PINS = [4, 17, 27, 22, 5, 6, 13] # BCM numbering

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
    time.sleep(0.2)