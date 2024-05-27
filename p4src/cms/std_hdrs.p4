/* -*- P4_16 -*- */

#ifndef _STD_HDRS_P4_
#define _STD_HDRS_P4_

#include <core.p4>
#include <t2na.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

header ethernet_t {
    bit<48>   dst_addr;
    bit<48>   src_addr;
    bit<16>   ether_type;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   total_len;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   frag_offset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdr_checksum;
    bit<32>   src_addr;
    bit<32>   dst_addr;
}

header tcp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> seq_no;
    bit<32> ack_no;
    bit<4>  data_offset;
    bit<4>  res;
    bit<8>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgent_ptr;
}

header udp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> length;
    bit<16> checksum;
}



struct switch_header_t {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    udp_t        udp;
    tcp_t        tcp;
}

struct my_info_t {
    
    bit<32> estimate_pkt_cnt;
    bit<32> estimate_pkt_len;
    bit<32> srcip2idx;
    bit<32> dstip2idx;
    bit<32> ip2idx;
    bit<1> src_exist;
    bit<1> dst_exist;
    bit<1> deq_flag;
    bit<1> minus_flag;
    bit<1> reset;
    bit<1> cv;
    bit<1> set_time;
    bit<8> pre_time;
    bit<8> rtflag;
    bit<32> ts_sec;
    bit<32> ts_miri;
    bit<32> ts_micro;
}

struct switch_ingress_metadata_t {
    my_info_t info;
}

struct switch_egress_metadata_t {

}


struct pair {
    bit<32>     packet_count;
    bit<32>     packet_length;
}

#endif
