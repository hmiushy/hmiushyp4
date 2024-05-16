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

## Resolution 2: the problem `2024-05-11 05:51:37.642962 BF_PLTFM ERROR - Error unable to find cdc_ethernet port`
Next, I want to fix this problem. <br> <br>
1. Copy `pkgsrc`
I copied `pkgsrc` of `bf-sde-9.7.0.10210-cpr` and replaced it with this file.
and run (`./build.sh -p angel_eye -u switch`) the code with certain lines commented out as shown below:
```bash
...
# echo ==== Pack $(basename $BSP)/packages/bf-platforms-$SDE_VERSION.tgz ====
# cd $BSP
# tar -vzcf $BSP/packages/bf-platforms-$SDE_VERSION.tgz bf-platforms-$SDE_VERSION

# echo ==== Pack $(basename $BSP).tgz =====
# cd $PROJECT_DIR
# tar -vzcf $BSP.tgz $(basename $BSP)

# echo ==== Pack SDE Packages =====
# cd $SDE/packages
# SDE_PACKAGES=("p4-compilers-9.7.0" "tofino-model-9.7.0" "p4-examples-9.7.0" "ptf-modules-9.7.0" "switch-p4-16-9.7.0" "bf-syslibs-9.7.0" "bf-diags-9.7.0" "bf-drivers-9.7.0" "p4o-1.0" "bf-utils-9.7.0" "p4i-9.7.0")
# for d in ${SDE_PACKAGES[@]}; do
#     echo "$d"
#     tar -zcf $SDE/packages/$d.tgz $d
# done

# Build Tofino 2 Profile
cd $SDE/p4studio
# echo Clean p4studio environment
# ./p4studio clean -y
# rm -rf $SDE/pkgsrc
# echo Start to Build Platform: $PLATFORM , Chip: ${CHIP_ARCH} with $USER_PROFILE
# echo ./install-p4studio-dependencies.sh
# ./install-p4studio-dependencies.sh
# echo ./p4studio dependencies install
# ./p4studio dependencies install
# echo ./p4studio packages extract
# ./p4studio packages extract
echo ./p4studio configure --bsp-path $BSP.tgz $USER_PROFILE asic $PLATFORM_NAME $CHIP_ARCH
./p4studio configure --bsp-path $BSP.tgz $USER_PROFILE asic $PLATFORM_NAME $CHIP_ARCH
echo ./p4studio build $TARGET
./p4studio build $TARGET
...
```
I already get p4 dependencies before runnning, so comment out these lines.
A few hours later... <br>
I cannot resolve the problem. <br> <br>
Next, copy `install` folder.
I tried to copy install folder in bf-sde.9.7.0.10210-cpr to my vm environment.
Finally, it works... Maybe, there are some errors at binary file of something into `$SDE_INSTALL` 
### Memo
Normally, when `./run_tofino_model.sh -p switch_tofino2_y1 --arch Tofino2` is executed and `./run_switchd.sh -p switch_tofino2_y1 --arch Tofino2` is executed, the following is displayed on `./run_tofino_model.sh`'s terminal.
```bash
...
Adding interface veth250 as port 2
Simulation target: Asic Model
Using TCP port range: 8001-8004
Listen socket created
bind done on port 8001. Listening..
Waiting for incoming connections...
CLI listening on port 8000
Connection accepted on port 8001
Client socket created
Connected on port 8002
INFO: DRU sim MTI initialized successfully
Tofino Verification Model - Version a2e46ca-dirty
Created 1 packet processing threads
:-:-:<0,-,0>:Waiting for packets to process
LOGS captured in: ./model_20240510_212217.log
:05-10 21:22:45.144120:    PORT UP asic 0 port 2
LOGS captured in: ./model_20240510_212217.log
:05-10 21:22:45.144144:    Setting logging fn
:05-10 21:22:45.144163:    Registering handler for tx
Opening p4 target config file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/p4/targets/tofino2/switch_tofino2_y1.conf' ...
:05-10 21:22:45.144174:    PORT UP asic 0 port 8
:05-10 21:22:45.144183:    PORT UP asic 0 port 9
:05-10 21:22:45.144190:    PORT UP asic 0 port 10
Loaded p4 target config file
:05-10 21:22:45.144197:    PORT UP asic 0 port 11
Device 0: Pipe 0: loading P4 name lookup file share/tofino2pd/switch_tofino2_y1/pipe/context.json found in /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/p4/targets/tofino2/switch_tofino2_y1.conf
Opening context file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json' ...
:05-10 21:22:45.144207:    PORT UP asic 0 port 12
:05-10 21:22:45.144217:    PORT UP asic 0 port 13
:05-10 21:22:45.144225:    PORT UP asic 0 port 14
:05-10 21:22:45.144233:    PORT UP asic 0 port 15
:05-10 21:22:45.144239:    PORT UP asic 0 port 16
:05-10 21:22:45.144246:    PORT UP asic 0 port 17
:05-10 21:22:45.144253:    PORT UP asic 0 port 18
:05-10 21:22:45.144262:    PORT UP asic 0 port 19
:05-10 21:22:45.144268:    PORT UP asic 0 port 20
:05-10 21:22:45.144275:    PORT UP asic 0 port 21
:05-10 21:22:45.144281:    PORT UP asic 0 port 22
:05-10 21:22:45.144288:    PORT UP asic 0 port 23
:05-10 21:22:45.144294:    PORT UP asic 0 port 24
Loaded context file
Device 0: Pipe 1: loading P4 name lookup file share/tofino2pd/switch_tofino2_y1/pipe/context.json found in /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/p4/targets/tofino2/switch_tofino2_y1.conf
Opening context file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json' ...
Loaded context file
Device 0: Pipe 2: loading P4 name lookup file share/tofino2pd/switch_tofino2_y1/pipe/context.json found in /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/p4/targets/tofino2/switch_tofino2_y1.conf
Opening context file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json' ...
Loaded context file
Device 0: Pipe 3: loading P4 name lookup file share/tofino2pd/switch_tofino2_y1/pipe/context.json found in /home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/p4/targets/tofino2/switch_tofino2_y1.conf
Opening context file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json' ...
Loaded context file
:05-10 21:22:45.302084:     Updating model log flags: clearing 0xffffffff ffffffff, setting 0x00000000 0000000f
:05-10 21:22:45.306296:    :-:-:<0,0,0>:Updating p4 log flags: clearing 0xffffffff ffffffff, setting 0x00000000 0000007f
:05-10 21:22:45.310592:    :-:-:<0,0,0>:Updating tofino log flags: clearing 0xffffffff ffffffff, setting 0x00000000 0000007f
:05-10 21:22:45.314841:    :-:-:<0,0,0>:Updating packet log flags: clearing 0xffffffff ffffffff, setting 0x00000000 0000007f
Dropping excess privileges...
:05-10 21:22:45.482255:    :-:-:<0,0,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-10 21:22:45.482299:    :-:-:<0,0,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-10 21:22:45.482605:    :-:-:<0,1,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-10 21:22:45.482619:    :-:-:<0,1,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-10 21:22:45.482925:    :-:-:<0,2,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-10 21:22:45.482938:    :-:-:<0,2,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-10 21:22:45.483244:    :-:-:<0,3,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-10 21:22:45.483256:    :-:-:<0,3,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
Reg channel closed. Restart reg connection...
Reg thread termination requested..
DRU thread terminating..
Reg thread calling harlyn_lld_re_init
Re-Init link to bf-drivers...
Listen socket created
bind done on port 8001. Listening..
Waiting for incoming connections...
Connection accepted on port 8001
Client socket created
Connected on port 8002
INFO: DRU MTI already initialized
Re-Init link to bf-drivers...done
Reg thread terminating..
:05-11 16:25:09.939478:    :-:-:<0,-,0>:Begin packet processing
:05-11 16:25:09.939519:    :-:-:<0,-,0>:Chip=0 Thread=0 Pipe=*: PktsIn=0 PktsOut=0 PktsTOT=0  Waits=6855
Tofino Verification Model - Version a2e46ca-dirty
Opening context file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json' ...
Loaded context file
Opening context file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json' ...
Loaded context file
Opening context file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json' ...
Loaded context file
Opening context file '/home/cnsrl/bf-sde-9.7.0.10210-cpr/install/share/tofino2pd/switch_tofino2_y1/pipe/context.json' ...
Loaded context file
Created 1 packet processing threads
:05-11 16:25:10.531875:    :-:-:<0,-,0>:Waiting for packets to process
:05-11 16:25:10.868241:    :-:-:<0,0,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-11 16:25:10.868286:    :-:-:<0,0,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-11 16:25:10.868606:    :-:-:<0,1,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-11 16:25:10.868618:    :-:-:<0,1,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-11 16:25:10.868933:    :-:-:<0,2,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-11 16:25:10.868944:    :-:-:<0,2,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-11 16:25:10.869263:    :-:-:<0,3,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
:05-11 16:25:10.869276:    :-:-:<0,3,->:LearningFilter::clear : Excessive clearing of filter 1 !!! Nothing to clear
Reg channel closed. Restart reg connection...
Reg thread termination requested..
DRU thread terminating..
Reg thread calling harlyn_lld_re_init
Re-Init link to bf-drivers...
Listen socket created
bind done on port 8001. Listening..
Waiting for incoming connections...
^C:05-13 09:57:12.412511:    PORT DOWN asic 0 port 2
:05-13 09:57:12.412629:    PORT DOWN asic 0 port 8
:05-13 09:57:12.412652:    PORT DOWN asic 0 port 9
:05-13 09:57:12.412669:    PORT DOWN asic 0 port 10
:05-13 09:57:12.412684:    PORT DOWN asic 0 port 11
:05-13 09:57:12.412699:    PORT DOWN asic 0 port 12
:05-13 09:57:12.412714:    PORT DOWN asic 0 port 13
:05-13 09:57:12.412728:    PORT DOWN asic 0 port 14
:05-13 09:57:12.412744:    PORT DOWN asic 0 port 15
:05-13 09:57:12.412758:    PORT DOWN asic 0 port 16
:05-13 09:57:12.412772:    PORT DOWN asic 0 port 17
:05-13 09:57:12.412805:    PORT DOWN asic 0 port 18
:05-13 09:57:12.412819:    PORT DOWN asic 0 port 19
:05-13 09:57:12.412834:    PORT DOWN asic 0 port 20
:05-13 09:57:12.412848:    PORT DOWN asic 0 port 21
:05-13 09:57:12.412862:    PORT DOWN asic 0 port 22
:05-13 09:57:12.412876:    PORT DOWN asic 0 port 23
:05-13 09:57:12.412891:    PORT DOWN asic 0 port 24
:05-13 09:57:13.017234:    :-:-:<0,-,0>:Begin packet processing
:05-13 09:57:13.017342:    :-:-:<0,-,0>:Chip=0 Thread=0 Pipe=*: PktsIn=0 PktsOut=0 PktsTOT=0  Waits=14952
done
```
