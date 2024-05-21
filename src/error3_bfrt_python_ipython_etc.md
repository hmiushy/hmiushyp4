
# Error of `bfrt_pythoon` when executing `run_switchd.sh`
## error in non-vm
1. sudo -s
2. ./run_switchd.sh -p `name` --arch Tofino2
   I got the error below:
```bash
bfruntime gRPC server started on 0.0.0.0:50052

        ********************************************
        *      WARNING: Authorised Access Only     *
        ********************************************
    

bfshell> bfrt_python 
ModuleNotFoundError: No module named 'bfrtcli'
Error in sys.excepthook:
Traceback (most recent call last):
  File "/usr/lib/python3.8/subprocess.py", line 64, in <module>
    import msvcrt
ModuleNotFoundError: No module named 'msvcrt'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/apport_python_hook.py", line 72, in apport_excepthook
    from apport.fileutils import likely_packaged, get_recent_crashes
  File "/usr/lib/python3/dist-packages/apport/__init__.py", line 5, in <module>
    from apport.report import Report
  File "/usr/lib/python3/dist-packages/apport/report.py", line 12, in <module>
    import subprocess, tempfile, os.path, re, pwd, grp, os, io
  File "/usr/lib/python3.8/subprocess.py", line 69, in <module>
    import _posixsubprocess
ModuleNotFoundError: No module named '_posixsubprocess'

Original exception was:
ModuleNotFoundError: No module named 'bfrtcli'
Failed to load bfrtcli python library
bfrt_cli_cmd:197 could not initialize bf_rt for the cli. err: 1
```
Maybe I have to set environmental variables properly.
## usual
```
bfruntime gRPC server started on 0.0.0.0:50052

        ********************************************
        *      WARNING: Authorised Access Only     *
        ********************************************
    

bfshell> bfrt_python 
cwd : /home/cnsrl/bf-sde-9.7.0.10210-cpr

Devices found :  [0]
We've found 1 p4 programs for device 0:
switch_tofino2_y1
Creating tree for dev 0 and program switch_tofino2_y1

Python 3.8.10 (default, Mar 22 2023, 18:01:07) 
Type 'copyright', 'credits' or 'license' for more information
IPython 8.11.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]: 
...
```
Next, I try to set `PYTHONENV` variable in `.profile` but I get the same error.
Second, I try to add the code below in `/usr/lib/python3/dist-packages/apport_python_hook.py` because
the error occured in the file:
```python

import os
import sys


sys.path.append(os.path.join(os.path.dirname(__file__), '/home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/tools2'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/usr/lib/python3/dist-packages'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/usr/lib/python3.8/dist-packages'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/usr/lib/python3.8/lib-dynload'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/usr/lib/python3.8'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/usr/lib/python2.7/lib-dynload'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/lib-dynload'))
sys.path.append(os.path.join(os.path.dirname(__file__), '/home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/lib2to3'))
```
This file maybe read the python code first, so I set the environment variables but I got some errors like these:
```python
bfshell> bfrt_python 
Traceback (most recent call last):
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/bfrtcli.py", line 17, in <module>
    from bfrtTable import BfRtTable
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/bfrtTable.py", line 4, in <module>
    from netaddr import EUI as mac
ModuleNotFoundError: No module named 'netaddr'
Failed to load bfrtcli python library
bfrt_cli_cmd:197 could not initialize bf_rt for the cli. err: 1
bfshell> bfrt_python
context.c:54: warning: mpd_setminalloc: ignoring request to set MPD_MINALLOC a second time

Traceback (most recent call last):
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/bfrtcli.py", line 17, in <module>
    from bfrtTable import BfRtTable
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/bfrtTable.py", line 4, in <module>
    from netaddr import EUI as mac
ModuleNotFoundError: No module named 'netaddr'
Failed to load bfrtcli python library
bfrt_cli_cmd:197 could not initialize bf_rt for the cli. err: 1

```
You can resolve this excuting `sudo pip3 install netaddr`,
and
```python
bfshell> bfrt_python
cwd : /home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0

Devices found :  [0]
We've found 1 p4 programs for device 0:
test
Creating tree for dev 0 and program test

/usr/local/lib/python3.8/dist-packages/traitlets/traitlets.py:706: UserWarning: Config option `use_jedi` not recognized by `IPCompleter`.
  obj._notify_trait(self.name, old_value, new_value)
Python 3.8.10 (default, Mar 22 2023, 18:01:07) 
Type "copyright", "credits" or "license" for more information.

IPython 5.10.0 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object', use 'object??' for extra details.
[TerminalIPythonApp] WARNING | Error in loading extension: bfrtcli
Check your config files in /root/.ipython/profile_default
Traceback (most receIn [1]: nt call last):
  File "/usr/local/lib/python3.8/dist-packages/IPython/core/shellapp.py", line 248, in init_extensions
    self.shell.extension_manager.load_extension(ext)
  File "/usr/local/lib/python3.8/dist-packages/IPython/core/extensions.py", line 85, in load_extension
    if self._call_load_ipython_extension(mod):
  File "/usr/local/lib/python3.8/dist-packages/IPython/core/extensions.py", line 132, in _call_load_ipython_extension
    mod.load_ipython_extension(self.shell)
  File "/home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/bfrtcli.py", line 2217, in load_ipython_extension
    ipython.input_transformers_cleanup.append(input_transform)
AttributeError: 'TerminalInteractiveShell' object has no attribute 'input_transformers_cleanup'

```
This is because IPython is not latest version.
My python3 refer to the path `/usr/local/lib/python3.8/dist-packages` so I have to use `sudo pip(3) install IPython` not `pip(3) install IPython`. If you use `pip install`, the library may be installed in `/usr/lib/...`.
I ran the code below:
```bash
sudo pip uninstall ipython
sudo pip install ipython
```
Finally, got the latest version.
## Memo
```bash
/home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install.old/lib/python3.8/bfrtLearn.py
/home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install.old/lib/python3.8/bfrtTable.py
/home/user1/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install.old/lib/python3.8/bfrtcli.py
['',
 '/usr/lib/python38.zip',
 '/usr/lib/python3.8',
 '/usr/lib/python3.8/lib-dynload',
 '/usr/local/lib/python3.8/dist-packages',
 '/usr/lib/python3/dist-packages']

```
# Try to `run_tofino_model.sh and run_switchd.sh` in Ubuntu18.
## ldd [reference](https://www.silicloud.com/ja/blog/linux%E3%81%A7glibc%E3%81%AE%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E3%82%92%E3%82%A2%E3%83%83%E3%83%97%E3%82%B0%E3%83%AC%E3%83%BC%E3%83%89%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95/)[2](https://stackoverflow.com/questions/74740941/how-can-i-resolve-this-issue-libm-so-6-version-glibc-2-29-not-found-c-c)
I tried to update ldd
```bash
wget -4c https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.gz
tar -xf glibc-x.x.tar.gz
cd glibc-x.x
mkdir build
cd build
../configure --prefix=/usr/local/glibc-new
```
```bash
checking for gawk... no
```
```bash
sudo apt install gawk
../configure --prefix=/usr/local/glibc-new
make

```



```
  File "<stdin>", line 1, in <module>
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/site-packages/tofino/bfrt_grpc/client.py", line 27, in <module>
    import bfrt_grpc.bfruntime_pb2_grpc as bfruntime_pb2_grpc
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/site-packages/tofino/bfrt_grpc/bfruntime_pb2_grpc.py", line 4, in <module>
    import bfruntime_pb2 as bfruntime__pb2
  File "/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/site-packages/tofino/bfrt_grpc/bfruntime_pb2.py", line 6, in <module>
    from google.protobuf.internal import enum_type_wrapper
ModuleNotFoundError: No module named 'google.protobuf'

```

```
  NoCompression = cygrpc.CompressionAlgorithm.none
AttributeError: 'NoneType' object has no attribute 'none'


```

[./builer.py?](https://stackoverflow.com/questions/71759248/importerror-cannot-import-name-builder-from-google-protobuf-internal)

```python
Import Os
Import Sys
From Scapy.All Import *
Import Time

Count = 8
While True:
    Try:
        Count = (Count + 1)
        Tmp_ip = "10.0.0."+Str(Count)
        Print("Send To {} From Veth0".Format(Tmp_ip))
        P1 = Ether(Type=0x800)/Ip(Src="10.0.0.8", Dst=Tmp_ip)
        P1.Show()
        Sendp(P1, Iface="Veth0")
        Time.Sleep(1)
        If Count == 24:
            Count = 8
    Except Keyboardinterrupt:
        Print(" Stop.")
        Break
    

```