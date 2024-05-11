## Error 2 executing `run_switchd.sh`

I got error below:
```bash
Using SDE /home/build/src/bf-sde-9.7.0
Using SDE_INSTALL /home/build/src/bf-sde-9.7.0/install
Setting up DMA Memory Pool
sysctl: setting key "vm.nr_hugepages": Read-only file system
sysctl: setting key "vm.nr_hugepages": Read-only file system
sysctl: setting key "vm.nr_hugepages": Read-only file system
sysctl: setting key "vm.nr_hugepages": Read-only file system
sysctl: setting key "vm.nr_hugepages": Read-only file system
sysctl: setting key "vm.nr_hugepages": Read-only file system
sysctl: setting key "vm.nr_hugepages": Read-only file system
mount: /mnt/huge: permission denied.
Using TARGET_CONFIG_FILE /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino2/switch_tofino2_y1.conf
Using PATH /home/build/src/bf-sde-9.7.0/install/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/build/src/bf-sde-9.7.0/install/bin:/home/build/src/bf-sde-9.7.0/install/bin:/home/build/src/bf-sde-9.7.0/install/bin
Using LD_LIBRARY_PATH /usr/local/lib:/home/build/src/bf-sde-9.7.0/install/lib:
bf_sysfs_fname /sys/class/bf/bf0/device/dev_add
Install dir: /home/build/src/bf-sde-9.7.0/install (0x5632eca54420)
bf_switchd: system services initialized
bf_switchd: loading conf_file /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino2/switch_tofino2_y1.conf...
bf_switchd: processing device configuration...
Configuration for dev_id 0
  Family        : tofino2
  pci_sysfs_str : /sys/devices/pci0000:00/0000:00:03.0/0000:05:00.0
  pci_domain    : 0
  pci_bus       : 5
  pci_fn        : 0
  pci_dev       : 0
  pci_int_mode  : 1
  sbus_master_fw: /home/build/src/bf-sde-9.7.0/install/
  pcie_fw       : /home/build/src/bf-sde-9.7.0/install/
  serdes_fw     : /home/build/src/bf-sde-9.7.0/install/
  sds_fw_path   : /home/build/src/bf-sde-9.7.0/install/share/tofino_sds_fw/avago/firmware
  microp_fw_path: 
bf_switchd: processing P4 configuration...
P4 profile for dev_id 0
num P4 programs 1
  p4_name: switch_tofino2_y1
  p4_pipeline_name: pipe
    libpd: 
    libpdthrift: 
    context: /home/build/src/bf-sde-9.7.0/build/p4-build/tofino2/diag/diag/tofino2/pipe/context.json
    config: /home/build/src/bf-sde-9.7.0/build/p4-build/tofino2/diag/diag/tofino2/pipe/tofino2.bin
  Pipes in scope [0 1 2 3 ]
  diag: 
  accton diag: 
  Agent[0]: /home/build/src/bf-sde-9.7.0/install/lib/libpltfm_mgr.so
  non_default_port_ppgs: 0
  SAI default initialize: 1 
bf_switchd: library /home/build/src/bf-sde-9.7.0/install/lib/libpltfm_mgr.so loaded
bf_switchd: agent[0] initialized
2024-05-11 05:51:37.642962 BF_PLTFM ERROR - Error unable to find cdc_ethernet port

CHSS MGMT ERROR: Failed to configure cdc_eth ipv6
Operational mode set to ASIC
Initialized the device types using platforms infra API
ASIC detected at PCI /sys/class/bf/bf0/device
ERROR getting ASIC pci device id fpr /sys/class/bf/bf0/device
bf_switchd: drivers initialized
error opening /dev/bf0
ERROR: Device mmap failed for dev_id 0
Please load driver with bf_kdrv_mod_load script. Exiting.. 
ERROR: bf_switchd_device_add failed(No system resources) for dev_id 0

bf_switchd: initialized 0 devices
bf_switchd: spawning cli server thread
bf_switchd: spawning driver shell
bf_switchd: server started - listening on port 9999
bfruntime gRPC server started on 0.0.0.0:50052

        ********************************************
        *      WARNING: Authorised Access Only     *
        ********************************************
    

bfshell> 

```
## Resolution 1: the problem `mount: : permission denied.`
I want to resolve the problem below:
```bash
...
sysctl: setting key "vm.nr_hugepages": Read-only file system
sysctl: setting key "vm.nr_hugepages": Read-only file system
mount: /mnt/huge: permission denied.
...
```
Run the code below.
```bash
docker run --cap-add=NET_ADMIN -it --privileged -v ${PROJECT_DIR}:/home/build/src --name debian-stretch-sde-${USER}-970-2 debian:build-docker-new
```
Not this code:
```bash
docker run --cap-add=NET_ADMIN -it -v ${PROJECT_DIR}:/home/build/src --name debian-stretch-sde-${USER}-970-2 debian:build-docker-new
```
`--privileged` means creating a container with all root privileges to the host computer. Might not be very desirable...