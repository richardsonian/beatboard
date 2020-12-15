#!/usr/bin/python3

# Hardware
import busio
import digitalio
import board
from pad4pi import rpi_gpio
import RPi.GPIO as GPIO
from adafruit_ssd1306 import SSD1306_I2C as OLED
# Software
import json
import time
from functools import partial
# Local
from analog_inputs import AnalogReader, Joystick
from screens import Menu
from supercollider import SuperCollider

# ~~~~ Initialize Supercollider Object ~~~~ #
sclang_ip = "192.168.1.36" # talk to sclang on laptop, bc pi is too slow to process
sclang_port = 57120

SC = SuperCollider(sclang_ip, sclang_port)

# ~~~~~ Initialize Menu ~~~~~~ #
big_screen_width = 128
big_screen_height = 64
big_screen_i2c_addr = 0x3d
menu_config_path = "/home/pi/beatboard/config/menu.json"

# Load menu config
with open(menu_config_path) as json_file:
    menu_items = json.load(json_file)

# init screen
big_screen = OLED(big_screen_width, big_screen_height, board.I2C(), addr=big_screen_i2c_addr)

# create menu object
menu = Menu(SC, big_screen, menu_items)

# ~~~~~ Initialize Joystick ~~~~~~ #
joystick_click_pin = 26

joystick = Joystick(joystick_click_pin, menu.up, menu.down, menu.left, menu.right, menu.select)

# NOTE: listeners for joystick X and Y pots set w/ AnalogReader callbacks

# ~~~~~ Initialize Button Matrix ~~~~~~ #
matrix_rows = 3
matrix_cols = 7

row_pins = [23, 24, 25] # BCM numbering
col_pins = [4, 17, 27, 22, 5, 6, 13]

button_names = [[(r, c) for c in range(0, matrix_cols)] for r in range(0, matrix_rows)]

factory = rpi_gpio.KeypadFactory()
keypad = factory.create_keypad(keypad=button_names, row_pins=row_pins, col_pins=col_pins)

# Debug
def printKey(key):
    print(key)

keypad.registerKeyPressHandler(SC.handleButtonPress) # fill in callback

# ~~~~~ Initialize Analog Reader ~~~~~~ #
adc_cs_pin = board.D8

# Load channel config
analog_config_path = "/home/pi/beatboard/config/analog_channels.json"
with open(analog_config_path) as json_file:
    channel_info = json.load(json_file)

# Get ADC serial bus
spi = board.SPI()

# Create reader object
analog = AnalogReader(spi, adc_cs_pin, channel_info)

# Debug
def printPotVal(name, val):
    print("Analog change: ({}: {})".format(name, val))

# Register callbacks
analog.registerCallback("joystick_x", joystick.processChange)
analog.registerCallback("joystick_y", joystick.processChange)
analog.registerCallback("knob_0", (lambda _, val : SC.sendMsg("/hihat", "/amp", val)))
analog.registerCallback("knob_1", (lambda _, val : SC.sendMsg("/snare", "/amp", val)))
analog.registerCallback("knob_2", (lambda _, val : SC.sendMsg("/kick", "/amp", val)))
analog.registerCallback("knob_3", (lambda _, val : SC.sendMsg("/bass", "/amp", val)))
analog.registerCallback("knob_4", (lambda _, val : SC.setTempo(val)))
analog.registerCallback("slider", printPotVal)

# Main loop & Exit cleanup
while True:
    code = input()
    if code == "exit":
        keypad.cleanup()
        GPIO.cleanup()
        analog.deinit()
        joystick.deinit()
        menu.clear()
        break