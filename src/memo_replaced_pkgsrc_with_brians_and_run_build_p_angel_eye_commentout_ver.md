# ./build.sh -p angel_eye -u switch
## code

```bash
#!/bin/bash
source .env
function print_help(){
  echo "USAGE: $(basename ""$0"") [OPTIONS]"
  echo "Options for build:"
  echo "  -h "
  echo "    help"
  echo "  -p <platform_name>"
  echo "    build platform name"
  echo "  -u <user_profile>"
  echo "    profile switch/diags/all"
  exit 0
}
trap 'exit' ERR

[ -z ${SDE} ] && echo "Environment variable SDE not set" && exit 1
[ -z ${SDE_INSTALL} ] && echo "Environment variable SDE_INSTALL not set" && exit 1

echo "Using SDE ${SDE}"
echo "Using SDE_INSTALL ${SDE_INSTALL}"

opts=`getopt -o hp:u: -- "$@"`
if [ $? != 0 ]; then
  exit 1
fi
eval set -- "$opts"

PROFILE=diags
HELP=false
while true; do
    case "$1" in
      -h) HELP=true; shift 1;;
      -p) PLATFORM=$2; shift 2;;
      -u) PROFILE=$2; shift 2;;
      --) shift; break;;
    esac
done

if [ $HELP = true ]; then
  print_help
fi

if [ "$PLATFORM" = "x308" ] || [ "$PLATFORM" = "x312" ]
then
    CHIP_ARCH=tofino
elif [ "$PLATFORM" = "angel_eye" ] 
then
    CHIP_ARCH=tofino2
    PLATFORM_NAME=newport
elif [ "$PLATFORM" = "snd12000" ] 
then
    CHIP_ARCH=tofino2
    PLATFORM_NAME=snd12000
elif [ "$PLATFORM" = "snd9510" ]
then
    CHIP_ARCH=tofino2
    PLATFORM_NAME=snd9510
else
    echo Platform $PLATFORM not support
    exit 1
fi

if [ "$PROFILE" = "diags" ]
then
    USER_PROFILE=bf-diags
elif [ "$PROFILE" = "switch" ]
then
    USER_PROFILE=switch
    TARGET=y1_tofino2
elif ["$PROFILE" = "all" ]
then
    USER_PROFILE=all_profile
else
    echo User Profile not support $PROFILE
    exit 1
fi

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

cd $SDE/tools/sonic

echo ==== ./make_platform_deb.sh ====
./make_platform_deb.sh
echo ==== ./make_sde_deb.sh ====
./make_sde_deb.sh

```
## Output
```bash
Using SDE /home/build/src/bf-sde-9.7.0
Using SDE_INSTALL /home/build/src/bf-sde-9.7.0/install
./p4studio configure --bsp-path /home/build/src/bf-reference-bsp-9.7.0.tgz switch asic newport tofino2
Configuring SDE build...
Installing BSP from /home/build/src/bf-reference-bsp-9.7.0.tgz
debug: Executing: tar xf /home/build/src/bf-reference-bsp-9.7.0.tgz -C /tmp/tmpdk1ytebp --strip-components 1
debug: Cmd 'tar xf /home/build/src/bf-reference-bsp-9.7.0.tgz -C /tmp/tmpdk1ytebp --strip-components 1' took: 0:00:00.580040
debug: Executing: tar xf /tmp/tmpdk1ytebp/packages/bf-platforms-9.7.0.tgz -C /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms --strip-components 1
debug: Cmd 'tar xf /tmp/tmpdk1ytebp/packages/bf-platforms-9.7.0.tgz -C /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms --strip-components 1' took: 0:00:00.405201
debug: Executing: cmake /home/build/src/bf-sde-9.7.0 -DSWITCH=ON -DASIC=ON -DNEWPORT=ON -DTOFINO2=ON -DBSP=ON -DCMAKE_BUILD_TYPE='relwithdebinfo' -DCMAKE_INSTALL_PREFIX='/home/build/src/bf-sde-9.7.0/install'
debug: --
debug: Begin bf-syslibs setup
debug: --
debug: Begin bf-utils setup
debug: --
debug: Begin bf-drivers setup
debug: Building drivers third_party
debug: -- Could NOT find Doxypy (missing: DOXYPY_EXECUTABLE)
debug: CMake Warning at pkgsrc/bf-drivers/src/bf_rt/CMakeLists.txt:293 (message):
debug:   Doxypy is needed to build BFRT gRPC python client documentation.  Please
debug:   install doxypy.


debug: -- Kernel release (uname -r): 4.19.0-14-amd64
debug: -- Kernel headers: /usr/src/linux-headers-4.19.0-14-amd64
debug: --
debug: Begin bf-platforms setup
debug: --
debug: Begin switch-p4-16 setup
debug: --
debug: Begin p4-examples setup
debug: -- Configuring done
debug: -- Generating done
debug: -- Build files have been written to: /home/build/src/bf-sde-9.7.0/build
debug: Cmd 'cmake /home/build/src/bf-sde-9.7.0 -DSWITCH=ON -DASIC=ON -DNEWPORT=ON -DTOFINO2=ON -DBSP=ON -DCMAKE_BUILD_TYPE='relwithdebinfo' -DCMAKE_INSTALL_PREFIX='/home/build/src/bf-sde-9.7.0/install'' took: 0:00:15.293231
SDE build configured.
./p4studio build y1_tofino2
Building and installing SDE...
Building...
debug: Executing: make --jobs=5 y1_tofino2
debug: Built target bf-p4c
debug: Generating y1_compile
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(662): [--Wwarn=unused] warning: Table tcp is not used; removing
debug:     table tcp {
debug:           ^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(34): [--Wwarn=unused] warning: inner2_ipv4_checksum: unused instance
debug:     Checksum() inner2_ipv4_checksum;
debug:                ^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(1493): [--Wwarn=unused] warning: inner_ipv4_checksum: unused instance
debug:     Checksum() inner_ipv4_checksum;
debug:                ^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/port.p4(279): [--Wwarn=unused] warning: Table cpu_to_bd_mapping is not used; removing
debug:     table cpu_to_bd_mapping {
debug:           ^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/port.p4(302): [--Wwarn=unused] warning: Table peer_link is not used; removing
debug:     table peer_link {
debug:           ^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/qos.p4(166): [--Wwarn=unused] warning: Table exp_tc_map is not used; removing
debug:     table exp_tc_map {
debug:           ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(814): [--Wwarn=unused] warning: int_edge: unused instance
debug:     IntEdge() int_edge;
debug:               ^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(538): [--Wwarn=unused] warning: sample_packet: unused instance
debug:     RegisterAction<switch_acl_sample_info_t, bit<8>, bit<1>>(samplers) sample_packet = {
debug:                                                                        ^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(285): [--Wwarn=uninitialized_out_param] warning: out parameter 'acl_nexthop' may be uninitialized when 'IngressIpAcl' terminates
debug:                      out switch_nexthop_t acl_nexthop)(
debug:                                           ^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(284)
debug: control IngressIpAcl(inout switch_ingress_metadata_t ig_md,
debug:         ^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(345): [--Wwarn=uninitialized_out_param] warning: out parameter 'acl_nexthop' may be uninitialized when 'IngressIpv4Acl' terminates
debug:                      out switch_nexthop_t acl_nexthop)(
debug:                                           ^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(344)
debug: control IngressIpv4Acl(inout switch_ingress_metadata_t ig_md,
debug:         ^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(412): [--Wwarn=uninitialized_out_param] warning: out parameter 'acl_nexthop' may be uninitialized when 'IngressIpv6Acl' terminates
debug:                      out switch_nexthop_t acl_nexthop)(
debug:                                           ^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(411)
debug: control IngressIpv6Acl(inout switch_ingress_metadata_t ig_md,
debug:         ^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(539): [--Wwarn=uninitialized_out_param] warning: out parameter 'flag' may be uninitialized when 'apply' terminates
debug:         void apply(inout switch_acl_sample_info_t reg, out bit<1> flag) {
debug:                                                                   ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(539)
debug:         void apply(inout switch_acl_sample_info_t reg, out bit<1> flag) {
debug:              ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(530): [--Wwarn=uninitialized_out_param] warning: out parameter 'acl_nexthop' may be uninitialized when 'IngressIpDtelSampleAcl' terminates
debug:                          out switch_nexthop_t acl_nexthop)(
debug:                                               ^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(529)
debug: control IngressIpDtelSampleAcl(inout switch_ingress_metadata_t ig_md,
debug:         ^^^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(872): [--Wwarn=uninitialized_use] warning: copp_meter_id may be uninitialized
debug:             copp_meter_id : ternary;
debug:             ^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(1158): [--Wwarn=uninitialized_use] warning: copp_color may be uninitialized
debug:             copp_color : exact;
debug:             ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(1159): [--Wwarn=uninitialized_use] warning: copp_meter_id may be uninitialized
debug:             copp_meter_id : exact;
debug:             ^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(1034): [--Wwarn=uninitialized_out_param] warning: out parameter 'eg_intr_md_for_dprsr' may be uninitialized when 'EgressSystemAcl' terminates
debug:         out egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr)(
debug:                                                      ^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(1030)
debug: control EgressSystemAcl(
debug:         ^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/l2.p4(170): [--Wwarn=uninitialized_use] warning: src_miss may be uninitialized
debug:             src_miss : exact;
debug:             ^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/l2.p4(171): [--Wwarn=uninitialized_use] warning: src_move may be uninitialized
debug:             src_move : ternary;
debug:             ^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(30): [--Wwarn=uninitialized_out_param] warning: out parameter 'ig_md' may be uninitialized when 'SwitchIngressParser' terminates
debug:         out switch_ingress_metadata_t ig_md,
debug:                                       ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(27)
debug: parser SwitchIngressParser(
debug:        ^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(669): [--Wwarn=uninitialized_out_param] warning: out parameter 'eg_md' may be uninitialized when 'SwitchEgressParser' terminates
debug:         out switch_egress_metadata_t eg_md,
debug:                                      ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/parde.p4(666)
debug: parser SwitchEgressParser(
debug:        ^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(532): [--Wwarn=uninitialized_use] warning: eg_intr_md_for_dprsr.mtu_trunc_len may be uninitialized
debug:         eg_md.pkt_length = eg_md.pkt_length |-| (bit<16>)eg_intr_md_for_dprsr.mtu_trunc_len;
debug:                                                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(533): [--Wwarn=uninitialized_use] warning: eg_intr_md_for_dprsr.mtu_trunc_len may be uninitialized
debug:         if (eg_md.pkt_length > 0 && eg_intr_md_for_dprsr.mtu_trunc_len > 0) {
debug:                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(496): [--Wwarn=uninitialized_use] warning: eg_intr_md_for_dprsr.mtu_trunc_len may be uninitialized
debug:         hdr.ipv4.total_len = (bit<16>)eg_intr_md_for_dprsr.mtu_trunc_len - 16w18;
debug:                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(498): [--Wwarn=uninitialized_use] warning: eg_intr_md_for_dprsr.mtu_trunc_len may be uninitialized
debug:         hdr.udp.length = (bit<16>)eg_intr_md_for_dprsr.mtu_trunc_len - 16w38;
debug:                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(501): [--Wwarn=uninitialized_use] warning: eg_intr_md_for_dprsr.mtu_trunc_len may be uninitialized
debug:         hdr.dtel.report_length = (bit<16>)eg_intr_md_for_dprsr.mtu_trunc_len -
debug:                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(40): [--Wwarn=uninitialized_out_param] warning: out parameter 'eg_intr_md_for_dprsr' may be uninitialized when 'MirrorRewrite' terminates
debug:                       out egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr)(
debug:                                                                    ^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(38)
debug: control MirrorRewrite(inout switch_header_t hdr,
debug:         ^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/port.p4(442): [--Wwarn=uninitialized_out_param] warning: out parameter 'egress_port' may be uninitialized when 'LAG' terminates
debug:             out switch_port_t egress_port) {
debug:                               ^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/port.p4(440)
debug: control LAG(inout switch_ingress_metadata_t ig_md,
debug:         ^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/qos.p4(77): [--Wwarn=uninitialized_out_param] warning: out parameter 'flag' may be uninitialized when 'PFCWd' terminates
debug:                out bool flag)(
debug:                         ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/qos.p4(75)
debug: control PFCWd(in switch_port_t port,
debug:         ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/meter.p4(44): [--Wwarn=uninitialized_out_param] warning: out parameter 'flag' may be uninitialized when 'StormControl' terminates
debug:                      out bool flag)(
debug:                               ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/meter.p4(42)
debug: control StormControl(inout switch_ingress_metadata_t ig_md,
debug:         ^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/wred.p4(152): [--Wwarn=uninitialized_use] warning: wred_flag may be uninitialized
debug:         if (!eg_md.flags.bypass_egress && wred_flag == 1) {
debug:                                           ^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/wred.p4(93): [--Wwarn=uninitialized_use] warning: index may be uninitialized
debug:             index : exact;
debug:             ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/wred.p4(134): [--Wwarn=uninitialized_use] warning: wred_drop may be uninitialized
debug:             wred_drop : exact;
debug:             ^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/wred.p4(109): [--Wwarn=uninitialized_use] warning: index may be uninitialized
debug:             index : exact;
debug:             ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/wred.p4(34): [--Wwarn=uninitialized_out_param] warning: out parameter 'wred_drop' may be uninitialized when 'WRED' terminates
debug:              out bool wred_drop) {
debug:                       ^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/wred.p4(31)
debug: control WRED(inout switch_header_t hdr,
debug:         ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(191): [--Wwarn=uninitialized_out_param] warning: out parameter 'flag' may be uninitialized when 'apply' terminates
debug:         void apply(inout switch_queue_alert_threshold_t reg, out bit<1> flag) {
debug:                                                                         ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(191)
debug:         void apply(inout switch_queue_alert_threshold_t reg, out bit<1> flag) {
debug:              ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(228): [--Wwarn=uninitialized_use] warning: quota_ may be uninitialized
debug:             reg.counter = (bit<32>) quota_[15:0];
debug:                                     ^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(233): [--Wwarn=uninitialized_out_param] warning: out parameter 'flag' may be uninitialized when 'apply' terminates
debug:         void apply(inout switch_queue_report_quota_t reg, out bit<1> flag) {
debug:                                                                      ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(233)
debug:         void apply(inout switch_queue_report_quota_t reg, out bit<1> flag) {
debug:              ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(250): [--Wwarn=uninitialized_out_param] warning: out parameter 'flag' may be uninitialized when 'apply' terminates
debug:         void apply(inout switch_queue_report_quota_t reg, out bit<1> flag) {
debug:                                                                      ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(250)
debug:         void apply(inout switch_queue_report_quota_t reg, out bit<1> flag) {
debug:              ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(275): [--Wwarn=uninitialized_use] warning: qalert may be uninitialized
debug:             qalert : exact;
debug:             ^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(182): [--Wwarn=uninitialized_out_param] warning: out parameter 'qalert' may be uninitialized when 'QueueReport' terminates
debug:                     out bit<1> qalert) {
debug:                                ^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(180)
debug: control QueueReport(inout switch_egress_metadata_t eg_md,
debug:         ^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(318): [--Wwarn=uninitialized_use] warning: digest may be uninitialized
debug:             } else if (reg == digest) {
debug:                               ^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(321): [--Wwarn=uninitialized_use] warning: digest may be uninitialized
debug:             reg = digest;
debug:                   ^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(315): [--Wwarn=uninitialized_out_param] warning: out parameter 'rv' may be uninitialized when 'apply' terminates
debug:         void apply(inout bit<16> reg, out bit<2> rv) {
debug:                                                  ^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(315)
debug:         void apply(inout bit<16> reg, out bit<2> rv) {
debug:              ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(330): [--Wwarn=uninitialized_use] warning: digest may be uninitialized
debug:             } else if (reg == digest) {
debug:                               ^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(333): [--Wwarn=uninitialized_use] warning: digest may be uninitialized
debug:             reg = digest;
debug:                   ^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(327): [--Wwarn=uninitialized_out_param] warning: out parameter 'rv' may be uninitialized when 'apply' terminates
debug:         void apply(inout bit<16> reg, out bit<2> rv) {
debug:                                                  ^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(327)
debug:         void apply(inout bit<16> reg, out bit<2> rv) {
debug:              ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(349): [--Wwarn=uninitialized_use] warning: flag may be uninitialized
debug:             flag = flag | filter2.execute(eg_md.dtel.hash[31:16]);
debug:                    ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(299): [--Wwarn=uninitialized_out_param] warning: out parameter 'flag' may be uninitialized when 'FlowReport' terminates
debug: control FlowReport(in switch_egress_metadata_t eg_md, out bit<2> flag) {
debug:                                                                  ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/dtel.p4(299)
debug: control FlowReport(in switch_egress_metadata_t eg_md, out bit<2> flag) {
debug:         ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/sflow.p4(37): [--Wwarn=uninitialized_out_param] warning: out parameter 'flag' may be uninitialized when 'apply' terminates
debug:         void apply(inout switch_sflow_info_t reg, out bit<1> flag) {
debug:                                                              ^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/sflow.p4(37)
debug:         void apply(inout switch_sflow_info_t reg, out bit<1> flag) {
debug:              ^^^^^
debug: warning: No size defined for table 'dtel_mod_config', setting default size to 512
debug: warning: No size defined for table 'dtel_mirror_session', setting default size to 512
debug: warning: No size defined for table 'same_mac_check_same_mac_check', setting default size to 512
debug: warning: No size defined for table 'mirror_rewrite_pkt_length', setting default size to 512
debug: warning: No size defined for table 'mirror_rewrite_pkt_len_trunc_adjustment', setting default size to 512
debug: warning: No size defined for table 'vlan_xlate_c_tag', setting default size to 512
debug: warning: No size defined for table 'vlan_xlate_set_ether_type', setting default size to 512
debug: warning: No size defined for table 'vlan_decap_vlan_decap', setting default size to 512
debug: warning: No size defined for table 'dtel_ingress_port_conversion', setting default size to 512
debug: warning: No size defined for table 'dtel_egress_port_conversion', setting default size to 512
debug: warning: No size defined for table 'dtel_config_config', setting default size to 512
debug: warning: In action SwitchIngress.system_acl.copy_sflow_to_cpu, write ingress::ig_md.cpu_reason; and read ingress::ig_md.sflow.session_id; sizes do not match up
debug: warning: In action SwitchIngress.system_acl.redirect_sflow_to_cpu, write ingress::ig_md.cpu_reason; and read ingress::ig_md.sflow.session_id; sizes do not match up
debug: warning: Instruction selection creates an instruction that the rest of the compiler cannot correctly interpret
debug: warning: In action SwitchIngress.system_acl.copy_sflow_to_cpu, write ingress::ig_md.cpu_reason; and read ingress::ig_md.sflow.session_id; sizes do not match up
debug: warning: In action SwitchIngress.system_acl.redirect_sflow_to_cpu, write ingress::ig_md.cpu_reason; and read ingress::ig_md.sflow.session_id; sizes do not match up
debug: warning: Instruction selection creates an instruction that the rest of the compiler cannot correctly interpret
debug: [--Wwarn=invalid] warning: "hdr.dtel.timestamp": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: [--Wwarn=invalid] warning: "hdr.dtel_report.ingress_port": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: [--Wwarn=invalid] warning: "hdr.dtel_report.egress_port": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: [--Wwarn=invalid] warning: "hdr.dtel_report.queue_id": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: [--Wwarn=invalid] warning: "hdr.dtel_switch_local_report.queue_occupancy": No matching PHV field in the pipe `pipe' . Ignoring pragma.
debug: warning: PHV allocation for unreferenced field 716:__phv_dummy_padding__<16> ^x ^x padding overlayable exact_containers H44 (width 16)
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(759): warning: table SwitchIngress.system_acl.system_acl: In the ALU operation over container H16 in action SwitchIngress.system_acl.copy_sflow_to_cpu, the number of bits in the write and read aren't equal { add ingress::hdr.bridged_md.base_cpu_reason; alias: ingress::ig_md.cpu_reason;, SwitchIngress.system_acl.copy_sflow_to_cpu:reason_code_8/reason_code, ingress::ig_md.sflow.session_id;; }
debug:     table system_acl {
debug:           ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(759): warning: table SwitchIngress.system_acl.system_acl: In the ALU operation over container H16 in action SwitchIngress.system_acl.copy_sflow_to_cpu, every write bit does not have a corresponding 2 or 0 read bits. { add ingress::hdr.bridged_md.base_cpu_reason; alias: ingress::ig_md.cpu_reason;, SwitchIngress.system_acl.copy_sflow_to_cpu:reason_code_8/reason_code, ingress::ig_md.sflow.session_id;; }
debug:     table system_acl {
debug:           ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(759): warning: table SwitchIngress.system_acl.system_acl: In the ALU operation over container H16 in action SwitchIngress.system_acl.redirect_sflow_to_cpu, the number of bits in the write and read aren't equal { add ingress::hdr.bridged_md.base_cpu_reason; alias: ingress::ig_md.cpu_reason;, SwitchIngress.system_acl.redirect_sflow_to_cpu:reason_code_10/reason_code, ingress::ig_md.sflow.session_id;; }
debug:     table system_acl {
debug:           ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(759): warning: table SwitchIngress.system_acl.system_acl: In the ALU operation over container H16 in action SwitchIngress.system_acl.redirect_sflow_to_cpu, every write bit does not have a corresponding 2 or 0 read bits. { add ingress::hdr.bridged_md.base_cpu_reason; alias: ingress::ig_md.cpu_reason;, SwitchIngress.system_acl.redirect_sflow_to_cpu:reason_code_10/reason_code, ingress::ig_md.sflow.session_id;; }
debug:     table system_acl {
debug:           ^^^^^^^^^^
debug: warning: PHV allocation creates an invalid container action within a Tofino ALU
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(424): [--Wwarn=table-placement] warning: Shrinking table SwitchEgress.mirror_rewrite.pkt_length: with 8 match bits, can only have 256 entries
debug:     table pkt_length {
debug:           ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(384): [--Wwarn=table-placement] warning: Shrinking table SwitchEgress.mirror_rewrite.rewrite: with 8 match bits, can only have 256 entries
debug:     table rewrite {
debug:           ^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/l3.p4(402): [--Wwarn=table-placement] warning: Shrinking table SwitchEgress.egress_vrf.vrf_mapping: with 10 match bits, can only have 1024 entries
debug:     table vrf_mapping {
debug:           ^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/mirror_rewrite.p4(507): [--Wwarn=table-placement] warning: Shrinking table SwitchEgress.mirror_rewrite.pkt_len_trunc_adjustment: with 2 match bits, can only have 4 entries
debug:     table pkt_len_trunc_adjustment {
debug:           ^^^^^^^^^^^^^^^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/l2.p4(510): [--Wwarn=table-placement] warning: Shrinking table SwitchEgress.vlan_xlate.c_tag: with 1 match bits, can only have 2 entries
debug:     table c_tag{
debug:           ^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/l2.p4(568): [--Wwarn=table-placement] warning: Shrinking table SwitchEgress.vlan_xlate.set_ether_type: with 2 match bits, can only have 4 entries
debug:     table set_ether_type {
debug:           ^^^^^^^^^^^^^^
debug: [--Wwarn=invalid] warning: "hdr.dtel.timestamp": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: [--Wwarn=invalid] warning: "hdr.dtel_report.ingress_port": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: [--Wwarn=invalid] warning: "hdr.dtel_report.egress_port": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: [--Wwarn=invalid] warning: "hdr.dtel_report.queue_id": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: [--Wwarn=invalid] warning: "hdr.dtel_switch_local_report.queue_occupancy": No matching PHV field in the pipe `pipe'. Ignoring pragma.
debug: warning: PHV allocation for unreferenced field 716:__phv_dummy_padding__<16> ^x ^x padding overlayable exact_containers H68 (width 16)
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(759): warning: table SwitchIngress.system_acl.system_acl: In the ALU operation over container H15 in action SwitchIngress.system_acl.copy_sflow_to_cpu, the number of bits in the write and read aren't equal { add ingress::hdr.bridged_md.base_cpu_reason; alias: ingress::ig_md.cpu_reason;, SwitchIngress.system_acl.copy_sflow_to_cpu:reason_code_8/reason_code, ingress::ig_md.sflow.session_id;; }
debug:     table system_acl {
debug:           ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(759): warning: table SwitchIngress.system_acl.system_acl: In the ALU operation over container H15 in action SwitchIngress.system_acl.copy_sflow_to_cpu, every write bit does not have a corresponding 2 or 0 read bits. { add ingress::hdr.bridged_md.base_cpu_reason; alias: ingress::ig_md.cpu_reason;, SwitchIngress.system_acl.copy_sflow_to_cpu:reason_code_8/reason_code, ingress::ig_md.sflow.session_id;; }
debug:     table system_acl {
debug:           ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(759): warning: table SwitchIngress.system_acl.system_acl: In the ALU operation over container H15 in action SwitchIngress.system_acl.redirect_sflow_to_cpu, the number of bits in the write and read aren't equal { add ingress::hdr.bridged_md.base_cpu_reason; alias: ingress::ig_md.cpu_reason;, SwitchIngress.system_acl.redirect_sflow_to_cpu:reason_code_10/reason_code, ingress::ig_md.sflow.session_id;; }
debug:     table system_acl {
debug:           ^^^^^^^^^^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/switch-p4-16/p4src/shared/acl.p4(759): warning: table SwitchIngress.system_acl.system_acl: In the ALU operation over container H15 in action SwitchIngress.system_acl.redirect_sflow_to_cpu, every write bit does not have a corresponding 2 or 0 read bits. { add ingress::hdr.bridged_md.base_cpu_reason; alias: ingress::ig_md.cpu_reason;, SwitchIngress.system_acl.redirect_sflow_to_cpu:reason_code_10/reason_code, ingress::ig_md.sflow.session_id;; }
debug:     table system_acl {
debug:           ^^^^^^^^^^
debug: warning: PHV allocation creates an invalid container action within a Tofino ALU
debug: [--Wwarn=substitution] warning: SwitchIngress.pkt_validation.validate_ip: Table key name not supported.  Replacing "hdr.ipv4.src_addr[31:0]" with "hdr.ipv4.src_addr".
debug: [--Wwarn=substitution] warning: SwitchIngress.pkt_validation.validate_ip: Table key name not supported.  Replacing "hdr.ipv6.src_addr[127:0]" with "hdr.ipv6.src_addr".
debug: [--Wwarn=substitution] warning: SwitchIngress.qos_map.dscp_tc_map: Table key name not supported.  Replacing "ig_md.lkp.ip_tos[7:2]" with "ig_md.lkp.ip_tos".
debug: [--Wwarn=substitution] warning: .ipv4_local_host: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[95:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv4_host: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[95:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: SwitchIngress.ingress_ipv4_acl.acl: Table key name not supported.  Replacing "ig_md.lkp.ip_src_addr[95:64]" with "ig_md.lkp.ip_src_addr".
debug: [--Wwarn=substitution] warning: SwitchIngress.ingress_ipv4_acl.acl: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[95:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv4_host: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[95:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: SwitchIngress.ingress_ipv4_acl.acl: Table key name not supported.  Replacing "ig_md.lkp.ip_src_addr[95:64]" with "ig_md.lkp.ip_src_addr".
debug: [--Wwarn=substitution] warning: SwitchIngress.ingress_ipv4_acl.acl: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[95:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv4_host: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[95:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv4_host: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[95:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv4_lpm: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[95:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: .ipv6_lpm64: Table key name not supported.  Replacing "ig_md.lkp.ip_dst_addr[127:64]" with "ig_md.lkp.ip_dst_addr".
debug: [--Wwarn=substitution] warning: SwitchEgress.egress_bd.bd_mapping: Table key name not supported.  Replacing "eg_md.bd[12:0]" with "eg_md.bd".
debug: [--Wwarn=substitution] warning: SwitchEgress.wred.v4_wred_action: Table key name not supported.  Replacing "hdr.ipv4.diffserv[1:0]" with "hdr.ipv4.diffserv".
debug: [--Wwarn=substitution] warning: SwitchEgress.wred.v6_wred_action: Table key name not supported.  Replacing "hdr.ipv6.traffic_class[1:0]" with "hdr.ipv6.traffic_class".
debug: [--Wwarn=substitution] warning: SwitchEgress.dtel_config.config: Table key name not supported.  Replacing "eg_md.lkp.tcp_flags[2:0]" with "eg_md.lkp.tcp_flags".
debug: [--Wwarn=substitution] warning: SwitchEgress.egress_bd_stats.bd_stats: Table key name not supported.  Replacing "eg_md.bd[12:0]" with "eg_md.bd".
debug: Built target y1_tofino2
debug: Cmd 'make --jobs=5 y1_tofino2' took: 0:15:23.998222
Built successfully
Installing...
debug: Executing: make --jobs=5 install
debug: [  0%] Built target bf-p4c
debug: [  1%] Built target bf-p4i
debug: [  1%] Built target bf-p4o
debug: Scanning dependencies of target ev_o
debug: [  2%] Built target build_tcmalloc
debug: [  2%] Built target build_edit
debug: [  2%] Building C object pkgsrc/bf-syslibs/third-party/libev/CMakeFiles/ev_o.dir/ev.c.o
debug: Scanning dependencies of target zlog_o
debug: [  2%] Built target libpython3.8
debug: [  2%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/buf.c.o
debug: Scanning dependencies of target bfsysutil_o
debug: Scanning dependencies of target cjson_o
debug: Scanning dependencies of target dynhash_o
debug: [  2%] Building C object pkgsrc/bf-utils/src/CMakeFiles/bfsysutil_o.dir/bf_utils.c.o
debug: [  2%] Building C object pkgsrc/bf-utils/third-party/cjson/CMakeFiles/cjson_o.dir/src/cJSON.c.o
debug: [  4%] Building C object pkgsrc/bf-utils/src/dynamic_hash/CMakeFiles/dynhash_o.dir/dynamic_hash.c.o
debug: [  4%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/category.c.o
debug: [  5%] Building C object pkgsrc/bf-utils/src/CMakeFiles/bfsysutil_o.dir/hashtbl/hashtbl.c.o
debug: [  5%] Building C object pkgsrc/bf-utils/src/dynamic_hash/CMakeFiles/dynhash_o.dir/bfn_hash_algorithm.c.o
debug: In file included from /usr/include/x86_64-linux-gnu/bits/libc-header-start.h:33,
debug:                  from /usr/include/string.h:26,
debug:                  from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-syslibs/third-party/zlog/src/category.c:9:
debug: /usr/include/features.h:184:3: warning: #warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE" [-Wcpp]
debug:  # warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE"
debug:    ^~~~~~~
debug: [  5%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/category_table.c.o
debug: [  5%] Building C object pkgsrc/bf-utils/src/CMakeFiles/bfsysutil_o.dir/bitset/bitset.c.o
debug: [  5%] Built target dynhash_o
debug: [  5%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/conf.c.o
debug: In file included from /usr/include/ctype.h:25,
debug:                  from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-syslibs/third-party/zlog/src/conf.c:10:
debug: /usr/include/features.h:184:3: warning: #warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE" [-Wcpp]
debug:  # warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE"
debug:    ^~~~~~~
debug: [  5%] Built target cjson_o
debug: Scanning dependencies of target JudyCommon
debug: [  5%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyCommon/CMakeFiles/JudyCommon.dir/JudyMalloc.c.o
debug: [  5%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/event.c.o
debug: [  5%] Building C object pkgsrc/bf-utils/src/CMakeFiles/bfsysutil_o.dir/fbitset/fbitset.c.o
debug: In file included from /usr/include/x86_64-linux-gnu/bits/libc-header-start.h:33,
debug:                  from /usr/include/string.h:26,
debug:                  from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-syslibs/third-party/zlog/src/event.c:10:
debug: /usr/include/features.h:184:3: warning: #warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE" [-Wcpp]
debug:  # warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE"
debug:    ^~~~~~~
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/format.c.o
debug: [  7%] Built target JudyCommon
debug: Scanning dependencies of target JudyL
debug: [  7%] Building C object pkgsrc/bf-utils/src/CMakeFiles/bfsysutil_o.dir/id/id.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyCascade.c.o
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/level.c.o
debug: Scanning dependencies of target Judy1
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyCascade.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/src/CMakeFiles/bfsysutil_o.dir/map/map.c.o
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/level_list.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/src/CMakeFiles/bfsysutil_o.dir/power2_allocator/power2_allocator.c.o
debug: [  7%] Built target ev_o
debug: Scanning dependencies of target JudySL
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/mdc.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudySL/CMakeFiles/JudySL.dir/JudySL.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/Judy1Tables.c.o
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/record.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/JudyLTables.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyCount.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyCount.c.o
debug: [  7%] Built target JudySL
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/record_table.c.o
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/rotater.c.o
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/rule.c.o
debug: In file included from /usr/include/x86_64-linux-gnu/bits/libc-header-start.h:33,
debug:                  from /usr/include/string.h:26,
debug:                  from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-syslibs/third-party/zlog/src/rule.c:11:
debug: /usr/include/features.h:184:3: warning: #warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE" [-Wcpp]
debug:  # warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE"
debug:    ^~~~~~~
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyCreateBranch.c.o
debug: [  7%] Built target bfsysutil_o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyCreateBranch.c.o
debug: Scanning dependencies of target JudyHS
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyDecascade.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyHS/CMakeFiles/JudyHS.dir/JudyHS.c.o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyDecascade.c.o
debug: Scanning dependencies of target tommyds_o
debug: [  7%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyalloc.c.o
debug: [  7%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/spec.c.o
debug: In file included from /usr/include/x86_64-linux-gnu/bits/libc-header-start.h:33,
debug:                  from /usr/include/stdlib.h:25,
debug:                  from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-syslibs/third-party/zlog/src/spec.c:11:
debug: /usr/include/features.h:184:3: warning: #warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE" [-Wcpp]
debug:  # warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE"
debug:    ^~~~~~~
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyarrayblk.c.o
debug: [  8%] Built target JudyHS
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyDel.c.o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyDel.c.o
debug: [  8%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/thread.c.o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyarrayblkof.c.o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyarray.c.o
debug: [  8%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/zc_arraylist.c.o
debug: Scanning dependencies of target xxhash_o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyarrayof.c.o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/xxhash/CMakeFiles/xxhash_o.dir/src/xxhash.c.o
debug: [  8%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/zc_hashtable.c.o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyhash.c.o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyhashdyn.c.o
debug: [  8%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/zc_profile.c.o
debug: In file included from /usr/include/x86_64-linux-gnu/bits/libc-header-start.h:33,
debug:                  from /usr/include/stdio.h:27,
debug:                  from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-syslibs/third-party/zlog/src/zc_profile.c:11:
debug: /usr/include/features.h:184:3: warning: #warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE" [-Wcpp]
debug:  # warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE"
debug:    ^~~~~~~
debug: [  8%] Built target xxhash_o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyhashlin.c.o
debug: [  8%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/zc_util.c.o
debug: Scanning dependencies of target dynhashStatic
debug: [  8%] Building C object pkgsrc/bf-utils/src/dynamic_hash/CMakeFiles/dynhashStatic.dir/dynamic_hash.c.o
debug: [  8%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommyhashtbl.c.o
debug: [  9%] Building C object pkgsrc/bf-syslibs/third-party/zlog/CMakeFiles/zlog_o.dir/src/zlog.c.o
debug: In file included from /usr/include/x86_64-linux-gnu/bits/libc-header-start.h:33,
debug:                  from /usr/include/stdio.h:27,
debug:                  from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-syslibs/third-party/zlog/src/zlog.c:11:
debug: /usr/include/features.h:184:3: warning: #warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE" [-Wcpp]
debug:  # warning "_BSD_SOURCE and _SVID_SOURCE are deprecated, use _DEFAULT_SOURCE"
debug:    ^~~~~~~
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommylist.c.o
debug: [  9%] Building C object pkgsrc/bf-utils/src/dynamic_hash/CMakeFiles/dynhashStatic.dir/bfn_hash_algorithm.c.o
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyFirst.c.o
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommytrie.c.o
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyFreeArray.c.o
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/tommyds/CMakeFiles/tommyds_o.dir/src/tommytrieinp.c.o
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyFirst.c.o
debug: [  9%] Linking C static library ../../../../../install/lib/libdynhash.a
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyGet.c.o
debug: [  9%] Built target zlog_o
debug: [  9%] Built target tommyds_o
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyFreeArray.c.o
debug: Scanning dependencies of target expat_o
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/expat/CMakeFiles/expat_o.dir/lib/xmlparse.c.o
debug: [  9%] Built target dynhashStatic
debug: [  9%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyGet.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyInsArray.c.o
debug: Scanning dependencies of target bigcode_o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_remove_link.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyInsArray.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_unlock.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_remove_link_free.c.o
debug: Scanning dependencies of target clish_o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/plugin_builtin.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/command/command.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_find.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyIns.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyIns.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_foreach.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/command/command_dump.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_reverse.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/param/param.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_last.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_free_all.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/param/param_dump.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/pargv/pargv.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_dump.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyInsertBranch.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_prepend.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/pargv/pargv_dump.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_log.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyMallocIF.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/ptype/ptype.c.o
debug: [ 11%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyInsertBranch.c.o
debug: [ 12%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_remove.c.o
debug: [ 12%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyMallocIF.c.o
debug: [ 12%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_append_list.c.o
debug: [ 12%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyMemActive.c.o
debug: [ 12%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/ptype/ptype_dump.c.o
debug: [ 12%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_find_custom.c.o
debug: [ 12%] Building C object pkgsrc/bf-utils/third-party/expat/CMakeFiles/expat_o.dir/lib/xmlrole.c.o
debug: [ 12%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/__/JudyCommon/JudyMemUsed.c.o
debug: [ 14%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_view.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyMemActive.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_remove.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/Judy1Next.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_ptype.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_to_array.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyMemUsed.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_var.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/__/JudyCommon/JudyByCount.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_find.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/expat/CMakeFiles/expat_o.dir/lib/xmltok.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_sort.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_command.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_from_array.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_dump.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_remove_link_free.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/JudyLNext.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_execute.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_from_data_array.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/Judy1NextEmpty.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_copy.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_next.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_help.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_lock.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_new.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_remove_link.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/JudyLNextEmpty.c.o
debug: [ 15%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_parse.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_append.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/Judy1Prev.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_length.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_file.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_length.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_loop.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_prepend_list.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_startup.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/JudyLPrev.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_alloc.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_wdog.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_prev.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_pwd.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_create.c.o
debug: [ 16%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/Judy1/CMakeFiles/Judy1.dir/Judy1PrevEmpty.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_tinyrl.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_to_data_array.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_plugin.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/judy-1.0.5/src/JudyL/CMakeFiles/JudyL.dir/JudyLPrevEmpty.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_append.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_xml.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_locked_free.c.o
debug: [ 18%] Built target Judy1
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_free.c.o
debug: Scanning dependencies of target bfshell
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_roxml.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell.dir/bin/bfshell.c.o
debug: [ 18%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_libxml2.c.o
debug: [ 19%] Built target JudyL
debug: [ 19%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_insert_sorted.c.o
debug: [ 19%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_prepend.c.o
debug: [ 19%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_expat.c.o
debug: [ 19%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_udata.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_free_all.c.o
debug: [ 21%] Linking C executable bfshell
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_misc.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/BigData/BigList/module/src/biglist_config.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/expat/CMakeFiles/expat_o.dir/lib/xmltok_impl.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_thread.c.o
debug: [ 21%] Built target bfshell
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/ELS/module/src/els_config.c.o
debug: Scanning dependencies of target bfshell_plugin_clish_o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/builtin_init.c.o
debug: [ 21%] Running gRPC and protobuf compiler on google/rpc/code.proto to generate python files
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/hook_access.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/ELS/module/src/els_log.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/shell_strmap.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/hook_config.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/ELS/module/src/els_enums.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/shell/context.c.o
debug: [ 21%] Built target code_pb2_grpc_py_target
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/expat/CMakeFiles/expat_o.dir/lib/xmltok_ns.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/ELS/module/src/els_ucli.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/view/view.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/view/view_dump.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/hook_log.c.o
debug: [ 21%] Built target expat_o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/ELS/module/src/els_module.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/sym_misc.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/bfshell_plugin_clish_o.dir/plugins/clish/sym_script.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/nspace/nspace.c.o
debug: [ 21%] Built target code_pb2_py_target
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/ELS/module/src/els.c.o
debug: [ 21%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/nspace/nspace_dump.c.o
debug: [ 21%] Built target bfshell_plugin_clish_o
debug: [ 21%] Running gRPC and protobuf compiler on google/rpc/status.proto to generate python files
debug: [ 21%] Running C++ gRPC and protobuf compiler on google/rpc/code.proto
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/var/var.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/var/var_dump.c.o
debug: [ 22%] Built target status_pb2_py_target
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/IOF/module/src/iof_log.c.o
debug: [ 22%] Running C++ gRPC and protobuf compiler on google/rpc/status.proto
debug: [ 22%] Running C++ gRPC and protobuf compiler on google/rpc/status.proto
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/action/action.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/action/action_dump.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/IOF/module/src/iof_module.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/config/config.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/config/config_dump.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/hotkey/hotkey.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/IOF/module/src/iof.c.o
debug: Scanning dependencies of target bf_google_protobuf_o
debug: Scanning dependencies of target bf_google_grpc_o
debug: [ 22%] Built target status_pb2_grpc_py_target
debug: [ 22%] Building CXX object pkgsrc/bf-drivers/third-party/CMakeFiles/bf_google_grpc_o.dir/cpp_out/google/rpc/status.grpc.pb.cc.o
debug: [ 22%] Building CXX object pkgsrc/bf-drivers/third-party/CMakeFiles/bf_google_protobuf_o.dir/cpp_out/google/rpc/status.pb.cc.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/IOF/module/src/iof_config.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/hotkey/hotkey_dump.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_sleep_osx.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_ucli.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/plugin/plugin.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_time_none.c.o
debug: [ 22%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/plugin/plugin_dump.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_sem_osx.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_config.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/clish/udata/udata.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_sem_windows.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/argv/argv.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_sleep_posix.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_sleep_none.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_sleep_windows.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_module.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_dump.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_find.c.o
debug: [ 23%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_time_posix.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_findfirst.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_findlast.c.o
debug: [ 25%] Building CXX object pkgsrc/bf-drivers/third-party/CMakeFiles/bf_google_grpc_o.dir/cpp_out/google/rpc/code.grpc.pb.cc.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_log.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_time_osx.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_findnext.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_findprevious.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_sem_none.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_init.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_time_windows.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_insert.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_sem_posix.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_iterator_init.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/OS/module/src/os_enums.c.o
debug: [ 25%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_iterator_next.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_pvs.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_object.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_iterator_previous.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_node_init.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_sparse.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_remove.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_memory.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/bintree/bintree_splay.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_pvs_file.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/list/list.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_pvs_syslog.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/ctype/ctype.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_rl.c.o
debug: [ 26%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_map.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/dump/dump.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_bitmap.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_printf.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/string/string.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_string.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/system/system_test.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/system/system_file.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_pvs_buffer.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/system/test.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_error.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/db/db.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_enums.c.o
debug: [ 28%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/ini/pair.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_valgrind.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/ini/ini.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_daemon.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/log/log.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_datatypes.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_modules_init.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/lub/conv/conv.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_config.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/tinyrl/tinyrl.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_log.c.o
debug: [ 29%] Built target bf_google_grpc_o
debug: [ 29%] Building CXX object pkgsrc/bf-drivers/third-party/CMakeFiles/bf_google_protobuf_o.dir/cpp_out/google/rpc/code.pb.cc.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/AIM/module/src/aim_module.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_util.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/tinyrl/history/history.c.o
debug: [ 29%] Built target firmware_install
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/tinyrl/history/history_entry.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/tinyrl/vt100/vt100.c.o
debug: Scanning dependencies of target dvm_o
debug: [ 29%] Building C object pkgsrc/bf-drivers/src/dvm/CMakeFiles/dvm_o.dir/dvm.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/konf/tree/tree.c.o
debug: [ 29%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_handlers.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/konf/tree/tree_dump.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_enums.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/konf/query/query.c.o
debug: [ 30%] Built target bf_google_protobuf_o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/konf/query/query_dump.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_config.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/konf/buf/buf.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/konf/net/net.c.o
debug: [ 30%] Building C object pkgsrc/bf-drivers/src/dvm/CMakeFiles/dvm_o.dir/dvm_clients.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_argparse.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/klish/CMakeFiles/clish_o.dir/libc/getopt.c.o
debug: [ 30%] Building C object pkgsrc/bf-drivers/src/dvm/CMakeFiles/dvm_o.dir/dvm_err_events.c.o
debug: Scanning dependencies of target lld_o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_log.c.o
debug: [ 30%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/bf_lld_if.c.o
debug: [ 30%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_error.c.o
debug: [ 32%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_printf.c.o
debug: [ 32%] Built target clish_o
debug: [ 32%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_module.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/dvm/CMakeFiles/dvm_o.dir/dvm_ucli.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/bf_int_if.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/bf_dma_if.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/dvm/CMakeFiles/dvm_o.dir/bf_drv_shell.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_i2c_if.c.o
debug: [ 32%] Building C object pkgsrc/bf-utils/third-party/bigcode/CMakeFiles/bigcode_o.dir/uCli/module/src/ucli_node.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_gpio_if.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld.c.o
debug: [ 32%] Built target dvm_o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_csr2jtag.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_debug.c.o
debug: [ 32%] Built target bigcode_o
debug: Scanning dependencies of target bfshell_plugin_debug_o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/bfshell_plugin_debug_o.dir/cli/debug_cli.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dev.c.o
debug: [ 32%] Built target bfshell_plugin_debug_o
debug: Scanning dependencies of target bfmc_mgr_o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dev_lock.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_bh.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dev_tof2.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_drv.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dev_tof.c.o
debug: Scanning dependencies of target bfport_mgr_o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/bf_port_if.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_handle.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/bf_map.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dr.c.o
debug: [ 32%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr.c.o
debug: [ 33%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_ha_cd.c.o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dr_tof2.c.o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dr_tof.c.o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_ha.c.o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_dev.c.o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_port.c.o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_ha_rd.c.o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_mac_stats.c.o
debug: Scanning dependencies of target bftraffic_mgr_o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dr_if.c.o
debug: [ 35%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_intf.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_map.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_umac_access.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_helper.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_pool.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dr_regs.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dr_regs_tof2.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_dr_regs_tof.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_port.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_efuse.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_ppg.c.o
debug: Scanning dependencies of target bfpkt_mgr_o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_intf.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/pkt_mgr/CMakeFiles/bfpkt_mgr_o.dir/pkt_mgr_drv.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_efuse_tof2.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_queue.c.o
debug: [ 36%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_sch.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_pipe.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_mcast.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/bf_ll_umac3_if.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_mem.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_mode.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_counter.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_node.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_cached_counters.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_rdm.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_efuse_tof.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_ecc.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/pkt_mgr/CMakeFiles/bfpkt_mgr_o.dir/pkt_mgr_pkt.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_api_misc.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_cfg_read.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/pkt_mgr/CMakeFiles/bfpkt_mgr_o.dir/pkt_mgr_txrx.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_fault_hdlr.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/pkt_mgr/CMakeFiles/bfpkt_mgr_o.dir/pkt_mgr_ucli.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_ind_reg_if.c.o
debug: [ 38%] Built target bfpkt_mgr_o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_ind_reg_if_tof2.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_eg.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_eg_pools.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_hw_access.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_ig_pools.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_rdm_tof.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_ig_ppg.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_rdm_tof2.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_init.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_ind_reg_if_tof.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tof2.c.o
debug: [ 38%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_reg.c.o
debug: [ 39%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tof2_default.c.o
debug: [ 39%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tof2_hw_intf.c.o
debug: [ 39%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_tof2_interrupt.c.o
debug: [ 39%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_port.c.o
debug: [ 39%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_queue.c.o
debug: [ 39%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_sch.c.o
debug: [ 39%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_mcast.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_tof_interrupt.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_path_counters.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tofino.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_shared_dr_wrapper.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_test.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_restart.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/mc_mgr/CMakeFiles/bfmc_mgr_o.dir/mc_mgr_ucli.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_restart_ut.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tofino_default.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tofino_hw_intf.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_interrupt.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tofinolite.c.o
debug: [ 40%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tofinolite_default.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/traffic_mgr_ucli.c.o
debug: [ 42%] Built target bfmc_mgr_o
debug: Scanning dependencies of target bfshell_plugin_pipemgr_o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfshell_plugin_pipemgr_o.dir/pipe_mgr_cli.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tofino_table_gen.c.o
debug: [ 42%] Built target bfshell_plugin_pipemgr_o
debug: Scanning dependencies of target bfpipe_mgr_o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_map.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/bf_pipe_mgr_mirror_buffer.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_mdio_if.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_reg_if.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_subdev_reg_if.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_reg_parse.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/traffic_mgr/CMakeFiles/bftraffic_mgr_o.dir/tm_tof2_table_gen.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/bf_ll_umac4_if.c.o
debug: [ 42%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/cuckoo_move.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/cuckoo_move_init.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_tof1.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_drv_workflows.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_tof1_dev.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_tof1_ha.c.o
debug: [ 43%] Built target bftraffic_mgr_o
debug: Scanning dependencies of target knet_mgr_o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_tof1_port.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/knet_mgr/CMakeFiles/knet_mgr_o.dir/knet_mgr.c.o
debug: [ 43%] Built target knet_mgr_o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_mgr.c.o
debug: Scanning dependencies of target bfshell_plugin_bf_rt_o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfshell_plugin_bf_rt_o.dir/cli/bf_rt_cli.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_mgr_dump.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_tof1_map.c.o
debug: [ 43%] Built target bfshell_plugin_bf_rt_o
debug: [ 43%] Generating python gRPC and protobuf files from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-drivers/src/bf_rt/proto/bfruntime.proto
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_ucli.c.o
debug: [ 43%] Built target bfruntime_pb2_py_target
debug: [ 43%] Generating cpp gRPC and protobuf files from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-drivers/src/bf_rt/proto/bfruntime.proto
debug: [ 43%] Built target bfruntime_pb2_grpc_py_target
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_mgr_init.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/bf_fsm_if.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/bf_fsm_hdlrs.c.o
debug: Scanning dependencies of target bfrt_o
debug: [ 43%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_info_impl.cpp.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_tofino.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_port_diag.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_sku.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_mac.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_serdes.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_spi_if.c.o
debug: [ 43%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_transaction.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_serdes_sbus_map.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_serdes_diag.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_ha_hlp.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_av_sd.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/port_mgr_av_sd_an.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lldlib_ucli.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_diag_ext.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/comira_reg_access_autogen.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_ha_llp.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_tof2_eos_tm.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_adt_ucli.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_tof2_eos.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof1/bf_serdes_if.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_tof2_hole_test.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/bf_ts_if.c.o
debug: [ 45%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/bf_tof2_serdes_if.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_tof_ts.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_alpm.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/lld/CMakeFiles/lld_o.dir/lld_tof2_ts.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/credo_sd_access.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/umac3c4_fld_access.c.o
debug: [ 46%] Built target lld_o
debug: Scanning dependencies of target ctx_json_o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/ctx_json/CMakeFiles/ctx_json_o.dir/ctx_json_utils.c.o
debug: [ 46%] Built target ctx_json_o
debug: Scanning dependencies of target pdfixed_o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_conn_mgr.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_devport_mgr.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_port_mgr.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_mau_snapshot.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_alpm_hlp_ha.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_mau_tbl_dbg_counters.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_mc.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_sd.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_mirror.c.o
debug: [ 46%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_ms.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_pkt.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_plcmt.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/umac3c4_access.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_tm.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_knet_mgr.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_bitmap.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/pd_ts.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_clpm.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/__/bf_pal/bf_pal_port_intf.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/__/bf_pal/dev_intf.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/__/bf_pal/pltfm_func_mgr.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/pdfixed/CMakeFiles/pdfixed_o.dir/__/bf_pal/bf_pal_pltfm_porting.c.o
debug: [ 47%] Built target pdfixed_o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/umac4c8_fld_access.c.o
debug: [ 47%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/umac4c8_access.c.o
debug: [ 49%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_clpm_hlp_ha.c.o
debug: [ 49%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_drv.c.o
debug: [ 49%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/eth400g_mac_rspec_access.c.o
debug: [ 49%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_cjson.cpp.o
debug: [ 49%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_table_data_impl.cpp.o
debug: [ 49%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_drv_workflows.c.o
debug: [ 49%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/eth400g_pcs_rspec_access.c.o
debug: [ 49%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_table_key_impl.cpp.o
debug: [ 49%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_hash.c.o
debug: [ 49%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_init.cpp.o
debug: [ 49%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_tbl_dump.c.o
debug: [ 50%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/eth100g_reg_rspec_access.c.o
debug: [ 50%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_tbl_init.c.o
debug: [ 52%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_init_impl.cpp.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/umac4_ctrs.c.o
debug: Scanning dependencies of target bf_pm_o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_dfe.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_autoneg.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_prbs.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_mac_loopback.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_tbl_mgr.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_pcs_loopback.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_mac_far_loopback.c.o
debug: Scanning dependencies of target dru_sim_o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_serdes_far_loopback.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_intf_fifo.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_pipe_loopback.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_mti.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_tx_mode.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_sw_model.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_emulator.c.o
debug: [ 52%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/port_fsm/bf_pm_fsm_if.c.o
debug: [ 53%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/pm_task.c.o
debug: [ 53%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/pm.c.o
debug: [ 53%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/bf_pm_intf.c.o
debug: [ 53%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_table_attributes_impl.cpp.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_parse.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_sim.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/umac4_ctrs_str.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/bf_pm/CMakeFiles/bf_pm_o.dir/bf_pm_ucli.c.o
debug: [ 54%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_table_operations_impl.cpp.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_transaction.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dma_sim_intf.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/dru_sim_o.dir/dru_intf_tcp.c.o
debug: [ 54%] Built target dru_sim_o
debug: Scanning dependencies of target model
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_intf_fifo.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_mti.c.o
debug: [ 54%] Built target bf_pm_o
debug: Scanning dependencies of target diag_o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_ha.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/diag/CMakeFiles/diag_o.dir/diag_fixed_api.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/diag/CMakeFiles/diag_o.dir/diag_ucli.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_llp_ha.c.o
debug: [ 54%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_utils.cpp.o
debug: [ 54%] Built target diag_o
debug: [ 54%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_table_impl.cpp.o
debug: Scanning dependencies of target perf_o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/perf/CMakeFiles/perf_o.dir/perf_ucli.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_map.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_dev.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_parse.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_hlp_ha.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_sim.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_umac.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_ucli.c.o
debug: [ 54%] Built target perf_o
debug: Scanning dependencies of target driver_o
debug: [ 54%] Building C object pkgsrc/bf-drivers/bf_switchd/CMakeFiles/driver_o.dir/bf_switchd_i2c.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/bf_switchd/CMakeFiles/driver_o.dir/bf_switchd.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_umac3.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_exm_utest.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dma_sim_intf.c.o
debug: [ 54%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/dru_intf_tcp.c.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/__/lld/lld_dr_regs_tof2.c.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/__/lld/lld_dr_regs_tof.c.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_fake_rmt_cfg.c.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/src/dru_sim/CMakeFiles/model.dir/__/lld/lld_dr_regs.c.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_umac4.c.o
debug: [ 56%] Linking C static library ../../../../../install/lib/libmodel.a
debug: [ 56%] Built target model
debug: [ 56%] Building C object pkgsrc/bf-drivers/bf_switchd/CMakeFiles/driver_o.dir/bf_switchd_log.c.o
debug: [ 56%] Generating bf_kdrv.ko
debug: [ 56%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_hw_dump.c.o
debug: [ 56%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_session_impl.cpp.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_microp.c.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/bf_switchd/CMakeFiles/driver_o.dir/switch_config.c.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/bf_switchd/CMakeFiles/driver_o.dir/switchd_ucli.c.o
debug: [ 56%] Building C object pkgsrc/bf-drivers/bf_switchd/CMakeFiles/driver_o.dir/bf_hw_porting_config.c.o
debug: [ 57%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_ibuf.c.o
debug: [ 59%] Building C object pkgsrc/bf-drivers/bf_switchd/CMakeFiles/driver_o.dir/bf_model_pltfm_porting.c.o
debug: [ 59%] Built target driver_o
debug: [ 59%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_idle.c.o
debug: [ 59%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_gpio.c.o
debug: [ 59%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_common/bf_rt_pipe_mgr_intf.cpp.o
debug: [ 59%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_mirror/bf_rt_mirror_table_data_impl.cpp.o
debug: [ 59%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_idle_sweep.c.o
debug: [ 59%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_serdes.c.o
debug: [ 59%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_mirror/bf_rt_mirror_table_impl.cpp.o
debug: [ 59%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_idle_ucli.c.o
debug: [ 59%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/port_mgr_tof2_port.c.o
debug: [ 60%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/bf_ll_serdes_if.c.o
debug: [ 60%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/bf_ll_eth100g_reg_rspec_if.c.o
debug: [ 60%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_int.c.o
debug: [ 60%] Built target bf_kdrv
debug: [ 61%] Generating bf_knet.ko
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/bf_ll_eth400g_mac_rspec_if.c.o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_intf.c.o
debug: [ 61%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_mirror/bf_rt_mirror_table_key_impl.cpp.o
debug: [ 61%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_p4/bf_rt_learn_impl.cpp.o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/port_mgr/CMakeFiles/bfport_mgr_o.dir/port_mgr_tof2/bf_ll_eth400g_pcs_rspec_if.c.o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_cfg.c.o
debug: [ 61%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_p4/bf_rt_learn_state.cpp.o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_mau_snapshot.c.o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_parde.c.o
debug: [ 61%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_p4/bf_rt_p4_table_data_impl.cpp.o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_learn.c.o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_learn_ucli.c.o
debug: [ 61%] Built target bf_knet
debug: [ 61%] Generating bf_kpkt.ko
debug: Scanning dependencies of target newport_driver_o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_mc_intf.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/tcl_server/tcl_server.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/platform_mgr/platform.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/platform_mgr/platform_board.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/platform_mgr/platform_health_mntr.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/platform_mgr/platform_stub.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/bf_pltfm_slave_i2c/bf_pltfm_slave_i2c.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/bf_pltfm_led/bf_pltfm_newport_led.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/bf_pltfm_led/bf_pltfm_newport_cpld_led.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_bmc_tty/bmc_tty.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_spi/bf_pltfm_spi.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/bf_pltfm_lmk5318/bf_pltfm_lmk5318.c.o
debug: [ 61%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/fpga_i2c/fpga_i2c_lib.c.o
debug: [ 61%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_mc_intf.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/fpga_i2c/fpga_i2c_ucli.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/common/devices/pca953x/bf_pcal9535.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/newport/src/qsfp/bf_newport_qsfp.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_intf.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_bd_eeprom.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_tmp.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_vrail.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_ps.c.o
debug: [ 63%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_mc_intf.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_fan.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_mac.c.o
debug: [ 63%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_ucli.c.o
debug: [ 63%] Built target newport_driver_o
debug: [ 63%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_mirror_buffer.c.o
debug: [ 63%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_p4/bf_rt_p4_table_impl.cpp.o
debug: [ 64%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_mirror_buffer.c.o
debug: [ 66%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_p4/bf_rt_p4_table_key_impl.cpp.o
debug: [ 66%] Built target bfport_mgr_o
debug: [ 66%] Built target bf_fpga_update
debug: [ 66%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_mirror_buffer.c.o
debug: Scanning dependencies of target acctonbf_driver_o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/tcl_server/tcl_server.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/platform_mgr/platform.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_bmc_tty/bmc_tty.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/platform_mgr/platform_board.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/platform_mgr/platform_health_mntr.c.o
debug: [ 67%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_mirror_buffer_ha.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_led/bf_pltfm_mav_led.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_led/bf_pltfm_mav_cpld_led.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_rptr/bf_pltfm_rptr.c.o
debug: [ 67%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_p4/bf_rt_table_attributes_state.cpp.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_rptr/bf_pltfm_rptr_ucli.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_rtmr/bf_pltfm_rtmr.c.o
debug: [ 67%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_parde.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_rtmr/bf_pltfm_rtmr_ucli.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_slave_i2c/bf_pltfm_slave_i2c.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_spi/bf_pltfm_spi.c.o
debug: [ 67%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_si5342/bf_pltfm_si5342.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/qsfp/bf_mav_qsfp_module.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/qsfp/bf_mav_qsfp_sub_module.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_intf.c.o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_parb.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_bd_eeprom.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_tmp.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_vrail.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_ps.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_fan.c.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_p4/bf_rt_table_state.cpp.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_mac.c.o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_phase0_tbl_mgr.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_ucli.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_cp2112/bf_pltfm_cp2112_intf.c.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_port/bf_rt_port_mgr_intf.cpp.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/acctonbf_driver_o.dir/platforms/accton-bf/src/bf_pltfm_cp2112/bf_pltfm_cp2112_intf_ucli.c.o
debug: [ 69%] Built target acctonbf_driver_o
debug: Scanning dependencies of target pltfm_o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_o.dir/drivers/src/bf_pltfm_mgr/pltfm_mgr_init.c.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_port/bf_rt_port_table_data_impl.cpp.o
debug: [ 69%] Built target pltfm_o
debug: Scanning dependencies of target tcl_server_o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/tcl_server_o.dir/platforms/accton-bf/tcl_server/tcl_server.c.o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_pipeline_cfg_dnld.c.o
debug: [ 69%] Built target tcl_server_o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_rmt_cfg.c.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_port/bf_rt_port_table_key_impl.cpp.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_port/bf_rt_port_table_impl.cpp.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_port/bf_rt_port_table_attributes_state.cpp.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_dev/bf_rt_dev_table_data_impl.cpp.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_dev/bf_rt_dev_table_impl.cpp.o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_select_ha_hlp.c.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_pktgen/bf_rt_pktgen_table_data_impl.cpp.o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_select_ha_llp.c.o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_select_tbl.c.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_pktgen/bf_rt_pktgen_table_key_impl.cpp.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_pktgen/bf_rt_pktgen_table_impl.cpp.o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_select_tbl_transaction.c.o
debug: [ 69%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_sel_tbl_ucli.c.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_pre/bf_rt_mc_mgr_intf.cpp.o
debug: [ 69%] Built target bf_kpkt
debug: Scanning dependencies of target pltfm_driver_o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_bd_cfg/bf_bd_cfg_intf.c.o
debug: [ 69%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_bd_cfg/bf_bd_cfg_intf_ucli.c.o
debug: [ 69%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_pre/bf_rt_pre_state.cpp.o
debug: [ 70%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_bd_cfg/bf_bd_cfg_porting.c.o
debug: [ 70%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_qsfp/bf_qsfp_cli.c.o
debug: [ 70%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_session.c.o
debug: [ 71%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_pre/bf_rt_pre_table_data_impl.cpp.o
debug: [ 71%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_qsfp/bf_qsfp_comm.c.o
debug: [ 71%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_pre/bf_rt_pre_table_impl.cpp.o
debug: [ 71%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_led/bf_led.c.o
debug: [ 71%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_port_mgmt/bf_pm_intf.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_sm.c.o
debug: [ 73%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_port_mgmt/bf_pm_intf_new.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_stat_drv_workflows.c.o
debug: [ 73%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_port_mgmt/bf_pm_qsfp_mgmt.c.o
debug: [ 73%] Building C object pkgsrc/bf-platforms/CMakeFiles/pltfm_driver_o.dir/drivers/src/bf_port_mgmt/bf_pm_porting.c.o
debug: [ 73%] Built target pltfm_driver_o
debug: Scanning dependencies of target accton_bin_srcs_o
debug: [ 73%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/platforms/accton-bf/src/bf_pltfm_cp2112/bf_pltfm_cp2112_intf.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_stat_lrt.c.o
debug: [ 73%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/platforms/accton-bf/src/bf_pltfm_bmc_tty/bmc_tty.c.o
debug: [ 73%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_pre/bf_rt_pre_table_key_impl.cpp.o
debug: [ 73%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_chss_mgmt_intf.c.o
debug: [ 73%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/platforms/accton-bf/src/bf_pltfm_chss_mgmt/bf_pltfm_bd_eeprom.c.o
debug: [ 73%] Building C object pkgsrc/bf-platforms/CMakeFiles/accton_bin_srcs_o.dir/drivers/src/bf_bd_cfg/bf_bd_cfg_intf.c.o
debug: [ 73%] Built target accton_bin_srcs_o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_stat_mgr_dump.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_stat_tbl_init.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_stat_tbl_mgr.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_stat_ucli.c.o
debug: [ 73%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_intf.cpp.o
debug: [ 73%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_state.cpp.o
debug: [ 73%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_data_impl.cpp.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_meter_tbl_mgr.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_meter_tbl_init.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_meter_drv_workflows.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_meter_ucli.c.o
debug: [ 73%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_key_impl.cpp.o
debug: [ 73%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl.cpp.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_stful_tbl_mgr.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_stful_ucli.c.o
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tbl.c.o
debug: [ 73%] Linking C shared library ../../../install/lib/libtcl_server.so
debug: [ 73%] Built target tcl_server
debug: [ 73%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tcam.c.o
debug: [ 74%] Built target bf_fpga
debug: [ 74%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_port.cpp.o
debug: Scanning dependencies of target parserobj
debug: [ 74%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/parserobj.dir/parser/model_parser.cpp.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tcam_hw.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tcam_tbl_ucli.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tcam_transaction.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tcam_hlp_ha.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tcam_llp_ha.c.o
debug: [ 76%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_portgroup.cpp.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tind.c.o
debug: [ 76%] Built target parserobj
debug: Scanning dependencies of target fmtobj
debug: [ 76%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/fmtobj.dir/third_party/fmtlib/format.cc.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_deprsr.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_ebuf.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_ibuf.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_mau_snapshot.c.o
debug: Scanning dependencies of target s3
debug: [ 76%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/parser/model_parser.cpp.o
debug: [ 76%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_helper_ppg.cpp.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_parb.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_prsr.c.o
debug: [ 76%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tofino_cfg.c.o
debug: [ 76%] Built target fmtobj
debug: [ 76%] Generating sai_map.cpp
debug: [ 76%] Built target saimap
debug: Scanning dependencies of target bf_sal_o
debug: [ 76%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/bf_sys_ver.c.o
debug: [ 76%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/linux_usr/bf_sys_str.c.o
debug: [ 76%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/linux_usr/bf_sys_sal.c.o
debug: [ 77%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/linux_usr/bf_sys_mem.c.o
debug: [ 77%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/linux_usr/bf_sys_sem.c.o
debug: [ 77%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/linux_usr/bf_sys_timer.c.o
debug: [ 77%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_traces.c.o
debug: [ 77%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_helper_sched.cpp.o
debug: [ 77%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/linux_usr/bf_sys_thread.c.o
debug: [ 77%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/linux_usr/bf_sys_log.c.o
debug: [ 78%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_ucli.c.o
debug: [ 78%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_pktgen_comm.c.o
debug: [ 78%] Building C object pkgsrc/bf-syslibs/src/bf_sal/CMakeFiles/bf_sal_o.dir/linux_usr/bf_sys_dma_hugepages.c.o
debug: [ 78%] Built target bf_sal_o
debug: [ 78%] Linking C static library ../../../../../install/lib/libexpat.a
debug: [ 78%] Built target expat
debug: [ 78%] Linking C shared library ../../../../../install/lib/libclish.so
debug: [ 78%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_pktgen.c.o
debug: [ 78%] Built target clish
debug: [ 78%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/third_party/fmtlib/format.cc.o
debug: [ 78%] Linking C shared library ../../../../../install/lib/bfshell_plugin_debug.so
debug: [ 78%] Built target bfshell_plugin_debug
debug: [ 78%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_helper_pipe.cpp.o
debug: [ 78%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_ppg.cpp.o
debug: [ 80%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_mirror.cpp.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_pktgen.c.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_pktgen.c.o
debug: [ 80%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_queue.cpp.o
debug: [ 80%] Building C object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/attribute.c.o
debug: [ 80%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/attribute_util.cpp.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_phy_mem_map.c.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_mau_tbl_dbg_counters.c.o
debug: [ 80%] Linking C shared library ../../../../../install/lib/bfshell_plugin_pipemgr.so
debug: [ 80%] Built target bfshell_plugin_pipemgr
debug: [ 80%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_l1_node.cpp.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_mau_snapshot.c.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_db.c.o
debug: [ 80%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_pool.cpp.o
debug: [ 80%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/bf_rt_backend.cpp.o
^Xhdebug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_db.c.o
debug: [ 80%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_counters.cpp.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_db.c.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_interrupt_comm.c.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_interrupt.c.o
debug: [ 80%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_cfg.cpp.o
debug: [ 80%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_interrupt.c.o
debug: [ 81%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_deprsr_interrupt.c.o
debug: [ 81%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/bf_rt_tm/bf_rt_tm_table_impl_pipe.cpp.o
debug: [ 81%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_lfltr_interrupt.c.o
debug: [ 81%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_mau_interrupt.c.o
debug: [ 81%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_mirror_interrupt.c.o
debug: [ 81%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_parde_interrupt.c.o
debug: [ 81%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_session_c.cpp.o
debug: [ 81%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_table_c.cpp.o
debug: [ 81%] Linking C shared library ../../../../../install/lib/bfshell_plugin_bf_rt.so
debug: [ 81%] Built target bfshell_plugin_bf_rt
debug: [ 81%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_table_data_c.cpp.o
debug: [ 81%] Linking C shared library ../../../../../install/lib/libdru_sim.so
debug: [ 81%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_parser_interrupt.c.o
debug: [ 81%] Built target dru_sim
debug: [ 81%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_table_key_c.cpp.o
debug: [ 81%] Linking C shared library ../../../install/lib/libbfsys.so
debug: [ 81%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_table_attributes_c.cpp.o
debug: [ 81%] Built target bfsys
debug: [ 81%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/log.cpp.o
debug: [ 81%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_table_operations_c.cpp.o
debug: [ 81%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_learn_c.cpp.o
debug: [ 81%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_pgr_interrupt.c.o
debug: [ 83%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_state_c.cpp.o
debug: [ 83%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_init_c.cpp.o
debug: [ 83%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/event.cpp.o
debug: [ 83%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/store.cpp.o
debug: [ 83%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/switch_store.cpp.o
debug: [ 83%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/c_frontend/bf_rt_info_c.cpp.o
debug: [ 83%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_sbc_interrupt.c.o
debug: [ 83%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/proto/bf_rt_server_impl.cpp.o
debug: [ 83%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_tm_interrupt.c.o
debug: [ 83%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/factory.cpp.o
debug: [ 83%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_interrupt.c.o
debug: [ 83%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/proto/bf_rt_server_mgr.cpp.o
debug: [ 83%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/bf_packetpath_counter.c.o
debug: [ 83%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/smi.cpp.o
debug: [ 83%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_pkt_path_counter_display.c.o
debug: [ 83%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_pkt_path_counter_display.c.o
debug: [ 83%] Building C object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/switch_packet.c.o
debug: [ 83%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_counters.c.o
debug: [ 83%] Linking C shared library ../../../../../install/lib/bfshell_plugin_clish.so
debug: [ 83%] Built target bfshell_plugin_clish
debug: [ 83%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_hash_compute.c.o
debug: [ 83%] Linking C shared library ../../../install/lib/libpltfm_driver.so
debug: [ 83%] Built target pltfm_driver
debug: [ 84%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_entry_format.c.o
debug: [ 85%] Building C object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/switch_utils.c.o
debug: [ 85%] Building C object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/switch_lpm.c.o
debug: [ 85%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/s3.dir/cli/bf_switch_cli_api.cpp.o
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_p4parser.c.o
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_p4parser.c.o
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_p4parser.c.o
debug: [ 85%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/cpp_out/bfruntime.pb.cc.o
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_prsr_instance.c.o
debug: [ 85%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/cpp_out/bfruntime.grpc.pb.cc.o
debug: [ 85%] Built target s3
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_hitless_ha.c.o
debug: [ 85%] Linking C shared library ../../../install/lib/libpltfm_mgr.so
debug: [ 85%] Built target pltfm_mgr
debug: [ 85%] Linking C shared library ../../../install/lib/libnewport_driver.so
debug: [ 85%] Built target newport_driver
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_ctx_json_hash.c.o
debug: [ 85%] Linking C shared library ../../../../install/lib/libbfutils.so
debug: [ 85%] Built target bfutils
debug: Scanning dependencies of target newport_spi_i2c_util
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_spi_i2c_util.dir/platforms/newport/tofino_spi_util/tofino_porting_spi.c.o
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/newport_spi_i2c_util.dir/platforms/newport/src/fpga_i2c/fpga_i2c_lib.c.o
debug: [ 85%] Linking C executable newport_spi_i2c_util
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_ctx_json_entry_format.c.o
debug: [ 85%] Built target newport_spi_i2c_util
debug: Scanning dependencies of target fpga_util
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/fpga_util.dir/platforms/newport/fpga_util/fpga_util.c.o
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_ctx_json_rmt_cfg.c.o
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/fpga_util.dir/platforms/newport/src/fpga_i2c/fpga_i2c_lib.c.o
debug: [ 85%] Linking C executable fpga_util
debug: [ 85%] Built target fpga_util
debug: [ 85%] Linking C shared library ../../../install/lib/libacctonbf_driver.so
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_ctx_json_parser.c.o
debug: [ 85%] Built target acctonbf_driver
debug: Scanning dependencies of target spi_i2c_util
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/spi_i2c_util.dir/platforms/accton-bf/tofino_spi_util/tofino_porting_spi.c.o
debug: [ 85%] Linking C executable spi_i2c_util
debug: Scanning dependencies of target cp2112_util
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/cp2112_util.dir/platforms/accton-bf/cp2112_util/cp2112_util.c.o
debug: [ 85%] Built target spi_i2c_util
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_ctx_json_dkm.c.o
debug: Scanning dependencies of target syseeprom_util
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/syseeprom_util.dir/platforms/accton-bf/cp2112_util/syseeprom_util.c.o
debug: In file included from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:1:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.h:75:12: warning: ISO C forbids zero-size array ‘value’ [-Wpedantic]
debug:    u_int8_t value[0];
debug:             ^~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.h: In function ‘tlv_type2name’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.h:140:17: warning: comparison of integer expressions of different signedness: ‘int’ and ‘long unsigned int’ [-Wsign-compare]
debug:    for (i = 0; i < sizeof(tlv_code_list) / sizeof(tlv_code_list[0]); i++) {
debug:                  ^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c: In function ‘read_sys_eeprom’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:12:22: warning: passing argument 2 of ‘process_request’ from incompatible pointer type [-Wincompatible-pointer-types]
debug:    process_request(6, cmd1);
debug:                       ^~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:3:38: note: expected ‘char **’ but argument is of type ‘const char **’
debug:  int process_request(int count, char *cmd[]);
debug:                                 ~~~~~~^~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:15:14: warning: comparison of integer expressions of different signedness: ‘unsigned int’ and ‘int’ [-Wsign-compare]
debug:    while (len < size) {
debug:               ^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:17:5: warning: implicit declaration of function ‘proc_addr_read’ [-Wimplicit-function-declaration]
debug:      proc_addr_read(8, cmd2, true, eeprom_hdr + len);
debug:      ^~~~~~~~~~~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c: In function ‘main’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:30:8: warning: implicit declaration of function ‘is_checksum_valid’ [-Wimplicit-function-declaration]
debug:    if (!is_checksum_valid(eeprom)) {
debug:         ^~~~~~~~~~~~~~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:47:21: warning: pointer targets in passing argument 2 of ‘strncpy’ differ in signedness [-Wpointer-sign]
debug:        strncpy(ret, t->value, t->length);
debug:                     ~^~~~~~~
debug: In file included from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.h:9,
debug:                  from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:1:
debug: /usr/include/string.h:124:14: note: expected ‘const char * restrict’ but argument is of type ‘u_int8_t *’ {aka ‘unsigned char *’}
debug:  extern char *strncpy (char *__restrict __dest,
debug:               ^~~~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/syseeprom_util.c:27:21: warning: variable ‘sts’ set but not used [-Wunused-but-set-variable]
debug:    bf_pltfm_status_t sts;
debug:                      ^~~
debug: [ 85%] Linking C executable cp2112_util
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/syseeprom_util.dir/platforms/accton-bf/cp2112_util/cp2112_util.c.o
debug: [ 85%] Built target cp2112_util
debug: [ 85%] Building C object pkgsrc/bf-platforms/CMakeFiles/syseeprom_util.dir/platforms/accton-bf/cp2112_util/onie_tlvinfo.c.o
debug: In file included from /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:4:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.h:75:12: warning: ISO C forbids zero-size array ‘value’ [-Wpedantic]
debug:    u_int8_t value[0];
debug:             ^~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.h: In function ‘tlv_type2name’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.h:140:17: warning: comparison of integer expressions of different signedness: ‘int’ and ‘long unsigned int’ [-Wsign-compare]
debug:    for (i = 0; i < sizeof(tlv_code_list) / sizeof(tlv_code_list[0]); i++) {
debug:                  ^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c: In function ‘set_bytes’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:96:12: warning: implicit declaration of function ‘isdigit’ [-Wimplicit-function-declaration]
debug:        if (!isdigit(*p)) {
debug:             ^~~~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c: In function ‘set_date’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:141:44: warning: format ‘%d’ expects argument of type ‘int’, but argument 2 has type ‘size_t’ {aka ‘long unsigned int’} [-Wformat=]
debug:      printf("ERROR: Date strlen() != 19 -- %d\n", strlen(string));
debug:                                            ~^     ~~~~~~~~~~~~~~
debug:                                            %ld
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c: In function ‘set_mac’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:221:51: warning: format ‘%d’ expects argument of type ‘int’, but argument 2 has type ‘size_t’ {aka ‘long unsigned int’} [-Wformat=]
debug:      printf("ERROR: MAC address strlen() != 17 -- %d\n", strlen(p));
debug:                                                   ~^     ~~~~~~~~~
debug:                                                   %ld
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:250:28: warning: pointer targets in passing argument 1 of ‘is_valid_ether_addr’ differ in signedness [-Wpointer-sign]
debug:    if (!is_valid_ether_addr((char *)buf)) {
debug:                             ^~~~~~~~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:77:19: note: expected ‘const u_int8_t *’ {aka ‘const unsigned char *’} but argument is of type ‘char *’
debug:  static inline int is_valid_ether_addr(const u_int8_t *addr) {
debug:                    ^~~~~~~~~~~~~~~~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c: In function ‘decode_tlv_value’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:327:9: warning: passing argument 1 to restrict-qualified parameter aliases with argument 3 [-Wrestrict]
debug:          sprintf(value, "%s 0x%02X", value, tlv->value[i]);
debug:          ^~~~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:342:9: warning: passing argument 1 to restrict-qualified parameter aliases with argument 3 [-Wrestrict]
debug:          sprintf(value, "%s 0x%02X", value, tlv->value[i]);
debug:          ^~~~~~~
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c: In function ‘decode_tlv’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:365:7: warning: unused variable ‘i’ [-Wunused-variable]
debug:    int i;
debug:        ^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c: In function ‘tlvinfo_add_tlv’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:740:21: warning: comparison of integer expressions of different signedness: ‘long unsigned int’ and ‘int’ [-Wsign-compare]
debug:         new_tlv_len) > max_size) {
debug:                      ^
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c: In function ‘show_tlv_code_list’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:782:17: warning: comparison of integer expressions of different signedness: ‘int’ and ‘long unsigned int’ [-Wsign-compare]
debug:    for (i = 0; i < sizeof(tlv_code_list) / sizeof(tlv_code_list[0]); i++) {
debug:                  ^
debug: At top level:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:567:12: warning: ‘is_sys_eeprom_valid’ defined but not used [-Wunused-function]
debug:  static int is_sys_eeprom_valid() { return hw_eeprom_valid; }
debug:             ^~~~~~~~~~~~~~~~~~~
debug: [ 85%] Linking CXX shared library ../../../../install/lib/libparserlib.so
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c: In function ‘tlvinfo_add_tlv’:
debug: /home/build/src/bf-sde-9.7.0/pkgsrc/bf-platforms/platforms/accton-bf/cp2112_util/onie_tlvinfo.c:685:7: warning: ‘strncpy’ specified bound 256 equals destination size [-Wstringop-truncation]
debug:        strncpy(data, strval, MAX_TLV_VALUE_LEN);
debug:        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
debug: [ 85%] Linking C executable syseeprom_util
debug: [ 85%] Built target parserlib
debug: [ 85%] Built target syseeprom_util
debug: Scanning dependencies of target graphgen
debug: [ 85%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/graphgen.dir/tools/graphgen.cpp.o
debug: Scanning dependencies of target aug_model_json_gen
debug: [ 85%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/aug_model_json_gen.dir/tools/aug_model_json_gen.cpp.o
debug: [ 85%] Built target bfrt_o
debug: Scanning dependencies of target doc_gen
debug: [ 85%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/doc_gen.dir/tools/doc_gen.cpp.o
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof_dkm.c.o
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_tof2_dkm.c.o
debug: [ 85%] Linking CXX executable aug_model_json_gen
debug: [ 85%] Built target aug_model_json_gen
debug: Scanning dependencies of target enum_gen
debug: [ 85%] Building CXX object pkgsrc/switch-p4-16/s3/CMakeFiles/enum_gen.dir/tools/enum_gen.cpp.o
debug: [ 85%] Linking CXX executable doc_gen
debug: [ 85%] Linking CXX executable graphgen
debug: [ 85%] Built target graphgen
debug: [ 85%] Built target doc_gen
debug: [ 85%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pipe_mgr_dkm.c.o
debug: [ 87%] Building C object pkgsrc/bf-drivers/src/pipe_mgr/CMakeFiles/bfpipe_mgr_o.dir/pkt_path_ucli.c.o
debug: [ 87%] Linking CXX executable enum_gen
debug: [ 87%] Built target enum_gen
debug: [ 87%] Generating switch.json
debug: [ 87%] Built target bfpipe_mgr_o
debug: [ 87%] Linking CXX shared library ../../../../install/lib/libdriver.so
debug: [ 87%] Generating aug_model.json
debug: [ 87%] Generating model.dox
debug: [ 87%] Generating model.h
debug: [ 87%] Generating bf_switchapi.xml
debug: [ 87%] Built target schema
debug: [ 87%] Built target switchdata
debug: Scanning dependencies of target switch
debug: [ 87%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/common/qos_pdfixed.cpp.o
debug: [ 87%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/common/utils.cpp.o
debug: [ 87%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/common/hostif.cpp.o
debug: [ 87%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/common/pal.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/acl.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/bf_rt_ids.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/device.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/dtel.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/etrap.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/features.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/hash.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/hostif_trap.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/init.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/l2.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/l3.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/meter.cpp.o
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/multicast.cpp.o
debug: [ 88%] Built target driver
debug: Scanning dependencies of target bf_switchd
debug: [ 88%] Building C object pkgsrc/bf-drivers/bf_switchd/CMakeFiles/bf_switchd.dir/bf_switchd_main.c.o
debug: [ 88%] Linking C executable bf_switchd
debug: [ 88%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/mirror.cpp.o
debug: [ 88%] Built target bf_switchd
debug: Scanning dependencies of target tna_idletimeout_example
debug: [ 88%] Building CXX object pkgsrc/bf-drivers/bf_switchd/bfrt_examples/CMakeFiles/tna_idletimeout_example.dir/tna_idletimeout.cpp.o
debug: [ 90%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/nat.cpp.o
debug: [ 90%] Linking CXX executable tna_idletimeout_example
debug: [ 90%] Built target tna_idletimeout_example
debug: Scanning dependencies of target tna_action_selector_example
debug: [ 90%] Building CXX object pkgsrc/bf-drivers/bf_switchd/bfrt_examples/CMakeFiles/tna_action_selector_example.dir/tna_action_selector.cpp.o
debug: [ 90%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/nexthop.cpp.o
debug: [ 90%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/pfc_wd.cpp.o
debug: [ 90%] Linking CXX executable tna_action_selector_example
debug: [ 90%] Built target tna_action_selector_example
debug: Scanning dependencies of target multithread_test_example
debug: [ 90%] Building C object pkgsrc/bf-drivers/bf_switchd/bfrt_examples/CMakeFiles/multithread_test_example.dir/multithread_test.c.o
debug: [ 91%] Linking C executable multithread_test_example
debug: [ 91%] Built target multithread_test_example
debug: Scanning dependencies of target tna_counter_c_example
debug: [ 91%] Building C object pkgsrc/bf-drivers/bf_switchd/bfrt_examples/CMakeFiles/tna_counter_c_example.dir/tna_counter_c.c.o
debug: [ 91%] Linking C executable tna_counter_c_example
debug: [ 91%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/port.cpp.o
debug: [ 91%] Built target tna_counter_c_example
debug: [ 91%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/qos.cpp.o
debug: Scanning dependencies of target tna_digest_example
debug: [ 91%] Building CXX object pkgsrc/bf-drivers/bf_switchd/bfrt_examples/CMakeFiles/tna_digest_example.dir/tna_digest.cpp.o
debug: [ 91%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/rewrite.cpp.o
debug: [ 91%] Linking CXX executable tna_digest_example
debug: [ 91%] Built target tna_digest_example
debug: Scanning dependencies of target tna_exact_match_example
debug: [ 91%] Building CXX object pkgsrc/bf-drivers/bf_switchd/bfrt_examples/CMakeFiles/tna_exact_match_example.dir/tna_exact_match.cpp.o
debug: [ 91%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/sflow.cpp.o
debug: [ 92%] Linking CXX executable tna_exact_match_example
debug: [ 92%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/triggers.cpp.o
debug: [ 92%] Built target tna_exact_match_example
debug: Scanning dependencies of target tna_exact_match_c_example
debug: [ 92%] Building C object pkgsrc/bf-drivers/bf_switchd/bfrt_examples/CMakeFiles/tna_exact_match_c_example.dir/tna_exact_match_c.c.o
debug: [ 92%] Linking C executable tna_exact_match_c_example
debug: [ 92%] Built target tna_exact_match_c_example
debug: [ 92%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/tunnel.cpp.o
debug: [ 92%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/tables.cpp.o
debug: [ 92%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/utils.cpp.o
debug: [ 92%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/validation.cpp.o
debug: [ 92%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/wred.cpp.o
debug: [ 92%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/switch_tna/mpls.cpp.o
debug: [ 94%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/common/bf_switch.cpp.o
debug: [ 94%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/switch.dir/common/bf_switch_api.cpp.o
debug: [ 94%] Built target switch
debug: [ 94%] Built target saidata
debug: Scanning dependencies of target bfshell_plugin_bf_switchapi_o
debug: [ 94%] Linking CXX shared library ../../../../install/lib/libbf_switch.so
debug: [ 94%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/bfshell_plugin_bf_switchapi_o.dir/__/s3/cli/bf_switch_cli.cpp.o
debug: [ 95%] Building CXX object pkgsrc/switch-p4-16/api/CMakeFiles/bfshell_plugin_bf_switchapi_o.dir/__/s3/cli/bf_switch_cli_clish.cpp.o
debug: Scanning dependencies of target sai_o
debug: [ 95%] Building C object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/__/submodules/SAI/meta/saimetadatautils.c.o
debug: [ 95%] Building C object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/__/submodules/SAI/meta/saiserialize.c.o
debug: [ 95%] Building C object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saimetadata.c.o
debug: [ 95%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sai_map.cpp.o
debug: [ 95%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sai_bflib.cpp.o
debug: [ 95%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sai.cpp.o
debug: [ 95%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiacl.cpp.o
debug: [ 95%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saibridge.cpp.o
debug: [ 95%] Built target bf_switch
debug: [ 95%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saibuffer.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saidebugcounter.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saidtel.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saifdb.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saihash.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saihostif.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiipmc.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiipmcgroup.cpp.o
debug: [ 97%] Built target bfshell_plugin_bf_switchapi_o
debug: [ 97%] Linking CXX shared library ../../../../install/lib/bfshell_plugin_bf_switchapi.so
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiisolationgroup.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sailag.cpp.o
debug: [ 97%] Built target bfshell_plugin_bf_switchapi
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saimirror.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saimpls.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sainat.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sainexthop.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sainexthopgroup.cpp.o
debug: [ 97%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saineighbor.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiobject.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiport.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saipolicer.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiqosmap.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiqueue.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sairoute.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/sairouterinterface.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saistp.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saisamplepacket.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saischeduler.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saischedulergroup.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiswitch.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saitunnel.cpp.o
debug: [ 98%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiudf.cpp.o
debug: [100%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiutils.cpp.o
debug: [100%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saivlan.cpp.o
debug: [100%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saivirtualrouter.cpp.o
debug: [100%] Building CXX object pkgsrc/switch-p4-16/sai/CMakeFiles/sai_o.dir/saiwred.cpp.o
debug: [100%] Built target sai_o
debug: [100%] Linking CXX shared library ../../../../install/lib/libsai.so
debug: [100%] Built target sai
debug: Install the project...
debug: -- Install configuration: "relwithdebinfo"
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bf-ptf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/afpacket.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/mask.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/parse.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/testutils.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/packet.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/testutils_scapy.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/platforms
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/platforms/local.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/platforms/eth.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/platforms/dummy.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/platforms/remote.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/platforms/nn.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/platforms/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/packet_scapy.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/ptfutils.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/thriftutils.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/base_tests.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/pcap_writer.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/dataplane.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf-ptf/ptf/netutils.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/build_information.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/packets
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/packets/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/__main__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/commands.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/main.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/tool.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/stream.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/decoder.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/bridge_and_sniff.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/answer.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/interface.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/sniff.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/utils/listener.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/validate_src_dst.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/tcp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/ipv4.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/container.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/packet.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/gre.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/bfd.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/pretty.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/bootp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/validate.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/dot1q.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/ipv6.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/igmp.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/alternative
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/alternative/platform_specific.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/alternative/erspan.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/alternative/erspan_iii.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/alternative/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/erspan.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/erspan_platform_specific.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/erspan_iii.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/erspan_ii.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/erspan/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/payload.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/tcp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/ipv6_ext_hdr_routing.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/ipv4.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/frame.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/ipoption.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/arp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/gre.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/bfd.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/bootp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/tcpoption.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/dot1q.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/ipv6.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/ethernet.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/dhcp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/control.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/icmp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/vxlan.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/mpls.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/udp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/gtpu.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/fabric_cpu_timestamp_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/postcard_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/fabric_multicast_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/fabric_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/fabric_payload_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/simple_l3_mirror_cpu_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/fabric_cpu_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/dtel_report_v2_hdr.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/fabric_cpu_sflow_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/mod_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/fabric_unicast_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/dtel_report_hdr.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/fabric_cpu_bfd_event_header.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/cpu/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/templates/icmpv6_unknown.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/ethernet.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/dhcp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/base.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/constant.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/icmp.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/extends
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/extends/l4checksum.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/extends/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/udp.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/validate_sport_dport.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/specs/__init__.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/chksum.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/bin.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/ip_types.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/constants.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/mac.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/bytes2hex.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/get_if_list.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/hexdump.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/helpers/ether_types.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/x_short_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/x_3byte_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/byte_enum_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/int_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/dest_mac_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/three_bytes_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/x_short_enum_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/enum_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/str_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/short_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/bit_enum_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/x_int_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/short_enum_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/x_long_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/bit_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/byte_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/source_mac_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/mac_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/x_bit_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/x_byte_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/validators/flags_field.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/library/__init__.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/all
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/all/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/bf_pktpy/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/tofino-model
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/run_ptf_tests.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/bf_switchd_dev_status.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/ptf_interfaces.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/erspan3.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/pd_base_tests.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/bfruntime_base_tests.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/bfruntime_client_base_tests.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/port_mapping.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/ptf_port.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/bfd_utils.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/traffic_utils.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/traffic_streams.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/traffic_protocols.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/TrafficGen.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/p4testutils/p4runtime_base_tests.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/port_mapping_clean
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/port_mapping_setup
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/port_ifup
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/port_ifdown
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/veth_setup.sh
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/veth_teardown.sh
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/dma_setup.sh
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/p4testutils/mavericks_port_mapping.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/p4testutils/montara_port_mapping.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bfsys/zlog-cfg
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/expat.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/expat_external.h
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/pkgconfig/expat.pc
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bfshell
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/cli/xml/startup.xml
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/cli/xml/types.xml
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bf_kdrv_mod_load
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bf_kdrv_mod_unload
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bf_knet_mod_load
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bf_knet_mod_unload
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bf_kpkt_mod_load
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bf_kpkt_mod_unload
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/google/rpc/status_pb2_grpc.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/google/rpc/status_pb2.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/google/rpc/code_pb2_grpc.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/google/rpc/code_pb2.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/google/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/google/rpc/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/cli/xml/debug.xml
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/cli/xml/pipemgr.xml
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/cli/xml/bf_rt.xml
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_mirror_tf1.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_mirror_tf2.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_dev_tf1.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_dev_tf2.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_port_tf1.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_port_tf2.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_pktgen_tf1.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_pktgen_tf2.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_pre_tf1.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_pre_tf2.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_tm_tf1.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_tm_tf2.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_p4_tf1.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/bf_rt_shared/bf_rt_p4_tf2.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/bfrt_grpc/bfruntime_pb2.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/bfrt_grpc/bfruntime_pb2_grpc.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.8
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/bfrtLearn.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/bfrtTable.py
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/tests
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/tests/bfpy_tna_counter_test.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/tests/bfpy_tna_idletimeout_test.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/tests/bfpy_tna_register_test.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/tests/bfpy_login_test.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/bfrtcli.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/bfrtTableEntry.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.8/bfrtInfo.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/bfrt_grpc/client.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/bfrt_grpc/info_parse.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/python3.7/site-packages/tofino/bfrt_grpc/__init__.py
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/bf_switchd
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/multithread_test_example
debug: -- Set runtime path of "/home/build/src/bf-sde-9.7.0/install/bin/multithread_test_example" to "$ORIGIN/../lib"
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/tna_action_selector_example
debug: -- Set runtime path of "/home/build/src/bf-sde-9.7.0/install/bin/tna_action_selector_example" to "$ORIGIN/../lib"
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/tna_counter_c_example
debug: -- Set runtime path of "/home/build/src/bf-sde-9.7.0/install/bin/tna_counter_c_example" to "$ORIGIN/../lib"
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/tna_digest_example
debug: -- Set runtime path of "/home/build/src/bf-sde-9.7.0/install/bin/tna_digest_example" to "$ORIGIN/../lib"
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/tna_exact_match_example
debug: -- Set runtime path of "/home/build/src/bf-sde-9.7.0/install/bin/tna_exact_match_example" to "$ORIGIN/../lib"
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/tna_exact_match_c_example
debug: -- Set runtime path of "/home/build/src/bf-sde-9.7.0/install/bin/tna_exact_match_c_example" to "$ORIGIN/../lib"
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/tna_idletimeout_example
debug: -- Set runtime path of "/home/build/src/bf-sde-9.7.0/install/bin/tna_idletimeout_example" to "$ORIGIN/../lib"
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_kdrv_mod_load
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_kdrv_mod_unload
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_knet_mod_load
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_knet_mod_unload
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_kpkt_mod_load
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_kpkt_mod_unload
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/modules/bf_kdrv.ko
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/modules/bf_knet.ko
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/lib/modules/bf_kpkt.ko
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/spi_i2c_util
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/cp2112_util
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/syseeprom_util
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/tofino_pci_bringup.sh
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/tofino_i2c_wr_local.sh
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/tofino_i2c_wr.sh
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/tofino_i2c_rd_local.sh
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/tofino_i2c_rd.sh
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/credo_firmware.bin
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/fpga_util
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_fpga_update
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/bin/newport_spi_i2c_util
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/platforms/board-maps/accton
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/platforms/board-maps/accton/board_lane_map_4404.json
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/platforms/board-maps/accton/board_lane_map_4404_old_tx.json
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/platforms/board-maps/accton/board_lane_map_8500.json
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_fpga_mod_load
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/bin/bf_fpga_mod_unload
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/lib/modules/bf_fpga.ko
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/include/bf_switch
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/bf_switch/bf_switch.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/bf_switch/bf_switch_types.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/bf_switch/bf_event.h
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/include/s3
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/smi.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/switch_packet.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/bf_rt_backend.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/attribute_util.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/factory.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/switch_store.h
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/include/s3/meta
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/meta/meta.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/attribute.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/s3/event.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/switch/aug_model.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/bf_switch/model.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/cli/xml/bf_switchapi.xml
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/include/sai
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saistp.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saisamplepacket.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saimirror.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiipmc.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sairoute.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiipmcgroup.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saifdb.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiwred.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saihostif.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saimacsec.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saischeduler.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiobject.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saisystemport.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sairouterinterface.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sai.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saivlan.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saibridge.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saibfd.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saipolicer.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sainexthopgroup.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiacl.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sailag.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saihash.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiudf.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saineighbor.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saimpls.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiqueue.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sairpfgroup.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saistatus.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saidtel.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sail2mc.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiqosmap.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sainexthop.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saicounter.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiswitch.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saitypes.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiisolationgroup.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saivirtualrouter.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saisegmentroute.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sail2mcgroup.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiport.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saidebugcounter.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saimcastfdb.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/sainat.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saibuffer.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saitunnel.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saischedulergroup.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saitam.h
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/include/sai
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiexperimentalbmtor.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiextensions.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saiswitchextensions.h
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/include/sai/saitypesextensions.h
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/switch
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/switch/bf-rt.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/switch/events.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/switch/source.json
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/switch/manifest.json
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/switch/pipe
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/switch/pipe/tofino2.bin
debug: -- Installing: /home/build/src/bf-sde-9.7.0/install/share/switch/pipe/context.json
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino/switch-32q-cpu-veth.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino/switch-sai.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino/switch.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino/switch-32q-asym-folded.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino/switch-sai-32q.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino/switch-32q-asym-folded-cpu-veth.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino/switch-sai-cpu-veth.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino/switch-16q-asym-folded-cpu-veth.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino2
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino2/switch-sai.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino2/switch.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino2/switch-32q-asym-folded-cpu-veth.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino2/switch-sai-cpu-veth.conf
debug: -- Up-to-date: /home/build/src/bf-sde-9.7.0/install/share/p4/targets/tofino2/switch-16q-asym-folded-cpu-veth.conf
debug: Cmd 'make --jobs=5 install' took: 0:07:16.847260
Installed successfully
SDE built and installed.
==== ./make_platform_deb.sh ====
Found SDE root at /home/build/src/bf-sde-9.7.0
Use SDE root as install dir
Building package in /tmp/tmp.XNkexcNyJj
/tmp/tmp.XNkexcNyJj /home/build/src/bf-sde-9.7.0/tools/sonic
Packaging Default Profile
/tmp/tmp.XNkexcNyJj
Creating debian package
Maintainer Name     : root
Email-Address       : support@barefootnetworks.com
Date                : Thu, 16 May 2024 05:42:57 +0000
Package Name        : bfnplatform
Version             : 1.0.0
License             : apache
Package Type        : single
Currently there is not top level Makefile. This may require additional tuning
Done. Please edit the files in the debian/ subdirectory now.

Creating debian package
dpkg-buildpackage: info: source package bfnplatform
dpkg-buildpackage: info: source version 1.0.0
dpkg-buildpackage: info: source distribution unstable
dpkg-buildpackage: info: source changed by root <support@barefootnetworks.com>
dpkg-buildpackage: info: host architecture amd64
 dpkg-source --before-build .
 debian/rules clean
dh clean
   dh_clean
 dpkg-source -b .
dpkg-source: info: using source format '3.0 (native)'
dpkg-source: info: building bfnplatform in bfnplatform_1.0.0.tar.xz
dpkg-source: info: building bfnplatform in bfnplatform_1.0.0.dsc
 debian/rules build
dh build
   dh_update_autotools_config
   dh_autoreconf
   create-stamp debian/debhelper-build-stamp
 debian/rules binary
dh binary
   dh_testroot
   dh_prep
   dh_install
   dh_installdocs
   dh_installchangelogs
   dh_perl
   debian/rules override_dh_usrlocal
make[1]: Entering directory '/tmp/tmp.XNkexcNyJj'
dh_shlibdeps -l:/tmp/tmp.XNkexcNyJj/files/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0 --dpkg-shlibdeps-params=--ignore-missing-info
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libacctonbf_driver.so contains an unresolvable reference to symbol bf_qsfp_has_pages: it's probably a plugin
dpkg-shlibdeps: warning: 30 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libnewport_driver.so contains an unresolvable reference to symbol ucli_node_subnode_add: it's probably a plugin
dpkg-shlibdeps: warning: 28 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libpltfm_driver.so contains an unresolvable reference to symbol bf_pm_port_precoding_rx_set: it's probably a plugin
dpkg-shlibdeps: warning: 60 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libbfsys.so contains an unresolvable reference to symbol log: it's probably a plugin
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libpltfm_mgr.so contains an unresolvable reference to symbol pow: it's probably a plugin
dpkg-shlibdeps: warning: 59 other similar warnings have been skipped (use -v to see them all)
make[1]: Leaving directory '/tmp/tmp.XNkexcNyJj'
   dh_link
   dh_strip_nondeterminism
   dh_compress
   dh_fixperms
   dh_missing
   dh_strip
   dh_makeshlibs
   debian/rules override_dh_shlibdeps
make[1]: Entering directory '/tmp/tmp.XNkexcNyJj'
dh_shlibdeps -l:/tmp/tmp.XNkexcNyJj/files/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0 -Xtcl -Xtk -- --ignore-missing-info
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libnewport_driver.so contains an unresolvable reference to symbol cJSON_GetErrorPtr: it's probably a plugin
dpkg-shlibdeps: warning: 28 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libpltfm_driver.so contains an unresolvable reference to symbol bf_serdes_prbs_mode_set: it's probably a plugin
dpkg-shlibdeps: warning: 60 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libpltfm_mgr.so contains an unresolvable reference to symbol bf_i2c_issue_stateout: it's probably a plugin
dpkg-shlibdeps: warning: 59 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libbfsys.so contains an unresolvable reference to symbol log: it's probably a plugin
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnplatform/opt/bfn/install/lib/platform/x86_64-accton_wedge100bf_65x-r0/libacctonbf_driver.so contains an unresolvable reference to symbol bf_pltfm_bd_cfg_rptr_info_get: it's probably a plugin
dpkg-shlibdeps: warning: 30 other similar warnings have been skipped (use -v to see them all)
make[1]: Leaving directory '/tmp/tmp.XNkexcNyJj'
   dh_installdeb
   dh_gencontrol
   dh_md5sums
   dh_builddeb
dpkg-deb: building package 'bfnplatform-dbgsym' in '../bfnplatform-dbgsym_1.0.0_amd64.deb'.
dpkg-deb: building package 'bfnplatform' in '../bfnplatform_1.0.0_amd64.deb'.
 dpkg-genbuildinfo
 dpkg-genchanges  >../bfnplatform_1.0.0_amd64.changes
dpkg-genchanges: info: including full source code in upload
 dpkg-source --after-build .
dpkg-buildpackage: info: full upload; Debian-native package (full source is included)
/home/build/src/bf-sde-9.7.0/tools/sonic
==== ./make_sde_deb.sh ====
Found SDE root at /home/build/src/bf-sde-9.7.0
Use SDE root as install dir
Building package in /tmp/tmp.Csk4LGLXKH
/tmp/tmp.Csk4LGLXKH /home/build/src/bf-sde-9.7.0/tools/sonic
Prepare Default Profile
/tmp/tmp.Csk4LGLXKH/files/opt/bfn/install/lib /tmp/tmp.Csk4LGLXKH /home/build/src/bf-sde-9.7.0/tools/sonic
/tmp/tmp.Csk4LGLXKH /home/build/src/bf-sde-9.7.0/tools/sonic
/tmp/tmp.Csk4LGLXKH/files/opt/bfn/install/lib /tmp/tmp.Csk4LGLXKH /home/build/src/bf-sde-9.7.0/tools/sonic
/tmp/tmp.Csk4LGLXKH /home/build/src/bf-sde-9.7.0/tools/sonic
Generate debian folder
Maintainer Name     : root
Email-Address       : support@barefootnetworks.com
Date                : Thu, 16 May 2024 05:44:46 +0000
Package Name        : bfnsdk
Version             : 1.0.0
License             : apache
Package Type        : single
Currently there is not top level Makefile. This may require additional tuning
Done. Please edit the files in the debian/ subdirectory now.

Build debian package
dpkg-buildpackage: info: source package bfnsdk
dpkg-buildpackage: info: source version 1.0.0
dpkg-buildpackage: info: source distribution unstable
dpkg-buildpackage: info: source changed by root <support@barefootnetworks.com>
dpkg-buildpackage: info: host architecture amd64
 dpkg-source --before-build .
 debian/rules clean
dh clean
   dh_clean
 debian/rules build
dh build
   dh_update_autotools_config
   dh_autoreconf
   create-stamp debian/debhelper-build-stamp
 debian/rules binary
dh binary
   dh_testroot
   dh_prep
   dh_install
   dh_installdocs
   dh_installchangelogs
   dh_perl
   dh_link
   dh_strip_nondeterminism
   dh_compress
   dh_fixperms
   dh_missing
   dh_strip
   dh_makeshlibs
   debian/rules override_dh_shlibdeps
make[1]: Entering directory '/tmp/tmp.Csk4LGLXKH'
dh_shlibdeps -l:/tmp/tmp.Csk4LGLXKH/debian/bfnsdk/opt/bfn/install/lib/  -Xtcl -Xtk -- --ignore-missing-info
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: debian/bfnsdk/opt/bfn/install/lib/bfshell_plugin_pipemgr.so contains an unresolvable reference to symbol reg_parse_main: it's probably a plugin
dpkg-shlibdeps: warning: 3 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnsdk/opt/bfn/install/lib/libbfutils.so contains an unresolvable reference to symbol pow: it's probably a plugin
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: debian/bfnsdk/opt/bfn/install/lib/bfshell_plugin_clish.so contains an unresolvable reference to symbol bf_sys_malloc: it's probably a plugin
dpkg-shlibdeps: warning: 1 similar warning has been skipped (use -v to see it)
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: debian/bfnsdk/opt/bfn/install/lib/libclish.so contains an unresolvable reference to symbol bf_sys_thread_join: it's probably a plugin
dpkg-shlibdeps: warning: 21 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnsdk/opt/bfn/install/lib/bfshell_plugin_bf_rt.so contains an unresolvable reference to symbol clish_pargv_find_arg: it's probably a plugin
dpkg-shlibdeps: warning: 19 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: debian/bfnsdk/opt/bfn/install/lib/libbfsys.so contains an unresolvable reference to symbol log: it's probably a plugin
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: debian/bfnsdk/opt/bfn/install/lib/bfshell_plugin_debug.so contains an unresolvable reference to symbol clish_context__get_install_dir: it's probably a plugin
dpkg-shlibdeps: warning: 14 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbf_switch.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libdriver.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libclish.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfutils.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: can't extract name and version from library name 'libbfsys.so'
dpkg-shlibdeps: warning: debian/bfnsdk/opt/bfn/install/lib/libavago.so contains an unresolvable reference to symbol bf_sys_mutex_init: it's probably a plugin
dpkg-shlibdeps: warning: 16 other similar warnings have been skipped (use -v to see them all)
dpkg-shlibdeps: warning: package could avoid a useless dependency if debian/bfnsdk/opt/bfn/install/bin/bf_switchd debian/bfnsdk/opt/bfn/install/lib/bfshell_plugin_bf_switchapi.so debian/bfnsdk/opt/bfn/install/lib/libbf_switch.so debian/bfnsdk/opt/bfn/install/lib/libdriver.so debian/bfnsdk/opt/bfn/install/lib/libsai.so were not linked against libgrpc++_reflection.so.1 (they use none of the library's symbols)
dpkg-shlibdeps: warning: package could avoid a useless dependency if debian/bfnsdk/opt/bfn/install/lib/libgpr.so.7.0.0 debian/bfnsdk/opt/bfn/install/lib/libgrpc++.so.1.17.0 debian/bfnsdk/opt/bfn/install/lib/libgrpc++_reflection.so.1.17.0 debian/bfnsdk/opt/bfn/install/lib/libgrpc.so.7.0.0 were not linked against libprofiler.so.0 (they use none of the library's symbols)
make[1]: Leaving directory '/tmp/tmp.Csk4LGLXKH'
   dh_installdeb
   dh_gencontrol
   dh_md5sums
   dh_builddeb
dpkg-deb: building package 'bfnsdk' in '../bfnsdk_1.0.0_amd64.deb'.
dpkg-deb: building package 'bfnsdk-dbgsym' in '../bfnsdk-dbgsym_1.0.0_amd64.deb'.
 dpkg-genbuildinfo --build=binary
 dpkg-genchanges --build=binary >../bfnsdk_1.0.0_amd64.changes
dpkg-genchanges: info: binary-only upload (no source code included)
 dpkg-source --after-build .
dpkg-buildpackage: info: binary-only upload (no source included)
/home/build/src/bf-sde-9.7.0/tools/sonic
```