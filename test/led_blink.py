#!/bin/bash

import time
import board
import digitalio
    
print("hello blinky!")

ledpin = board.D18

led = digitalio.DigitalInOut(ledpin)
led.direction = digitalio.Direction.OUTPUT
    
while True:
    led.value = True
    time.sleep(0.5)
    led.value = False
    time.sleep(0.5)