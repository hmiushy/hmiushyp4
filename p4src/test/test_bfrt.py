#!/usr/bin/env python
## bfrt_python ./p4src/test/bfrt_starter.py
from __future__ import print_function

import os
import sys
import pdb

SDE_INSTALL   = os.environ['SDE_INSTALL']
SDE_PYTHON_27 = os.path.join(SDE_INSTALL, 'lib', 'python2.7', 'site-packages')

sys.path.append(SDE_PYTHON_27)
sys.path.append(os.path.join(SDE_PYTHON_27, 'tofino'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/tofino/bfrt_grpc'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/tofino'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/tofino2pd/diag'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/python3.8/site-packages/tofino_pd_api'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/include'))
                
import grpc
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



############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")
