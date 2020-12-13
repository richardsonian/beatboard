import busio
import digitalio
import board
import RPi.GPIO as GPIO
import adafruit_mcp3xxx.mcp3008 as MCP
from adafruit_mcp3xxx.analog_in import AnalogIn
import time
from threading import Timer, Thread

class AnalogReader:

    DEFAULT_READ_FREQ = 0.1
    DEFAULT_TRIGGER_DELTA = 10

    def __init__(self, spi, cs_pin, channel_info, frequency=DEFAULT_READ_FREQ, delta=DEFAULT_TRIGGER_DELTA):
        cs = digitalio.DigitalInOut(cs_pin)
        self._mcp = MCP.MCP3008(spi, cs)

        self._channel_info = channel_info
        self._channels = {name:AnalogIn(self._mcp, ch["pin"]) for (name, ch) in channel_info.items()} 
        self._old_values = {name:0 for name in channel_info.keys()}

        self._callbacks = {name:None for name in channel_info.keys()}
        
        self._delta = delta
        self._timer = Timer(frequency, self._read)
        self._timer.start()
     
    def registerCallback(self, channel_name, callback):
        self._callbacks[channel_name] = callback

    def removeCallback(self, channel_name):
        del self._callbacks[channel_name]

    def _read(self):
        for (name, channel) in self._channels.items():
            val = channel.value
            if abs(self._old_values[name] - val) >= self._delta:
                # Update the old value
                self._old_values[name] = val

                # Normalize the value
                scaled_val = _scale(val, self._channel_info[name]["min"], self._channel_info[name]["max"], 0, 1)

                # Start callback in new thread so that our reading isn't blocked
                thread_name = name + "_callback"
                arguments = (name, scaled_val)
                print("debug: About to start thread: {} with args: {}".format(thread_name, arguments))
                Thread(target=self._callbacks[name], name=thread_name, args=arguments).start()
                

class Joystick:
    DEFAULT_REPEAT_DELAY = 0.4 # seconds
    DEFAULT_THRESHOLD = 0.8 # 80% of max 

    def __init__(self, clickPin, upAction, downAction, leftAction, rightAction, clickAction, repeat_delay=DEFAULT_REPEAT_DELAY, threshold=DEFAULT_THRESHOLD, clickDebounce=200):
        self.threshold = threshold
        self.repeat_delay = repeat_delay
        self._repeat_timer = None

        # Callbacks
        self.onUp = upAction
        self.onDown = downAction
        self.onLeft = leftAction
        self.onRight = rightAction
        self.onClick = clickAction

        # Init click
        GPIO.setup(clickPin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
        GPIO.add_event_detect(clickPin, GPIO.RISING, callback=self.onClick, bouncetime=clickDebounce)

    def processChange(self, axis_name, value):
        if (value >= self.threshold) and (value <= (1 - self.threshold)):
            if self._repeat_timer is None:
                # Find the right callback for the direction moved
                if axis_name == "joystick_x":
                    if value >= self.threshold:
                        callback = self.onRight
                    elif value <= (1 - self.threshold):
                        callback = self.onLeft
                elif axis_name == "joystick_y":
                    if value >= self.threshold:
                        callback = self.onUp
                    elif value <= (1 - self.threshold):
                        callback = self.onDown
                
                # call it once
                Thread(target=callback, name=axis_name + "_callback", args=()).start()
                # set repeat timer
                self._repeat_timer = Timer(self.repeat_delay, callback)
                self._repeat_timer.start()

        elif self._repeat_timer is not None:
                self._repeat_timer.cancel()
                self._repeat_timer = None
                


# ~~~~~ Helper functions ~~~~~ #
def _scale(num, oldMin, oldMax, newMin, newMax):
        return (((num - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin

def _millis():
    return time.time() * 1000

                
    