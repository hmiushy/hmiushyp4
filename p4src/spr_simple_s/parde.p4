/*******************************************************************************
 * BAREFOOT NETWORKS CONFIDENTIAL & PROPRIETARY
 *
 * Copyright (c) 2015-2019 Barefoot Networks, Inc.
 *
 * NOTICE: All information contained herein is, and remains the property of
 * Barefoot Networks, Inc. and its suppliers, if any. The intellectual and
 * technical concepts contained herein are proprietary to Barefoot Networks,
 * Inc.
 * and its suppliers and may be coverep by U.S. and Foreign Patents, patents in
 * process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from
 * Barefoot Networks, Inc.
 *
 * No warranty, explicit or implicit is provided, unless granted under a
 * written agreement with Barefoot Networks, Inc.
 *
 ******************************************************************************/

#include "headers.p4"
#include "types.p4"

//=============================================================================
// Ingress parser
//=============================================================================
parser SwitchIngressParser(
        packet_in pkt,
        out switch_header_t hdr,
        out switch_ingress_metadata_t ig_md,
        out ingress_intrinsic_metadata_t ig_intr_md) {
    Checksum() ipv4_checksum;
    Checksum() inner_ipv4_checksum;
    Checksum() inner2_ipv4_checksum;
    value_set<bit<16>>(1) udp_port_vxlan;
    value_set<switch_cpu_port_value_set_t>(1) cpu_port;
    value_set<switch_nvgre_value_set_t>(1) nvgre_st_key;
#ifdef NAT_ENABLE
    Checksum() tcp_checksum;
    Checksum() udp_checksum;
#endif

    state start {
        pkt.extract(ig_intr_md);
        ig_md.port = ig_intr_md.ingress_port;
#if defined(PTP_ENABLE) || defined(INT_V2)
        ig_md.timestamp = ig_intr_md.ingress_mac_tstamp;
#else
        ig_md.timestamp = ig_intr_md.ingress_mac_tstamp[31:0];
#endif
        // Check for resubmit flag if packet is resubmitted.
        // transition select(ig_intr_md.resubmit_flag) {
        //    1 : parse_resubmit;
        //    0 : parse_port_metadata;
        // }
        transition parse_port_metadata;
    }

    state parse_resubmit {
        // Parse resubmitted packet here.
        transition accept;
    }

    state parse_port_metadata {
        // Parse port metadata produced by ibuf
        switch_port_metadata_t port_md = port_metadata_unpack<switch_port_metadata_t>(pkt);
        ig_md.port_lag_index = port_md.port_lag_index;
        ig_md.port_lag_label = port_md.port_lag_label;
#ifdef ASYMMETRIC_FOLDED_PIPELINE
        ig_md.port = port_md.ext_ingress_port;
#endif
        transition parse_packet;
    }

    state parse_packet {
        /*added by Brian*/
        switch_update_mirror_metadata_h mirror_md = pkt.lookahead<switch_update_mirror_metadata_h>();
        transition select( mirror_md.type) {
            (SWITCH_MIRROR_TYPE_UPDATE) : parse_mirrored_update;
        default: parse_ethernet;
        }
    }

    /*added by Brian*/
    state parse_mirrored_update {
        switch_update_mirror_metadata_h update_mirror_md;
        pkt.extract(update_mirror_md);
        ig_md.count_r0 = update_mirror_md.count_r0;
        ig_md.count_r1 = update_mirror_md.count_r1;
        ig_md.count_r2 = update_mirror_md.count_r2;
        ig_md.count_r3 = update_mirror_md.count_r3;
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type, ig_md.port) {
            cpu_port  : parse_cpu;
            (ETHERTYPE_IPV4, _) : parse_ipv4;
            (ETHERTYPE_ARP, _)  : parse_arp;
            (ETHERTYPE_IPV6, _) : parse_ipv6;
            (ETHERTYPE_VLAN, _) : parse_vlan;
            (ETHERTYPE_QINQ, _) : parse_vlan;
#ifdef MPLS_ENABLE
            (ETHERTYPE_MPLS, _) : parse_mpls;
#endif /* MPLS_ENABLE */
            default : accept;
        }
    }

    state parse_cpu {
        pkt.extract(hdr.fabric);
        pkt.extract(hdr.cpu);
        ig_md.bypass = hdr.cpu.reason_code;
#if defined(PTP_ENABLE)
        ig_md.flags.capture_ts = (bool) hdr.cpu.capture_ts;
#endif
        transition select(hdr.cpu.ether_type) {
            ETHERTYPE_IPV4 : parse_ipv4;
            ETHERTYPE_ARP  : parse_arp;
            ETHERTYPE_IPV6 : parse_ipv6;
            ETHERTYPE_VLAN : parse_vlan;
            ETHERTYPE_QINQ : parse_vlan;
#ifdef MPLS_ENABLE
            ETHERTYPE_MPLS : parse_mpls;
#endif /* MPLS_ENABLE */
            default : accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.ip_type = SWITCH_IP_TYPE_IPV4;
        ig_md.hash_fields.ip_src_addr[95:64] = hdr.ipv4.src_addr;
        ig_md.hash_fields.ip_dst_addr[95:64] = hdr.ipv4.dst_addr;
        ig_md.hash_fields.ip_proto = hdr.ipv4.protocol;
#endif /* INNER_HASH_ENABLE */
        ipv4_checksum.add(hdr.ipv4);
#ifdef NAT_ENABLE
        tcp_checksum.subtract({hdr.ipv4.src_addr,hdr.ipv4.dst_addr});
        udp_checksum.subtract({hdr.ipv4.src_addr,hdr.ipv4.dst_addr});
#endif
        transition select(hdr.ipv4.ihl) {
            5 : parse_ipv4_no_options;
            6 : parse_ipv4_options;
            default : accept;
        }
    }

    state parse_ipv4_options {
        // Only a single 32-bit option (e.g. router alert) is supported.
        pkt.extract(hdr.ipv4_option);
        ipv4_checksum.add(hdr.ipv4_option);
        transition parse_ipv4_no_options;
    }

    state parse_ipv4_no_options {
        ig_md.flags.ipv4_checksum_err = ipv4_checksum.verify();
        transition select(hdr.ipv4.protocol, hdr.ipv4.frag_offset) {
            (IP_PROTOCOLS_ICMP, 0) : parse_icmp;
            (IP_PROTOCOLS_IGMP, 0) : parse_igmp;
            (IP_PROTOCOLS_TCP, 0) : parse_tcp;
            (IP_PROTOCOLS_UDP, 0) : parse_udp;
            (IP_PROTOCOLS_GRE, 0) : parse_ip_gre;
            (IP_PROTOCOLS_IPV4, 0) : parse_ipinip;
            (IP_PROTOCOLS_IPV6, 0) : parse_ipv6inip;
            // Do NOT parse the next header if IP packet is fragmented.
            default : accept;
        }
    }

    state parse_arp {
        pkt.extract(hdr.arp);
        transition accept;
    }

    state parse_vlan {
        pkt.extract(hdr.vlan_tag.next);
        transition select(hdr.vlan_tag.last.ether_type) {
            ETHERTYPE_ARP : parse_arp;
            ETHERTYPE_IPV4 : parse_ipv4;
            ETHERTYPE_VLAN : parse_vlan;
            ETHERTYPE_IPV6 : parse_ipv6;
#ifdef MPLS_ENABLE
            ETHERTYPE_MPLS : parse_mpls;
#endif /* MPLS_ENABLE */
            default : accept;
        }
    }

    state parse_ipv6 {
#ifdef IPV6_ENABLE
        pkt.extract(hdr.ipv6);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.ip_type = SWITCH_IP_TYPE_IPV6;
        ig_md.hash_fields.ip_src_addr = hdr.ipv6.src_addr;
        ig_md.hash_fields.ip_dst_addr = hdr.ipv6.dst_addr;
        ig_md.hash_fields.ip_proto = hdr.ipv6.next_hdr;
        ig_md.hash_fields.ipv6_flow_label = hdr.ipv6.flow_label;
#endif /* INNER_HASH_ENABLE */
#ifdef NAT_ENABLE
        tcp_checksum.subtract({hdr.ipv6.src_addr,hdr.ipv6.dst_addr});
        udp_checksum.subtract({hdr.ipv6.src_addr,hdr.ipv6.dst_addr});
#endif
        transition select(hdr.ipv6.next_hdr) {
            IP_PROTOCOLS_ICMPV6 : parse_icmp;
            IP_PROTOCOLS_TCP : parse_tcp;
            IP_PROTOCOLS_UDP : parse_udp;
            IP_PROTOCOLS_GRE : parse_ip_gre;
            IP_PROTOCOLS_IPV4 : parse_ipinip;
            IP_PROTOCOLS_IPV6 : parse_ipv6inip;
#ifdef SRV6_ENABLE
            IP_PROTOCOLS_ROUTING : parse_srh_base;
#endif /* SRV6_ENABLE */
            default : accept;
        }
#else
        transition accept;
#endif
    }

#ifdef MPLS_ENABLE
    state parse_mpls {
        pkt.extract(hdr.mpls.next);
        transition select(hdr.mpls.last.bos) {
            0 : parse_mpls;
            1 : parse_mpls_bos;
        }
    }

    state parse_mpls_bos {
        ig_md.tunnel.type = SWITCH_INGRESS_TUNNEL_TYPE_MPLS;
        transition select(pkt.lookahead<bit<4>>()) {
            0x4 : parse_inner_ipv4;
            0x6 : parse_inner_ipv6;
            default : accept;
//            default : parse_inner_ethernet; // Inner L2 is not supported
        }
    }
#endif /* MPLS_ENABLE */

#ifdef SRV6_ENABLE
    state parse_srh_base {
        pkt.extract(hdr.srh_base);
        ig_md.tunnel.srh_seg_left = hdr.srh_base.seg_left;
        ig_md.tunnel.srh_next_hdr = hdr.srh_base.next_hdr;
        transition select(hdr.srh_base.last_entry, hdr.srh_base.seg_left) {
            (0, 1) : parse_srh_active_and_done_0; // active and the last segment in the segment list
            (0, _) : parse_srh_done_0;            // last segment
            (_, 1) : parse_srh_active_and_continue_0; // active segment
            default : parse_srh_continue_0;           // continue parsing
        }
    }

    state parse_srh_active_and_done_0 {
        pkt.extract(hdr.srh_seg_list[0]);
        ig_md.tunnel.srh_next_sid = hdr.srh_seg_list[0].sid;
        transition parse_srh_next_hdr;
    }

    state parse_srh_done_0 {
        pkt.extract(hdr.srh_seg_list[0]);
        // ig_md.tunnel.srh_next_sid is not populated since ip_da is assumed to be carrying the last segment
        transition parse_srh_next_hdr;
    }

    state parse_srh_active_and_continue_0 {
        pkt.extract(hdr.srh_seg_list[0]);
        ig_md.tunnel.srh_next_sid = hdr.srh_seg_list[0].sid;
        transition parse_srh_segment_1;
    }

    state parse_srh_continue_0 {
        pkt.extract(hdr.srh_seg_list[0]);
//        ig_md.tunnel.srh_next_sid = hdr.srh_seg_list[0].sid;
        transition parse_srh_segment_1;
    }

    state parse_srh_segment_1 {
        transition select(hdr.srh_base.last_entry, hdr.srh_base.seg_left) {
            (1, 2) : parse_srh_active_and_done_1; // active and the last segment in the segment list
            (1, _) : parse_srh_done_1;            // last segment
            (0, _) : parse_srh_done_1;            // last segment
            default : accept;
        }
    }

    state parse_srh_active_and_done_1 {
        pkt.extract(hdr.srh_seg_list[1]);
        ig_md.tunnel.srh_next_sid = hdr.srh_seg_list[1].sid;
        transition parse_srh_next_hdr;
    }

    state parse_srh_done_1 {
        pkt.extract(hdr.srh_seg_list[1]);
        transition parse_srh_next_hdr;
    }

    #define PARSE_SRH_SEGMENT(curr, next) \
    state parse_srh_segment_##curr { \
        transition select(hdr.srh_base.last_entry, hdr.srh_base.seg_left) { \
            (##curr, ##next) : parse_srh_active_and_done_##curr; \
            (##curr, _) : parse_srh_done_##curr; \
            (_, 1) : parse_srh_active_and_continue_##curr; \
            default : parse_srh_continue_##curr; \
        } \
    } \
    state parse_srh_active_and_done_##curr { \
        pkt.extract(hdr.srh_seg_list[##curr]); \
        ig_md.tunnel.srh_next_sid = hdr.srh_seg_list[##curr].sid; \
        transition parse_srh_next_hdr; \
    } \
    state parse_srh_done_##curr { \
        pkt.extract(hdr.srh_seg_list[##curr]);\
        transition parse_srh_next_hdr; \
    } \
    state parse_srh_active_and_continue_##curr { \
        pkt.extract(hdr.srh_seg_list[##curr]); \
        ig_md.tunnel.srh_next_sid = hdr.srh_seg_list[##curr].sid; \
        transition parse_srh_segment_##next; \
    } \
    state parse_srh_continue_##curr { \
        pkt.extract(hdr.srh_seg_list[##curr]); \
        ig_md.tunnel.srh_next_sid = hdr.srh_seg_list[##curr].sid; \
        transition parse_srh_segment_##next; \
    } \
    /*
    PARSE_SRH_SEGMENT(1,2)
    PARSE_SRH_SEGMENT(2,3)
    */
    state parse_srh_next_hdr {
        // TODO : Parse TLV
        // TLV is present if (hdr.srh_base.last_entry+1)*2 < hdr.srh_base.hdr_ext_len
        transition select(hdr.srh_base.next_hdr) {
            IP_PROTOCOLS_IPV6 : parse_inner_ipv6;
            IP_PROTOCOLS_IPV4 : parse_inner_ipv4;
//            IP_PROTOCOLS_NONXT : parse_inner_ethernet;
            default: accept;
        }
    }
#endif /* SRV6_ENABLE */


#ifdef NVGRE_ENABLE
    // With outer IP as V4/V6
    // nvgre key is 32 bits i.e. combination of both vsid[24 bit], flow_id [8 bit]
    // nvgre-st format  - ipv4/ipv6 -> gre -> nvgre[key==config-key] -> ipv4/ipv6
    // nvgre format     - ipv4/ipv6 -> gre -> nvgre[key!=config-key] -> ipv4/ipv6
    state parse_ip_nvgre {
        pkt.extract(hdr.nvgre);
        ig_md.tunnel.vni = hdr.nvgre.vsid_flowid[31:8];
        ig_md.tunnel.nvgre_flow_id = hdr.nvgre.vsid_flowid[7:0];

        // nvgre-st will have config key value or 0x6400
        transition select(hdr.nvgre.vsid_flowid) {
            nvgre_st_key : parse_nvgre_st;     // nvgre-st
            default : parse_nvgre;             // nvgre
        }
    }

    // nvgre format - ipv4/ipv6 -> gre -> nvgre[key!=config-key] -> ipv4/ipv6
    state parse_nvgre {
        ig_md.tunnel.type = SWITCH_INGRESS_TUNNEL_TYPE_NVGRE;
        transition parse_inner_ethernet;
    }

    // nvgre-st format - ipv4/ipv6 -> gre -> nvgre[key=config-key] -> ipv4/ipv6
    state parse_nvgre_st {
        ig_md.tunnel.type = SWITCH_INGRESS_TUNNEL_TYPE_NVGRE_ST;
        transition parse_inner_ethernet;
    }
#endif

    state parse_ip_gre {
        pkt.extract(hdr.gre);
        transition select(hdr.gre.C, hdr.gre.R, hdr.gre.K, hdr.gre.S, hdr.gre.s,
                          hdr.gre.recurse, hdr.gre.flags, hdr.gre.version, hdr.gre.proto) {
#ifdef NVGRE_ENABLE
            (0, 0, 1, 0, 0, 0, 0, 0, GRE_PROTOCOLS_NVGRE) : parse_ip_nvgre;
#endif
            (_, _, _, _, _, _, _, _, GRE_PROTOCOLS_IP) : parse_inner_ipv4;
            (_, _, _, _, _, _, _, _, GRE_PROTOCOLS_IPV6) : parse_inner_ipv6;
            default : accept;
        }
    }

    state parse_udp {
        pkt.extract(hdr.udp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port = hdr.udp.src_port;
        ig_md.hash_fields.l4_dst_port = hdr.udp.dst_port;
#endif /* INNER_HASH_ENABLE */
#ifdef NAT_ENABLE
        udp_checksum.subtract_all_and_deposit(ig_md.tcp_udp_checksum);
        udp_checksum.subtract({hdr.udp.checksum});
        udp_checksum.subtract({hdr.udp.src_port, hdr.udp.dst_port});
#endif
        transition select(hdr.udp.dst_port) {
            UDP_PORT_GTP_U : parse_gtp_u;
#ifdef VXLAN_ENABLE
            udp_port_vxlan : parse_vxlan;
#endif
            UDP_PORT_ROCEV2 : parse_rocev2;
                default : accept;
            }
    }

    state parse_tcp {
        pkt.extract(hdr.tcp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port = hdr.tcp.src_port;
        ig_md.hash_fields.l4_dst_port = hdr.tcp.dst_port;
#endif /* INNER_HASH_ENABLE */
#ifdef NAT_ENABLE
        tcp_checksum.subtract_all_and_deposit(ig_md.tcp_udp_checksum);
        tcp_checksum.subtract({hdr.tcp.checksum});
        tcp_checksum.subtract({hdr.tcp.src_port, hdr.tcp.dst_port});
#endif
        transition accept;
    }

    state parse_icmp {
        pkt.extract(hdr.icmp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port[7:0] = hdr.icmp.type;
        ig_md.hash_fields.l4_src_port[15:8] = hdr.icmp.code;
#endif /* INNER_HASH_ENABLE */
        transition accept;
    }

    state parse_igmp {
        pkt.extract(hdr.igmp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port[7:0] = hdr.igmp.type;
        ig_md.hash_fields.l4_src_port[15:8] = hdr.igmp.code;
#endif /* INNER_HASH_ENABLE */
        transition accept;
    }

    state parse_gtp_u {
        // TODO : is there a need to parse inner headers
        pkt.extract(hdr.gtp);
        transition accept;
    }

    state parse_rocev2 {
#ifdef ROCEV2_ACL_ENABLE
        pkt.extract(hdr.rocev2_bth);
#endif
        transition accept;
    }

    state parse_vxlan {
        pkt.extract(hdr.vxlan);
        ig_md.tunnel.type = SWITCH_INGRESS_TUNNEL_TYPE_VXLAN;
        ig_md.tunnel.vni = hdr.vxlan.vni;
        transition parse_inner_ethernet;
    }

    state parse_ipinip {
#ifdef IPINIP_ENABLE
        ig_md.tunnel.type = SWITCH_INGRESS_TUNNEL_TYPE_IPINIP;
        transition parse_inner_ipv4;
#else
        transition accept;
#endif
    }

    state parse_ipv6inip {
#if defined(IPINIP_ENABLE)
        ig_md.tunnel.type = SWITCH_INGRESS_TUNNEL_TYPE_IPINIP;
        transition parse_inner_ipv6;
#else
        transition accept;
#endif
    }

    state parse_inner_ethernet {
        pkt.extract(hdr.inner_ethernet);
        transition select(hdr.inner_ethernet.ether_type) {
            ETHERTYPE_IPV4 : parse_inner_ipv4;
            ETHERTYPE_IPV6 : parse_inner_ipv6;
            default : accept;
        }
    }

    state parse_inner_ipv4 {
        pkt.extract(hdr.inner_ipv4);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.ip_type = SWITCH_IP_TYPE_IPV4;
        ig_md.hash_fields.ip_src_addr[95:64] = hdr.inner_ipv4.src_addr;
        ig_md.hash_fields.ip_dst_addr[95:64] = hdr.inner_ipv4.dst_addr;
        ig_md.hash_fields.ip_proto = hdr.inner_ipv4.protocol;
#endif /* INNER_HASH_ENABLE */
        inner_ipv4_checksum.add(hdr.inner_ipv4);
        ig_md.flags.inner_ipv4_checksum_err = inner_ipv4_checksum.verify();
        transition select(hdr.inner_ipv4.protocol) {
            IP_PROTOCOLS_ICMP : parse_inner_icmp;
            IP_PROTOCOLS_TCP : parse_inner_tcp;
            IP_PROTOCOLS_UDP : parse_inner_udp;
#ifdef INNER_HASH_ENABLE
            IP_PROTOCOLS_IPV4 : parse_inner2_ipv4;
            IP_PROTOCOLS_IPV6 : parse_inner2_ipv6;
#endif /* INNER_HASH_ENABLE */
            default : accept;
        }
    }

    state parse_inner_ipv6 {
        pkt.extract(hdr.inner_ipv6);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.ip_type = SWITCH_IP_TYPE_IPV6;
        ig_md.hash_fields.ip_src_addr = hdr.inner_ipv6.src_addr;
        ig_md.hash_fields.ip_dst_addr = hdr.inner_ipv6.dst_addr;
        ig_md.hash_fields.ip_proto = hdr.inner_ipv6.next_hdr;
        ig_md.hash_fields.ipv6_flow_label = hdr.inner_ipv6.flow_label;
#endif /* INNER_HASH_ENABLE */
        transition select(hdr.inner_ipv6.next_hdr) {
            IP_PROTOCOLS_ICMPV6 : parse_inner_icmp;
            IP_PROTOCOLS_TCP : parse_inner_tcp;
            IP_PROTOCOLS_UDP : parse_inner_udp;
            default : accept;
        }
    }

    state parse_inner_udp {
        pkt.extract(hdr.inner_udp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port = hdr.inner_udp.src_port;
        ig_md.hash_fields.l4_dst_port = hdr.inner_udp.dst_port;
#endif /* INNER_HASH_ENABLE */
        transition accept;
    }

    state parse_inner_tcp {
        pkt.extract(hdr.inner_tcp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port = hdr.inner_tcp.src_port;
        ig_md.hash_fields.l4_dst_port = hdr.inner_tcp.dst_port;
#endif /* INNER_HASH_ENABLE */
        transition accept;
    }

    state parse_inner_icmp {
        pkt.extract(hdr.inner_icmp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port[7:0] = hdr.inner_icmp.type;
        ig_md.hash_fields.l4_src_port[15:8] = hdr.inner_icmp.code;
#endif /* INNER_HASH_ENABLE */
        transition accept;
    }

#ifdef INNER_HASH_ENABLE
    state parse_inner2_ipv4 {
        pkt.extract(hdr.inner2_ipv4);
        ig_md.hash_fields.ip_type = SWITCH_IP_TYPE_IPV4;
        ig_md.hash_fields.ip_src_addr[95:64] = hdr.inner2_ipv4.src_addr;
        ig_md.hash_fields.ip_dst_addr[95:64] = hdr.inner2_ipv4.dst_addr;
        ig_md.hash_fields.ip_proto = hdr.inner2_ipv4.protocol;
        inner2_ipv4_checksum.add(hdr.inner2_ipv4);
        ig_md.flags.inner2_ipv4_checksum_err = inner2_ipv4_checksum.verify();
        transition select(hdr.inner2_ipv4.protocol) {
            IP_PROTOCOLS_ICMP : parse_inner2_icmp;
            IP_PROTOCOLS_TCP : parse_inner2_tcp;
            IP_PROTOCOLS_UDP : parse_inner2_udp;
            default : accept;
        }
    }

    state parse_inner2_ipv6 {
        pkt.extract(hdr.inner2_ipv6);
        ig_md.hash_fields.ip_type = SWITCH_IP_TYPE_IPV6;
        ig_md.hash_fields.ip_src_addr = hdr.inner2_ipv6.src_addr;
        ig_md.hash_fields.ip_dst_addr = hdr.inner2_ipv6.dst_addr;
        ig_md.hash_fields.ip_proto = hdr.inner2_ipv6.next_hdr;
        ig_md.hash_fields.ipv6_flow_label = hdr.inner2_ipv6.flow_label;
        transition select(hdr.inner2_ipv6.next_hdr) {
            IP_PROTOCOLS_ICMPV6 : parse_inner2_icmp;
            IP_PROTOCOLS_TCP : parse_inner2_tcp;
            IP_PROTOCOLS_UDP : parse_inner2_udp;
            default : accept;
        }
    }

    state parse_inner2_udp {
        pkt.extract(hdr.inner2_udp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port = hdr.inner2_udp.src_port;
        ig_md.hash_fields.l4_dst_port = hdr.inner2_udp.dst_port;
#endif /* INNER_HASH_ENABLE */
        transition accept;
    }

    state parse_inner2_tcp {
        pkt.extract(hdr.inner2_tcp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port = hdr.inner2_tcp.src_port;
        ig_md.hash_fields.l4_dst_port = hdr.inner2_tcp.dst_port;
#endif /* INNER_HASH_ENABLE */
        transition accept;
    }

    state parse_inner2_icmp {
        pkt.extract(hdr.inner2_icmp);
#ifdef INNER_HASH_ENABLE
        ig_md.hash_fields.l4_src_port[7:0] = hdr.inner2_icmp.type;
        ig_md.hash_fields.l4_src_port[15:8] = hdr.inner2_icmp.code;
#endif /* INNER_HASH_ENABLE */
        transition accept;
    }

#endif /* INNER_HASH_ENABLE */

}

//----------------------------------------------------------------------------
// Egress parser
//----------------------------------------------------------------------------
parser SwitchEgressParser(
        packet_in pkt,
        out switch_header_t hdr,
        out switch_egress_metadata_t eg_md,
        out egress_intrinsic_metadata_t eg_intr_md) {

    value_set<bit<16>>(1) udp_port_vxlan;
    value_set<switch_cpu_port_value_set_t>(1) cpu_port;
    value_set<switch_nvgre_value_set_t>(1) nvgre_st_key;

    @critical
    state start {
        pkt.extract(eg_intr_md);
        eg_md.pkt_length = eg_intr_md.pkt_length;
        eg_md.port = eg_intr_md.egress_port;
        eg_md.qos.qdepth = eg_intr_md.deq_qdepth;

#ifdef MIRROR_ENABLE
        switch_port_mirror_metadata_h mirror_md = pkt.lookahead<switch_port_mirror_metadata_h>();
        transition select(eg_intr_md.deflection_flag, mirror_md.src, mirror_md.type) {
            (1, _, _) : parse_deflected_pkt;
            (_, SWITCH_PKT_SRC_BRIDGED, _) : parse_bridged_pkt;
            (_, _, SWITCH_MIRROR_TYPE_PORT) : parse_port_mirrored_metadata;
            (_, SWITCH_PKT_SRC_CLONED_EGRESS, SWITCH_MIRROR_TYPE_CPU) : parse_cpu_mirrored_metadata;
            (_, SWITCH_PKT_SRC_CLONED_INGRESS, SWITCH_MIRROR_TYPE_DTEL_DROP) : parse_dtel_drop_metadata_from_ingress;
            (_, _, SWITCH_MIRROR_TYPE_DTEL_DROP) : parse_dtel_drop_metadata_from_egress;
            (_, _, SWITCH_MIRROR_TYPE_DTEL_SWITCH_LOCAL) : parse_dtel_switch_local_metadata;
            (_, _, SWITCH_MIRROR_TYPE_SIMPLE) : parse_simple_mirrored_metadata;
        }
#else
        transition parse_bridged_pkt;
#endif
    }

    state parse_bridged_pkt {
        pkt.extract(hdr.bridged_md);
        eg_md.pkt_src = SWITCH_PKT_SRC_BRIDGED;
        eg_md.ingress_port = hdr.bridged_md.base.ingress_port;
        eg_md.port_lag_index = hdr.bridged_md.base.ingress_port_lag_index;
        eg_md.bd = hdr.bridged_md.base.ingress_bd;
        eg_md.nexthop = hdr.bridged_md.base.nexthop;
        eg_md.cpu_reason = hdr.bridged_md.base.cpu_reason;
        eg_md.flags.routed = hdr.bridged_md.base.routed;
        eg_md.flags.bypass_egress = hdr.bridged_md.base.bypass_egress;

#if defined(MLAG_ENABLE)
        eg_md.flags.peer_link = hdr.bridged_md.base.peer_link;
#endif
#if defined(PTP_ENABLE)
        eg_md.flags.capture_ts = hdr.bridged_md.base.capture_ts;
#endif
        eg_md.pkt_type = hdr.bridged_md.base.pkt_type;
        eg_md.ingress_timestamp = hdr.bridged_md.base.timestamp;
        eg_md.qos.tc = hdr.bridged_md.base.tc;
        eg_md.qos.qid = hdr.bridged_md.base.qid;
        eg_md.qos.color = hdr.bridged_md.base.color;
        eg_md.vrf = hdr.bridged_md.base.vrf;

#if defined(EGRESS_IP_ACL_ENABLE) || defined(EGRESS_MIRROR_ACL_ENABLE)
        eg_md.l4_src_port_label = hdr.bridged_md.acl.l4_src_port_label;
        eg_md.l4_dst_port_label = hdr.bridged_md.acl.l4_dst_port_label;
        eg_md.lkp.l4_src_port = hdr.bridged_md.acl.l4_src_port;
        eg_md.lkp.l4_dst_port = hdr.bridged_md.acl.l4_dst_port;
        eg_md.lkp.tcp_flags = hdr.bridged_md.acl.tcp_flags;
#ifdef ACL_USER_META_ENABLE
        eg_md.user_metadata = hdr.bridged_md.acl.user_metadata;
#endif // ACL_USER_META_ENABLE
#elif defined (DTEL_FLOW_REPORT_ENABLE)
        eg_md.lkp.tcp_flags = hdr.bridged_md.acl.tcp_flags;
#endif // EGRESS_IP_ACL_ENABLE || EGRESS_MIRROR_ACL_ENABLE
#ifdef TUNNEL_ENABLE
        eg_md.tunnel_nexthop = hdr.bridged_md.tunnel.tunnel_nexthop;
#ifdef VXLAN_ENABLE
        eg_md.tunnel.hash = hdr.bridged_md.tunnel.hash;
#endif
#ifdef MPLS_ENABLE
        eg_md.tunnel.mpls_pop_count = hdr.bridged_md.tunnel.mpls_pop_count;
#endif
#ifdef TUNNEL_TTL_MODE_ENABLE
        eg_md.tunnel.ttl_mode = hdr.bridged_md.tunnel.ttl_mode;
#endif /* TUNNEL_TTL_MODE_ENABLE */
#ifdef TUNNEL_QOS_MODE_ENABLE
        eg_md.tunnel.qos_mode = hdr.bridged_md.tunnel.qos_mode;
#endif /* TUNNEL_QOS_MODE_ENABLE */
        eg_md.tunnel.terminate = hdr.bridged_md.tunnel.terminate;
#endif /* TUNNEL_ENABLE */
#ifdef DTEL_ENABLE
        eg_md.dtel.report_type = hdr.bridged_md.dtel.report_type;
        eg_md.dtel.hash = hdr.bridged_md.dtel.hash;
        eg_md.dtel.session_id = hdr.bridged_md.dtel.session_id;
#endif

        transition parse_ethernet;
    }

    state parse_deflected_pkt {
#ifdef DTEL_ENABLE
        pkt.extract(hdr.bridged_md);
        eg_md.pkt_src = SWITCH_PKT_SRC_DEFLECTED;
#ifdef PACKET_LENGTH_ADJUSTMENT
        eg_md.mirror.type = SWITCH_MIRROR_TYPE_DTEL_DEFLECT;
#endif
        eg_md.dtel.report_type = hdr.bridged_md.dtel.report_type;
        eg_md.dtel.hash = hdr.bridged_md.dtel.hash;
        // Initialize eg_md.dtel.session_id to prevent it from being marked @pa_no_init.
        eg_md.dtel.session_id = 0;
        eg_md.mirror.session_id = hdr.bridged_md.dtel.session_id;
        eg_md.qos.qid = hdr.bridged_md.base.qid;
#ifdef INT_V2
        hdr.dtel_metadata_1 = {
            0,
            hdr.bridged_md.base.ingress_port,
            0,
            hdr.bridged_md.dtel.egress_port};
        hdr.dtel_metadata_4 = {
            0,
            hdr.bridged_md.base.timestamp};
        hdr.dtel_drop_report = {
            0,
            hdr.bridged_md.base.qid,
            SWITCH_DROP_REASON_TRAFFIC_MANAGER,
            0};
#else
        eg_md.ingress_timestamp = hdr.bridged_md.base.timestamp;
        hdr.dtel_report = {
            0,
            hdr.bridged_md.base.ingress_port,
            0,
            hdr.bridged_md.dtel.egress_port,
            0,
            hdr.bridged_md.base.qid};
        hdr.dtel_drop_report = {
            SWITCH_DROP_REASON_TRAFFIC_MANAGER,
            0};
#endif /* INT_V2 */
        transition accept;
#else
        transition reject;
#endif /* DTEL_ENABLE */
    }

    state parse_port_mirrored_metadata {
        switch_port_mirror_metadata_h port_md;
        pkt.extract(port_md);
        pkt.extract(hdr.ethernet);
        eg_md.pkt_src = port_md.src;
        eg_md.mirror.session_id = port_md.session_id;
        eg_md.ingress_timestamp = port_md.timestamp;
        eg_md.flags.bypass_egress = true;
#ifdef PACKET_LENGTH_ADJUSTMENT
        eg_md.mirror.type = port_md.type;
#endif
#ifdef DTEL_ENABLE
        // Initialize eg_md.dtel.session_id to prevent it from being marked @pa_no_init.
        eg_md.dtel.session_id = 0;
#endif
        transition accept;
    }

    state parse_cpu_mirrored_metadata {
        switch_cpu_mirror_metadata_h cpu_md;
        pkt.extract(cpu_md);
        pkt.extract(hdr.ethernet);
        eg_md.pkt_src = cpu_md.src;
        eg_md.flags.bypass_egress = true;
        eg_md.bd = cpu_md.bd;
        // eg_md.ingress_port = cpu_md.md.port;
        eg_md.cpu_reason = cpu_md.reason_code;
#ifdef PACKET_LENGTH_ADJUSTMENT
        eg_md.mirror.type = cpu_md.type;
#endif
#ifdef DTEL_ENABLE
        // Initialize eg_md.dtel.session_id to prevent it from being marked @pa_no_init.
        eg_md.dtel.session_id = 0;
#endif
        transition accept;
    }

    state parse_dtel_drop_metadata_from_egress {
#ifdef DTEL_ENABLE
        switch_dtel_drop_mirror_metadata_h dtel_md;
        pkt.extract(dtel_md);
        eg_md.pkt_src = dtel_md.src;
        eg_md.mirror.type = dtel_md.type;
        eg_md.dtel.report_type = dtel_md.report_type;
        eg_md.dtel.hash = dtel_md.hash;
        // Initialize eg_md.dtel.session_id to prevent it from being marked @pa_no_init.
        eg_md.dtel.session_id = 0;
        eg_md.mirror.session_id = dtel_md.session_id;
#ifdef INT_V2
        hdr.dtel_metadata_1 = {
            0,
            dtel_md.ingress_port,
            0,
            dtel_md.egress_port};
        hdr.dtel_metadata_4 = {
            0,
            dtel_md.timestamp};
        hdr.dtel_drop_report = {
            0,
            dtel_md.qid,
            dtel_md.drop_reason,
            0};
#else
        eg_md.ingress_timestamp = dtel_md.timestamp;
        hdr.dtel_report = {
            0,
            dtel_md.ingress_port,
            0,
            dtel_md.egress_port,
            0,
            dtel_md.qid};
        hdr.dtel_drop_report = {
            dtel_md.drop_reason,
            0};
#endif /* INT_V2 */
        transition accept;
#else
        transition reject;
#endif /* DTEL_ENABLE */
    }

    /* Separate parse state for drop metadata from ingress, in order to set
     * hdr.dtel_report.egress_port to SWITCH_PORT_INVALID */
    state parse_dtel_drop_metadata_from_ingress {
#ifdef DTEL_ENABLE
        switch_dtel_drop_mirror_metadata_h dtel_md;
        pkt.extract(dtel_md);
        eg_md.pkt_src = dtel_md.src;
        eg_md.mirror.type = dtel_md.type;
        eg_md.dtel.report_type = dtel_md.report_type;
        eg_md.dtel.hash = dtel_md.hash;
        // Initialize eg_md.dtel.session_id to prevent it from being marked @pa_no_init.
        eg_md.dtel.session_id = 0;
        eg_md.mirror.session_id = dtel_md.session_id;
#ifdef INT_V2
        hdr.dtel_metadata_1 = {
            0,
            dtel_md.ingress_port,
            0,
            SWITCH_PORT_INVALID};
        hdr.dtel_metadata_4 = {
            0,
            dtel_md.timestamp};
        hdr.dtel_drop_report = {
            0,
            dtel_md.qid,
            dtel_md.drop_reason,
            0};
#else
        eg_md.ingress_timestamp = dtel_md.timestamp;
        hdr.dtel_report = {
            0,
            dtel_md.ingress_port,
            0,
            SWITCH_PORT_INVALID,
            0,
            dtel_md.qid};
        hdr.dtel_drop_report = {
            dtel_md.drop_reason,
            0};
#endif /* INT_V2 */
        transition accept;
#else
        transition reject;
#endif /* DTEL_ENABLE */
    }

    state parse_dtel_switch_local_metadata {
#ifdef DTEL_ENABLE
        switch_dtel_switch_local_mirror_metadata_h dtel_md;
        pkt.extract(dtel_md);
        eg_md.pkt_src = dtel_md.src;
        eg_md.mirror.type = dtel_md.type;
        eg_md.dtel.report_type = dtel_md.report_type;
        eg_md.dtel.hash = dtel_md.hash;
        // Initialize eg_md.dtel.session_id to prevent it from being marked @pa_no_init.
        eg_md.dtel.session_id = 0;
        eg_md.mirror.session_id = dtel_md.session_id;
#ifdef INT_V2
        hdr.dtel_metadata_1 = {
            0,
            dtel_md.ingress_port,
            0,
            dtel_md.egress_port};
        //TODO: Preserve latency as well as quantized latency
        //      and add to mirror metadata
        //hdr.dtel_metadata_2 = {
        //    dtel_md.latency};
        hdr.dtel_metadata_3 = {
            0,
            dtel_md.qid,
            0,
            dtel_md.qdepth};
        hdr.dtel_metadata_4 = {
            0,
            dtel_md.timestamp};
        hdr.dtel_metadata_5 = {
            0,
            dtel_md.egress_timestamp};
#else
        eg_md.ingress_timestamp = dtel_md.timestamp;
        hdr.dtel_report = {
            0,
            dtel_md.ingress_port,
            0,
            dtel_md.egress_port,
            0,
            dtel_md.qid};
        hdr.dtel_switch_local_report = {
            0,
            dtel_md.qdepth,
            dtel_md.egress_timestamp};
#endif /* INT_V2 */
        transition accept;
#else
        transition reject;
#endif /* DTEL_ENABLE */
    }

    state parse_simple_mirrored_metadata {
#ifdef DTEL_ENABLE
        switch_simple_mirror_metadata_h simple_mirror_md;
        pkt.extract(simple_mirror_md);
        eg_md.pkt_src = simple_mirror_md.src;
        eg_md.mirror.type = simple_mirror_md.type;
        eg_md.mirror.session_id = simple_mirror_md.session_id;
        eg_md.flags.bypass_egress = true;
        transition parse_ethernet;
#else
        transition reject;
#endif
    }

    state parse_packet {
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type, eg_intr_md.egress_port) {
            cpu_port : parse_cpu;
            (ETHERTYPE_IPV4, _) : parse_ipv4;
            (ETHERTYPE_IPV6, _) : parse_ipv6;
            (ETHERTYPE_VLAN, _) : parse_vlan;
            (ETHERTYPE_QINQ, _) : parse_vlan;
#ifdef MPLS_ENABLE
            (ETHERTYPE_MPLS, _) : parse_mpls;
#endif /* MPLS_ENABLE */
            default : accept;
        }
    }

    state parse_cpu {
        eg_md.flags.bypass_egress = true;
        transition accept;
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol, hdr.ipv4.ihl, hdr.ipv4.frag_offset) {
#if defined(TUNNEL_ENABLE) || (defined(DTEL_ENABLE) && __TARGET_TOFINO__ == 1)
            (IP_PROTOCOLS_UDP, 5, 0) : parse_udp;
#ifdef IPINIP_ENABLE
            (IP_PROTOCOLS_IPV4, 5, 0) : parse_inner_ipv4;
            (IP_PROTOCOLS_IPV6, 5, 0) : parse_inner_ipv6;
#endif
#endif
            // (IP_PROTOCOLS_GRE, 5, 0) : parse_ip_gre;
            (_, 6, _) : parse_ipv4_options;
            default : accept;
        }
    }

    state parse_ipv4_options {
        pkt.extract(hdr.ipv4_option);
        transition select(hdr.ipv4.protocol, hdr.ipv4.frag_offset) {
#if defined(TUNNEL_ENABLE) || (defined(DTEL_ENABLE) && __TARGET_TOFINO__ == 1)
            (IP_PROTOCOLS_UDP, 0) : parse_udp;
#ifdef IPINIP_ENABLE
            (IP_PROTOCOLS_IPV4, 0) : parse_inner_ipv4;
            (IP_PROTOCOLS_IPV6, 0) : parse_inner_ipv6;
#endif
#endif
            // (IP_PROTOCOLS_GRE, 0) : parse_ip_gre;
            default : accept;
        }
    }

    state parse_vlan {
        pkt.extract(hdr.vlan_tag.next);
        transition select(hdr.vlan_tag.last.ether_type) {
            ETHERTYPE_IPV4 : parse_ipv4;
            ETHERTYPE_VLAN : parse_vlan;
            ETHERTYPE_IPV6 : parse_ipv6;
#ifdef MPLS_ENABLE
            ETHERTYPE_MPLS : parse_mpls;
#endif /* MPLS_ENABLE */
            default : accept;
        }
    }

    state parse_ipv6 {
#ifdef IPV6_ENABLE
        pkt.extract(hdr.ipv6);
        transition select(hdr.ipv6.next_hdr) {
#ifdef IPV6_TUNNEL_ENABLE
            // IP_PROTOCOLS_TCP : parse_tcp;
            IP_PROTOCOLS_UDP : parse_udp;
#ifdef IPINIP_ENABLE
            IP_PROTOCOLS_IPV4 : parse_inner_ipv4;
            IP_PROTOCOLS_IPV6 : parse_inner_ipv6;
#endif /* IPINIP_ENABLE */
#endif /* IPV6_TUNNEL_ENABLE */
            // IP_PROTOCOLS_GRE : parse_ip_gre;
            default : accept;
        }
#else
        transition accept;
#endif /* IPV6_ENABLE */
    }

#ifdef MPLS_ENABLE
    state parse_mpls {
        pkt.extract(hdr.mpls.next);
        transition select(hdr.mpls.last.bos) {
            0 : parse_mpls;
            1 : parse_mpls_bos;
        }
    }

    state parse_mpls_bos {
        transition select(pkt.lookahead<bit<4>>()) {
            0x4 : parse_inner_ipv4;
            0x6 : parse_inner_ipv6;
            default : accept;
//            default : parse_inner_ethernet;
        }
    }
#endif /* MPLS_ENABLE */

#ifdef NVGRE_ENABLE
    // nvgre key is 32 bits i.e. combination of both vsid[24 bit], flow_id [8 bit]
    // nvgre-st format  - ipv4/ipv6 -> gre -> nvgre[key==config-key] -> ipv4/ipv6
    // nvgre format     - ipv4/ipv6 -> gre -> nvgre[key!=config-key] -> ipv4/ipv6
    state parse_ip_nvgre {
        pkt.extract(hdr.nvgre);
        // nvgre-st will have config key value or 0x6400
        transition select(hdr.nvgre.vsid_flowid) {
            nvgre_st_key : parse_inner_ethernet;      // nvgre-st
            default  : parse_inner_ethernet;          // nvgre
        }
    }
#endif

    state parse_ip_gre {
        pkt.extract(hdr.gre);
        transition select(hdr.gre.C, hdr.gre.R, hdr.gre.K, hdr.gre.S, hdr.gre.s,
                          hdr.gre.recurse, hdr.gre.flags, hdr.gre.version, hdr.gre.proto) {
#ifdef NVGRE_ENABLE
            (0, 0, 1, 0, 0, 0, 0, 0, GRE_PROTOCOLS_NVGRE) : parse_ip_nvgre;
#endif
            // (_, _, _, _, _, _, _, _, GRE_PROTOCOLS_IP) : parse_inner_ipv4;
            // (_, _, _, _, _, _, _, _, GRE_PROTOCOLS_IPV6) : parse_inner_ipv6;
            default : accept;
        }
    }

    state parse_udp {
        pkt.extract(hdr.udp);
        transition select(hdr.udp.dst_port) {
#ifdef VXLAN_ENABLE
            udp_port_vxlan : parse_vxlan;
#endif
            default : accept;
        }
    }

    state parse_tcp {
        pkt.extract(hdr.tcp);
        transition accept;
    }

    state parse_vxlan {
        pkt.extract(hdr.vxlan);
        transition parse_inner_ethernet;
    }

    state parse_inner_ethernet {
        pkt.extract(hdr.inner_ethernet);
        transition select(hdr.inner_ethernet.ether_type) {
            ETHERTYPE_IPV4 : parse_inner_ipv4;
            ETHERTYPE_IPV6 : parse_inner_ipv6;
            default : accept;
        }
    }

    state parse_inner_ipv4 {
        pkt.extract(hdr.inner_ipv4);
        transition select(hdr.inner_ipv4.protocol) {
            // IP_PROTOCOLS_TCP : parse_inner_tcp;
            IP_PROTOCOLS_UDP : parse_inner_udp;
            default : accept;
        }
    }

    state parse_inner_ipv6 {
        pkt.extract(hdr.inner_ipv6);
        transition select(hdr.inner_ipv6.next_hdr) {
            // IP_PROTOCOLS_TCP : parse_inner_tcp;
            IP_PROTOCOLS_UDP : parse_inner_udp;
            default : accept;
        }
    }

    state parse_inner_udp {
        pkt.extract(hdr.inner_udp);
        transition accept;
    }

    state parse_inner_tcp {
        pkt.extract(hdr.inner_tcp);
        transition accept;
    }

    state parse_inner_icmp {
        pkt.extract(hdr.inner_icmp);
        transition accept;
    }
}


//----------------------------------------------------------------------------
// Mirror packet deparser
//-----------------------------------------------------------------------------
control IngressMirror(
    inout switch_header_t hdr,
    in switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr) {
// Ingress deparser create a copy of the original ingress packet and prepend the prepend the mirror
// header.
    Mirror() mirror;

    apply {
#ifdef MIRROR_ENABLE
        if (ig_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_PORT) {
            mirror.emit<switch_port_mirror_metadata_h>(
                ig_md.mirror.session_id,
                {ig_md.mirror.src,
                 ig_md.mirror.type,
                 ig_md.timestamp,
#if __TARGET_TOFINO__ == 1
                 0,
#endif
                 ig_md.mirror.session_id});

        } else if (ig_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_DTEL_DROP) {
#ifdef DTEL_ENABLE
            mirror.emit<switch_dtel_drop_mirror_metadata_h>(ig_md.dtel.session_id, {
                ig_md.mirror.src,
                ig_md.mirror.type,
                ig_md.timestamp,
#if __TARGET_TOFINO__ == 1
                 0,
#endif
                ig_md.dtel.session_id,
                ig_md.lag_hash,
                ig_md.dtel.report_type,
                0,
                ig_md.port,
                0,
                ig_md.egress_port,
                0,
                ig_md.qos.qid,
                ig_md.drop_reason
            });

#endif /* DTEL_ENABLE */
        }
#endif /* MIRROR_ENABLE */

/*added by Brian*/
    if (ig_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_UPDATE ) {
            mirror.emit<switch_update_mirror_metadata_h>(ig_md.ing_mir_ses, {
                ig_md.pkt_mirror_type,
                ig_md.count_r0,
                ig_md.count_r1,
                ig_md.count_r2,
                ig_md.count_r3
            });
        }
    }
}

control EgressMirror(
    inout switch_header_t hdr,
    in switch_egress_metadata_t eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr) {
// Egress deparser first construct the output packet and then prepend the mirror header.
    Mirror() mirror;

    apply {
#ifdef MIRROR_ENABLE
        if (eg_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_PORT) {
            mirror.emit<switch_port_mirror_metadata_h>(eg_md.mirror.session_id, {
                eg_md.mirror.src,
                eg_md.mirror.type,
                eg_md.ingress_timestamp,
#if __TARGET_TOFINO__ == 1
                0,
#endif
                eg_md.mirror.session_id});
        } else if (eg_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_CPU) {
            mirror.emit<switch_cpu_mirror_metadata_h>(eg_md.mirror.session_id, {
                eg_md.mirror.src,
                eg_md.mirror.type,
                0,
                eg_md.ingress_port,
                eg_md.bd,
                0,
                eg_md.port_lag_index,
                eg_md.cpu_reason});
        } else if (eg_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_DTEL_SWITCH_LOCAL) {
#ifdef DTEL_ENABLE
            mirror.emit<switch_dtel_switch_local_mirror_metadata_h>(eg_md.dtel.session_id, {
                eg_md.mirror.src, eg_md.mirror.type,
                eg_md.ingress_timestamp,
#if __TARGET_TOFINO__ == 1
                0,
#endif
                eg_md.dtel.session_id,
                eg_md.dtel.hash,
                eg_md.dtel.report_type,
                0,
                eg_md.ingress_port,
                0,
                eg_md.port,
                0,
                eg_md.qos.qid,
                0,
                eg_md.qos.qdepth,
                eg_md.timestamp
            });
#endif /* DTEL_ENABLE */
        } else if (eg_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_DTEL_DROP) {
#ifdef DTEL_ENABLE
            mirror.emit<switch_dtel_drop_mirror_metadata_h>(eg_md.dtel.session_id, {
                eg_md.mirror.src,
                eg_md.mirror.type,
                eg_md.ingress_timestamp,
#if __TARGET_TOFINO__ == 1
                 0,
#endif
                eg_md.dtel.session_id,
                eg_md.dtel.hash,
                eg_md.dtel.report_type,
                0,
                eg_md.ingress_port,
                0,
                eg_md.port,
                0,
                eg_md.qos.qid,
                eg_md.drop_reason
            });
#endif /* DTEL_ENABLE */
        } else if (eg_intr_md_for_dprsr.mirror_type == SWITCH_MIRROR_TYPE_SIMPLE) {
#ifdef DTEL_ENABLE
            mirror.emit<switch_simple_mirror_metadata_h>(eg_md.dtel.session_id, {
                eg_md.mirror.src,
                eg_md.mirror.type,
#if __TARGET_TOFINO__ == 1
                0,
#endif
                eg_md.dtel.session_id
            });
#endif /* DTEL_ENABLE */
        }
#endif /* MIRROR_ENABLE */
    }
}

control IngressNatChecksum(
    inout switch_header_t hdr,
    in switch_ingress_metadata_t ig_md) {
    Checksum() tcp_checksum;
    Checksum() udp_checksum;
    apply {
#ifdef NAT_ENABLE
        if(hdr.tcp.isValid()) {
          hdr.tcp.checksum = tcp_checksum.update({
                  ig_md.lkp.ip_src_addr,
                  ig_md.lkp.ip_dst_addr,
                  hdr.tcp.src_port,
                  hdr.tcp.dst_port,
                  ig_md.tcp_udp_checksum});
        } else if(hdr.udp.isValid()) {
          hdr.udp.checksum = udp_checksum.update({
                  ig_md.lkp.ip_src_addr,
                  ig_md.lkp.ip_dst_addr,
                  hdr.udp.src_port,
                  hdr.udp.dst_port,
                  ig_md.tcp_udp_checksum});
        }
#endif
    }
}

//-----------------------------------------------------------------------------
// Ingress Deparser
//-----------------------------------------------------------------------------
control SwitchIngressDeparser(
    packet_out pkt,
    inout switch_header_t hdr,
    in switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr) {

    IngressMirror() mirror;
    Digest<switch_learning_digest_t>() digest;
    /*added by Brian*/
    Digest<switch_report_digest_t>() digest_report;
#ifdef NAT_ENABLE
    Checksum() tcp_checksum;
    Checksum() udp_checksum;
    Checksum() v6_checksum;
    IngressNatChecksum() nat_checksum;
#endif

    apply {
        mirror.apply(hdr, ig_md, ig_intr_md_for_dprsr);
        if (ig_intr_md_for_dprsr.digest_type == SWITCH_DIGEST_TYPE_MAC_LEARNING) {
            digest.pack({ig_md.bd, ig_md.port_lag_index, ig_md.lkp.mac_src_addr});
        }
        /*added by Brian*/
        if(ig_intr_md_for_dprsr.digest_type == SWITCH_DIGEST_TYPE_REPORT){
            digest_report.pack({hdr.ipv4.src_addr});
        }
#ifdef NAT_ENABLE
        nat_checksum.apply(hdr,ig_md);
#endif

        pkt.emit(hdr.bridged_md); // Ingress only.
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.vlan_tag);
        pkt.emit(hdr.arp); // Ingress only.
        pkt.emit(hdr.ipv4);
        pkt.emit(hdr.ipv4_option);
        pkt.emit(hdr.ipv6);
#ifdef SRV6_ENABLE
        pkt.emit(hdr.srh_base);
        pkt.emit(hdr.srh_seg_list);
#endif /* SRV6_ENABLE */
#ifdef MPLS_ENABLE
        pkt.emit(hdr.mpls);
#endif /* MPLS_ENABLE */
        pkt.emit(hdr.udp);
        pkt.emit(hdr.tcp); // Ingress only.
        pkt.emit(hdr.icmp); // Ingress only.
        pkt.emit(hdr.igmp); // Ingress only.
        pkt.emit(hdr.rocev2_bth); // Ingress only.
#ifdef VXLAN_ENABLE
        pkt.emit(hdr.vxlan);
#endif
        pkt.emit(hdr.gre);
#ifdef NVGRE_ENABLE
        pkt.emit(hdr.nvgre);
#endif
        pkt.emit(hdr.inner_ethernet);
        pkt.emit(hdr.inner_ipv4);
        pkt.emit(hdr.inner_ipv6);
        pkt.emit(hdr.inner_udp);
        pkt.emit(hdr.inner_tcp);
        pkt.emit(hdr.inner_icmp);
    }
}


//-----------------------------------------------------------------------------
// Egress Deparser
//-----------------------------------------------------------------------------
control SwitchEgressDeparser(
        packet_out pkt,
        inout switch_header_t hdr,
        in switch_egress_metadata_t eg_md,
        in egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr) {

    EgressMirror() mirror;
    Checksum() ipv4_checksum;
    Checksum() inner_ipv4_checksum;

    apply {
        mirror.apply(hdr, eg_md, eg_intr_md_for_dprsr);

#if !defined(IPV4_CSUM_IN_MAU)
        hdr.ipv4.hdr_checksum = ipv4_checksum.update({
            hdr.ipv4.version,
            hdr.ipv4.ihl,
            hdr.ipv4.diffserv,
            hdr.ipv4.total_len,
            hdr.ipv4.identification,
            hdr.ipv4.flags,
            hdr.ipv4.frag_offset,
            hdr.ipv4.ttl,
            hdr.ipv4.protocol,
            hdr.ipv4.src_addr,
            hdr.ipv4.dst_addr,
            hdr.ipv4_option.type,
            hdr.ipv4_option.length,
            hdr.ipv4_option.value});

#ifdef TUNNEL_ENABLE
        if (eg_md.inner_ipv4_checksum_update_en) {
            hdr.inner_ipv4.hdr_checksum = inner_ipv4_checksum.update({
                hdr.inner_ipv4.version,
                hdr.inner_ipv4.ihl,
                hdr.inner_ipv4.diffserv,
                hdr.inner_ipv4.total_len,
                hdr.inner_ipv4.identification,
                hdr.inner_ipv4.flags,
                hdr.inner_ipv4.frag_offset,
                hdr.inner_ipv4.ttl,
                hdr.inner_ipv4.protocol,
                hdr.inner_ipv4.src_addr,
                hdr.inner_ipv4.dst_addr});
        }
#endif /* TUNNEL_ENABLE */
#endif /* IPV4_CSUM_IN_MAU */

        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.fabric); // Egress only.
        pkt.emit(hdr.cpu); // Egress only.
        pkt.emit(hdr.timestamp); // Egress only.
        pkt.emit(hdr.vlan_tag);
        pkt.emit(hdr.ipv4);
        pkt.emit(hdr.ipv4_option);
        pkt.emit(hdr.ipv6);
#ifdef SRV6_ENABLE
        pkt.emit(hdr.srh_base);
        pkt.emit(hdr.srh_seg_list);
#endif /* SRV6_ENABLE */
#ifdef MPLS_ENABLE
        pkt.emit(hdr.mpls);
#endif /* MPLS_ENABLE */
        pkt.emit(hdr.udp);
        pkt.emit(hdr.dtel); // Egress only.
#ifdef INT_V2
        pkt.emit(hdr.dtel_metadata_1); // Egress only.
        pkt.emit(hdr.dtel_metadata_2); // Egress only.
        pkt.emit(hdr.dtel_metadata_3); // Egress only.
        pkt.emit(hdr.dtel_metadata_4); // Egress only.
        pkt.emit(hdr.dtel_metadata_5); // Egress only.
#else
        pkt.emit(hdr.dtel_report); // Egress only.
        pkt.emit(hdr.dtel_switch_local_report); // Egress only.
#endif
        pkt.emit(hdr.dtel_drop_report); // Egress only.
#ifdef VXLAN_ENABLE
        pkt.emit(hdr.vxlan);
#endif
        pkt.emit(hdr.gre);
#ifdef NVGRE_ENABLE
        pkt.emit(hdr.nvgre);
#endif
        pkt.emit(hdr.erspan); // Egress only.
        pkt.emit(hdr.erspan_type2); // Egress only.
        pkt.emit(hdr.erspan_type3); // Egress only.
        pkt.emit(hdr.erspan_platform); // Egress only.
        pkt.emit(hdr.inner_ethernet);
        pkt.emit(hdr.inner_ipv4);
        pkt.emit(hdr.inner_ipv6);
        pkt.emit(hdr.inner_udp);
    }
}
