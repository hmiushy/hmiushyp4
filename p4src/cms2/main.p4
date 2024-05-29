/* -*- P4_16 -*- */
#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
#include "parser.p4"
#include "cms.p4"

/************************************************************************* 
**************  I N G R E S S   P R O C E S S I N G   ******************* 
*************************************************************************/

control SwitchIngress(
    inout switch_header_t hdr,
    inout switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
    inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm) {
    CMS_b() cms;
    apply {
        // ----------------------------------------------------------------------
        cms.apply(hdr, ig_md, ig_intr_md, ig_intr_from_prsr,ig_intr_md_for_dprsr, ig_intr_md_for_tm);
    }   
}
/************************************************************************* 
****************  E G R E S S   P R O C E S S I N G   ******************* 
*************************************************************************/

control SwitchEgress(
    inout switch_header_t hdr,
    inout switch_egress_metadata_t eg_md,
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