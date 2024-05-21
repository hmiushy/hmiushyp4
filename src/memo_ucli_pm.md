# Memo of bfrt_python, ucli, pm
##
Autonegotiation
[japanese](https://fujikura-solutions.co.jp/technology/tcate/auto-negotiation/)
[wikipedia](https://ja.wikipedia.org/wiki/%E3%82%AA%E3%83%BC%E3%83%88%E3%83%8D%E3%82%B4%E3%82%B7%E3%82%A8%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3)

[bfrtref](https://github.com/zhaoyboo/p4-tofino-examples/blob/main/bri_handle/test.py#L171)
```python
################### You can now use BFRT CLIENT ###########################

key_list = []
data_list = []
print(" ---------------------- pass 0")
dev_tgt = bfrt_client.Target(device_id = 0)
table = bfrt_info.table_get('pipe.SwitchIngress.ipv4_exact')
table.info.key_field_annotation_add("dstAddr","ipv4")
#table.info.data_field_annotation_add("port","set_port","ipv4")
#table = bfrt_info.table_get("SwitchIngress.$PORT_METADATA")
print(" ---------------------- pass 0.1")
start = 8
end = 24
for i in range(start,end+1):
    ip = "10.0.0."+str(i)
    key_list.append(table.make_key([bfrt_client.KeyTuple("hdr.ipv4.dstAddr", ip)]))
    data_list.append(table.make_data([bfrt_client.DataTuple('port', i)],"SwitchIngress.set_port"))
print(" ---------------------- pass 0.2")
table.entry_add(dev_tgt,key_list=key_list,data_list=data_list,p4_name=bfrt_info.p4_name_get())
#for i in range(8,25):
#    ip = "10.0.0."+str(i)
#    bfrt.test.pipe.SwitchIngress.ipv4_exact.add_with_set_port(dstAddr=ip,port=i)
for (data,key) in table.entry_get(dev_tgt,key_list=key_list):
    print(key.to_dict(), '->')
    print(' ',data.to_dict())
#bfrt.test.pipe.SwitchIngress.ipv4_exact.add_with_set_port("hdr.ipv4.dstAddr"==0xa0000010,10)
bfrt.test.pipe.SwitchIngress.ipv4_exact.dump()
############################## FINALLY ####################################

```