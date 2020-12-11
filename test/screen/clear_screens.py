#!/usr/bin/python3


import board
import busio
from PIL import Image, ImageDraw, ImageFont
import adafruit_ssd1306

# Change these
# to the right size for your display!
BIG_WIDTH = 128
BIG_HEIGHT = 64

SMALL_WIDTH = 128
SMALL_HEIGHT = 32

i2c = board.I2C()
small_screen = adafruit_ssd1306.SSD1306_I2C(SMALL_WIDTH, SMALL_HEIGHT, i2c, addr=0x3c)
big_screen = adafruit_ssd1306.SSD1306_I2C(BIG_WIDTH, BIG_HEIGHT, i2c, addr=0x3d)


# Clear display.
small_screen.fill(0)
small_screen.show()

big_screen.fill(0)
big_screen.show()