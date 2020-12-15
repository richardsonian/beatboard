import os
import subprocess
import liblo

class SuperCollider:
    def __init__(self, ip, port):
        self.ip = ip
        self.port = port

    def sendMsg(self, *msg):
        liblo.send((self.ip, self.port), *msg)
    
    def setTempo(self, tempo):
        self.sendMsg("/tempo", tempo)
    
    def setVolume(self, target, amp):
        self.sendMsg(target, amp)

    def setChordRoot(self, root):
        self.sendMsg("/bass", "/root", root)

