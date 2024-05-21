#!/usr/bin/env python
## bfrt_python ./p4src/test/bfrt_starter.py
from __future__ import print_function

import os
import sys
import pdb
import logging
import copy
import pprint
logger = logging.getLogger('Test')
logger.addHandler(logging.StreamHandler())
SDE_INSTALL   = os.environ['SDE_INSTALL']
SDE_PYTHON_27 = os.path.join(SDE_INSTALL, 'lib', 'python2.7', 'site-packages')

sys.path.append(SDE_PYTHON_27)
sys.path.append(os.path.join(SDE_PYTHON_27, 'tofino'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/tofino/bfrt_grpc'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/tofino'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/tofino2pd/diag'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/tofino_pd_api'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/bf-ptf/ptf'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/include'))
                
                

import grpc
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as bfrt_client
from scapy.all import *
import ipaddress
from ptf import config
from ptf.thriftutils import *
import ptf.testutils as testutils


from ptf import config
from ptf.thriftutils import *
import ptf.testutils as testutils
#from bfruntime_client_base_tests import BfRuntimeTest
import google.rpc.code_pb2 as code_pb2
from functools import partial


#
# Connect to the BF Runtime Server
#
interface = bfrt_client.ClientInterface(
    grpc_addr = '0.0.0.0:50052',
    client_id = 0,
    device_id = 0)
print('Connected to BF Runtime Server')

#
# Get the information about the running program
#
bfrt_info = interface.bfrt_info_get()
print('The target runs the program ', bfrt_info.p4_name_get())

#
# Establish that you are using this program on the given connection
#
interface.bind_pipeline_config(bfrt_info.p4_name_get())

################### You can now use BFRT CLIENT ###########################

key_list = []
data_list = []
print(" ---------------------- pass 0")
dev_tgt = bfrt_client.Target(device_id = 0, pipe_id=0xffff) #,pipe_id=0x0)
# ------------------------------------------------------------------------------------
mtc_tbl    = bfrt_info.table_get('pipe.SwitchIngress.ipv4_exact')
#action_tbl = bfrt_info.table_get('pipe.SwitchIngress.action_profile')
# ------------------------------------------------------------------------------------
mtc_tbl.info.key_field_annotation_add("dstAddr","ipv4")
mtc_tbl.info.key_field_annotation_add("hdr.ipv4.dstAddr","ipv4")
mtc_tbl.info.data_field_annotation_add("port","SwitchIngress.set_port","bytes")
#table = bfrt_info.table_get("SwitchIngress.$PORT_METADATA")
print(" ---------------------- pass 0.1")

# ------------------------------------------------------------------------------------
start = 8
end = 24
table = mtc_tbl
lpm_dict = {}
tmp_list = []
for i in range(start,end+1):
    ip = "10.0.0."+str(i)
    tmp_list.append(ip)
    key_list.append(table.make_key([bfrt_client.KeyTuple("hdr.ipv4.dstAddr", ip)]))
    data_list.append(table.make_data([bfrt_client.DataTuple('port', i)],"SwitchIngress.set_port"))
    #key = table.make_key([bfrt_client.KeyTuple("hdr.ipv4.dstAddr", ip)])
    #data = table.make_data([bfrt_client.DataTuple('port', i)],"SwitchIngress.set_port")
    #key.apply_mask()
    #lpm_dict[key] = data
    #table.entry_add(dev_tgt, [key], [data])
    
key_list.append(table.make_key([bfrt_client.KeyTuple("hdr.ipv4.dstAddr", "192.168.100.10")]))
data_list.append(table.make_data([bfrt_client.DataTuple('port', 11)],"SwitchIngress.set_port"))
table.entry_add(dev_tgt,key_list=key_list,data_list=data_list,p4_name=bfrt_info.p4_name_get())

route_action_data = {}
#route_action_data['ports'] = [swports[random.randint(1, 5)] for x in range(num_entries)]
# ------------------------------------------------------------------------------------
#table = action_tbl
#for i in range(start,end+1):
#    key_list.append(table.make_key([bfrt_client.KeyTuple('$ACTION_MEMBER_ID', i)]))
#    data_list.append(table.make_data(
#                    [bfrt_client.DataTuple('port', i)],
#                     "SwitchIngress.set_port"))
#table.entry_add(dev_tgt,key_list=key_list,data_list=data_list,p4_name=bfrt_info.p4_name_get())
print(" ---------------------- pass 0.2")
#for i in range(8,25):
#    ip = "10.0.0."+str(i)
#    bfrt.test.pipe.SwitchIngress.ipv4_exact.add_with_set_port(dstAddr=ip,port=i)
#table = mtc_tbl
#for (data,key) in table.entry_get(dev_tgt,key_list=key_list):
#    print(key.to_dict(), '->', end="")
#    print(' ',data.to_dict())
#table = action_tbl
#for (data,key) in table.entry_get(dev_tgt,key_list=key_list):
#    print(key.to_dict(), '->')
#    print(' ',data.to_dict())
#bfrt.test.pipe.SwitchIngress.ipv4_exact.add_with_set_port("hdr.ipv4.dstAddr"==0xa0000010,10)
bfrt.test.pipe.SwitchIngress.ipv4_exact.dump()
############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")
