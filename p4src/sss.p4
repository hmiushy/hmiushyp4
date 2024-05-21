/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

//#include "std_hdrs.p4"
//#include "parser.p4"
//#include "const.p4"
#include "headers.p4"
#include "types.p4"
#include "parde.p4"
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
    /*
    //ActionProfile(ACTION_COUNT) action_profile; // ACTION_COUNT in const.p4
    const bit<32> bool_register_table_size = 1 << 10;
    Register<bit<1>, bit<32>>(bool_register_table_size, 0) bool_register_table;
    RegisterAction<bit<1>, bit<32>, bit<1>>(bool_register_table) bool_register_table_action = {
        void apply(inout bit<1> val, out bit<1> rv) {
            rv = ~val;
        }
    };
    
    Register<pair, bit<32>>(32w1024) test_reg;
    RegisterAction<pair, bit<32>, bit<32>>(test_reg) test_reg_action = {
        void apply(inout pair value, out bit<32> read_value){
            read_value = value.second;
            value.first = value.first + 1;
            value.second = value.second + 100;
        }
    };
    */
    action set_port(bit<9> port) {
        ig_intr_md_for_tm.ucast_egress_port = port;
    }
    
    table ipv4_exact {
        key = { 
            hdr.ipv4.dst_addr : exact;
        }
        actions = { 
            set_port;
        }
        size           = 1024; // in const.p4
        default_action = set_port(2);
    }
    apply {
        ipv4_exact.apply();
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
