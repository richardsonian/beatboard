#!/usr/bin/python3
import busio
import digitalio
import board
import adafruit_mcp3xxx.mcp3008 as MCP
from adafruit_mcp3xxx.analog_in import AnalogIn
import time
    
# create the spi bus
spi = busio.SPI(clock=board.SCK, MISO=board.MISO, MOSI=board.MOSI)
    
# create the cs (chip select)
cs = digitalio.DigitalInOut(board.D8)
    
# create the mcp object
mcp = MCP.MCP3008(spi, cs)
    
# create analog inputs
pots = [AnalogIn(mcp, channel) for channel in [MCP.P0, MCP.P1, MCP.P2, MCP.P3, MCP.P4]]
slider = AnalogIn(mcp, MCP.P5)
joystick = [AnalogIn(mcp, channel) for channel in [MCP.P6, MCP.P7]]

while True:
    print("Pots: {0}, Slider: {1}, Joy: (x: {2}, y: {3})".format([ch.value for ch in pots], slider.value, joystick[0].value, joystick[1].value))
    time.sleep(0.2)