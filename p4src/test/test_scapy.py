import os
import sys
from scapy.all import *
import time

count = 8
while True:
    try:
        count = (count + 1)
        tmp_ip = "10.0.0."+str(count)
        print("send to {} from veth0".format(tmp_ip))
        p1 = Ether(type=0x800)/IP(src="10.0.0.8", dst=tmp_ip)
        p1.show()
        sendp(p1, iface="veth0")
        time.sleep(1)
        if count == 24:
            count = 8
    except KeyboardInterrupt:
        print(" Stop.")
        break
    