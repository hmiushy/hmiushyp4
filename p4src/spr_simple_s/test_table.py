#!/usr/bin/env python
## bfrt_python ./p4src/test/bfrt_starter.py
from __future__ import print_function

import os
import sys
import pdb
import logging
import copy
import pprint

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
bfrt.sss.pipe.SwitchIngress.ipv4_exact.dump()
############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")
