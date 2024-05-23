#!/usr/bin/env python
from __future__ import print_function

import os
import sys
import pdb
import logging
import copy
import pprint
import time
sys.path.append("/usr/lib/python3/dist-packages")

SDE_INSTALL   = os.environ['SDE_INSTALL']
SDE_PYTHON_27 = os.path.join(SDE_INSTALL, 'lib', 'python2.7', 'site-packages')
SDE_PYTHON_38 = os.path.join(SDE_INSTALL, 'lib', 'python3.8', 'site-packages')
sys.path.append(SDE_PYTHON_27)
sys.path.append(os.path.join(SDE_PYTHON_27, 'tofino'))
sys.path.append(SDE_PYTHON_38)
sys.path.append(os.path.join(SDE_PYTHON_38, 'tofino'))
sys.path.append(os.path.join(SDE_PYTHON_38, 'tofino/bfrt_grpc'))
pprint.pprint(sys.path)

import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import bfrt_grpc.client as bfrt_client

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
dev_tgt = bfrt_client.Target(device_id = 0, pipe_id=0xffff) #,pipe_id=0x0)
# ------------------------------------------------------------------------------------
mtc_tbl    = bfrt_info.table_get('pipe.SwitchIngress.ipv4_exact')
#action_tbl = bfrt_info.table_get('pipe.SwitchIngress.action_profile')
# ------------------------------------------------------------------------------------
mtc_tbl.info.key_field_annotation_add("dst_addr","ipv4")
mtc_tbl.info.key_field_annotation_add("hdr.ipv4.dst_addr","ipv4")
mtc_tbl.info.data_field_annotation_add("port","SwitchIngress.set_port","bytes")
# ------------------------------------------------------------------------------------
start = 8
end = 24
table = mtc_tbl
for i in range(start,end+1):
    ip = "10.0.0."+str(i)
    key_list.append(table.make_key([bfrt_client.KeyTuple("hdr.ipv4.dst_addr", ip)]))
    data_list.append(table.make_data([bfrt_client.DataTuple('port', i)],"SwitchIngress.set_port"))
table.entry_add(dev_tgt,key_list=key_list,data_list=data_list,p4_name=bfrt_info.p4_name_get())

#bfrt.reg.pipe.SwitchIngress.ipv4_exact.dump()
time_step = 0

while True:
    count_reg_name = "SwitchIngress.count.just_packet_cnt"
    debug_name     = "SwitchIngress.count.for_debug"
    count_reg = bfrt_info.table_get("pipe."+count_reg_name)
    debug = bfrt_info.table_get("pipe."+debug_name)
    print("------ =============================================== -------")
    packet_count = 0
    count_resp = count_reg.entry_get(dev_tgt,
        [count_reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX", 0)])], 
        {"from_hw":True})
    debug_resp_0 = debug.entry_get(dev_tgt,
        [debug.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX", 0)])], 
        {"from_hw":True})
    debug_resp_1 = debug.entry_get(dev_tgt,
        [debug.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX", 1)])], 
        {"from_hw":True})
    
    data,_ = next(count_resp)
    data_dict = data.to_dict()
    print("cnt: ",data_dict[count_reg_name+".packet_count"]," len: ",
        data_dict[count_reg_name+".packet_length"])
    packet_count += data_dict[count_reg_name+".packet_count"][0]
    print("total packet: {}".format(packet_count))

    data,_ = next(debug_resp_0)
    data_dict = data.to_dict()
    print(data_dict[debug_name+".f1"])
    data,_ = next(debug_resp_1)
    data_dict = data.to_dict()
    print(data_dict[debug_name+".f1"][0]/10e8)
    

    #bfrt.p4_main.pipe.SwitchIngress.count.for_debug.operation_register_sync
    #bfrt.p4_main.pipe.SwitchIngress.count.for_debug.dump()
    time_step += 1 

    time.sleep(1)
        
    

############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")
