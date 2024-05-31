## Error running bfrt_python to read register values
In cycu, and in the lab, I can run `./run_switchd.sh -p ~ --arch
Tofino2`. However, I build the same env in my lab, I got the error above:
```bash
Traceback (most recent call last):
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/bfrtcli.py", line 2279, in start_bfrt
    exec(open(udf).read())
  File "<string>", line 23, in <module>
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/site-packages/tofino/bfrt_grpc/bfruntime_pb2.py", line 6, in <module>
    from google.protobuf.internal import enum_type_wrapper
ModuleNotFoundError: No module named 'google.protobuf'
```

This means that the lib path or env path is not followed if you
already install the module. You have to set the values.

``` bash
## find the lib
sudo find ./install -path "*google/protobuf/internal/enum*"
## copy the lib to the SDE_INSTALL_LIB (usually, these're installed when ran p4build code.)
sudo cp -r /usr/lib/python3/dist-packages/google/protobuf ./install/lib/python3.8/site-packages/google/

```
Then, I got the error next:
```bash
    import grpc
ModuleNotFoundError: No module named 'grpc'
```
You can just install using pip. 
```
sudo pip3 install grpcio
```
sometimes I got the below message:
```bash
Requirement already satisfied: grpcio in /usr/local/lib/python3.8/dist-packages (1.64.0)
```
I try to copy:
```
sudo cp -r /usr/local/lib/python3.8/dist-packages/grpc ./install/lib/python3.7/site-packages/
```
End.
