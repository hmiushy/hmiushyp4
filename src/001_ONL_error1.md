Things to do before executing `./p4studio interactive`
---
- Check the Python version with `python -V` and confirm version 3. <br>
- Install python-pip3 with `sudo apt install python3-pip`. <br>
- Upgrade pip with `pip install -U pip` or `pip3 install -U pip`. <br>
- Install requirements with `pip install -r requirements.txt`. <br>
- Install `packaging` with `pip install packaging`. <br>
- Check the path of the BSP file and input it like this. <br>
  ![image](https://github.com/user-attachments/assets/a9bdf42a-b857-41d4-972d-d04421218241)
- Replace P4 file in `$SDE/pkgsrc/switch-p4-16/p4src/switch-tofino` to your P4 file. <br>
  I replace all folders in `$SDE/pkgsrc/switch-p4-16/p4src`.  <br>
  Note that make a backup, `$SDE/pkgsrc/switch-p4-16/p4src`.  <br>
  
Confirmations
---
- If you could get success the first time, you don't need to set `Y`. You should put `N` because installing dependencies takes a lot of time.
  ```
  ./p4studio interactive
  ```
  You get asking this question.
  ```
  Do you want to install dependencies? [Y/n]: Y → N
  ```
  You can check whether the results are successful or not.
  ![image](https://github.com/user-attachments/assets/918d7c47-edc5-465f-bf11-25e1bd85faa3)


Error: Problem occurred while installing pip3 dependencies <br>
----
  Answer: Executing `sudo apt install python3-pip`<be><br>
  ![image](https://github.com/user-attachments/assets/fe9bc0be-c5df-438a-b6c4-fb18d6d251df)<br>
  - You can check the log file `sde-****/p4studio/logs/p4studio_newest_file.log,` and find the error in more detail.
  ```bash
  ...                                                                                                   
  2024-10-24 05:33:19,998: OS dependencies installed
  2024-10-24 05:33:19,999: Installing pip3 dependencies...
  2024-10-24 05:33:19,999: Executing: sudo -E env pip3 install PyYAML Tenjin crc16 crcmod ctypesgen==1.0.1 getmac==0.8.2 ipaddress ipython~=5.10.0 jsl jsonschema==2.6.0 netifaces pack                                                                                                                                        aging==20.9 ply psutil pysubnettree scapy-helper setuptools==44.1.1 simplejson six>=1.12.0 xmlrunner doxypy
  2024-10-24 05:33:20,013: env: ‘pip3’: No such file or directory
  2024-10-24 05:33:20,014: Cmd 'sudo -E env pip3 install PyYAML Tenjin crc16 crcmod ctypesgen==1.0.1 getmac==0.8.2 ipaddress ipython~=5.10.0 jsl jsonschema==2.6.0 netifaces packaging=                                                                                                                                        =20.9 ply psutil pysubnettree scapy-helper setuptools==44.1.1 simplejson six>=1.12.0 xmlrunner doxypy' took: 0:00:00.014460

  ```
  In this example, you get the error when executing `sudo -E env pip3 ...` and resolve it by researching this command. <br>
  I can resolve this by doing `sudo apt install python3-pip`
    
Error: Problem occurred while installing thrift <br>
----
  p4studio.log<br>
  ```bash
  2024-10-24 05:47:57,581: Executing: env python3 /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/p4studio/dependencies/source/install_thrift.py --os-name Ubuntu --os-version 20.04 --jobs 8 --sde-install /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install --keyword apt-get --with-proto yes
  2024-10-24 05:48:07,754:         - Building thrift ...
  2024-10-24 05:48:07,756:                COMMAND: [wget http://archive.apache.org/dist/thrift/0.13.0/thrift-0.13.0.tar.gz -O thrift-0.13.0.tar.gz]
  2024-10-24 05:48:07,756:        ERROR: Failed to install thrift - Extraction of thrift failed, command - wget http://archive.apache.org/dist/thrift/0.13.0/thrift-0.13.0.tar.gz -O thrift-0.13.0.tar.gz, error - --2024-10-24 05:47:57--  http://archive.apache.org/dist/thrift/0.13.0/thrift-0.13.0.tar.gz
  2024-10-24 05:48:07,756: Resolving archive.apache.org (archive.apache.org)... failed: Temporary failure in name resolution.
  2024-10-24 05:48:07,757: wget: unable to resolve host address ‘archive.apache.org’
  2024-10-24 05:48:07,757:
  2024-10-24 05:48:07,764: Cmd 'env python3 /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/p4studio/dependencies/source/install_thrift.py --os-name Ubuntu --os-version 20.04 --jobs 8 --sde-install /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install --keyword apt-get --with-proto yes' took: 0:00:10.182233
  onie@ubuntu:~/9.7.0/p4studio$ Error: Problem occurred while installing thrift
  ```
  This is caused by a temporary error. Please run one more time. (一時的に実行できないだけだったので，もう一回実行するとうまくいった)
  
Error
----
  Run `pip install packaging`<be><br>
  ![image](https://github.com/user-attachments/assets/62435d70-1962-4bfc-bf6b-6821f5ed9d5f) <br>
  
  log<br>
  ```
  2024-10-24 06:41:40,453: bf-p4c: error: unrecognized arguments: --bf-rt-schema /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/p4-examples/p4_16_programs/tna_operations/tna_operations.p4
  2024-10-24 06:41:40,453: Traceback (most recent call last):
  2024-10-24 06:41:40,453:   File "/home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install/share/p4c/p4c_src/config.py", line 47, in load_from_config
  2024-10-24 06:41:40,453:     exec(compile(data, path, 'exec'), cfg_globals, None)
  2024-10-24 06:41:40,453:   File "/home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install/share/p4c/p4c_src/p4c.tofino.cfg", line 16, in <module>
  2024-10-24 06:41:40,453:     import p4c_src.barefoot as bfn
  2024-10-24 06:41:40,453:   File "/home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install/share/p4c/p4c_src/barefoot.py", line 21, in <module>
  2024-10-24 06:41:40,454:     from packaging import version
  2024-10-24 06:41:40,454: ModuleNotFoundError: No module named 'packaging'
  2024-10-24 06:41:40,454:
  2024-10-24 06:41:40,454: Traceback (most recent call last):
  2024-10-24 06:41:40,454:   File "/home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install/share/p4c/p4c_src/config.py", line 47, in load_from_config
  2024-10-24 06:41:40,454:     exec(compile(data, path, 'exec'), cfg_globals, None)
  2024-10-24 06:41:40,454:   File "/home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install/share/p4c/p4c_src/p4c.tofino2.cfg", line 16, in <module>
  2024-10-24 06:41:40,454:     import p4c_src.barefoot as bfn
  2024-10-24 06:41:40,454:   File "/home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install/share/p4c/p4c_src/barefoot.py", line 21, in <module>
  2024-10-24 06:41:40,454:     from packaging import version
  2024-10-24 06:41:40,454: ModuleNotFoundError: No module named 'packaging'
  2024-10-24 06:41:40,454:
  2024-10-24 06:41:40,459: make[3]: *** [pkgsrc/p4-examples/CMakeFiles/tna_operations-tofino.dir/build.make:62: pkgsrc/p4-examples/tna_operations/tofino/bf-rt.json] Error 2
  2024-10-24 06:41:40,459: make[2]: *** [CMakeFiles/Makefile2:10891: pkgsrc/p4-examples/CMakeFiles/tna_operations-tofino.dir/all] Error 2
  2024-10-24 06:41:40,460: make[1]: *** [CMakeFiles/Makefile2:10787: pkgsrc/p4-examples/CMakeFiles/p4-16-programs.dir/rule] Error 2
  2024-10-24 06:41:40,461: make: *** [Makefile:4311: p4-16-programs] Error 2
  2024-10-24 06:41:40,462: Cmd 'make --jobs=8 p4-16-programs x1_tofino' took: 0:04:53.220271

  ```


memo
```

2024-10-24 08:29:50,263: -- Build files have been written to: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/build
2024-10-24 08:29:50,296: Cmd 'cmake /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0 -DTOFINO=ON -DTOFINO2M=OFF -DASIC=ON -DTOFINO2=OFF -DTOFINO2H=OFF -DBF-DIAGS=ON -DSWITCH=ON -DBSP=ON -DCMAKE_BUILD_TYPE='relwithdebinfo' -DCMAKE_INSTALL_PREFIX='/home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install'' took: 0:00:03.750795
2024-10-24 08:29:50,297: SDE build configured.
2024-10-24 08:29:50,297:
2024-10-24 08:29:50,298: Building and installing SDE...
2024-10-24 08:29:50,299: Building...
2024-10-24 08:29:50,299: Executing: make --jobs=8 x1_tofino
2024-10-24 08:29:50,474: [100%] Built target bf-p4c
2024-10-24 08:29:50,494: Scanning dependencies of target x1_tofino
2024-10-24 08:29:50,514: [100%] Generating x1_compile
2024-10-24 08:30:19,453: warning: No size defined for table 'same_mac_check_same_mac_check', setting default size to 512
2024-10-24 08:30:19,453: warning: No size defined for table 'TE_det_vid', setting default size to 512
2024-10-24 08:30:19,456: warning: No size defined for table 'mirror_rewrite_pkt_length', setting default size to 512
2024-10-24 08:30:19,457: warning: No size defined for table 'dtel_ingress_port_conversion', setting default size to 512
2024-10-24 08:30:19,457: warning: No size defined for table 'dtel_egress_port_conversion', setting default size to 512
2024-10-24 08:30:19,457: warning: No size defined for table 'dtel_config_config', setting default size to 512
2024-10-24 08:30:52,099: warning: Tofino does not support clear-on-write semantic on re-assignment to field egress::eg_md.flags.bypass_egress in parser state egress::parse_cpu.
2024-10-24 08:30:52,099: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(958): warning: egress::eg_md.flags.bypass_egress has previous assignment in parser state egress::parse_bridged_pkt.
2024-10-24 08:30:52,099:         eg_md.flags.bypass_egress = true;
2024-10-24 08:30:52,099:         ^^^^^^^^^^^^^^^^^^^^^^^^^
2024-10-24 08:30:52,099: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(958): warning: egress::eg_md.flags.bypass_egress has previous assignment in parser state egress::parse_simple_mirrored_metadata.
2024-10-24 08:30:52,099:         eg_md.flags.bypass_egress = true;
2024-10-24 08:30:52,099:         ^^^^^^^^^^^^^^^^^^^^^^^^^
2024-10-24 08:30:53,476: [--Wwarn=invalid] warning: "hdr.bridged_md.base_qid": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,476: [--Wwarn=invalid] warning: "hdr.bridged_md.dtel_report_type": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,483: [--Wwarn=invalid] warning: "hdr.bridged_md.base_qid": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,486: [--Wwarn=invalid] warning: "hdr.bridged_md.base_qid": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,486: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_0": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,487: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_1": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,487: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_2": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,487: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_3": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,487: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_4": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:30:53,487: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_5": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:11,480: warning: Tofino does not support clear-on-write semantic on re-assignment to field egress::eg_md.flags.bypass_egress in parser state egress::parse_cpu.
2024-10-24 08:44:11,480: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(958): warning: egress::eg_md.flags.bypass_egress has previous assignment in parser state egress::parse_bridged_pkt.
2024-10-24 08:44:11,480:         eg_md.flags.bypass_egress = true;
2024-10-24 08:44:11,481:         ^^^^^^^^^^^^^^^^^^^^^^^^^
2024-10-24 08:44:11,481: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(958): warning: egress::eg_md.flags.bypass_egress has previous assignment in parser state egress::parse_simple_mirrored_metadata.
2024-10-24 08:44:11,481:         eg_md.flags.bypass_egress = true;
2024-10-24 08:44:11,481:         ^^^^^^^^^^^^^^^^^^^^^^^^^
2024-10-24 08:44:12,468: [--Wwarn=invalid] warning: "hdr.bridged_md.base_qid": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,468: [--Wwarn=invalid] warning: "hdr.bridged_md.dtel_report_type": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,473: [--Wwarn=invalid] warning: "hdr.bridged_md.base_qid": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,475: [--Wwarn=invalid] warning: "hdr.bridged_md.base_qid": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,475: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_0": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,475: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_1": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,475: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_2": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,475: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_3": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,475: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_4": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:44:12,475: [--Wwarn=invalid] warning: "hdr.bridged_md.__pad_5": No matching PHV field in the pipe `pipe'. Ignoring pragma.
2024-10-24 08:45:30,755: [100%] Built target x1_tofino
2024-10-24 08:45:30,767: Cmd 'make --jobs=8 x1_tofino' took: 0:15:40.467835
2024-10-24 08:45:30,768: Built successfully
2024-10-24 08:45:30,768: Installing...
2024-10-24 08:45:30,768: Executing: make --jobs=8 install
2024-10-24 08:45:30,860: Scanning dependencies of target bf-p4o
2024-10-24 08:45:30,861: Scanning dependencies of target bf-p4i
2024-10-24 08:45:30,878: [  0%] Creating directories for 'bf-p4o'
2024-10-24 08:45:30,879: Scanning dependencies of target libpython3.8
2024-10-24 08:45:30,881: [  2%] Built target bf-p4c
2024-10-24 08:45:30,881: [  2%] Built target build_tcmalloc
2024-10-24 08:45:30,881: [  2%] Creating directories for 'bf-p4i'
2024-10-24 08:45:30,881: [  3%] Built target ev_o
2024-10-24 08:45:30,887: [  6%] Built target zlog_o
2024-10-24 08:45:30,899: [  6%] Creating directories for 'libpython3.8'
2024-10-24 08:45:30,917: [  6%] Built target cjson_o
2024-10-24 08:45:30,918: [  6%] Built target bfsysutil_o
2024-10-24 08:45:30,919: [  6%] Built target dynhash_o
2024-10-24 08:45:30,927: [  6%] Built target JudyCommon
2024-10-24 08:45:30,955: [  6%] Built target JudySL
2024-10-24 08:45:30,957: [  7%] Built target Judy1
2024-10-24 08:45:30,959: [  7%] Built target build_edit
2024-10-24 08:45:30,971: [  7%] Built target JudyHS
2024-10-24 08:45:30,980: Scanning dependencies of target dynhashStatic
2024-10-24 08:45:30,991: [  7%] Built target xxhash_o
2024-10-24 08:45:30,992: [  9%] Built target tommyds_o
2024-10-24 08:45:30,996: [  9%] Building C object pkgsrc/bf-utils/src/dynamic_hash/CMakeFiles/dynhashStatic.dir/dynamic_hash.c.o
2024-10-24 08:45:31,011: [  9%] Performing download step for 'bf-p4i'
2024-10-24 08:45:31,015: [ 11%] Built target JudyL
2024-10-24 08:45:31,020: [ 11%] Performing download step for 'bf-p4o'
2024-10-24 08:45:31,026: [ 11%] Built target expat_o
2024-10-24 08:45:31,031: p4i.linux/LICENSE.electron.txt
2024-10-24 08:45:31,031: p4i.linux/LICENSES.chromium.html
2024-10-24 08:45:31,032: p4o-1.0/bin/
2024-10-24 08:45:31,032: p4o-1.0/bin/p4obfuscator
2024-10-24 08:45:31,040: [ 11%] No download step for 'libpython3.8'
2024-10-24 08:45:31,040: [ 11%] Building C object pkgsrc/bf-utils/src/dynamic_hash/CMakeFiles/dynhashStatic.dir/bfn_hash_algorithm.c.o
2024-10-24 08:45:31,053: Scanning dependencies of target bfshell_plugin_clish_o
2024-10-24 08:45:31,059: [ 21%] Built target bigcode_o
2024-10-24 08:45:31,070: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/builtin_init.c.o
2024-10-24 08:45:31,083: [ 21%] No patch step for 'libpython3.8'
2024-10-24 08:45:31,101: Scanning dependencies of target bfshell
2024-10-24 08:45:31,119: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell.dir/bin/bfshell.c.o
2024-10-24 08:45:31,127: [ 22%] No update step for 'libpython3.8'
2024-10-24 08:45:31,159: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/hook_access.c.o
2024-10-24 08:45:31,172: [ 22%] Performing configure step for 'libpython3.8'
2024-10-24 08:45:31,243: [ 28%] Built target clish_o
2024-10-24 08:45:31,300: [ 30%] Built target bf_google_protobuf_o
2024-10-24 08:45:31,309: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/hook_config.c.o
2024-10-24 08:45:31,339: p4o-1.0/share/
2024-10-24 08:45:31,340: p4o-1.0/share/p4o/
2024-10-24 08:45:31,340: p4o-1.0/share/p4o/README
2024-10-24 08:45:31,352: [ 30%] Linking C executable bfshell
2024-10-24 08:45:31,368: [ 30%] No patch step for 'bf-p4o'
2024-10-24 08:45:31,412: [ 30%] No update step for 'bf-p4o'
2024-10-24 08:45:31,415: [ 30%] Built target bf_google_grpc_o
2024-10-24 08:45:31,419: [ 30%] Built target bfshell
2024-10-24 08:45:31,435: Scanning dependencies of target status_pb2_grpc_py_target
2024-10-24 08:45:31,438: Scanning dependencies of target status_pb2_py_target
2024-10-24 08:45:31,440: Scanning dependencies of target code_pb2_py_target
2024-10-24 08:45:31,449: p4i.linux/chrome-sandbox
2024-10-24 08:45:31,450: p4i.linux/chrome_100_percent.pak
2024-10-24 08:45:31,453: p4i.linux/chrome_200_percent.pak
2024-10-24 08:45:31,454: [ 30%] Running gRPC and protobuf compiler on google/rpc/status.proto to generate python files
2024-10-24 08:45:31,454: [ 30%] No configure step for 'bf-p4o'
2024-10-24 08:45:31,455: [ 30%] Running gRPC and protobuf compiler on google/rpc/status.proto to generate python files
2024-10-24 08:45:31,468: [ 30%] Running gRPC and protobuf compiler on google/rpc/code.proto to generate python files
2024-10-24 08:45:31,473: [ 30%] Linking C static library ../../../../../install/lib/libdynhash.a
2024-10-24 08:45:31,474: p4i.linux/icudtl.dat
2024-10-24 08:45:31,499: [ 30%] No build step for 'bf-p4o'
2024-10-24 08:45:31,500: [ 30%] Built target status_pb2_py_target
2024-10-24 08:45:31,509: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/hook_log.c.o
2024-10-24 08:45:31,513: [ 30%] Built target code_pb2_py_target
2024-10-24 08:45:31,516: Scanning dependencies of target code_pb2_grpc_py_target
2024-10-24 08:45:31,526: [ 30%] Built target dynhashStatic
2024-10-24 08:45:31,528: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/sym_misc.c.o
2024-10-24 08:45:31,533: [ 30%] Built target code_pb2_grpc_py_target
2024-10-24 08:45:31,545: Scanning dependencies of target firmware_install
2024-10-24 08:45:31,545: [ 31%] No install step for 'bf-p4o'
2024-10-24 08:45:31,548: [ 32%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/sym_script.c.o
2024-10-24 08:45:31,583: [ 32%] Built target firmware_install
2024-10-24 08:45:31,592: [ 32%] Completed 'bf-p4o'
2024-10-24 08:45:31,627: [ 32%] Built target status_pb2_grpc_py_target
2024-10-24 08:45:31,631: [ 32%] Built target dvm_o
2024-10-24 08:45:31,665: [ 32%] Built target bf-p4o
2024-10-24 08:45:31,685: [ 36%] Built target lld_o
2024-10-24 08:45:31,700: [ 38%] Built target bfmc_mgr_o
2024-10-24 08:45:31,703: [ 38%] Built target bfshell_plugin_clish_o
2024-10-24 08:45:31,723: Scanning dependencies of target bfshell_plugin_pipemgr_o
2024-10-24 08:45:31,742: [ 38%] Built target bfpkt_mgr_o
2024-10-24 08:45:31,751: [ 38%] Built target knet_mgr_o
2024-10-24 08:45:31,757: [ 42%] Built target bftraffic_mgr_o
2024-10-24 08:45:31,759: Scanning dependencies of target bfruntime_pb2_py_target
2024-10-24 08:45:31,775: Scanning dependencies of target bfruntime_pb2_grpc_py_target
2024-10-24 08:45:31,780: [ 47%] Built target bfport_mgr_o
2024-10-24 08:45:31,782: [ 47%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfshell_plugin_pipemgr_o.dir/pipe_mgr_cli.c.o
2024-10-24 08:45:31,784: [ 47%] Generating python gRPC and protobuf files from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/src/bf_rt/proto/bfruntime.proto
2024-10-24 08:45:31,820: [ 47%] Built target ctx_json_o
2024-10-24 08:45:31,859: [ 48%] Generating python gRPC and protobuf files from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/src/bf_rt/proto/bfruntime.proto
2024-10-24 08:45:31,867: [ 48%] Built target bfruntime_pb2_py_target
2024-10-24 08:45:31,870: [ 53%] Built target bfrt_o
2024-10-24 08:45:31,878: [ 55%] Built target pdfixed_o
2024-10-24 08:45:31,907: [ 67%] Built target bfpipe_mgr_o
2024-10-24 08:45:31,919: [ 68%] Built target bf_pm_o
2024-10-24 08:45:31,943: [ 68%] Built target diag_o
2024-10-24 08:45:31,943: [ 68%] Built target bfshell_plugin_pipemgr_o
2024-10-24 08:45:31,958: [ 68%] Built target perf_o
2024-10-24 08:45:31,963: Scanning dependencies of target bf_kdrv
2024-10-24 08:45:31,979: [ 68%] Generating bf_kdrv.ko
2024-10-24 08:45:31,984: [ 68%] Built target driver_o
2024-10-24 08:45:31,993: Scanning dependencies of target bf_knet
2024-10-24 08:45:32,010: [ 68%] Generating bf_knet.ko
2024-10-24 08:45:32,020: [ 68%] Built target bfruntime_pb2_grpc_py_target
2024-10-24 08:45:32,063: Scanning dependencies of target bf_kpkt
2024-10-24 08:45:32,069: Scanning dependencies of target model
2024-10-24 08:45:32,074: Scanning dependencies of target pltfm_o
2024-10-24 08:45:32,090: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_intf_fifo.c.o
2024-10-24 08:45:32,094: [ 68%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_o.dir/drivers/src/bf_pltfm_mgr/pltfm_mgr_init.c.o
2024-10-24 08:45:32,096: Scanning dependencies of target dru_sim_o
2024-10-24 08:45:32,121: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_intf_fifo.c.o
2024-10-24 08:45:32,161: [ 68%] Generating bf_kpkt.ko
2024-10-24 08:45:32,222: p4i.linux/libEGL.so
2024-10-24 08:45:32,229: p4i.linux/libGLESv2.so
2024-10-24 08:45:32,237: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_mti.c.o
2024-10-24 08:45:32,276: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_mti.c.o
2024-10-24 08:45:32,304: [ 68%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_o.dir/drivers/src/bf_pltfm_mgr/pltfm_mgr_handlers.c.o
2024-10-24 08:45:32,438: [ 68%] Built target pltfm_o
2024-10-24 08:45:32,467: Scanning dependencies of target tcl_server_o
2024-10-24 08:45:32,486: [ 68%] Building C object pkgsrc/bf-platforms/CMakeFiles/tcl_server_o.dir/platforms/accton-bf/tcl_server/tcl_server.c.o
2024-10-24 08:45:32,677: [ 68%] Built target tcl_server_o
2024-10-24 08:45:32,732: Scanning dependencies of target accton_bin_srcs_o
2024-10-24 08:45:32,753: [ 68%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/platforms/accton-bf/src/bf_pltfm_cp2112/bf_pltfm_cp2112_intf.c.o
2024-10-24 08:45:32,756: p4i.linux/libffmpeg.so
2024-10-24 08:45:33,002: p4i.linux/libvk_swiftshader.so
2024-10-24 08:45:33,386: p4i.linux/libvulkan.so.1
2024-10-24 08:45:33,432: [ 68%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/platforms/accton-bf/src/bf_pltfm_bmc_tty/bmc_tty.c.o
2024-10-24 08:45:33,661: p4i.linux/locales/
2024-10-24 08:45:33,661: p4i.linux/locales/am.pak
2024-10-24 08:45:33,666: p4i.linux/locales/ar.pak
2024-10-24 08:45:33,670: p4i.linux/locales/bg.pak
2024-10-24 08:45:33,675: p4i.linux/locales/bn.pak
2024-10-24 08:45:33,683: [ 68%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_intf.c.o
2024-10-24 08:45:33,684: p4i.linux/locales/ca.pak
2024-10-24 08:45:33,687: p4i.linux/locales/cs.pak
2024-10-24 08:45:33,726: p4i.linux/locales/da.pak
2024-10-24 08:45:33,730: p4i.linux/locales/de.pak
2024-10-24 08:45:33,734: p4i.linux/locales/el.pak
2024-10-24 08:45:33,740: p4i.linux/locales/en-GB.pak
2024-10-24 08:45:33,744: p4i.linux/locales/en-US.pak
2024-10-24 08:45:33,748: p4i.linux/locales/es-419.pak
2024-10-24 08:45:33,752: p4i.linux/locales/es.pak
2024-10-24 08:45:33,757: p4i.linux/locales/et.pak
2024-10-24 08:45:33,793: p4i.linux/locales/fa.pak
2024-10-24 08:45:33,797: p4i.linux/locales/fi.pak
2024-10-24 08:45:33,801: p4i.linux/locales/fil.pak
2024-10-24 08:45:33,804: p4i.linux/locales/fr.pak
2024-10-24 08:45:33,809: p4i.linux/locales/gu.pak
2024-10-24 08:45:33,815: p4i.linux/locales/he.pak
2024-10-24 08:45:33,819: p4i.linux/locales/hi.pak
2024-10-24 08:45:33,855: p4i.linux/locales/hr.pak
2024-10-24 08:45:33,859: p4i.linux/locales/hu.pak
2024-10-24 08:45:33,863: p4i.linux/locales/id.pak
2024-10-24 08:45:33,866: p4i.linux/locales/it.pak
2024-10-24 08:45:33,870: p4i.linux/locales/ja.pak
2024-10-24 08:45:33,874: p4i.linux/locales/kn.pak
2024-10-24 08:45:33,910: p4i.linux/locales/ko.pak
2024-10-24 08:45:33,913: p4i.linux/locales/lt.pak
2024-10-24 08:45:33,917: p4i.linux/locales/lv.pak
2024-10-24 08:45:33,922: p4i.linux/locales/ml.pak
2024-10-24 08:45:33,931: p4i.linux/locales/mr.pak
2024-10-24 08:45:33,937: p4i.linux/locales/ms.pak
2024-10-24 08:45:33,956: [ 68%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_bd_eeprom.c.o
2024-10-24 08:45:33,977: p4i.linux/locales/nb.pak
2024-10-24 08:45:33,980: p4i.linux/locales/nl.pak
2024-10-24 08:45:33,984: p4i.linux/locales/pl.pak
2024-10-24 08:45:33,989: p4i.linux/locales/pt-BR.pak
2024-10-24 08:45:33,994: p4i.linux/locales/pt-PT.pak
2024-10-24 08:45:33,998: p4i.linux/locales/ro.pak
2024-10-24 08:45:34,002: p4i.linux/locales/ru.pak
2024-10-24 08:45:34,008: p4i.linux/locales/sk.pak
2024-10-24 08:45:34,019: In file included from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:56:
2024-10-24 08:45:34,020: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet_priv.h:75:32: error: field ‘link_ksettings’ has incomplete type
2024-10-24 08:45:34,020:    75 |  struct ethtool_link_ksettings link_ksettings;
2024-10-24 08:45:34,020:       |                                ^~~~~~~~~~~~~~
2024-10-24 08:45:34,040: p4i.linux/locales/sl.pak
2024-10-24 08:45:34,043: p4i.linux/locales/sr.pak
2024-10-24 08:45:34,045: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:631:37: warning: ‘struct ethtool_drvinfo’ declared inside parameter list will not be visible outside of this definition or declaration
2024-10-24 08:45:34,045:   631 |                              struct ethtool_drvinfo *info)
2024-10-24 08:45:34,045:       |                                     ^~~~~~~~~~~~~~~
2024-10-24 08:45:34,045: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c: In function ‘knet_get_drvinfo’:
2024-10-24 08:45:34,045: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:633:14: error: dereferencing pointer to incomplete type ‘struct ethtool_drvinfo’
2024-10-24 08:45:34,045:   633 |  strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
2024-10-24 08:45:34,045:       |              ^~
2024-10-24 08:45:34,046: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c: In function ‘bf_knet_hostif_get_link_ksettings’:
2024-10-24 08:45:34,046: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:642:44: error: dereferencing pointer to incomplete type ‘struct ethtool_link_ksettings’
2024-10-24 08:45:34,046:   642 |  memcpy(&priv->link_ksettings, cmd, sizeof(*cmd));
2024-10-24 08:45:34,046:       |                                            ^~~~
2024-10-24 08:45:34,046: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c: In function ‘bf_knet_hostif_set_link_ksettings’:
2024-10-24 08:45:34,046: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:650:44: error: dereferencing pointer to incomplete type ‘const struct ethtool_link_ksettings’
2024-10-24 08:45:34,046:   650 |  memcpy(&priv->link_ksettings, cmd, sizeof(*cmd));
2024-10-24 08:45:34,046:       |                                            ^~~~
2024-10-24 08:45:34,047: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c: At top level:
2024-10-24 08:45:34,047: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:666:21: error: variable ‘bf_knet_ethtool_ops’ has initializer but incomplete type
2024-10-24 08:45:34,047:   666 | static const struct ethtool_ops bf_knet_ethtool_ops = {
2024-10-24 08:45:34,047:       |                     ^~~~~~~~~~~
2024-10-24 08:45:34,047: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:668:3: error: ‘const struct ethtool_ops’ has no member named ‘get_link_ksettings’
2024-10-24 08:45:34,047:   668 |  .get_link_ksettings = bf_knet_hostif_get_link_ksettings,
2024-10-24 08:45:34,047:       |   ^~~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,047: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:668:24: warning: excess elements in struct initializer
2024-10-24 08:45:34,047:   668 |  .get_link_ksettings = bf_knet_hostif_get_link_ksettings,
2024-10-24 08:45:34,048:       |                        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,048: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:668:24: note: (near initialization for ‘bf_knet_ethtool_ops’)
2024-10-24 08:45:34,048: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:669:3: error: ‘const struct ethtool_ops’ has no member named ‘set_link_ksettings’
2024-10-24 08:45:34,048:   669 |  .set_link_ksettings = bf_knet_hostif_set_link_ksettings,
2024-10-24 08:45:34,048:       |   ^~~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,048: p4i.linux/locales/sv.pak
2024-10-24 08:45:34,048: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:669:24: warning: excess elements in struct initializer
2024-10-24 08:45:34,048:   669 |  .set_link_ksettings = bf_knet_hostif_set_link_ksettings,
2024-10-24 08:45:34,048:       |                        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,048: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:669:24: note: (near initialization for ‘bf_knet_ethtool_ops’)
2024-10-24 08:45:34,049: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:673:3: error: ‘const struct ethtool_ops’ has no member named ‘get_drvinfo’
2024-10-24 08:45:34,049:   673 |  .get_drvinfo  = knet_get_drvinfo,
2024-10-24 08:45:34,049:       |   ^~~~~~~~~~~
2024-10-24 08:45:34,049: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:673:18: warning: excess elements in struct initializer
2024-10-24 08:45:34,049:   673 |  .get_drvinfo  = knet_get_drvinfo,
2024-10-24 08:45:34,049:       |                  ^~~~~~~~~~~~~~~~
2024-10-24 08:45:34,049: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:673:18: note: (near initialization for ‘bf_knet_ethtool_ops’)
2024-10-24 08:45:34,049: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:674:3: error: ‘const struct ethtool_ops’ has no member named ‘get_link’
2024-10-24 08:45:34,049:   674 |  .get_link     = ethtool_op_get_link,
2024-10-24 08:45:34,050:       |   ^~~~~~~~
2024-10-24 08:45:34,051: p4i.linux/locales/sw.pak
2024-10-24 08:45:34,054: p4i.linux/locales/ta.pak
2024-10-24 08:45:34,062: p4i.linux/locales/te.pak
2024-10-24 08:45:34,100: p4i.linux/locales/th.pak
2024-10-24 08:45:34,106: p4i.linux/locales/tr.pak
2024-10-24 08:45:34,109: p4i.linux/locales/uk.pak
2024-10-24 08:45:34,114: p4i.linux/locales/vi.pak
2024-10-24 08:45:34,117: p4i.linux/locales/zh-CN.pak
2024-10-24 08:45:34,120: p4i.linux/locales/zh-TW.pak
2024-10-24 08:45:34,121: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:674:18: error: ‘ethtool_op_get_link’ undeclared here (not in a function)
2024-10-24 08:45:34,121:   674 |  .get_link     = ethtool_op_get_link,
2024-10-24 08:45:34,121:       |                  ^~~~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,121: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:674:18: warning: excess elements in struct initializer
2024-10-24 08:45:34,121: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:674:18: note: (near initialization for ‘bf_knet_ethtool_ops’)
2024-10-24 08:45:34,121: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:675:3: error: ‘const struct ethtool_ops’ has no member named ‘get_ts_info’
2024-10-24 08:45:34,121:   675 |  .get_ts_info  = ethtool_op_get_ts_info,
2024-10-24 08:45:34,122:       |   ^~~~~~~~~~~
2024-10-24 08:45:34,122: p4i.linux/p4i
2024-10-24 08:45:34,209: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:675:18: error: ‘ethtool_op_get_ts_info’ undeclared here (not in a function)
2024-10-24 08:45:34,209:   675 |  .get_ts_info  = ethtool_op_get_ts_info,
2024-10-24 08:45:34,209:       |                  ^~~~~~~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,209: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:675:18: warning: excess elements in struct initializer
2024-10-24 08:45:34,210: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:675:18: note: (near initialization for ‘bf_knet_ethtool_ops’)
2024-10-24 08:45:34,296: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2250:21: error: variable ‘knet_ethtool_ops’ has initializer but incomplete type
2024-10-24 08:45:34,296:  2250 | static const struct ethtool_ops knet_ethtool_ops = {
2024-10-24 08:45:34,297:       |                     ^~~~~~~~~~~
2024-10-24 08:45:34,297: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2251:6: error: ‘const struct ethtool_ops’ has no member named ‘get_drvinfo’
2024-10-24 08:45:34,297:  2251 |     .get_drvinfo = knet_get_drvinfo,
2024-10-24 08:45:34,297:       |      ^~~~~~~~~~~
2024-10-24 08:45:34,297: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2251:20: warning: excess elements in struct initializer
2024-10-24 08:45:34,297:  2251 |     .get_drvinfo = knet_get_drvinfo,
2024-10-24 08:45:34,297:       |                    ^~~~~~~~~~~~~~~~
2024-10-24 08:45:34,297: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2251:20: note: (near initialization for ‘knet_ethtool_ops’)
2024-10-24 08:45:34,298: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2252:6: error: ‘const struct ethtool_ops’ has no member named ‘get_msglevel’
2024-10-24 08:45:34,298:  2252 |     .get_msglevel = knet_get_msglevel,
2024-10-24 08:45:34,298:       |      ^~~~~~~~~~~~
2024-10-24 08:45:34,298: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2252:21: warning: excess elements in struct initializer
2024-10-24 08:45:34,298:  2252 |     .get_msglevel = knet_get_msglevel,
2024-10-24 08:45:34,298:       |                     ^~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,298: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2252:21: note: (near initialization for ‘knet_ethtool_ops’)
2024-10-24 08:45:34,299: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2253:6: error: ‘const struct ethtool_ops’ has no member named ‘set_msglevel’
2024-10-24 08:45:34,299:  2253 |     .set_msglevel = knet_set_msglevel,
2024-10-24 08:45:34,299:       |      ^~~~~~~~~~~~
2024-10-24 08:45:34,299: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2253:21: warning: excess elements in struct initializer
2024-10-24 08:45:34,299:  2253 |     .set_msglevel = knet_set_msglevel,
2024-10-24 08:45:34,299:       |                     ^~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,299: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2253:21: note: (near initialization for ‘knet_ethtool_ops’)
2024-10-24 08:45:34,308: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:666:33: error: storage size of ‘bf_knet_ethtool_ops’ isn’t known
2024-10-24 08:45:34,309:   666 | static const struct ethtool_ops bf_knet_ethtool_ops = {
2024-10-24 08:45:34,309:       |                                 ^~~~~~~~~~~~~~~~~~~
2024-10-24 08:45:34,309: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.c:2250:33: error: storage size of ‘knet_ethtool_ops’ isn’t known
2024-10-24 08:45:34,309:  2250 | static const struct ethtool_ops knet_ethtool_ops = {
2024-10-24 08:45:34,309:       |                                 ^~~~~~~~~~~~~~~~
2024-10-24 08:45:34,343: [ 68%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/drivers/src/bf_bd_cfg/bf_bd_cfg_intf.c.o
2024-10-24 08:45:34,379: make[4]: *** [scripts/Makefile.build:297: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/build/pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.o] Error 1
2024-10-24 08:45:34,379: make[3]: *** [Makefile:1910: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/build/pkgsrc/bf-drivers/kdrv/bf_knet] Error 2
2024-10-24 08:45:34,379: make[2]: *** [pkgsrc/bf-drivers/kdrv/bf_knet/CMakeFiles/bf_knet.dir/build.make:64: pkgsrc/bf-drivers/kdrv/bf_knet/bf_knet.ko] Error 2
2024-10-24 08:45:34,380: make[1]: *** [CMakeFiles/Makefile2:6067: pkgsrc/bf-drivers/kdrv/bf_knet/CMakeFiles/bf_knet.dir/all] Error 2
2024-10-24 08:45:34,380: make[1]: *** Waiting for unfinished jobs....
2024-10-24 08:45:34,766: [ 68%] Built target accton_bin_srcs_o
2024-10-24 08:45:35,909: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c: In function ‘bf_msix_mask_irq’:
2024-10-24 08:45:35,909: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:186:23: error: ‘struct msi_desc’ has no member named ‘masked’
2024-10-24 08:45:35,909:   186 |   u32 mask_bits = desc->masked;
2024-10-24 08:45:35,909:       |                       ^~
2024-10-24 08:45:35,910: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:196:24: error: ‘struct msi_desc’ has no member named ‘masked’
2024-10-24 08:45:35,910:   196 |   if (mask_bits != desc->masked) {
2024-10-24 08:45:35,910:       |                        ^~
2024-10-24 08:45:35,910: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:199:9: error: ‘struct msi_desc’ has no member named ‘masked’
2024-10-24 08:45:35,910:   199 |     desc->masked = mask_bits;
2024-10-24 08:45:35,910:       |         ^~
2024-10-24 08:45:35,943: In file included from ./include/linux/kernel.h:19,
2024-10-24 08:45:35,943:                  from ./arch/x86/include/asm/percpu.h:27,
2024-10-24 08:45:35,943:                  from ./arch/x86/include/asm/current.h:6,
2024-10-24 08:45:35,943:                  from ./include/linux/sched.h:12,
2024-10-24 08:45:35,943:                  from ./include/linux/ratelimit.h:6,
2024-10-24 08:45:35,943:                  from ./include/linux/dev_printk.h:16,
2024-10-24 08:45:35,943:                  from ./include/linux/device.h:15,
2024-10-24 08:45:35,943:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:33:
2024-10-24 08:45:35,943: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c: In function ‘bf_pci_probe’:
2024-10-24 08:45:35,944: ./include/linux/printk.h:450:44: warning: this statement may fall through [-Wimplicit-fallthrough=]
2024-10-24 08:45:35,944:   450 | #define printk(fmt, ...) printk_index_wrap(_printk, fmt, ##__VA_ARGS__)
2024-10-24 08:45:35,944:       |                                            ^
2024-10-24 08:45:35,944: ./include/linux/printk.h:422:3: note: in definition of macro ‘printk_index_wrap’
2024-10-24 08:45:35,944:   422 |   _p_func(_fmt, ##__VA_ARGS__);    \
2024-10-24 08:45:35,944:       |   ^~~~~~~
2024-10-24 08:45:35,944: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:1135:9: note: in expansion of macro ‘printk’
2024-10-24 08:45:35,944:  1135 |         printk(KERN_ERR "bf error allocating MSIX vectors. Trying MSI...\n");
2024-10-24 08:45:35,944:       |         ^~~~~~
2024-10-24 08:45:35,944: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:1141:5: note: here
2024-10-24 08:45:35,944:  1141 |     case BF_INTR_MODE_MSI:
2024-10-24 08:45:35,944:       |     ^~~~
2024-10-24 08:45:35,945: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:1167:10: warning: this statement may fall through [-Wimplicit-fallthrough=]
2024-10-24 08:45:35,945:  1167 |       if (num_irq > 0) {
2024-10-24 08:45:35,945:       |          ^
2024-10-24 08:45:35,945: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:1180:5: note: here
2024-10-24 08:45:35,945:  1180 |     case BF_INTR_MODE_LEGACY:
2024-10-24 08:45:35,945:       |     ^~~~
2024-10-24 08:45:35,945: In file included from ./include/linux/kernel.h:19,
2024-10-24 08:45:35,945:                  from ./arch/x86/include/asm/percpu.h:27,
2024-10-24 08:45:35,945:                  from ./arch/x86/include/asm/current.h:6,
2024-10-24 08:45:35,945:                  from ./include/linux/sched.h:12,
2024-10-24 08:45:35,945:                  from ./include/linux/ratelimit.h:6,
2024-10-24 08:45:35,946:                  from ./include/linux/dev_printk.h:16,
2024-10-24 08:45:35,946:                  from ./include/linux/device.h:15,
2024-10-24 08:45:35,946:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:33:
2024-10-24 08:45:35,946: ./include/linux/printk.h:450:44: warning: this statement may fall through [-Wimplicit-fallthrough=]
2024-10-24 08:45:35,946:   450 | #define printk(fmt, ...) printk_index_wrap(_printk, fmt, ##__VA_ARGS__)
2024-10-24 08:45:35,946:       |                                            ^
2024-10-24 08:45:35,946: ./include/linux/printk.h:422:3: note: in definition of macro ‘printk_index_wrap’
2024-10-24 08:45:35,946:   422 |   _p_func(_fmt, ##__VA_ARGS__);    \
2024-10-24 08:45:35,946:       |   ^~~~~~~
2024-10-24 08:45:35,946: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:1188:7: note: in expansion of macro ‘printk’
2024-10-24 08:45:35,946:  1188 |       printk(KERN_NOTICE " bf PCI INTx mask not supported\n");
2024-10-24 08:45:35,946:       |       ^~~~~~
2024-10-24 08:45:35,946: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.c:1191:5: note: here
2024-10-24 08:45:35,946:  1191 |     case BF_INTR_MODE_NONE:
2024-10-24 08:45:35,946:       |     ^~~~
2024-10-24 08:45:35,960: make[4]: *** [scripts/Makefile.build:297: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/build/pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.o] Error 1
2024-10-24 08:45:35,960: make[3]: *** [Makefile:1910: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/build/pkgsrc/bf-drivers/kdrv/bf_kdrv] Error 2
2024-10-24 08:45:35,961: make[2]: *** [pkgsrc/bf-drivers/kdrv/bf_kdrv/CMakeFiles/bf_kdrv.dir/build.make:64: pkgsrc/bf-drivers/kdrv/bf_kdrv/bf_kdrv.ko] Error 2
2024-10-24 08:45:35,961: make[1]: *** [CMakeFiles/Makefile2:6013: pkgsrc/bf-drivers/kdrv/bf_kdrv/CMakeFiles/bf_kdrv.dir/all] Error 2
2024-10-24 08:45:36,897: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_parse.c.o
2024-10-24 08:45:36,965: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_sim.c.o
2024-10-24 08:45:37,643: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_parse.c.o
2024-10-24 08:45:38,534: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dma_sim_intf.c.o
2024-10-24 08:45:38,777: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_sim.c.o
2024-10-24 08:45:38,785: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_intf_tcp.c.o
2024-10-24 08:45:38,917: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/__/lld/lld_dr_regs_tof2.c.o
2024-10-24 08:45:39,072: [ 68%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/__/lld/lld_dr_regs_tof.c.o
2024-10-24 08:45:39,218: [ 69%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/__/lld/lld_dr_regs.c.o
2024-10-24 08:45:41,832: [ 69%] Linking C static library ../../../../../install/lib/libmodel.a
2024-10-24 08:45:42,003: [ 69%] Built target model
2024-10-24 08:45:42,351: [ 69%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dma_sim_intf.c.o
2024-10-24 08:45:42,623: [ 69%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_intf_tcp.c.o
2024-10-24 08:45:43,680: [ 69%] Built target dru_sim_o
2024-10-24 08:45:45,820: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c: In function ‘bf_msix_mask_irq’:
2024-10-24 08:45:45,820: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:186:23: error: ‘struct msi_desc’ has no member named ‘masked’
2024-10-24 08:45:45,821:   186 |   u32 mask_bits = desc->masked;
2024-10-24 08:45:45,821:       |                       ^~
2024-10-24 08:45:45,821: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:196:24: error: ‘struct msi_desc’ has no member named ‘masked’
2024-10-24 08:45:45,821:   196 |   if (mask_bits != desc->masked) {
2024-10-24 08:45:45,821:       |                        ^~
2024-10-24 08:45:45,821: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:199:9: error: ‘struct msi_desc’ has no member named ‘masked’
2024-10-24 08:45:45,821:   199 |     desc->masked = mask_bits;
2024-10-24 08:45:45,822:       |         ^~
2024-10-24 08:45:45,855: In file included from ./include/linux/kernel.h:19,
2024-10-24 08:45:45,855:                  from ./arch/x86/include/asm/percpu.h:27,
2024-10-24 08:45:45,856:                  from ./arch/x86/include/asm/current.h:6,
2024-10-24 08:45:45,856:                  from ./include/linux/sched.h:12,
2024-10-24 08:45:45,856:                  from ./include/linux/ratelimit.h:6,
2024-10-24 08:45:45,856:                  from ./include/linux/dev_printk.h:16,
2024-10-24 08:45:45,857:                  from ./include/linux/device.h:15,
2024-10-24 08:45:45,857:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:33:
2024-10-24 08:45:45,857: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c: In function ‘bf_pci_probe’:
2024-10-24 08:45:45,857: ./include/linux/printk.h:450:44: error: this statement may fall through [-Werror=implicit-fallthrough=]
2024-10-24 08:45:45,857:   450 | #define printk(fmt, ...) printk_index_wrap(_printk, fmt, ##__VA_ARGS__)
2024-10-24 08:45:45,858:       |                                            ^
2024-10-24 08:45:45,858: ./include/linux/printk.h:422:3: note: in definition of macro ‘printk_index_wrap’
2024-10-24 08:45:45,858:   422 |   _p_func(_fmt, ##__VA_ARGS__);    \
2024-10-24 08:45:45,858:       |   ^~~~~~~
2024-10-24 08:45:45,858: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:1135:9: note: in expansion of macro ‘printk’
2024-10-24 08:45:45,858:  1135 |         printk(KERN_ERR "bf error allocating MSIX vectors. Trying MSI...\n");
2024-10-24 08:45:45,859:       |         ^~~~~~
2024-10-24 08:45:45,859: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:1141:5: note: here
2024-10-24 08:45:45,859:  1141 |     case BF_INTR_MODE_MSI:
2024-10-24 08:45:45,859:       |     ^~~~
2024-10-24 08:45:45,859: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:1167:10: error: this statement may fall through [-Werror=implicit-fallthrough=]
2024-10-24 08:45:45,859:  1167 |       if (num_irq > 0) {
2024-10-24 08:45:45,859:       |          ^
2024-10-24 08:45:45,860: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:1180:5: note: here
2024-10-24 08:45:45,860:  1180 |     case BF_INTR_MODE_LEGACY:
2024-10-24 08:45:45,860:       |     ^~~~
2024-10-24 08:45:45,860: In file included from ./include/linux/kernel.h:19,
2024-10-24 08:45:45,860:                  from ./arch/x86/include/asm/percpu.h:27,
2024-10-24 08:45:45,860:                  from ./arch/x86/include/asm/current.h:6,
2024-10-24 08:45:45,861:                  from ./include/linux/sched.h:12,
2024-10-24 08:45:45,861:                  from ./include/linux/ratelimit.h:6,
2024-10-24 08:45:45,861:                  from ./include/linux/dev_printk.h:16,
2024-10-24 08:45:45,861:                  from ./include/linux/device.h:15,
2024-10-24 08:45:45,861:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:33:
2024-10-24 08:45:45,861: ./include/linux/printk.h:450:44: error: this statement may fall through [-Werror=implicit-fallthrough=]
2024-10-24 08:45:45,861:   450 | #define printk(fmt, ...) printk_index_wrap(_printk, fmt, ##__VA_ARGS__)
2024-10-24 08:45:45,862:       |                                            ^
2024-10-24 08:45:45,862: ./include/linux/printk.h:422:3: note: in definition of macro ‘printk_index_wrap’
2024-10-24 08:45:45,862:   422 |   _p_func(_fmt, ##__VA_ARGS__);    \
2024-10-24 08:45:45,862:       |   ^~~~~~~
2024-10-24 08:45:45,862: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:1188:7: note: in expansion of macro ‘printk’
2024-10-24 08:45:45,862:  1188 |       printk(KERN_NOTICE " bf PCI INTx mask not supported\n");
2024-10-24 08:45:45,863:       |       ^~~~~~
2024-10-24 08:45:45,863: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.c:1191:5: note: here
2024-10-24 08:45:45,863:  1191 |     case BF_INTR_MODE_NONE:
2024-10-24 08:45:45,863:       |     ^~~~
2024-10-24 08:45:45,863: cc1: all warnings being treated as errors
2024-10-24 08:45:45,868: make[4]: *** [scripts/Makefile.build:297: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/build/pkgsrc/bf-drivers/kdrv/bf_kpkt/../bf_kdrv/bf_kdrv.o] Error 1
2024-10-24 08:45:45,869: make[4]: *** Waiting for unfinished jobs....
2024-10-24 08:45:46,348: make[3]: *** [Makefile:1910: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/build/pkgsrc/bf-drivers/kdrv/bf_kpkt] Error 2
2024-10-24 08:45:46,349: make[2]: *** [pkgsrc/bf-drivers/kdrv/bf_kpkt/CMakeFiles/bf_kpkt.dir/build.make:64: pkgsrc/bf-drivers/kdrv/bf_kpkt/bf_kpkt.ko] Error 2
2024-10-24 08:45:46,350: make[1]: *** [CMakeFiles/Makefile2:6121: pkgsrc/bf-drivers/kdrv/bf_kpkt/CMakeFiles/bf_kpkt.dir/all] Error 2
2024-10-24 08:45:49,146: p4i.linux/resources/
2024-10-24 08:45:49,146: p4i.linux/resources.pak
2024-10-24 08:45:49,602: p4i.linux/resources/app.asar
2024-10-24 08:45:52,746: p4i.linux/snapshot_blob.bin
2024-10-24 08:45:52,749: p4i.linux/swiftshader/
2024-10-24 08:45:52,749: p4i.linux/swiftshader/libEGL.so
2024-10-24 08:45:52,762: p4i.linux/swiftshader/libGLESv2.so
2024-10-24 08:45:52,914: p4i.linux/v8_context_snapshot.bin
2024-10-24 08:45:52,926: p4i.linux/vk_swiftshader_icd.json
2024-10-24 08:45:52,949: [ 69%] No update step for 'bf-p4i'
2024-10-24 08:45:52,950: [ 69%] No patch step for 'bf-p4i'
2024-10-24 08:45:53,032: [ 69%] No configure step for 'bf-p4i'
2024-10-24 08:45:53,074: [ 69%] No build step for 'bf-p4i'
2024-10-24 08:45:53,109: [ 69%] Performing install step for 'bf-p4i'
2024-10-24 08:45:53,137: [ 69%] Completed 'bf-p4i'
2024-10-24 08:45:53,198: [ 69%] Built target bf-p4i
2024-10-24 08:46:17,700: [ 69%] Performing build step for 'libpython3.8'
2024-10-24 08:46:17,706: make[3]: warning: -j8 forced in submake: resetting jobserver mode.
2024-10-24 08:46:50,237: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/_testcapimodule.c: In function ‘PyInit__testcapi’:
2024-10-24 08:46:50,237: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/_testcapimodule.c:6328:5: warning: ‘tp_print’ is deprecated [-Wdeprecated-declarations]
2024-10-24 08:46:50,237:  6328 |     MyList_Type.tp_print = 0;
2024-10-24 08:46:50,237:       |     ^~~~~~~~~~~
2024-10-24 08:46:50,238: In file included from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Include/object.h:746,
2024-10-24 08:46:50,238:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Include/pytime.h:6,
2024-10-24 08:46:50,238:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Include/Python.h:85,
2024-10-24 08:46:50,238:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/_testcapimodule.c:15:
2024-10-24 08:46:50,238: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Include/cpython/object.h:260:30: note: declared here
2024-10-24 08:46:50,238:   260 |     Py_DEPRECATED(3.8) int (*tp_print)(PyObject *, FILE *, int);
2024-10-24 08:46:50,238:       |                              ^~~~~~~~
2024-10-24 08:46:50,240: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/_testcapimodule.c: In function ‘test_buildvalue_issue38913’:
2024-10-24 08:46:50,241: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/_testcapimodule.c:6463:15: warning: variable ‘res’ set but not used [-Wunused-but-set-variable]
2024-10-24 08:46:50,241:  6463 |     PyObject *res;
2024-10-24 08:46:50,241:       |               ^~~
2024-10-24 08:46:53,871: In file included from /usr/include/string.h:495,
2024-10-24 08:46:53,871:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Include/Python.h:30,
2024-10-24 08:46:53,871:                  from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/socketmodule.c:103:
2024-10-24 08:46:53,871: In function ‘memset’,
2024-10-24 08:46:53,871:     inlined from ‘getsockaddrarg’ at /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/socketmodule.c:2288:9,
2024-10-24 08:46:53,871:     inlined from ‘sock_bind’ at /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/socketmodule.c:3066:10:
2024-10-24 08:46:53,871: /usr/include/x86_64-linux-gnu/bits/string_fortified.h:71:10: warning: ‘__builtin_memset’ offset [17, 88] from the object at ‘addrbuf’ is out of the bounds of referenced subobject ‘sa’ with type ‘struct sockaddr’ at offset 0 [-Warray-bounds]
2024-10-24 08:46:53,871:    71 |   return __builtin___memset_chk (__dest, __ch, __len, __bos0 (__dest));
2024-10-24 08:46:53,871:       |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2024-10-24 08:47:02,266: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/_ctypes/callbacks.c: In function ‘_ctypes_alloc_callback’:
2024-10-24 08:47:02,266: /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/_ctypes/callbacks.c:433:9: warning: ‘ffi_prep_closure’ is deprecated: use ffi_prep_closure_loc instead [-Wdeprecated-declarations]
2024-10-24 08:47:02,266:   433 |         result = ffi_prep_closure(p->pcl_write, &p->cif, closure_fcn, p);
2024-10-24 08:47:02,266:       |         ^~~~~~
2024-10-24 08:47:02,266: In file included from /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/pkgsrc/bf-utils/third-party/cpython/Modules/_ctypes/callbacks.c:6:
2024-10-24 08:47:02,266: /usr/include/x86_64-linux-gnu/ffi.h:334:1: note: declared here
2024-10-24 08:47:02,267:   334 | ffi_prep_closure (ffi_closure*,
2024-10-24 08:47:02,267:       | ^~~~~~~~~~~~~~~~
2024-10-24 08:47:11,036: [ 69%] Performing install step for 'libpython3.8'
2024-10-24 08:47:11,042: make[3]: warning: jobserver unavailable: using -j1.  Add '+' to parent make rule.
2024-10-24 08:47:29,451: Looking in links: .
2024-10-24 08:47:29,473: Processing ./backcall-0.2.0-py2.py3-none-any.whl
2024-10-24 08:47:29,487: Processing ./decorator-5.0.9-py3-none-any.whl
2024-10-24 08:47:29,500: Processing ./ipython-7.18.1-py3-none-any.whl
2024-10-24 08:47:29,517: Processing ./ipython_genutils-0.2.0-py2.py3-none-any.whl
2024-10-24 08:47:29,530: Processing ./jedi-0.18.0-py2.py3-none-any.whl
2024-10-24 08:47:29,562: Processing ./netaddr-0.8.0-py2.py3-none-any.whl
2024-10-24 08:47:29,575: Processing ./parso-0.8.2-py2.py3-none-any.whl
2024-10-24 08:47:29,589: Processing ./pexpect-4.8.0-py2.py3-none-any.whl
2024-10-24 08:47:29,601: Processing ./pickleshare-0.7.5-py2.py3-none-any.whl
2024-10-24 08:47:29,614: Processing ./prompt_toolkit-3.0.19-py3-none-any.whl
2024-10-24 08:47:29,629: Processing ./ptyprocess-0.7.0-py2.py3-none-any.whl
2024-10-24 08:47:29,641: Processing ./Pygments-2.9.0-py3-none-any.whl
2024-10-24 08:47:29,657: Processing ./tabulate-0.8.9-py3-none-any.whl
2024-10-24 08:47:29,671: Processing ./traitlets-5.0.5-py3-none-any.whl
2024-10-24 08:47:29,697: Processing ./wcwidth-0.2.5-py2.py3-none-any.whl
2024-10-24 08:47:29,752: Requirement already satisfied: setuptools>=18.5 in /home/onie/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/python3.8/site-packages (from ipython==7.18.1->-r bf-python.requirements.txt (line 3)) (56.0.0)
2024-10-24 08:47:29,946: Installing collected packages: wcwidth, ptyprocess, parso, ipython-genutils, traitlets, Pygments, prompt-toolkit, pickleshare, pexpect, jedi, decorator, backcall, tabulate, netaddr, ipython
2024-10-24 08:47:34,421: Successfully installed Pygments-2.9.0 backcall-0.2.0 decorator-5.0.9 ipython-7.18.1 ipython-genutils-0.2.0 jedi-0.18.0 netaddr-0.8.0 parso-0.8.2 pexpect-4.8.0 pickleshare-0.7.5 prompt-toolkit-3.0.19 ptyprocess-0.7.0 tabulate-0.8.9 traitlets-5.0.5 wcwidth-0.2.5
2024-10-24 08:47:34,527: [ 69%] Completed 'libpython3.8'
2024-10-24 08:47:34,594: [ 69%] Built target libpython3.8
2024-10-24 08:47:34,596: make: *** [Makefile:130: all] Error 2
2024-10-24 08:47:34,596: Cmd 'make --jobs=8 install' took: 0:02:03.827871
onie@ubuntu:~/barefoot-sde-9.7.0/bf-sde-9.7.0/p4studio$

```

