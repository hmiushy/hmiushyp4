/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

const bit<16> ETHERTYPE_IPV4 = 0x0800;

header ethernet_h {
    bit<48>   dst_addr;
    bit<48>   src_addr;
    bit<16>   ether_type;
}

header ipv4_h {
    bit<8>       version_ihl;
    bit<8>       diffserv;
    bit<16>      total_len;
    bit<16>      identification;
    bit<16>      flags_frag_offset;
    bit<8>       ttl;
    bit<8>       protocol;
    bit<16>      hdr_checksum;
    bit<32>      src_addr;
    bit<32>      dst_addr;
}

struct my_ingress_headers_t {
    ethernet_h   ethernet;
    ipv4_h       ipv4;
}
struct my_egress_headers_t {
    ethernet_h   ethernet;
    ipv4_h       ipv4;
}

struct my_ingress_metadata_t {
}

struct empty_metadata_t {
}


struct my_egress_metadata_t {
}

/************************************************************************* 
**************  I N G R E S S   P R O C E S S I N G   ******************* 
*************************************************************************/

parser SwitchIngressParser(
    packet_in pkt,
    out my_ingress_headers_t hdr,
    inout my_ingress_metadata_t meta,
    in ingress_intrinsic_metadata_t ig_intr_md) {
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4:  parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }

}
control SwitchIngress(
    inout my_ingress_headers_t hdr,
    inout my_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
    inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm){

    apply {

    }
}

control SwitchIngressDeparser(
    packet_out pkt,
    inout my_ingress_headers_t hdr,
    in my_ingress_metadata_t meta,
    in ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    in ingress_intrinstic_metadata_t ig_intr_md){
    apply {
        pkt.emit(hdr);
    }
}

/************************************************************************* 
****************  E G R E S S   P R O C E S S I N G   ******************* 
*************************************************************************/ 

control SwitchEgressParser (
    packet_in pkt,
    out my_egress_headers_t hdr,
    inout my_egress_metadata_t meta,
    out egress_intrinsicmetadata_t eg_intr_md) {
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4:  parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }        
}

control SwitchEgress(
    inout my_ingress_headers_t hdr,
    inout my_ingress_metadata_t eg_md,
    in egress_intrinsic_metadata_t eg_intr_md,
    in egress_intrinsic_metadata_from_parser_t eg_intr_md_from_prsr,
    inout egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr,
    inout egress_intrinsic_metadata_for_output_port_t eg_intr_md_for_oport) {
    apply {
        
    }   
}
control SwitchEgressDeparser(
    packet_out pkt,
    inout my_egress_header_t hdr,
    in my_egress_metadata_t eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr)
    apply {
        pkt.emit(hdr);
    }
}

/************************************************************************* 
*************************  P I P E - L I N E  **************************** 
*************************************************************************/ 

Pipeline(SwitchIngressParser(),
        SwitchIngress(),
        SwitchIngressDeparser(),
        SwitchEgressParser(),
        SwitchEgress(),
        SwitchEgressDeparser()) pipe;

Switch(pipe) main;