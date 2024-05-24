import os
import sys
from scapy.all import *
import time
import random

count = 0
while True:
    try:
        count = (count + 1)
        print(count)
        num1 = random.randint(2, 255)
        num2 = random.randint(2, 255)
        num3 = random.randint(2, 255)
        num4 = random.randint(2, 255)
        #num2 = 0
        tmp_ip = "{}.{}.{}.{}".format(num1,num2,num3,num4)
        print("send to {} from veth0".format(tmp_ip))
        p1 = Ether(type=0x800)/IP(src="10.0.0.8", dst=tmp_ip)
        sendp(p1, iface="veth0")
        time.sleep(1)
    except KeyboardInterrupt:
        print(" Stop.")
        break
    
