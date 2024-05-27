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

def look_tbl_all(tbl_name,dev_tgt, num):
    global bfrt_info
    global bfrt_client
    global pprint
    #my_packet = {"packet_count": [], "packet_length": []}
    for i in range(num):
        reg = bfrt_info.table_get("pipe."+tbl_name)
        reg.operations_execute(dev_tgt, 'Sync')
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
                #print("{}:[{}]".format(i, val), end=" ")
                #my_packet[see_val].append(val)
                print("[{}]".format(val), end=" ")
    """
    for tkey in my_packet.keys():
        print(tkey)
        for i in my_packet[tkey]:
            print(i, end=" ")
        print()
    """
    print()
def look_tbl(tbl_name,dev_tgt):
    global bfrt_info
    global bfrt_client
    reg = bfrt_info.table_get("pipe."+tbl_name)
    reg.operations_execute(dev_tgt, 'Sync')
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
def get_time(tbl_name,dev_tgt):
    global bfrt_info
    global bfrt_client
    reg = bfrt_info.table_get("pipe."+tbl_name)
    reg.operations_execute(dev_tgt, 'Sync')
    resp = reg.entry_get(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX",
                                            0)])],
                         {"from_hw":True})
    data,_ = next(resp)
    data_dict = data.to_dict()
    return_val = -1
    for tmp_name in data_dict.keys():
        if tbl_name in tmp_name:
            str_len = len(tbl_name)+1
            see_val = tmp_name[str_len:len(tmp_name)]
            see_k = tbl_name+"."+see_val
            val = data_dict[see_k][0]
            return_val = val
            
    return return_val

def del_tbl(tbl_name,dev_tgt):
    global bfrt_info
    global bfrt_client
    reg = bfrt_info.table_get("pipe."+tbl_name)
    reg.operations_execute(dev_tgt, 'Sync')
    resp = reg.entry_mod(dev_tgt,
        [reg.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX",
                                            0)])])
            
time_step = 0
pre_time = -1
all_timestep = []
all_data = []
def com_name(func1, reg_name):
    return "SwitchIngress."+func1+"."+reg_name

while True:
    print("------ ====================================== -------")
    bname = "bfrt.p4_main.pipe.SwitchIngress"
    func1 = "cms"

    # tbl_name = com_name(func1, "src_ip_reg")
    # look_tbl_all(tbl_name,dev_tgt, 32)
    # tbl_name = com_name(func1, "dst_ip_reg")
    # look_tbl_all(tbl_name,dev_tgt, 32)
    
    tbl_name = com_name(func1, "just_packet_cnt")
    #look_tbl(tbl_name,dev_tgt)
    tbl_name = com_name(func1, "check_value")
    look_tbl(tbl_name,dev_tgt)

    queue_size = 100
    tbl_name = com_name(func1, "src_ip_queue")
    #look_tbl_all(tbl_name,dev_tgt,queue_size)
    
    # tbl_name = com_name(func1, "arrival_miri")
    # now_time = get_time(tbl_name, dev_tgt)
    
    # if now_time - pre_time < 0:
    #     pre_time = now_time
    # elif pre_time == -1:
    #     pre_time = now_time
    # elif now_time - pre_time > 10000:
    #     reg_name = "just_packet_cnt"
    #     tbl_name = com_name(func1, reg_name)
    #     look_tbl(tbl_name, dev_tgt)
    #     eval_str = bname+"."+func1+"."+reg_name+".clear()"
    #     eval(eval_str)
        
        # for i in range(num_cms):
        #     reg_name = "just_packet_cnt"
        #     tbl_name = com_name(func1, reg_name)
        #     look_tbl_all(tbl_name, dev_tgt, 32)
        #     eval_str = bname+"."+func1+"."+reg_name+".clear()"
        #     eval(eval_str)
        #pre_time = now_time
        
    """
    if now_time - pre_time < 0:
        pre_time = now_time
    elif pre_time == -1:
        pre_time = now_time
    elif now_time - pre_time > 10000:
        reg_name = "estimate_pcnt"
        tbl_name = com_name(func1, reg_name)
        look_tbl(tbl_name, dev_tgt)
        eval_str = bname+"."+func1+"."+reg_name+".clear()"
        eval(eval_str)

        reg_name = "estimate_plen"
        tbl_name = com_name(func1, reg_name)
        look_tbl(tbl_name, dev_tgt)
        eval_str = bname+"."+func1+"."+reg_name+".clear()"
        eval(eval_str)
        num_cms = 1
        for i in range(num_cms):
            reg_name = "cms_reg_"+str(i)
            tbl_name = com_name(func1, reg_name)
            look_tbl_all(tbl_name, dev_tgt, 32)
            eval_str = bname+"."+func1+"."+reg_name+".clear()"
            eval(eval_str)
        pre_time = now_time
    """
    
    time_step += 1
    time.sleep(0.1)

############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")
