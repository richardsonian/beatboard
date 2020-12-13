#!/usr/bin/python3

# Hardware
import busio
import digitalio
import board
from pad4pi import rpi_gpio
import RPi.GPIO as GPIO
# Software
import json
# Local
from analog_inputs import AnalogReader, Joystick
from screens import Menu

# ~~~~~ Initialize Menu ~~~~~~ #
menu = Menu()

# ~~~~~ Initialize Joystick ~~~~~~ #
joystick_click_pin = 26
joystick = Joystick(joystick_click_pin, menu.up, menu.down, menu.left, menu.right, menu.select)
# listeners for joystick X and Y pots set w/ AnalogReader callbacks

# ~~~~~ Initialize Button Matrix ~~~~~~ #
matrix_rows = 3
matrix_cols = 7

button_names = [[(r, c) for c in range(0, matrix_cols)] for r in range(0, matrix_rows)]

row_pins = [23, 24, 25] # BCM numbering
col_pins = [4, 17, 27, 22, 5, 6, 13]

factory = rpi_gpio.KeypadFactory()
keypad = factory.create_keypad(keypad=button_names, row_pins=row_pins, col_pins=col_pins)

def printKey(key): #temp
    print(key)

keypad.registerKeyPressHandler(printKey) # fill in callback

# ~~~~~ Initialize Analog Reader ~~~~~~ #
adc_cs_pin = board.D8

# Load channel config
analog_config_path = "/home/pi/beatboard/config/analog_channels.json"
with open(analog_config_path) as json_file:
    channel_info = json.load(json_file)

# Get DAC serial bus
spi = board.SPI()

# Create reader object
analog = AnalogReader(spi, adc_cs_pin, channel_info)

#temp
def printPotVal(name, val):
    print("Analog change: ({}: {})".format(name, val))

# Register callbacks
analog.registerCallback("joystick_x", joystick.processChange)
analog.registerCallback("joystick_y", joystick.processChange)
for i in range (5):
    analog.registerCallback("knob_{}".format(i), printPotVal)
analog.registerCallback("slider", printPotVal)


# ~~~~ Initialize Supercollider server ~~~~ #


# Main loop
while True:
    code = input()
    if code == "exit":
        keypad.cleanup()
        GPIO.cleanup()