## Memo
`$SDE_INSTALL/lib/python3.8/site-packages/tofino/bfrt_grpc`
`field_dict`
`DataTuple`
`KeyTuple`

```python
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
from scapy.all import *
import ipaddress
#import client

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
def testTable(table, key_list, data_list, target, data_filter=None):
    print(111111)       
    handle_list = []
    # Add entries
    if len(data_list) > 0:
        print(2222222)      
        table.entry_add(target,key_list=key_list,data_list=data_list)
        print(3333333)
    else:
        table.entry_add(target,key_list) 
    # Fetch handles
    for key in key_list:
        resp = table.handle_get(target, [key])
        handle_list.append(resp)

        # Now use handle to get entry data and key.
        # First entry_get is for data and key (tableEntryGet),
        # second one will fetch only key (tableEntryKeyGet).
    for handle in handle_list:
        if len(data_list) > 0:
            # Apply data filter if applicable
            resp = table.entry_get(target, required_data=data_filter,
                                       handle=handle, flags={"from_hw":False})
            for data, _ in resp:
                data_dict = data.to_dict()
                try:
                    data_list.remove(data)
                except ValueError:
                    assert False, 'Invalid data returned'
        resp = table.entry_get(target, handle=handle,
                               flags={"key_only": True})
        for data, key, tgt in resp:
            key_dict = key.to_dict()
            try:
                key_list.remove(key)
            except ValueError:
                assert False, 'Invalid key returned'
            try:
                data.to_dict()
            except Exception:
                logger.info("No data received - as expected")
            else:
                assert False, 'Unexpected data received'
            assert tgt==target, 'Received entry target do not match expected'
    # Clear table
    table.entry_del(self.target, [])
    assert len(data_list) == 0, 'data_list should be empty after receiving all test entries'
    assert len(key_list) == 0, 'key_list should be empty after receiving all test entries'

                        
key_list = []
data_list = []
print(" ---------------------- pass 0")
dev_tgt = bfrt_client.Target(device_id = 0,pipe_id = 3)
table = bfrt_info.table_get('pipe.SwitchIngress.ipv4_exact')
table.info.key_field_annotation_add("hdr.ipv4.dstAddr","ipv4")
table.info.data_field_annotation_add("port","set_port","ipv4")
my_test = bfrt_info.table_get('pipe.SwitchIngress.ipv4_exact')
#table = bfrt_info.table_get("SwitchIngress.$PORT_METADATA")
print(" ---------------------- pass 0.1")
key_list.append(table.make_key([bfrt_client.KeyTuple('hdr.ipv4.dstAddr', 0xa000009)]))
data_list.append(table.make_data([bfrt_client.DataTuple('port', 0x9)],"SwitchIngress.set_port"))
print(" ---------------------- pass 0.2")
#table.entry_add(dev_tgt,key_list=key_list,data_list=data_list,p4_name=bfrt_info.p4_name_get())

#testTable(table, key_list, data_list, dev_tgt)#, data_filter=data_list[0])
print(" ---------------------- pass 0.3")
#key_list.append(table.make_key([bfrt_client.KeyTuple('port', 8)]))

print(my_test.info.key_field_name_list_get())
print(my_test.info.data_field_name_list_get())
print(my_test.info.action_name_list_get())

# my_test2 = bfrt_info.table_get("pipe.SwitchIngress.set_port")
my_test.info.key_field_annotation_add("hdr.ipv4.dstAddr","ipv4")
my_test.info.data_field_annotation_add("port","set_port","ipv4")
print(" ---------------------- pass 1")
#tmp_ipv4 = str(ipaddress.IPv4Address("10.0.0.8"))
tmp_ipv4 = 0xa000008
key1 = my_test.make_key([bfrt_client.KeyTuple("hdr.ipv4.dstAddr", tmp_ipv4)])
print(" ---------------------- pass 2")
#tmp_ipv4 = str(ipaddress.IPv4Address("10.0.0.9"))
tmp_ipv4 = 0xa000009
key2 = my_test.make_key([bfrt_client.KeyTuple("hdr.ipv4.dstAddr", tmp_ipv4)])
print(" ---------------------- pass 3")
print(key_list)
key_list = []
key_list.append(key1)
key_list.append(key2)
data1 = my_test.make_data([bfrt_client.DataTuple("port",0x8)],"SwitchIngress.set_port")
print(" ---------------------- pass 3.2")
#data1 = my_test.make_data([],'SwitchIngress.ipv4_exact.set_port')
#data1 = my_test.make_data([bfrt_client.DataTuple("set_port",int_arr_val=[9])])
data2 = my_test.make_data([bfrt_client.DataTuple("port",0x9)],"SwitchIngress.set_port")
print(" ---------------------- pass 3.5")
#data2 = my_test.make_data([9],"SwitchIngress.ipv4_exact.set_port")
data_list = []
data_list.append(data1)
data_list.append(data2)
print(" ---------------------- pass 4")
#my_test.entry_add(dev_tgt,key_list,data_list)
print(" ---------------------- pass 4.1")
# my_test.operations_execute(dev_tgt, 'Sync')

#key_list = bfrt_client.DataTuple("hdr.ipv4.dstAddr")
#key_tuple1 = bfrt_client.KeyTuple("hdr.ipv4.dstAddr",value="LPM",prefix_len=32)
#key_tuple2 = bfrt_client.KeyTuple("10.0.0.8",value="LPM",prefix_len=32)
#print(" ---------------------- pass 2")
#key_tuples = [key_tuple1, key_tuple2]
#key_tuples = ["10.0.0.8", "10.0.0.9"]
#key_list = bfrt_client._Table.make_key(key_tuples)


#print(" ---------------------- pass 3")
#print(" ---------------------- pass 4")
#print(" ---------------------- pass 5")

#data_list = [8,9]
#my_test = my_test.entry_add(dev_tgt, key_list=key_list, data_list=data_list,p4_name="test")
bfrt.test.pipe.SwitchIngress.ipv4_exact.add_with_set_port("hdr.ipv4.dstAddr"==0xa000009,9)
bfrt.test.pipe.SwitchIngress.ipv4_exact.add_with_set_port("hdr.ipv4.dstAddr"==0xa0000010,10)
bfrt.test.pipe.SwitchIngress.ipv4_exact.dump()
############################## FINALLY ####################################
#
# If you use SDE prior to 9.4.0, uncomment the line below
# interface._tear_down_stream()

print("The End")


```
```

            hdr.ipv4.dstAddr : exact;
        }
        actions = { 
            set_port;
            NoAction; 
        }
        const entries = {
            0xa000008: set_port(8);
            0xa000009: set_port(9);
            0xa00000a: set_port(10);
            0xa00000b: set_port(11);
            0xa00000c: set_port(12);
        }
```