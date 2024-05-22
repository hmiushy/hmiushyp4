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

parser TofinoIngressParser(
    packet_in pkt,
    out ingress_intrinsic_metadata_t ig_intr_md) {
    state start {
        pkt.extract(ig_intr_md);
        transition select(ig_intr_md.resubmit_flag) {
            1 : parse_resubmit;
            0 : parse_port_metadata;
        }
    }

    state parse_resubmit {
        transition reject;
    }

    state parse_port_metadata {
        pkt.advance(PORT_METADATA_SIZE);
        transition accept;
    }
}


parser SwitchIngressParser(
    packet_in pkt,
    out switch_header_t hdr,
    out switch_ingress_metadata_t ig_md,
    out ingress_intrinsic_metadata_t ig_intr_md) {
    
    TofinoIngressParser() tofino_parser;

    state start {
        tofino_parser.apply(pkt, ig_intr_md);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select (hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4 : parse_ipv4;
            default : reject;
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
    inout switch_header_t hdr,
    in switch_ingress_metadata_t meta,
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
parser SwitchEgressParser(
        packet_in pkt,
        out switch_header_t hdr,
        out switch_egress_metadata_t eg_md,
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
    inout switch_header_t hdr,
    in switch_egress_metadata_t eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr) {
    apply {
        pkt.emit(hdr);
    }
}
