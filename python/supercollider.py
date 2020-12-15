import os
import subprocess
import liblo
from util import scale

MIN_TEMPO = 60
MAX_TEMPO = 200

class SuperCollider:
    def __init__(self, ip, port):
        self.ip = ip
        self.port = port

    def sendMsg(self, *msg):
        liblo.send((self.ip, self.port), *msg)
    
    def setTempo(self, tempo): # tempo from 0-1
        new_tempo = round(scale(tempo, 0, 1, MIN_TEMPO, MAX_TEMPO))
        self.sendMsg("/tempo", new_tempo)

    def handleButtonPress(self, button):
        scale_degree = button[1] # the col index of the button
        self.sendMsg("/bass", "/root", scale_degree)


