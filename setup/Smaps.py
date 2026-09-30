import sys
import os

class SMAPx:
    def __init__(self, name : str):
        self.path = "/home/cc/labs/NanoMod/setup/"
        self.name = name + ".txt"
    

    def GetSmap(self):
        smap = []
        lines = []
        with open(self.path + self.name, "r") as f:
           
            lines = f.readlines()
        
        for line in lines:
            x = int(line.strip(), 16)
            smap.append(x)
            print("{0:x}".format(x))
        return smap


# qam16 = SMAPx("QAM16").GetSmap()
# path = os.getcwd()
# print( path)
