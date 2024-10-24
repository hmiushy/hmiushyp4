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
    

