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

#ifndef _P4_TYPES_
#define _P4_TYPES_

// ----------------------------------------------------------------------------
// Common protocols/types
//-----------------------------------------------------------------------------
#define ETHERTYPE_IPV4 0x0800
#define ETHERTYPE_ARP  0x0806
#define ETHERTYPE_VLAN 0x8100
#define ETHERTYPE_IPV6 0x86dd
#define ETHERTYPE_MPLS 0x8847
#define ETHERTYPE_PTP  0x88F7
#define ETHERTYPE_FCOE 0x8906
#define ETHERTYPE_ROCE 0x8915
#define ETHERTYPE_BFN  0x9000
//#define ETHERTYPE_QINQ 0x88A8 // Note: uncomment once ptf/scapy-vxlan are fixed
#define ETHERTYPE_QINQ 0x8100

#define IP_PROTOCOLS_ICMP   1
#define IP_PROTOCOLS_IGMP   2
#define IP_PROTOCOLS_IPV4   4
#define IP_PROTOCOLS_TCP    6
#define IP_PROTOCOLS_UDP    17
#define IP_PROTOCOLS_IPV6   41
#define IP_PROTOCOLS_GRE    47
#define IP_PROTOCOLS_SRV6   43
#define IP_PROTOCOLS_GRE    47
#define IP_PROTOCOLS_ROUTING 43
#define IP_PROTOCOLS_ICMPV6 58
#define IP_PROTOCOLS_NONXT 59

#define UDP_PORT_VXLAN_GPE 4788
#define UDP_PORT_VXLAN  4789
#define UDP_PORT_ROCEV2 4791
#define UDP_PORT_GENEVE 6081
#define UDP_PORT_SFLOW  6343
#define UDP_PORT_MPLS   6635
#define UDP_PORT_GTP_U   2123
#define UDP_PORT_GTP_C   2152

#define GRE_PROTOCOLS_ERSPAN_TYPE_3 0x22EB
#define GRE_PROTOCOLS_NVGRE         0x6558
#define GRE_PROTOCOLS_IP            0x0800
#define GRE_PROTOCOLS_ERSPAN_TYPE_2 0x88BE
#define GRE_PROTOCOLS_IPV6          0x86dd
#define GRE_FLAGS_PROTOCOL_NVGRE    0x20006558

#define IPV6_EXT_TYPE_HBH 0
#define IPV6_EXT_TYPE_DST 0x3C
#define IPV6_EXT_TYPE_ROUTING 0x2B
#define IPV6_EXT_TYPE_FRAGMENT 0x2C
#define IPV6_EXT_TYPE_ESP 0x32
#define IPV6_EXT_TYPE_AH 0x33

#define VLAN_DEPTH 2
#define MPLS_DEPTH 3
#define SEGMENT_DEPTH 2
#define IPV6_FLOW_LABEL_IN_HASH_ENABLE

// ----------------------------------------------------------------------------
// Common table sizes
//-----------------------------------------------------------------------------

const bit<32> MIN_TABLE_SIZE = 512;

const bit<32> LAG_TABLE_SIZE = 1024;
const bit<32> LAG_GROUP_TABLE_SIZE = 256;
const bit<32> LAG_MAX_MEMBERS_PER_GROUP = 64;
const bit<32> LAG_SELECTOR_TABLE_SIZE = 16384;  // 256 * 64

const bit<32> VRF_TABLE_SIZE = 1024;

const bit<32> DTEL_GROUP_TABLE_SIZE = 4;
const bit<32> DTEL_MAX_MEMBERS_PER_GROUP = 64;
const bit<32> DTEL_SELECTOR_TABLE_SIZE = 256;

const bit<32> IPV4_DST_VTEP_TABLE_SIZE = 512;
const bit<32> IPV6_DST_VTEP_TABLE_SIZE = 512;
const bit<32> VNI_MAPPING_TABLE_SIZE = 4096;

// ----------------------------------------------------------------------------
// LPM
//-----------------------------------------------------------------------------

#ifdef IPV4_ALPM_OPT_EN
#define ipv4_lpm_subset_width 18
#define ipv4_lpm_shift_granularity 1
@pa_container_size("ingress", "ig_md.lkp.ip_dst_addr", 32)
@pa_container_size("ingress", "_ipv4_lpm_partition_key", 32)
@pa_container_size("ingress", "hdr.ipv4.dst_addr", 32)
@pa_container_size("ingress", "hdr.ipv6.dst_addr", 32)
@pa_container_size("ingress", "hdr.inner_ipv4.dst_addr", 32)
@pa_container_size("ingress", "hdr.inner_ipv6.dst_addr", 32)
#endif

#ifndef ipv4_lpm_number_partitions
#if __TARGET_TOFINO__ == 1
#define ipv4_lpm_number_partitions 1024
#else
#define ipv4_lpm_number_partitions 2048
#endif
#endif

#ifndef ipv4_lpm_subtrees_per_partition
#define ipv4_lpm_subtrees_per_partition 2
#endif

#ifndef ipv6_lpm128_number_partitions
#ifdef IPV6_LPM64_ENABLE
#define ipv6_lpm128_number_partitions 1024
#else
#define ipv6_lpm128_number_partitions 1024
#endif
#endif

#ifndef ipv6_lpm128_subtrees_per_partition
#ifdef IPV6_LPM64_ENABLE
#define ipv6_lpm128_subtrees_per_partition 1
#else
#define ipv6_lpm128_subtrees_per_partition 2
#endif
#endif

#ifndef ipv6_lpm64_number_partitions
#define ipv6_lpm64_number_partitions 2048
#endif

#ifndef ipv6_lpm64_subtrees_per_partition
#define ipv6_lpm64_subtrees_per_partition 2
#endif

#ifndef ip_lpm64_number_partitions
#define ip_lpm64_number_partitions 2048
#endif

#ifndef ip_lpm64_subtrees_per_partition
#define ip_lpm64_subtrees_per_partition 2
#endif

// ----------------------------------------------------------------------------
// Common types
//-----------------------------------------------------------------------------
typedef bit<32> switch_uint32_t;
typedef bit<16> switch_uint16_t;
typedef bit<8> switch_uint8_t;

#ifndef switch_counter_width
#define switch_counter_width 32
#endif

typedef PortId_t switch_port_t;
#if __TARGET_TOFINO__ == 3
const switch_port_t SWITCH_PORT_INVALID = 11w0x1ff;
typedef bit<5> switch_port_padding_t;
#else
const switch_port_t SWITCH_PORT_INVALID = 9w0x1ff;
typedef bit<7> switch_port_padding_t;
#endif

typedef QueueId_t switch_qid_t;

typedef ReplicationId_t switch_rid_t;
const switch_rid_t SWITCH_RID_DEFAULT = 0xffff;

typedef bit<3> switch_ingress_cos_t;

typedef bit<3> switch_digest_type_t;
const switch_digest_type_t SWITCH_DIGEST_TYPE_INVALID = 0;
const switch_digest_type_t SWITCH_DIGEST_TYPE_MAC_LEARNING = 1;
const switch_digest_type_t SWITCH_DIGEST_TYPE_REPORT = 2;  /*added by Brian*/

typedef bit<16> switch_ifindex_t;
typedef bit<10> switch_port_lag_index_t;
const switch_port_lag_index_t SWITCH_FLOOD = 0x3ff;
typedef bit<8> switch_isolation_group_t;

typedef bit<16> switch_bd_t;
const switch_bd_t SWITCH_BD_DEFAULT_VRF = 4097; // bd allocated for default vrf

#ifndef switch_vrf_width
#define switch_vrf_width 8
#endif
typedef bit<switch_vrf_width> switch_vrf_t;

#ifndef switch_nexthop_width
#define switch_nexthop_width 16
#endif
typedef bit<switch_nexthop_width> switch_nexthop_t;

#ifndef switch_user_metadata_width
#define switch_user_metadata_width 10
#endif
typedef bit<switch_user_metadata_width> switch_user_metadata_t;

#ifdef RESILIENT_ECMP_HASH_ENABLE
#define switch_hash_width 64
#else
#define switch_hash_width 32
#endif
typedef bit<switch_hash_width> switch_hash_t;

typedef bit<128> srv6_sid_t;

#ifndef egress_dtel_drop_report_width
#define egress_dtel_drop_report_width 17
#endif

#ifdef TUNNEL_ENABLE
#define TUNNEL_ENCAP_ENABLE
#define INDEPENDENT_TUNNEL_NEXTHOP_ENABLE
#endif

typedef bit<16> switch_xid_t;
typedef bit<9> switch_yid_t;

#ifdef NAT_ENABLE
typedef bit<24> switch_ig_port_lag_label_t;
#else
typedef bit<32> switch_ig_port_lag_label_t;
#endif
typedef bit<16> switch_eg_port_lag_label_t;
typedef bit<16> switch_bd_label_t;
typedef bit<16> switch_if_label_t;

typedef bit<16> switch_mtu_t;

typedef bit<12> switch_stats_index_t;

typedef bit<16> switch_cpu_reason_t;
const switch_cpu_reason_t SWITCH_CPU_REASON_PTP = 8;

typedef bit<8> switch_fib_label_t;

struct switch_cpu_port_value_set_t {
    bit<16> ether_type;
    switch_port_t port;
}

#define switch_drop_reason_width 8
typedef bit<switch_drop_reason_width> switch_drop_reason_t;
const switch_drop_reason_t SWITCH_DROP_REASON_UNKNOWN = 0;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_SRC_MAC_ZERO = 10;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_SRC_MAC_MULTICAST = 11;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_DST_MAC_ZERO = 12;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_ETHERNET_MISS = 13;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_SAME_MAC_CHECK = 17;
const switch_drop_reason_t SWITCH_DROP_REASON_SRC_MAC_ZERO = 14;
const switch_drop_reason_t SWITCH_DROP_REASON_SRC_MAC_MULTICAST = 15;
const switch_drop_reason_t SWITCH_DROP_REASON_DST_MAC_ZERO = 16;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_VERSION_INVALID = 25;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_TTL_ZERO = 26;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_SRC_MULTICAST = 27;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_SRC_LOOPBACK = 28;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_MISS = 29;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_IHL_INVALID = 30;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_INVALID_CHECKSUM = 31;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_DST_LOOPBACK = 32;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_SRC_UNSPECIFIED = 33;
const switch_drop_reason_t SWITCH_DROP_REASON_OUTER_IP_SRC_CLASS_E = 34;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_VERSION_INVALID = 40;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_TTL_ZERO = 41;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_SRC_MULTICAST = 42;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_SRC_LOOPBACK = 43;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_IHL_INVALID = 44;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_INVALID_CHECKSUM = 45;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_SRC_CLASS_E = 46;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_DST_LINK_LOCAL = 47;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_SRC_LINK_LOCAL = 48;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_DST_UNSPECIFIED = 49;
const switch_drop_reason_t SWITCH_DROP_REASON_IP_SRC_UNSPECIFIED = 50;
const switch_drop_reason_t SWITCH_DROP_REASON_PORT_VLAN_MAPPING_MISS = 55;
const switch_drop_reason_t SWITCH_DROP_REASON_STP_STATE_LEARNING = 56;
const switch_drop_reason_t SWITCH_DROP_REASON_STP_STATE_BLOCKING = 57;
const switch_drop_reason_t SWITCH_DROP_REASON_SAME_IFINDEX = 58;
const switch_drop_reason_t SWITCH_DROP_REASON_MULTICAST_SNOOPING_ENABLED = 59;
const switch_drop_reason_t SWITCH_DROP_REASON_MTU_CHECK_FAIL = 70;
const switch_drop_reason_t SWITCH_DROP_REASON_TRAFFIC_MANAGER = 71;
const switch_drop_reason_t SWITCH_DROP_REASON_STORM_CONTROL = 72;
const switch_drop_reason_t SWITCH_DROP_REASON_WRED = 73;
const switch_drop_reason_t SWITCH_DROP_REASON_INGRESS_PORT_METER = 75;
const switch_drop_reason_t SWITCH_DROP_REASON_INGRESS_ACL_METER = 76;
const switch_drop_reason_t SWITCH_DROP_REASON_EGRESS_PORT_METER = 77;
const switch_drop_reason_t SWITCH_DROP_REASON_EGRESS_ACL_METER = 78;
const switch_drop_reason_t SWITCH_DROP_REASON_ACL_DENY = 80;
const switch_drop_reason_t SWITCH_DROP_REASON_RACL_DENY = 81;
const switch_drop_reason_t SWITCH_DROP_REASON_URPF_CHECK_FAIL = 82;
const switch_drop_reason_t SWITCH_DROP_REASON_IPSG_MISS = 83;
const switch_drop_reason_t SWITCH_DROP_REASON_IFINDEX = 84;
const switch_drop_reason_t SWITCH_DROP_REASON_CPU_COLOR_YELLOW = 85;
const switch_drop_reason_t SWITCH_DROP_REASON_CPU_COLOR_RED = 86;
const switch_drop_reason_t SWITCH_DROP_REASON_STORM_CONTROL_COLOR_YELLOW = 87;
const switch_drop_reason_t SWITCH_DROP_REASON_STORM_CONTROL_COLOR_RED = 88;
const switch_drop_reason_t SWITCH_DROP_REASON_L2_MISS_UNICAST = 89;
const switch_drop_reason_t SWITCH_DROP_REASON_L2_MISS_MULTICAST = 90;
const switch_drop_reason_t SWITCH_DROP_REASON_L2_MISS_BROADCAST = 91;
const switch_drop_reason_t SWITCH_DROP_REASON_EGRESS_ACL_DENY = 92;
const switch_drop_reason_t SWITCH_DROP_REASON_NEXTHOP = 93;
const switch_drop_reason_t SWITCH_DROP_REASON_NON_IP_ROUTER_MAC = 94;
const switch_drop_reason_t SWITCH_DROP_REASON_MLAG_MEMBER = 95;
const switch_drop_reason_t SWITCH_DROP_REASON_L3_IPV4_DISABLE = 99;
const switch_drop_reason_t SWITCH_DROP_REASON_L3_IPV6_DISABLE = 100;
const switch_drop_reason_t SWITCH_DROP_REASON_INGRESS_PFC_WD_DROP = 101;
const switch_drop_reason_t SWITCH_DROP_REASON_EGRESS_PFC_WD_DROP = 102;
const switch_drop_reason_t SWITCH_DROP_REASON_MPLS_LABEL_DROP = 103;
const switch_drop_reason_t SWITCH_DROP_REASON_SRV6_LOCAL_SID_DROP = 104;
const switch_drop_reason_t SWITCH_DROP_REASON_PORT_ISOLATION_DROP = 105;

typedef bit<1> switch_port_type_t;
const switch_port_type_t SWITCH_PORT_TYPE_NORMAL = 0;
const switch_port_type_t SWITCH_PORT_TYPE_CPU = 1;

typedef bit<2> switch_ip_type_t;
const switch_ip_type_t SWITCH_IP_TYPE_NONE = 0;
const switch_ip_type_t SWITCH_IP_TYPE_IPV4 = 1;
const switch_ip_type_t SWITCH_IP_TYPE_IPV6 = 2;
const switch_ip_type_t SWITCH_IP_TYPE_MPLS = 3; // Consider renaming ip_type to l3_type

typedef bit<2> switch_ip_frag_t;
const switch_ip_frag_t SWITCH_IP_FRAG_NON_FRAG = 0b00; // Not fragmented.
const switch_ip_frag_t SWITCH_IP_FRAG_HEAD = 0b10; // First fragment of the fragmented packets.
const switch_ip_frag_t SWITCH_IP_FRAG_NON_HEAD = 0b11; // Fragment with non-zero offset.

// Bypass flags ---------------------------------------------------------------
typedef bit<16> switch_ingress_bypass_t;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_L2 = 16w0x0001;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_L3 = 16w0x0002;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_ACL = 16w0x0004;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_SYSTEM_ACL = 16w0x0008;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_QOS = 16w0x0010;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_METER = 16w0x0020;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_STORM_CONTROL = 16w0x0040;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_STP = 16w0x0080;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_SMAC = 16w0x0100;
const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_NAT = 16w0x0200;

// Add more ingress bypass flags here.

const switch_ingress_bypass_t SWITCH_INGRESS_BYPASS_ALL = 16w0xffff;
#define INGRESS_BYPASS(t) (ig_md.bypass & SWITCH_INGRESS_BYPASS_##t != 0)

// PKT ------------------------------------------------------------------------
typedef bit<16> switch_pkt_length_t;

typedef bit<8> switch_pkt_src_t;
const switch_pkt_src_t SWITCH_PKT_SRC_BRIDGED = 0;
const switch_pkt_src_t SWITCH_PKT_SRC_CLONED_INGRESS = 1;
const switch_pkt_src_t SWITCH_PKT_SRC_CLONED_EGRESS = 2;
const switch_pkt_src_t SWITCH_PKT_SRC_DEFLECTED = 3;

typedef bit<2> switch_pkt_color_t;
const switch_pkt_color_t SWITCH_METER_COLOR_GREEN = 0;
const switch_pkt_color_t SWITCH_METER_COLOR_YELLOW = 1;
const switch_pkt_color_t SWITCH_METER_COLOR_RED = 3;

typedef bit<2> switch_pkt_type_t;
const switch_pkt_type_t SWITCH_PKT_TYPE_UNICAST = 0;
const switch_pkt_type_t SWITCH_PKT_TYPE_MULTICAST = 1;
const switch_pkt_type_t SWITCH_PKT_TYPE_BROADCAST = 2;

// LOU ------------------------------------------------------------------------
#define switch_l4_port_label_width 8
typedef bit<switch_l4_port_label_width> switch_l4_port_label_t;

// STP ------------------------------------------------------------------------
typedef bit<2> switch_stp_state_t;
const switch_stp_state_t SWITCH_STP_STATE_FORWARDING = 0;
const switch_stp_state_t SWITCH_STP_STATE_BLOCKING = 1;
const switch_stp_state_t SWITCH_STP_STATE_LEARNING = 2;

typedef bit<10> switch_stp_group_t;

struct switch_stp_metadata_t {
    switch_stp_group_t group;
    switch_stp_state_t state_;
}

// Nexthop --------------------------------------------------------------------
typedef bit<2> switch_nexthop_type_t;
const switch_nexthop_type_t SWITCH_NEXTHOP_TYPE_IP = 0;
const switch_nexthop_type_t SWITCH_NEXTHOP_TYPE_MPLS = 1;
const switch_nexthop_type_t SWITCH_NEXTHOP_TYPE_TUNNEL_ENCAP = 2;

// Sflow ----------------------------------------------------------------------
typedef bit<8> switch_sflow_id_t;
const switch_sflow_id_t SWITCH_SFLOW_INVALID_ID = 8w0xff;

struct switch_sflow_metadata_t {
    switch_sflow_id_t session_id;
    bit<1> sample_packet;
}

typedef bit<8> switch_hostif_trap_t;

// Metering -------------------------------------------------------------------
#define switch_copp_meter_id_width 8
typedef bit<switch_copp_meter_id_width> switch_copp_meter_id_t;

#define switch_meter_index_width 10
typedef bit<switch_meter_index_width> switch_meter_index_t;

#define switch_mirror_meter_id_width 8
typedef bit<switch_mirror_meter_id_width> switch_mirror_meter_id_t;

// QoS ------------------------------------------------------------------------
typedef bit<2> switch_qos_trust_mode_t;
const switch_qos_trust_mode_t SWITCH_QOS_TRUST_MODE_UNTRUSTED = 0;
const switch_qos_trust_mode_t SWITCH_QOS_TRUST_MODE_TRUST_DSCP = 1;
const switch_qos_trust_mode_t SWITCH_QOS_TRUST_MODE_TRUST_PCP = 2;

typedef bit<5> switch_qos_group_t;

#define switch_tc_width 8
typedef bit<switch_tc_width> switch_tc_t;
typedef bit<3> switch_cos_t;

#define switch_etrap_index_width 11
typedef bit<switch_etrap_index_width> switch_etrap_index_t;

//MYIP type
typedef bit<2> switch_myip_type_t;
const switch_myip_type_t SWITCH_MYIP_NONE = 0;
const switch_myip_type_t SWITCH_MYIP = 1;
const switch_myip_type_t SWITCH_MYIP_SUBNET = 2;


struct switch_qos_metadata_t {
    switch_qos_trust_mode_t trust_mode; // Ingress only.
    switch_qos_group_t group;
    switch_tc_t tc;
    switch_pkt_color_t color;
    switch_pkt_color_t acl_meter_color;
    switch_pkt_color_t port_color;
    switch_pkt_color_t flow_color;
    switch_pkt_color_t storm_control_color;
    switch_meter_index_t port_meter_index;
    switch_meter_index_t acl_meter_index;
    switch_qid_t qid;
    switch_ingress_cos_t icos; // Ingress only.
    bit<19> qdepth; // Egress only.
    switch_etrap_index_t etrap_index;
    switch_pkt_color_t etrap_color;
    switch_tc_t etrap_tc;
    bit<1> etrap_state;
}

// Learning -------------------------------------------------------------------
typedef bit<1> switch_learning_mode_t;
const switch_learning_mode_t SWITCH_LEARNING_MODE_DISABLED = 0;
const switch_learning_mode_t SWITCH_LEARNING_MODE_LEARN = 1;

struct switch_learning_digest_t {
    switch_bd_t bd;
    switch_port_lag_index_t port_lag_index;
    mac_addr_t src_addr;
}

struct switch_learning_metadata_t {
    switch_learning_mode_t bd_mode;
    switch_learning_mode_t port_mode;
    switch_learning_digest_t digest;
}

// Multicast ------------------------------------------------------------------
typedef bit<2> switch_multicast_mode_t;
const switch_multicast_mode_t SWITCH_MULTICAST_MODE_NONE = 0;
const switch_multicast_mode_t SWITCH_MULTICAST_MODE_PIM_SM = 1; // Sparse mode
const switch_multicast_mode_t SWITCH_MULTICAST_MODE_PIM_BIDIR = 2; // Bidirectional

typedef MulticastGroupId_t switch_mgid_t;

typedef bit<16> switch_multicast_rpf_group_t;

struct switch_multicast_metadata_t {
    switch_mgid_t id;
    bit<2> mode;
    switch_multicast_rpf_group_t rpf_group;
}

// URPF -----------------------------------------------------------------------
typedef bit<2> switch_urpf_mode_t;
const switch_urpf_mode_t SWITCH_URPF_MODE_NONE = 0;
const switch_urpf_mode_t SWITCH_URPF_MODE_LOOSE = 1;
const switch_urpf_mode_t SWITCH_URPF_MODE_STRICT = 2;

// WRED/ECN -------------------------------------------------------------------
#define switch_wred_index_width 10
typedef bit<switch_wred_index_width> switch_wred_index_t;

typedef bit<2> switch_ecn_codepoint_t;
const switch_ecn_codepoint_t SWITCH_ECN_CODEPOINT_NON_ECT = 0b00; // Non ECN-capable transport
const switch_ecn_codepoint_t SWITCH_ECN_CODEPOINT_ECT0 = 0b10; // ECN capable transport
const switch_ecn_codepoint_t SWITCH_ECN_CODEPOINT_ECT1 = 0b01; // ECN capable transport
const switch_ecn_codepoint_t SWITCH_ECN_CODEPOINT_CE = 0b11; // Congestion encountered
const switch_ecn_codepoint_t NON_ECT = 0b00; // Non ECN-capable transport
const switch_ecn_codepoint_t ECT0 = 0b10; // ECN capable transport
const switch_ecn_codepoint_t ECT1 = 0b01; // ECN capable transport
const switch_ecn_codepoint_t CE = 0b11; // Congestion encountered

// Mirroring ------------------------------------------------------------------
typedef MirrorId_t switch_mirror_session_t; // Defined in tna.p4
const switch_mirror_session_t SWITCH_MIRROR_SESSION_CPU = 250;

// Using same mirror type for both Ingress/Egress to simplify the parser.
typedef bit<8> switch_mirror_type_t;
#define SWITCH_MIRROR_TYPE_INVALID 0
#define SWITCH_MIRROR_TYPE_PORT 1
#define SWITCH_MIRROR_TYPE_CPU 2
#define SWITCH_MIRROR_TYPE_DTEL_DROP 3
#define SWITCH_MIRROR_TYPE_DTEL_SWITCH_LOCAL 4
#define SWITCH_MIRROR_TYPE_SIMPLE 5
/*added by Brian*/
#define SWITCH_MIRROR_TYPE_UPDATE 6
/* Although strictly speaking deflected packets are not mirrored packets,
 * need a mirror_type codepoint for packet length adjustment.
 * Pick a large value since this is not used by mirror logic.
 */
#define SWITCH_MIRROR_TYPE_DTEL_DEFLECT 255

// Common metadata used for mirroring.
struct switch_mirror_metadata_t {
    switch_pkt_src_t src;
    switch_mirror_type_t type;
    switch_mirror_session_t session_id;
    switch_mirror_meter_id_t meter_index;
}

header switch_port_mirror_metadata_h {
    switch_pkt_src_t src;
    switch_mirror_type_t type;
#if defined(PTP_ENABLE) || defined(INT_V2)
    bit<48> timestamp;
#else
    bit<32> timestamp;
#endif
#if __TARGET_TOFINO__ == 1
    bit<6> _pad;
#endif
    switch_mirror_session_t session_id;

}

header switch_cpu_mirror_metadata_h {
    switch_pkt_src_t src;
    switch_mirror_type_t type;
    switch_port_padding_t _pad1;
    switch_port_t port;
    switch_bd_t bd;
    bit<6> _pad2;
    switch_port_lag_index_t port_lag_index;
    switch_cpu_reason_t reason_code;
}

// Tunneling ------------------------------------------------------------------
typedef bit<1> switch_tunnel_mode_t;
const switch_tunnel_mode_t SWITCH_TUNNEL_MODE_PIPE = 0;
const switch_tunnel_mode_t SWITCH_TUNNEL_MODE_UNIFORM = 1;

typedef bit<4> switch_tunnel_type_t;
const switch_tunnel_type_t SWITCH_INGRESS_TUNNEL_TYPE_NONE = 0;
const switch_tunnel_type_t SWITCH_INGRESS_TUNNEL_TYPE_VXLAN = 1;
const switch_tunnel_type_t SWITCH_INGRESS_TUNNEL_TYPE_IPINIP = 2;
const switch_tunnel_type_t SWITCH_INGRESS_TUNNEL_TYPE_NVGRE = 3;
const switch_tunnel_type_t SWITCH_INGRESS_TUNNEL_TYPE_MPLS = 4;
const switch_tunnel_type_t SWITCH_INGRESS_TUNNEL_TYPE_SRV6 = 5;
const switch_tunnel_type_t SWITCH_INGRESS_TUNNEL_TYPE_NVGRE_ST = 6;

const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_NONE = 0;
const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_IPV4_VXLAN = 1;
const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_IPV6_VXLAN = 2;
const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_IPV4_IPINIP = 3;
const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_IPV6_IPINIP = 4;
const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_IPV4_NVGRE = 5;
const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_IPV6_NVGRE = 6;
const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_MPLS = 7;
const switch_tunnel_type_t SWITCH_EGRESS_TUNNEL_TYPE_SRV6 = 8;

enum switch_tunnel_term_mode_t { P2P, P2MP };

#if defined(VXLAN_ENABLE) || defined(NVGRE_ENABLE)
#define INNER_L2_ENABLE
#endif

#define USID_BLOCK_MASK 0xffffffff000000000000000000000000
#define USID_BLOCK_LEN 32
#define USID_ID_LEN 16

#ifndef switch_tunnel_index_width
#define switch_tunnel_index_width 4
#endif
typedef bit<switch_tunnel_index_width> switch_tunnel_index_t;
#ifndef switch_tunnel_ip_index_width
#define switch_tunnel_ip_index_width 16
#endif
typedef bit<switch_tunnel_ip_index_width> switch_tunnel_ip_index_t;
#ifndef switch_tunnel_nexthop_width
#define switch_tunnel_nexthop_width 16
#endif
typedef bit<switch_tunnel_nexthop_width> switch_tunnel_nexthop_t;
typedef bit<24> switch_tunnel_vni_t;

struct switch_tunnel_metadata_t {
    switch_tunnel_type_t type;
    switch_tunnel_index_t index; // Egress only.
    switch_tunnel_ip_index_t dip_index;
    switch_tunnel_vni_t vni;
    switch_ifindex_t ifindex;
    switch_tunnel_mode_t qos_mode;
    switch_tunnel_mode_t ttl_mode;
    bit<8> encap_ttl;
    bit<8> encap_dscp;
    bit<16> hash;
    bool terminate;
    bit<8> nvgre_flow_id;
    bit<2> mpls_pop_count;
    bit<3> mpls_push_count;
    bit<8> mpls_encap_ttl;
    bit<3> mpls_encap_exp;
    bit<1> mpls_swap;
    bit<128> srh_next_sid;
    bit<8> srh_seg_left;
    bit<8> srh_next_hdr;
    bit<3> srv6_seg_len;
    bit<6> srh_hdr_len;
    bool remove_srh;
    bool pop_active_segment;
    bool srh_decap_forward;
}

struct switch_nvgre_value_set_t {
    bit<32> vsid_flowid;
}

// Data-plane telemetry (DTel) ------------------------------------------------
/* report_type bits for drop and flow reflect dtel_acl results,
 * i.e. whether drop reports and flow reports may be triggered by this packet.
 * report_type bit for queue is not used by bridged / deflected packets,
 * reflects whether queue report is triggered by this packet in cloned packets.
 */
typedef bit<8> switch_dtel_report_type_t;
const switch_dtel_report_type_t SWITCH_DTEL_REPORT_TYPE_NONE = 0b000;
const switch_dtel_report_type_t SWITCH_DTEL_REPORT_TYPE_DROP = 0b100;
const switch_dtel_report_type_t SWITCH_DTEL_REPORT_TYPE_QUEUE = 0b010;
const switch_dtel_report_type_t SWITCH_DTEL_REPORT_TYPE_FLOW = 0b001;

const switch_dtel_report_type_t SWITCH_DTEL_SUPPRESS_REPORT = 0b1000;
const switch_dtel_report_type_t SWITCH_DTEL_REPORT_TYPE_IFA_CLONE = 0b10000;
const switch_dtel_report_type_t SWITCH_DTEL_IFA_EDGE = 0b100000;
const switch_dtel_report_type_t SWITCH_DTEL_REPORT_TYPE_ETRAP_CHANGE = 0b1000000;
const switch_dtel_report_type_t SWITCH_DTEL_REPORT_TYPE_ETRAP_HIT = 0b10000000;

typedef bit<8> switch_ifa_sample_id_t;

#ifdef INT_V2
#define switch_dtel_hw_id_width 4
#else
#define switch_dtel_hw_id_width 6
#endif
typedef bit<switch_dtel_hw_id_width> switch_dtel_hw_id_t;

// Outer header sizes for DTEL Reports
/* Up to the beginning of the DTEL Report v0.5 header
 * 14 (Eth) + 20 (IPv4) + 8 (UDP) + 4 (CRC) = 46 bytes */
const bit<16> DTEL_REPORT_V0_5_OUTER_HEADERS_LENGTH = 46;
/* Outer headers + part of DTEL Report v2 length not included in report_length
 * 14 (Eth) + 20 (IPv4) + 8 (UDP) + 12 (DTEL) + 4 (CRC) = 58 bytes */
const bit<16> DTEL_REPORT_V2_OUTER_HEADERS_LENGTH = 58;

struct switch_dtel_metadata_t {
    switch_dtel_report_type_t report_type;
    bit<1> ifa_gen_clone; // Ingress only, indicates desire to clone this packet
    bit<1> ifa_cloned; // Egress only, indicates this is an ifa cloned packet
    bit<32> latency; // Egress only.
    switch_mirror_session_t session_id;
    switch_mirror_session_t clone_session_id; // Used for IFA interop
    bit<32> hash;
    bit<2> drop_report_flag; // Egress only.
    bit<2> flow_report_flag; // Egress only.
    bit<1> queue_report_flag; // Egress only.
}

typedef bit<4> switch_ingress_nat_hit_type_t;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_NONE = 0;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_FLOW_NONE = 1;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_FLOW_NAPT = 2;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_FLOW_NAT = 3;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_DEST_NONE = 4;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_DEST_NAPT = 5;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_DEST_NAT = 6;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_SRC_NONE = 7;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_SRC_NAPT = 8;
const switch_ingress_nat_hit_type_t SWITCH_NAT_HIT_TYPE_SRC_NAT = 9;

typedef bit<1> switch_nat_zone_t;
const switch_nat_zone_t SWITCH_NAT_INSIDE_ZONE_ID = 0;
const switch_nat_zone_t SWITCH_NAT_OUTSIDE_ZONE_ID = 1;

struct switch_nat_ingress_metadata_t {
  switch_ingress_nat_hit_type_t hit;
  switch_nat_zone_t ingress_zone;
  bit<16> dnapt_index;
  bit<16> snapt_index;
  bool nat_disable;
  bool dnat_pool_hit;
}

header switch_dtel_switch_local_mirror_metadata_h {
    switch_pkt_src_t src;
    switch_mirror_type_t type;
#if defined(PTP_ENABLE) || defined(INT_V2)
    bit<48> timestamp;
#else
    bit<32> timestamp;
#endif
#if __TARGET_TOFINO__ == 1
    bit<6> _pad;
#endif
    switch_mirror_session_t session_id;
    bit<32> hash;
    switch_dtel_report_type_t report_type;
    switch_port_padding_t _pad2;
    switch_port_t ingress_port;
    switch_port_padding_t _pad3;
    switch_port_t egress_port;
#if __TARGET_TOFINO__ == 1
    bit<3> _pad4;
#else
    bit<1> _pad4;
#endif
    switch_qid_t qid;
    bit<5> _pad5;
    bit<19> qdepth;
#ifdef INT_V2
    bit<48> egress_timestamp;
#else
    bit<32> egress_timestamp;
#endif
}

header switch_dtel_drop_mirror_metadata_h {
    switch_pkt_src_t src;
    switch_mirror_type_t type;
#if defined(PTP_ENABLE) || defined(INT_V2)
    bit<48> timestamp;
#else
    bit<32> timestamp;
#endif
#if __TARGET_TOFINO__ == 1
    bit<6> _pad;
#endif
    switch_mirror_session_t session_id;
    bit<32> hash;
    switch_dtel_report_type_t report_type;
    switch_port_padding_t _pad2;
    switch_port_t ingress_port;
    switch_port_padding_t _pad3;
    switch_port_t egress_port;
#if __TARGET_TOFINO__ == 1
    bit<3> _pad4;
#else
    bit<1> _pad4;
#endif
    switch_qid_t qid;
    switch_drop_reason_t drop_reason;
}

// Used for dtel truncate_only and ifa_clone mirror sessions
header switch_simple_mirror_metadata_h {
    switch_pkt_src_t src;
    switch_mirror_type_t type;
#if __TARGET_TOFINO__ == 1
    bit<6> _pad;
#endif
    switch_mirror_session_t session_id;
}

/*added by Brian*/
header switch_update_mirror_metadata_h {
    switch_mirror_type_t type;
    bit<32> count_r0;
    bit<32> count_r1;
    bit<32> count_r2;
    bit<32> count_r3;
}

@flexible
struct switch_bridged_metadata_dtel_extension_t {
    switch_dtel_report_type_t report_type;
    switch_mirror_session_t session_id;
    bit<32> hash;
    switch_port_t egress_port;
}

//-----------------------------------------------------------------------------
// Other Metadata Definitions
//-----------------------------------------------------------------------------
// Flags
//XXX Force the fields that are XORd to NOT share containers.
@pa_container_size("ingress", "ig_md.checks.same_if", 16)
#ifdef L3_UNICAST_SELF_FORWARDING_CHECK
@pa_container_size("ingress", "ig_md.checks.same_bd", 16)
#endif
@pa_mutually_exclusive("ingress", "lkp.arp_opcode", "lkp.ip_src_addr")
@pa_mutually_exclusive("ingress", "lkp.arp_opcode", "lkp.ip_dst_addr")
@pa_mutually_exclusive("ingress", "lkp.arp_opcode", "lkp.ipv6_flow_label")
@pa_mutually_exclusive("ingress", "lkp.arp_opcode", "lkp.ip_proto")
@pa_mutually_exclusive("ingress", "lkp.arp_opcode", "lkp.ip_ttl")
@pa_mutually_exclusive("ingress", "lkp.arp_opcode", "lkp.ip_tos")
#ifdef MPLS_ENABLE
@pa_mutually_exclusive("ingress", "lkp.mpls_lookup_label", "lkp.ip_src_addr")
@pa_mutually_exclusive("ingress", "lkp.mpls_lookup_label", "lkp.ip_dst_addr")
@pa_mutually_exclusive("ingress", "lkp.mpls_lookup_label", "lkp.ipv6_flow_label")
@pa_mutually_exclusive("ingress", "lkp.mpls_lookup_label", "lkp.ip_proto")
@pa_mutually_exclusive("ingress", "lkp.mpls_lookup_label", "lkp.ip_ttl")
@pa_mutually_exclusive("ingress", "lkp.mpls_lookup_label", "lkp.ip_tos")
@pa_mutually_exclusive("ingress", "lkp.mpls_lookup_label", "lkp.arp_opcode")
@pa_mutually_exclusive("egress", "hdr.mpls[2].label", "hdr.ipv6.dst_addr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].exp",   "hdr.ipv6.dst_addr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].bos",   "hdr.ipv6.dst_addr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].label", "hdr.ipv6.src_addr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].exp",   "hdr.ipv6.src_addr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].bos",   "hdr.ipv6.src_addr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].label", "hdr.ipv6.flow_label")
@pa_mutually_exclusive("egress", "hdr.mpls[2].exp",   "hdr.ipv6.flow_label")
@pa_mutually_exclusive("egress", "hdr.mpls[2].bos",   "hdr.ipv6.flow_label")
@pa_mutually_exclusive("egress", "hdr.mpls[2].label", "hdr.ipv6.next_hdr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].exp",   "hdr.ipv6.next_hdr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].bos",   "hdr.ipv6.next_hdr")
@pa_mutually_exclusive("egress", "hdr.mpls[2].label", "hdr.ipv6.payload_len")
@pa_mutually_exclusive("egress", "hdr.mpls[2].exp",   "hdr.ipv6.payload_len")
@pa_mutually_exclusive("egress", "hdr.mpls[2].bos",   "hdr.ipv6.payload_len")
#endif

struct switch_ingress_flags_t {
    bool ipv4_checksum_err;
    bool inner_ipv4_checksum_err;
    bool inner2_ipv4_checksum_err;
    bool link_local;
    bool routed;
    bool acl_deny;
    bool racl_deny;
    bool port_vlan_miss;
    bool rmac_hit;
    bool dmac_miss;
    switch_myip_type_t myip;
    bool glean;
    bool storm_control_drop;
    bool acl_meter_drop;
    bool port_meter_drop;
    bool flood_to_multicast_routers;
    bool peer_link;
    bool capture_ts;
    bool mac_pkt_class;
    bool pfc_wd_drop;
    bool bypass_egress;
    bool mpls_trap;
    bool srv6_trap;
    // Add more flags here.
}

struct switch_egress_flags_t {
    bool routed;
    bool bypass_egress;
    bool acl_deny;
    bool mlag_member;
    bool peer_link;
    bool capture_ts;
    bool wred_drop;
    bool port_meter_drop;
    bool acl_meter_drop;
    bool pfc_wd_drop;
    bool isolation_packet_drop;

    // Add more flags here.
}


// Checks
struct switch_ingress_checks_t {
    switch_port_lag_index_t same_if;
    bool mrpf;
    bool urpf;
#ifdef NAT_ENABLE
    switch_nat_zone_t same_zone_check;
#endif
#ifdef L3_UNICAST_SELF_FORWARDING_CHECK
    switch_bd_t same_bd;
#endif
    // Add more checks here.
}

struct switch_egress_checks_t {
    switch_bd_t same_bd;
    switch_mtu_t mtu;
    bool stp;

    // Add more checks here.
}

// IP
struct switch_ip_metadata_t {
    bool unicast_enable;
    bool multicast_enable;
    bool multicast_snooping;
    // switch_urpf_mode_t urpf_mode;
}

struct switch_lookup_fields_t {
    switch_pkt_type_t pkt_type;

    mac_addr_t mac_src_addr;
    mac_addr_t mac_dst_addr;
    bit<16> mac_type;
    bit<3> pcp;

    // 1 for ARP request, 2 for ARP reply.
    bit<16> arp_opcode;

    switch_ip_type_t ip_type;
    bit<8> ip_proto;
    bit<8> ip_ttl;
    bit<8> ip_tos;
    switch_ip_frag_t ip_frag;
    bit<128> ip_src_addr;
    bit<128> ip_dst_addr;
    bit<20> ipv6_flow_label;

    bit<8> tcp_flags;
    bit<16> l4_src_port;
    bit<16> l4_dst_port;
    bit<16> hash_l4_src_port;
    bit<16> hash_l4_dst_port;

    bool mpls_pkt;
    bit<1> mpls_router_alert_label;
    bit<20> mpls_lookup_label;

    switch_hostif_trap_t hostif_trap_id;
}

struct switch_hash_fields_t {
    mac_addr_t mac_src_addr;
    mac_addr_t mac_dst_addr;
    bit<16> mac_type;
    switch_ip_type_t ip_type;
    bit<8> ip_proto;
    bit<128> ip_src_addr;
    bit<128> ip_dst_addr;
    bit<16> l4_src_port;
    bit<16> l4_dst_port;
    bit<20> ipv6_flow_label;
}

// Header types used by ingress/egress deparsers.
@flexible
struct switch_bridged_metadata_t {
    // user-defined metadata carried over from ingress to egress.
    switch_port_t ingress_port;
    switch_port_lag_index_t ingress_port_lag_index;
    switch_bd_t ingress_bd;
    switch_nexthop_t nexthop;
    switch_pkt_type_t pkt_type;
    bool routed;
    bool bypass_egress;
    //TODO(msharif) : Fix the bridged metadata fields for PTP.
#if defined(PTP_ENABLE)
    bool capture_ts;
#endif
#ifdef MLAG_ENABLE
    bool peer_link;
#endif
    switch_cpu_reason_t cpu_reason;
#if defined(PTP_ENABLE) || defined(INT_V2)
    bit<48> timestamp;
#else
    bit<32> timestamp;
#endif
    switch_tc_t tc;
    switch_qid_t qid;
    switch_pkt_color_t color;
    switch_vrf_t vrf;

    // Add more fields here.
}

@flexible
struct switch_bridged_metadata_acl_extension_t {
#if defined(EGRESS_IP_ACL_ENABLE) || defined(EGRESS_MIRROR_ACL_ENABLE)
    bit<16> l4_src_port;
    bit<16> l4_dst_port;
    bit<8> tcp_flags;
    switch_l4_port_label_t l4_src_port_label;
    switch_l4_port_label_t l4_dst_port_label;
#ifdef ACL_USER_META_ENABLE
    switch_user_metadata_t user_metadata;
#endif
#else
    bit<8> tcp_flags;
#endif
}

@flexible
struct switch_bridged_metadata_tunnel_extension_t {
//    switch_tunnel_index_t index;
    switch_tunnel_nexthop_t tunnel_nexthop;
#ifdef VXLAN_ENABLE
    bit<16> hash;
#endif
#ifdef MPLS_ENABLE
    bit<2> mpls_pop_count;
#endif
#ifdef TUNNEL_TTL_MODE_ENABLE
    switch_tunnel_mode_t ttl_mode;
#endif /* TUNNEL_TTL_MODE_ENABLE */
#ifdef TUNNEL_QOS_MODE_ENABLE
    switch_tunnel_mode_t qos_mode;
#endif /* TUNNEL_QOS_MODE_ENABLE */
    bool terminate;
}

#ifdef DTEL_ENABLE
@pa_atomic("ingress", "hdr.bridged_md.base_qid")
@pa_container_size("ingress", "hdr.bridged_md.base_qid", 8)
@pa_container_size("ingress", "hdr.bridged_md.dtel_report_type", 8)
@pa_no_overlay("ingress", "hdr.bridged_md.base_qid")
@pa_no_overlay("ingress", "hdr.bridged_md.__pad_0")
@pa_no_overlay("ingress", "hdr.bridged_md.__pad_1")
@pa_no_overlay("ingress", "hdr.bridged_md.__pad_2")
@pa_no_overlay("ingress", "hdr.bridged_md.__pad_3")
@pa_no_overlay("ingress", "hdr.bridged_md.__pad_4")
@pa_no_overlay("ingress", "hdr.bridged_md.__pad_5")
@pa_no_overlay("egress", "hdr.dtel_report.ingress_port")
@pa_no_overlay("egress", "hdr.dtel_report.egress_port")
@pa_no_overlay("egress", "hdr.dtel_report.queue_id")
@pa_no_overlay("egress", "hdr.dtel_drop_report.drop_reason")
@pa_no_overlay("egress", "hdr.dtel_drop_report.reserved")
#ifdef INT_V2
@pa_no_overlay("egress", "hdr.dtel_metadata_1.ingress_port")
@pa_no_overlay("egress", "hdr.dtel_metadata_1.egress_port")
@pa_no_overlay("egress", "hdr.dtel_metadata_3.queue_id")
@pa_no_overlay("egress", "hdr.dtel_metadata_4.ingress_timestamp")
@pa_no_overlay("egress", "hdr.dtel_metadata_5.egress_timestamp")
@pa_no_overlay("egress", "hdr.dtel_metadata_3.queue_occupancy")
#endif
@pa_no_overlay("egress", "hdr.dtel_switch_local_report.queue_occupancy")
#endif

#if defined(VXLAN_ENABLE) && defined(ERSPAN_ENABLE)
@pa_mutually_exclusive("egress", "hdr.erspan.version_vlan", "hdr.vxlan.flags")
@pa_mutually_exclusive("egress", "hdr.erspan.version_vlan", "hdr.vxlan.reserved")
@pa_mutually_exclusive("egress", "hdr.erspan.version_vlan", "hdr.vxlan.vni")
@pa_mutually_exclusive("egress", "hdr.erspan.version_vlan", "hdr.vxlan.reserved2")
@pa_mutually_exclusive("egress", "hdr.erspan.session_id", "hdr.vxlan.flags")
@pa_mutually_exclusive("egress", "hdr.erspan.session_id", "hdr.vxlan.reserved")
@pa_mutually_exclusive("egress", "hdr.erspan.session_id", "hdr.vxlan.vni")
@pa_mutually_exclusive("egress", "hdr.erspan.session_id", "hdr.vxlan.reserved2")
#endif
#if defined(ERSPAN_ENABLE)
@pa_mutually_exclusive("egress", "hdr.erspan_type3.timestamp", "hdr.erspan_type2.index")
#endif
#if defined(SRV6_ENABLE) && defined(ERSPAN_ENABLE)
@pa_mutually_exclusive("egress", "hdr.gre.proto", "hdr.srh_base.next_hdr")
@pa_mutually_exclusive("egress", "hdr.gre.proto", "hdr.srh_base.hdr_ext_len")
@pa_mutually_exclusive("egress", "hdr.gre.proto", "hdr.srh_base.routing_type")
@pa_mutually_exclusive("egress", "hdr.gre.proto", "hdr.srh_base.seg_left")
@pa_mutually_exclusive("egress", "hdr.gre.proto", "hdr.srh_base.last_entry")
@pa_mutually_exclusive("egress", "hdr.gre.proto", "hdr.srh_base.flags")
@pa_mutually_exclusive("egress", "hdr.gre.proto", "hdr.srh_base.tag")
@pa_mutually_exclusive("egress", "hdr.erspan_type3.timestamp",  "hdr.srh_seg_list[0].sid")
@pa_mutually_exclusive("egress", "hdr.erspan_type3.ft_d_other", "hdr.srh_seg_list[0].sid")
@pa_mutually_exclusive("egress", "hdr.erspan.version_vlan",     "hdr.srh_seg_list[0].sid")
@pa_mutually_exclusive("egress", "hdr.erspan.session_id",       "hdr.srh_seg_list[0].sid")
@pa_mutually_exclusive("egress", "hdr.erspan_type3.timestamp",  "hdr.srh_seg_list[1].sid")
@pa_mutually_exclusive("egress", "hdr.erspan_type3.ft_d_other", "hdr.srh_seg_list[1].sid")
@pa_mutually_exclusive("egress", "hdr.erspan.version_vlan",     "hdr.srh_seg_list[1].sid")
@pa_mutually_exclusive("egress", "hdr.erspan.session_id",       "hdr.srh_seg_list[1].sid")
@pa_mutually_exclusive("egress", "hdr.erspan_type3.timestamp",  "hdr.srh_seg_list[2].sid")
@pa_mutually_exclusive("egress", "hdr.erspan_type3.ft_d_other", "hdr.srh_seg_list[2].sid")
@pa_mutually_exclusive("egress", "hdr.erspan.version_vlan",     "hdr.srh_seg_list[2].sid")
@pa_mutually_exclusive("egress", "hdr.erspan.session_id",       "hdr.srh_seg_list[2].sid")
#endif

typedef bit<8> switch_bridge_type_t;

header switch_bridged_metadata_h {
    switch_pkt_src_t src;
    switch_bridge_type_t type;
    switch_bridged_metadata_t base;
#if defined(EGRESS_IP_ACL_ENABLE) || defined(EGRESS_MIRROR_ACL_ENABLE) \
    || defined(DTEL_FLOW_REPORT_ENABLE)
    switch_bridged_metadata_acl_extension_t acl;
#endif
#ifdef TUNNEL_ENABLE
    switch_bridged_metadata_tunnel_extension_t tunnel;
#endif
#ifdef DTEL_ENABLE
    switch_bridged_metadata_dtel_extension_t dtel;
#endif
}

struct switch_port_metadata_t {
    switch_port_lag_index_t port_lag_index;
    switch_ig_port_lag_label_t port_lag_label;
#ifdef ASYMMETRIC_FOLDED_PIPELINE
    switch_port_t ext_ingress_port;
#endif
}

// consistent hash - calculation of v6 high/low ip is
// multi-stage process. So this variable tracks the
// v6 ip sequence for crc hash - must be one of the below
//   - none
//   - low-ip is sip, high-ip is dip
//   - low-ip is dip, high-ip is sip
typedef bit<2> switch_cons_hash_ip_seq_t;
const switch_cons_hash_ip_seq_t SWITCH_CONS_HASH_IP_SEQ_NONE = 0;
const switch_cons_hash_ip_seq_t SWITCH_CONS_HASH_IP_SEQ_SIPDIP = 1;
const switch_cons_hash_ip_seq_t SWITCH_CONS_HASH_IP_SEQ_DIPSIP = 2;

@pa_auto_init_metadata

@pa_container_size("ingress", "ig_md.mirror.src", 8)
@pa_container_size("ingress", "ig_md.mirror.type", 8)
@pa_container_size("ingress", "smac_src_move", 16)
@pa_alias("ingress", "ig_md.egress_port", "ig_intr_md_for_tm.ucast_egress_port")
#if !defined(DTEL_DROP_REPORT_ENABLE) && !defined(DTEL_QUEUE_REPORT_ENABLE)
@pa_alias("ingress", "ig_md.multicast.id", "ig_intr_md_for_tm.mcast_grp_b")
#endif
@pa_alias("ingress", "ig_md.qos.qid", "ig_intr_md_for_tm.qid")
@pa_alias("ingress", "ig_md.qos.icos", "ig_intr_md_for_tm.ingress_cos")
@pa_alias("ingress", "ig_intr_md_for_dprsr.mirror_type", "ig_md.mirror.type")
@pa_container_size("ingress", "ig_md.egress_port_lag_index", 16)
#ifdef NAT_ENABLE
// Prevent container_size 32 which doubles src_napt action ram
@pa_container_size("ingress", "ig_md.nat.snapt_index", 16)
#endif
// Ingress metadata
struct switch_ingress_metadata_t {
    switch_port_t port;                            /* ingress port */
    switch_port_t egress_port;                     /* egress port */
    switch_port_lag_index_t port_lag_index;        /* ingress port/lag index */
    switch_port_lag_index_t egress_port_lag_index; /* egress port/lag index */
    switch_bd_t bd;
    switch_vrf_t vrf;
    switch_nexthop_t nexthop;
    switch_tunnel_nexthop_t tunnel_nexthop;
    switch_nexthop_t acl_nexthop;
    bool acl_port_redirect;
    switch_nexthop_t unused_nexthop;
#if defined(PTP_ENABLE) || defined(INT_V2)
    bit<48> timestamp;
#else
    bit<32> timestamp;
#endif
    switch_hash_t hash;
    switch_hash_t lag_hash;

    switch_ingress_flags_t flags;
    switch_ingress_checks_t checks;
    switch_ingress_bypass_t bypass;

    /*added by Brian*/
    bit<32> count_r0;
    bit<32> count_r1;
    bit<32> count_r2;
    bit<32> count_r3;
    MirrorId_t ing_mir_ses;
    bit<8> pkt_mirror_type;
    switch_digest_type_t dig_type;
    
    switch_ip_metadata_t ipv4;
    switch_ip_metadata_t ipv6;
    switch_ig_port_lag_label_t port_lag_label;
    switch_bd_label_t bd_label;
    switch_if_label_t if_label;
    switch_l4_port_label_t l4_src_port_label;
    switch_l4_port_label_t l4_dst_port_label;

    switch_drop_reason_t l2_drop_reason;
    switch_drop_reason_t drop_reason;
    switch_cpu_reason_t cpu_reason;

    switch_lookup_fields_t lkp;
    switch_hash_fields_t hash_fields;
    switch_multicast_metadata_t multicast;
    switch_stp_metadata_t stp;
    switch_qos_metadata_t qos;
    switch_sflow_metadata_t sflow;
    switch_tunnel_metadata_t tunnel;
    switch_learning_metadata_t learning;
    switch_mirror_metadata_t mirror;
    switch_dtel_metadata_t dtel;
    mac_addr_t same_mac;

    switch_user_metadata_t user_metadata;
#ifdef NAT_ENABLE
    bit<16> tcp_udp_checksum;
    switch_nat_ingress_metadata_t nat;
#endif
    bit<10> partition_key;
    bit<12> partition_index;
    switch_fib_label_t fib_label;

    switch_cons_hash_ip_seq_t cons_hash_v6_ip_seq;
}

/*added by Brian*/
struct switch_report_digest_t {
    ipv4_addr_t src_addr;
    //switch_digest_type_t dig_type;
}

// Egress metadata
@pa_container_size("egress", "eg_md.mirror.src", 8)
@pa_container_size("egress", "eg_md.mirror.type", 8)
#ifdef DTEL_ENABLE
@pa_container_size("egress", "hdr.dtel_drop_report.drop_reason", 8)
@pa_mutually_exclusive("egress", "hdr.dtel.timestamp", "hdr.erspan_type3.timestamp")
#endif

struct switch_egress_metadata_t {
    switch_pkt_src_t pkt_src;
    switch_pkt_length_t pkt_length;
    switch_pkt_type_t pkt_type;

    /* ingress port_lag_index for cpu going packets, egress port_lag_index for
     * normal ports */
    switch_port_lag_index_t port_lag_index;

    switch_port_type_t port_type;               /* egress port type */
    switch_port_t port;                         /* Mutable copy of egress port */
    switch_port_t ingress_port;                 /* ingress port */
    switch_bd_t bd;
    switch_vrf_t vrf;
    switch_nexthop_t nexthop;
    switch_tunnel_nexthop_t tunnel_nexthop;

#if defined(PTP_ENABLE) || defined(INT_V2)
    bit<48> timestamp;
    bit<48> ingress_timestamp;
#else
    bit<32> timestamp;
    bit<32> ingress_timestamp;
#endif

    switch_egress_flags_t flags;
    switch_egress_checks_t checks;

    // for egress ACL
    switch_eg_port_lag_label_t port_lag_label;
    switch_bd_label_t bd_label;
    switch_if_label_t if_label;
    switch_l4_port_label_t l4_src_port_label;
    switch_l4_port_label_t l4_dst_port_label;

    switch_lookup_fields_t lkp;
    switch_qos_metadata_t qos;
    switch_tunnel_metadata_t tunnel;
    switch_mirror_metadata_t mirror;
    switch_dtel_metadata_t dtel;
    switch_sflow_metadata_t sflow;

    switch_cpu_reason_t cpu_reason;
    switch_drop_reason_t drop_reason;

    switch_nexthop_type_t nexthop_type;

#ifdef ACL_USER_META_ENABLE
    switch_user_metadata_t user_metadata;
#endif
    bool inner_ipv4_checksum_update_en;
#ifdef PORT_ISOLATION_ENABLE
    switch_isolation_group_t isolation_group;
#endif
}

// Header format for mirrored metadata fields
struct switch_mirror_metadata_h {
    switch_port_mirror_metadata_h port;
    switch_cpu_mirror_metadata_h cpu;
    switch_dtel_drop_mirror_metadata_h dtel_drop;
    switch_dtel_switch_local_mirror_metadata_h dtel_switch_local;
    switch_simple_mirror_metadata_h simple_mirror;
}


struct switch_header_t {
    switch_bridged_metadata_h bridged_md;
    // switch_mirror_metadata_h mirror;
    ethernet_h ethernet;
    fabric_h fabric;
    cpu_h cpu;
    timestamp_h timestamp;
    vlan_tag_h[VLAN_DEPTH] vlan_tag;
    mpls_h[MPLS_DEPTH] mpls;
    ipv4_h ipv4;
    ipv4_option_h ipv4_option;
    ipv6_h ipv6;
    arp_h arp;
    ipv6_srh_h srh_base;
    ipv6_segment_h[SEGMENT_DEPTH] srh_seg_list;
    udp_h udp;
    icmp_h icmp;
    igmp_h igmp;
    tcp_h tcp;
#ifdef INT_V2
    dtel_report_v20_h dtel;
    dtel_metadata_1_h dtel_metadata_1;
    dtel_metadata_2_h dtel_metadata_2;
    dtel_metadata_3_h dtel_metadata_3;
    dtel_metadata_4_h dtel_metadata_4;
    dtel_metadata_5_h dtel_metadata_5;
    dtel_report_metadata_15_h dtel_drop_report;
#else
    dtel_report_v05_h dtel;
    dtel_report_base_h dtel_report;
    dtel_switch_local_report_h dtel_switch_local_report;
    dtel_drop_report_h dtel_drop_report;
#endif
    rocev2_bth_h rocev2_bth;
    gtpu_h gtp;
    vxlan_h vxlan;
    gre_h gre;
    nvgre_h nvgre;
    geneve_h geneve;
    erspan_h erspan;
    erspan_type2_h erspan_type2;
    erspan_type3_h erspan_type3;
    erspan_platform_h erspan_platform;
    ethernet_h inner_ethernet;
    ipv4_h inner_ipv4;
    ipv6_h inner_ipv6;
    udp_h inner_udp;
    tcp_h inner_tcp;
    icmp_h inner_icmp;
    ipv4_h inner2_ipv4;
    ipv6_h inner2_ipv6;
    udp_h inner2_udp;
    tcp_h inner2_tcp;
    icmp_h inner2_icmp;
}

#endif /* _P4_TYPES_ */
