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
global bfrt_info
global brft_client
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

def look_tbl_all(tbl_name,dev_tgt, num):
    global bfrt_info
    global bfrt_client
    for i in range(num):
        reg = bfrt_info.table_get("pipe."+tbl_name)
        resp = reg.entry_get(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX", i)]
        )],{"from_hw":True})
        data,_ = next(resp)
        data_dict = data.to_dict()
        for tmp_name in data_dict.keys():
            if tbl_name in tmp_name:
                str_len = len(tbl_name)+1
                see_val = tmp_name[str_len:len(tmp_name)]
                see_k = tbl_name+"."+see_val
                val = data_dict[see_k][0]
                print("{}:[{}]".format(i, val), end=" ")
    print()

def look_tbl(tbl_name,dev_tgt):
    global bfrt_info
    global bfrt_client
    reg = bfrt_info.table_get("pipe."+tbl_name)
    resp = reg.entry_get(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX",
                                            0)])],
                         {"from_hw":True})
    data,_ = next(resp)
    data_dict = data.to_dict()
    for tmp_name in data_dict.keys():
        if tbl_name in tmp_name:
            str_len = len(tbl_name)+1
            see_val = tmp_name[str_len:len(tmp_name)]
            see_k = tbl_name+"."+see_val
            val = data_dict[see_k][0]
            print("{}.{}: {} ".format(tbl_name,see_val,
                                      val,
                                      end=" "))
time_step = 0
while True:
    print("------ ====================================== -------")
    ## get register info ------------------------- count
    #tbl_name  = "SwitchIngress.count.just_packet_cnt"
    #  plook_tbl(tbl_name, dev_tgt)
    
    ## get register info ------------------------- for_debug
    #tbl_name  = "SwitchIngress.count.for_debug"
    #look_tbl(tbl_name, dev_tgt)

    ## get register info ------------------------- repo_name
    reg_size = 20
    tbl_name  = "SwitchIngress.count.repo_cnt"
    look_tbl_all(tbl_name,dev_tgt, reg_size)
    tbl_name  = "SwitchIngress.count.repo_len"
    look_tbl_all(tbl_name,dev_tgt, reg_size)
    
    tbl_name = "SwitchIngress.count.pre_pkt_nano"
    look_tbl(tbl_name, dev_tgt)
    tbl_name = "SwitchIngress.count.pre_repo_miri"
    look_tbl(tbl_name, dev_tgt)

    
    ## get register info ------------------------- micro_name
    #tbl_name = "SwitchIngress.count.micro_sec"
    #look_tbl(tbl_name, dev_tgt)

    ## get register info ------------------------- sec_name
    #tbl_name = "SwitchIngress.count.diff_val"
    #look_tbl(tbl_name, dev_tgt)
    #tbl_name = "SwitchIngress.before_pkt_miri.diff_val"
    #look_tbl(tbl_name, dev_tgt)
    time_step += 1
    time.sleep(1)
        
    

############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")
