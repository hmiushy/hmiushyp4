## Usual
"""bash
Using SDE /home/cnsrl/bf-sde-9.7.0.10210-cpr
Using SDE_INSTALL /home/cnsrl/bf-sde-9.7.0.10210-cpr/install
Setting up DMA Memory Pool
Using TARGET_CONFIG_FILE /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/p4/targets/tofino2/switch_tofino2_y1.conf
Using PATH /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/bin:/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/bin:/tools/Xilinx/Vitis_HLS/2020.2/bin:/tools/Xilinx/Model_Composer/2020.2/bin:/tools/Xilinx/Vivado/2020.2/bin:/tools/Xilinx/DocNav:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
Using LD_LIBRARY_PATH /usr/local/lib:/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib:
bf_sysfs_fname /sys/class/bf/bf0/device/dev_add
Install dir: /home/cnsrl/bf-sde-9.7.0.10210-cpr/install (0x559fe72cebd0)
bf_switchd: system services initialized
bf_switchd: loading conf_file /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/p4/targets/tofino2/switch_tofino2_y1.conf...
bf_switchd: processing device configuration...
Configuration for dev_id 0
  Family        : tofino2
  pci_sysfs_str : /sys/devices/pci0000:00/0000:00:03.0/0000:05:00.0
  pci_domain    : 0
  pci_bus       : 5
  pci_fn        : 0
  pci_dev       : 0
  pci_int_mode  : 1
  sbus_master_fw: /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/
  pcie_fw       : /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/
  serdes_fw     : /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/
  sds_fw_path   : /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino_sds_fw/avago/firmware
  microp_fw_path: 
bf_switchd: processing P4 configuration...
P4 profile for dev_id 0
num P4 programs 1
  p4_name: switch_tofino2_y1
  p4_pipeline_name: pipe
    libpd: 
    libpdthrift: 
    context: /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json
    config: /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/tofino2.bin
  Pipes in scope [0 1 2 3 ]
  diag: 
  accton diag: 
  Agent[0]: /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/lib/libpltfm_mgr.so
  non_default_port_ppgs: 0
  SAI default initialize: 1 
Operational mode set to default: MODEL
Starting PD-API RPC server on port 9090
bf_switchd: drivers initialized
bf_switchd: initializing dru_sim service
bf_switchd: library libdru_sim.so loaded
INFO: DRU sim MTI initialized successfully
dru_sim: client socket created
dru_sim: connected on port 8001
dru_sim: listen socket created
dru_sim: bind done on port 8002, listening...
dru_sim: waiting for incoming connections...
dru_sim: connection accepted on port 8002
dru_sim: DRU simulator running
-2024-05-10 21:22:46.192062 BF_BFRT ERROR - getStartBit:3090 ERROR eg_md.flags.ctag_flag Context json node not found for the key field. Hence unable to determine the start bit
2024-05-10 21:22:46.192110 BF_BFRT ERROR - keyByteSizeAndOffsetGet:1330 pipe.SwitchEgress.vlan_xlate.c_tag ERROR key field name eg_md.flags.ctag_flag not found in match_key_field_name_to_position_map 
2024-05-10 21:22:46.192117 BF_BFRT ERROR - parseTable:1870 pipe.SwitchEgress.vlan_xlate.c_tag ERROR in processing key field eg_md.flags.ctag_flag while trying to get field size and offset
2024-05-10 21:22:46.192165 BF_BFRT ERROR - getStartBit:3090 ERROR hdr.vlan_tag$0.$valid Context json node not found for the key field. Hence unable to determine the start bit
2024-05-10 21:22:46.192170 BF_BFRT ERROR - keyByteSizeAndOffsetGet:1330 pipe.SwitchEgress.vlan_xlate.set_ether_type ERROR key field name hdr.vlan_tag$0.$valid not found in match_key_field_name_to_position_map 
2024-05-10 21:22:46.192175 BF_BFRT ERROR - parseTable:1870 pipe.SwitchEgress.vlan_xlate.set_ether_type ERROR in processing key field hdr.vlan_tag$0.$valid while trying to get field size and offset
2024-05-10 21:22:46.193551 BF_BFRT ERROR - getStartBit:3090 ERROR hdr.tcp.$valid Context json node not found for the key field. Hence unable to determine the start bit
2024-05-10 21:22:46.193565 BF_BFRT ERROR - keyByteSizeAndOffsetGet:1330 pipe.SwitchIngress.pkt_validation.validate_other ERROR key field name hdr.tcp.$valid not found in match_key_field_name_to_position_map 
2024-05-10 21:22:46.193570 BF_BFRT ERROR - parseTable:1870 pipe.SwitchIngress.pkt_validation.validate_other ERROR in processing key field hdr.tcp.$valid while trying to get field size and offset

bf_switchd: dev_id 0 initialized

bf_switchd: initialized 1 devices
bf_switchd: spawning cli server thread
bf_switchd: spawning driver shell
bf_switchd: server started - listening on port 9999
bfruntime gRPC server started on 0.0.0.0:50052

        ********************************************
        *      WARNING: Authorised Access Only     *
        ********************************************
    

bfshell> 
"""