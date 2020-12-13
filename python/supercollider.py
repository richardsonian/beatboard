import os
import subprocess
import liblo

DEFAULT_SERVER_IP = "localhost"
DEFAULT_SERVER_PORT = 57120

def startServer(ip=DEFAULT_SERVER_IP, port=DEFAULT_SERVER_PORT):
    subprocess.call("~/beatboard/run_sclang.sh")

def sendMsg(ip, port, path, msg):
    liblo.send((ip, port), path, msg)

