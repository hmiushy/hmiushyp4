/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
#include "parser.p4"

/************************************************************************* 
**************  I N G R E S S   P R O C E S S I N G   ******************* 
*************************************************************************/

control SwitchIngress(
    inout headers_t hdr,
    inout ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
    inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm){
    
    action set_port(bit<9> port) {
        ig_intr_md_for_tm.ucast_egress_port = port;
    }
    table ipv4_ex {
        key = { 
            hdr.ipv4.dstAddr : exact;
        }
        
        actions = { 
            set_port;
            NoAction; 
        }
        size           = 1024; 
        default_action = NoAction();
    }
    apply {
        ipv4_ex.apply();
    }
}

/************************************************************************* 
****************  E G R E S S   P R O C E S S I N G   ******************* 
*************************************************************************/ 

control SwitchEgress(
    inout headers_t hdr,
    inout egress_metadata_t eg_md,
    in egress_intrinsic_metadata_t eg_intr_md,
    in egress_intrinsic_metadata_from_parser_t eg_intr_md_from_prsr,
    inout egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr,
    inout egress_intrinsic_metadata_for_output_port_t eg_intr_md_for_oport) {
    apply {
        
    }   
}

/************************************************************************* 
****************************  S W I T C H  ******************************
*************************************************************************/
Pipeline(SwitchIngressParser(),
    SwitchIngress(),
    SwitchIngressDeparser(),
    SwitchEgressParser(),
    SwitchEgress(),
    SwitchEgressDeparser()) pipe;

Switch(pipe) main;