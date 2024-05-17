/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
/*
=========================================================================================
======================================== INGRESS ========================================
=========================================================================================
*/
/*************************************************
**********  I N G R E S S   P A R S E R **********
**************************************************/
parser SwitchIngressParser(
    packet_in pkt,
    out headers_t hdr,
    out ingress_metadata_t meta,
    out ingress_intrinsic_metadata_t ig_intr_md) {
    state start {
        transition parse_ethernet;
    }
    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            ETHERTYPE_IPV4:  parse_ipv4;
            default: accept;
        }
    }
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }
}

/*************************************************
********  I N G R E S S   D E P A R S E R ********
**************************************************/
control SwitchIngressDeparser(
    packet_out pkt,
    inout headers_t hdr,
    in ingress_metadata_t meta,
    in ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr){
    apply {
        pkt.emit(hdr);
    }
}

/*
=========================================================================================
======================================== EGRESS =========================================
=========================================================================================
*/
/***************************************************************
****************  E G R E S S   P A R S E R  ******************* 
****************************************************************/
parser SwitchEgressParser (
    packet_in pkt,
    out headers_t hdr,
    out egress_metadata_t mg_md,
    out egress_intrinsic_metadata_t eg_intr_md) {
    state start {
          pkt.extract(eg_intr_md);
          transition accept;
    }
}

/***************************************************************
****************  E G R E S S   D E P A R S E R  ***************
****************************************************************/
control SwitchEgressDeparser(
    packet_out pkt,
    inout headers_t hdr,
    in egress_metadata_t eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr) {
    apply {
        pkt.emit(hdr);
    }
}