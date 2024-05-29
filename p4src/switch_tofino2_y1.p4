/*******************************************************************************
 * BAREFOOT NETWORKS CONFIDENTIAL & PROPRIETARY
 *
 * Copyright (c) 2015-2019 Barefoot Networks, Inc.

 * All Rights Reserved.
 *
 * NOTICE: All information contained herein is, and remains the property of
 * Barefoot Networks, Inc. and its suppliers, if any. The intellectual and
 * technical concepts contained herein are proprietary to Barefoot Networks,
 * Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents, patents in
 * process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from
 * Barefoot Networks, Inc.
 *
 * No warranty, explicit or implicit is provided, unless granted under a
 * written agreement with Barefoot Networks, Inc.
 *
 ******************************************************************************/

#include <core.p4>
#include <t2na.p4>

//-----------------------------------------------------------------------------
// Features.
//-----------------------------------------------------------------------------
// L2 Unicast
//#define COPP_ENABLE
//#define STORM_CONTROL_ENABLE

// L3 Unicast
#define IPV6_ENABLE
//#define IPV6_LPM64_ENABLE

// ACLs
//#define L4_PORT_LOU_ENABLE
//#define EGRESS_IP_ACL_ENABLE
//#define ETYPE_IN_IP_ACL_KEY_ENABLE

// Mirror
//#define MIRROR_ENABLE
//#define INGRESS_PORT_MIRROR_ENABLE
//#define EGRESS_PORT_MIRROR_ENABLE
//#define ERSPAN_ENABLE
//#define ERSPAN_TYPE2_ENABLE
//#define PACKET_LENGTH_ADJUSTMENT
//#define DEPARSER_TRUNCATE

// QoS
//#define QOS_ENABLE
// #define QOS_ACL_ENABLE
//#define INGRESS_ACL_METER_ENABLE
//#define ECN_ACL_ENABLE
//#define WRED_ENABLE
//#define PFC_ENABLE

// DTEL
//#define DTEL_ENABLE
//#define DTEL_QUEUE_REPORT_ENABLE
//#define DTEL_DROP_REPORT_ENABLE
//#define DTEL_FLOW_REPORT_ENABLE
//#define DTEL_ACL_ENABLE

#define IPV4_CSUM_IN_MAU

//-----------------------------------------------------------------------------
// Table sizes.
//-----------------------------------------------------------------------------

#define ipv4_lpm_number_partitions 2048

// 4K L2 vlans
const bit<32> VLAN_TABLE_SIZE = 4096;
const bit<32> BD_FLOOD_TABLE_SIZE = VLAN_TABLE_SIZE * 4;

// 1K (port, vlan) <--> BD
const bit<32> PORT_VLAN_TABLE_SIZE = 1024;

// 5K BDs
const bit<32> BD_TABLE_SIZE = 5120;

// 16K MACs
const bit<32> MAC_TABLE_SIZE = 16384;

// IP Hosts/Routes
const bit<32> IPV4_HOST_TABLE_SIZE = 65536;
const bit<32> IPV4_LOCAL_HOST_TABLE_SIZE = 16384;
const bit<32> IPV4_LPM_TABLE_SIZE = 32*1024;
const bit<32> IPV6_HOST_TABLE_SIZE = 192512;
const bit<32> IPV6_LPM_TABLE_SIZE = 16384;
const bit<32> IPV6_LPM64_TABLE_SIZE = 16384;

// ECMP/Nexthop
const bit<32> ECMP_GROUP_TABLE_SIZE = 512;
const bit<32> ECMP_SELECT_TABLE_SIZE = 32768;
#define switch_nexthop_width 14
const bit<32> NEXTHOP_TABLE_SIZE = 1 << switch_nexthop_width;

// Ingress ACLs
const bit<32> INGRESS_MAC_ACL_TABLE_SIZE = 512;
const bit<32> INGRESS_IPV4_ACL_TABLE_SIZE = 2048;
const bit<32> INGRESS_IPV6_ACL_TABLE_SIZE = 2048;
const bit<32> INGRESS_IP_MIRROR_ACL_TABLE_SIZE = 512;
const bit<32> INGRESS_IP_DTEL_ACL_TABLE_SIZE = 512;

// Egress ACLs
const bit<32> EGRESS_MAC_ACL_TABLE_SIZE = 512;
const bit<32> EGRESS_IPV4_ACL_TABLE_SIZE = 512;
const bit<32> EGRESS_IPV6_ACL_TABLE_SIZE = 512;

#include "headers.p4"
#include "types.p4"
#include "util.p4"
#include "hash.p4"

#include "l3.p4"
#include "nexthop.p4"
#include "parde.p4"
#include "port.p4"
#include "validation.p4"
#include "mirror_rewrite.p4"
#include "multicast.p4"
#include "qos.p4"
#include "meter.p4"
#include "wred.p4"
#include "acl.p4"
#include "dtel.p4"
#include "ipv4_csum.p4"


#include "cms.p4"


// XXX(yumin): currently Brig may pack fields with SALU ops with
// other fields which were set by action data. Until Brig fixes
// it, it is safer to mark SALU related fields as solitary.
@pa_solitary("egress", "eg_md.dtel.queue_report_flag")

control SwitchIngress(
        inout switch_header_t hdr,
        inout switch_ingress_metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
        inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
        inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm) {
    IngressPortMapping(PORT_VLAN_TABLE_SIZE, BD_TABLE_SIZE) ingress_port_mapping;
    PktValidation() pkt_validation;
    SMAC(MAC_TABLE_SIZE) smac;
    DMAC(MAC_TABLE_SIZE) dmac;
    IngressBd(BD_TABLE_SIZE) bd_stats;
    EnableFragHash() enable_frag_hash;
    Ipv4Hash() ipv4_hash;
    Ipv6Hash() ipv6_hash;
    NonIpHash() non_ip_hash;
    Lagv4Hash() lagv4_hash;
    Lagv6Hash() lagv6_hash;
    LOU() lou;
    Fibv4(IPV4_HOST_TABLE_SIZE,
        IPV4_LPM_TABLE_SIZE,
        true,
        IPV4_LOCAL_HOST_TABLE_SIZE) ipv4_fib;
    Fibv6(IPV6_HOST_TABLE_SIZE, IPV6_LPM_TABLE_SIZE, IPV6_LPM64_TABLE_SIZE) ipv6_fib;
    IngressIpv4Acl(INGRESS_IPV4_ACL_TABLE_SIZE) ingress_ipv4_acl;
    IngressIpv6Acl(INGRESS_IPV6_ACL_TABLE_SIZE) ingress_ipv6_acl;
    IngressIpAcl(INGRESS_IP_MIRROR_ACL_TABLE_SIZE) ingress_ip_mirror_acl;
    IngressIpDtelSampleAcl(INGRESS_IP_DTEL_ACL_TABLE_SIZE) ingress_ip_dtel_acl;
    ECNAcl() ecn_acl;
    PFCWd(512) pfc_wd;
    IngressQoSMap() qos_map;
    IngressTC() traffic_class;
    PPGStats() ppg_stats;
//    StormControl() storm_control;
    Nexthop(NEXTHOP_TABLE_SIZE, ECMP_GROUP_TABLE_SIZE, ECMP_SELECT_TABLE_SIZE) nexthop;
    LAG() lag;
    MulticastFlooding(BD_FLOOD_TABLE_SIZE) flood;
    IngressSystemAcl() system_acl;
    IngressDtel() dtel;



    CMS_b() cms;



    apply {
        pkt_validation.apply(hdr, ig_md);
        ingress_port_mapping.apply(hdr, ig_md, ig_intr_md_for_tm, ig_intr_md_for_dprsr);
        lou.apply(ig_md);
        smac.apply(ig_md.lkp.mac_src_addr, ig_md, ig_intr_md_for_dprsr.digest_type);
        bd_stats.apply(ig_md.bd, ig_md.lkp.pkt_type);
        if (ig_md.flags.rmac_hit) {
            if (!INGRESS_BYPASS(L3) && ig_md.lkp.ip_type == SWITCH_IP_TYPE_IPV6 && ig_md.ipv6.unicast_enable) {
                ipv6_fib.apply(ig_md);
            } else if (!INGRESS_BYPASS(L3) && ig_md.lkp.ip_type == SWITCH_IP_TYPE_IPV4 && ig_md.ipv4.unicast_enable) {
                ipv4_fib.apply(ig_md);
            }
        } else {
            dmac.apply(ig_md.lkp.mac_dst_addr, ig_md);
        }

        if (ig_md.lkp.ip_type != SWITCH_IP_TYPE_IPV6) {
            ingress_ipv4_acl.apply(ig_md, ig_md.unused_nexthop);
        }
        if (ig_md.lkp.ip_type != SWITCH_IP_TYPE_IPV4) {
            ingress_ipv6_acl.apply(ig_md, ig_md.unused_nexthop);
        }
        ingress_ip_mirror_acl.apply(ig_md, ig_md.unused_nexthop);

        enable_frag_hash.apply(ig_md.lkp);
        if (ig_md.lkp.ip_type == SWITCH_IP_TYPE_NONE) {
            non_ip_hash.apply(ig_md, ig_md.lag_hash);
        } else if (ig_md.lkp.ip_type == SWITCH_IP_TYPE_IPV4) {
            lagv4_hash.apply(ig_md.lkp, ig_md.lag_hash);
        } else {
            lagv6_hash.apply(ig_md.lkp, ig_md.lag_hash);
        }

        if (ig_md.lkp.ip_type == SWITCH_IP_TYPE_IPV4) {
            ipv4_hash.apply(ig_md.lkp, ig_md.hash[31:0]);
        } else {
            ipv6_hash.apply(ig_md.lkp, ig_md.hash[31:0]);
        }

        nexthop.apply(ig_md);
        qos_map.apply(hdr, ig_md);
        traffic_class.apply(ig_md);

//        storm_control.apply(ig_md, ig_md.lkp.pkt_type, ig_md.flags.storm_control_drop);

        if (ig_md.egress_port_lag_index == SWITCH_FLOOD) {
            flood.apply(ig_md);
        } else {
            lag.apply(ig_md, ig_md.lag_hash, ig_intr_md_for_tm.ucast_egress_port);
        }



        cms.apply(hdr, ig_md, ig_intr_md, ig_intr_from_prsr, ig_intr_md_for_dprsr, ig_intr_md_for_tm);




        ecn_acl.apply(ig_md, ig_md.lkp, ig_intr_md_for_tm.packet_color);
        pfc_wd.apply(ig_md.port, ig_md.qos.qid, ig_md.flags.pfc_wd_drop);

        system_acl.apply(hdr, ig_md, ig_intr_md_for_tm, ig_intr_md_for_dprsr);
        ppg_stats.apply(ig_md);
        ingress_ip_dtel_acl.apply(ig_md, ig_md.unused_nexthop);
        dtel.apply(
            hdr, ig_md.lkp, ig_md, ig_md.lag_hash[15:0], ig_intr_md_for_dprsr, ig_intr_md_for_tm);

        add_bridged_md(hdr.bridged_md, ig_md);

        set_ig_intr_md(ig_md, ig_intr_md_for_dprsr, ig_intr_md_for_tm);
    }
}

control SwitchEgress(
        inout switch_header_t hdr,
        inout switch_egress_metadata_t eg_md,
        in egress_intrinsic_metadata_t eg_intr_md,
        in egress_intrinsic_metadata_from_parser_t eg_intr_md_from_prsr,
        inout egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr,
        inout egress_intrinsic_metadata_for_output_port_t eg_intr_md_for_oport) {
    EgressPortMapping() egress_port_mapping;
    EgressIpv4Acl(EGRESS_IPV4_ACL_TABLE_SIZE) egress_ipv4_acl;
    EgressIpv6Acl(EGRESS_IPV6_ACL_TABLE_SIZE) egress_ipv6_acl;
    EgressQoS() qos;
    EgressQueue() queue;
    EgressSystemAcl() system_acl;
    PFCWd(512) pfc_wd;
    EgressVRF() egress_vrf;
    EgressBD() egress_bd;
    OuterNexthop() outer_nexthop;
    EgressBDStats() egress_bd_stats;
    MirrorRewrite() mirror_rewrite;
    VlanXlate(VLAN_TABLE_SIZE, PORT_VLAN_TABLE_SIZE) vlan_xlate;
    VlanDecap() vlan_decap;
    MTU() mtu;
    WRED() wred;
    EgressDtel() dtel;
    DtelConfig() dtel_config;
    IPv4_Checksum_Compute() ipv4_csum_compute;
    EgressCpuRewrite() cpu_rewrite;
    Neighbor() neighbor;

    apply {
        egress_port_mapping.apply(hdr, eg_md, eg_intr_md_for_dprsr, eg_intr_md.egress_port);
        if (eg_md.pkt_src == SWITCH_PKT_SRC_BRIDGED) {
            vlan_decap.apply(hdr, eg_md);
            qos.apply(hdr, eg_intr_md.egress_port, eg_md);
            wred.apply(hdr, eg_md, eg_intr_md, eg_md.flags.wred_drop);
            egress_vrf.apply(hdr, eg_md);
            outer_nexthop.apply(hdr, eg_md);
            egress_bd.apply(hdr, eg_md);
            ipv4_csum_compute.apply(hdr);
            if (hdr.ipv4.isValid()) {
                egress_ipv4_acl.apply(hdr, eg_md);
            } else if (hdr.ipv6.isValid()) {
                egress_ipv6_acl.apply(hdr, eg_md);
            }
            neighbor.apply(hdr, eg_md);
            egress_bd_stats.apply(hdr, eg_md);
            mtu.apply(hdr, eg_md);
            vlan_xlate.apply(hdr, eg_md);
            pfc_wd.apply(eg_intr_md.egress_port, eg_md.qos.qid, eg_md.flags.pfc_wd_drop);
            dtel.apply(hdr, eg_md, eg_intr_md, eg_intr_md_from_prsr, eg_md.dtel.hash);
            system_acl.apply(hdr, eg_md, eg_intr_md, eg_intr_md_for_dprsr);
            dtel_config.apply(hdr, eg_md, eg_intr_md_for_dprsr);
        } else {
            mirror_rewrite.apply(hdr, eg_md, eg_intr_md_for_dprsr);
        }
        cpu_rewrite.apply(hdr, eg_md, eg_intr_md_for_dprsr, eg_intr_md.egress_port);
        set_eg_intr_md(eg_md, eg_intr_md_for_dprsr, eg_intr_md_for_oport);
        queue.apply(eg_intr_md.egress_port, eg_md);
    }
}

Pipeline(SwitchIngressParser(),
        SwitchIngress(),
        SwitchIngressDeparser(),
        SwitchEgressParser(),
        SwitchEgress(),
        SwitchEgressDeparser()) pipe;

Switch(pipe) main;

