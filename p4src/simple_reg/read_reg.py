#!/usr/bin/env python
from __future__ import print_function

import os
import sys
import pdb
import logging
import copy
import pprint
import time

SDE_INSTALL   = os.environ['SDE_INSTALL']
SDE_PYTHON_27 = os.path.join(SDE_INSTALL, 'lib', 'python2.7', 'site-packages')
SDE_PYTHON_38 = os.path.join(SDE_INSTALL, 'lib', 'python3.8', 'site-packages')
sys.path.append(SDE_PYTHON_27)
sys.path.append(os.path.join(SDE_PYTHON_27, 'tofino'))
sys.path.append(SDE_PYTHON_38)
sys.path.append(os.path.join(SDE_PYTHON_38, 'tofino'))
sys.path.append(os.path.join(SDE_PYTHON_38, 'tofino/bfrt_grpc'))

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
    try:
        cms_0_reg_name = "pipe.SwitchIngress.cms.cms_reg_0"
        cms_1_reg_name = "pipe.SwitchIngress.cms.cms_reg_1"
        cms_0 = bfrt_info.table_get('pipe.SwitchIngress.cms.cms_reg_0')
        cms_1 = bfrt_info.table_get('pipe.SwitchIngress.cms.cms_reg_1')
        idx = 0
        print("------ =============================================== -------")
        print("------ TS-{} Result CMS register 0 -------".format(time_step))
        cms_width = 16
        packet_count = 0
        for idx in range(cms_width):
            cms_0_resp = cms_0.entry_get(dev_tgt,
                [cms_0.make_key([bfrt_client.KeyTuple("$REGISTER_INDEX", idx)])], 
                {"from_hw":True})
            data,_ = next(cms_0_resp)
            data_dict = data.to_dict()
            print("cnt: ",data_dict["SwitchIngress.cms.cms_reg_0.packet_count"]," len: ",
            data_dict["SwitchIngress.cms.cms_reg_0.packet_length"], " ",idx)
            packet_count += data_dict["SwitchIngress.cms.cms_reg_0.packet_count"][0]
        print("total packet: {}".format(packet_count))
        time_step += 1 
        ## Sync Target Table using bfrt_python
        #bfrt.reg.pipe.SwitchIngress.cms.estimate_pcnt.operation_register_sync 
        #bfrt.reg.pipe.SwitchIngress.cms.estimate_plen.operation_register_sync 
        """
        cms_0 = bfrt.reg.pipe.SwitchIngress.cms.cms_reg_0
        cms_1 = bfrt.reg.pipe.SwitchIngress.cms.cms_reg_1
        cms_0.operation_register_sync 
        cms_1.operation_register_sync 
        for i in range(3):
            cms_0.get(REGISTER_INDEX=i,from_hw=True).data[b'SwitchIngress.cms.cms_reg_0.packet_count']
            cms_0.get(REGISTER_INDEX=i,from_hw=True).data[b'SwitchIngress.cms.cms_reg_0.packet_length']
        """
        time.sleep(1)
    except KeyboardInterrupt:
        print(" Stop.")
        break
        
    

############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")
