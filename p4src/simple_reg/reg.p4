/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
#include "parser.p4"

#define CMS_width 1024
#define CMS_depth 10

typedef bit<16> hash_t;

/************************************************************************* 
**************  I N G R E S S   P R O C E S S I N G   ******************* 
*************************************************************************/
control CMS (
        inout switch_header_t hdr,
        inout switch_ingress_metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
        inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
        inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm) {

    //DirectCounter<bit<32>>(CounterType_t.PACKETS_AND_BYTES) direct_counter;
    //DirectCounter<bit<32>>(CounterType_t.PACKETS_AND_BYTES) direct_counter_2;

    hash_t hash_id_0;    // hash number
    bit<32> idx_0;       // key to index
    bit<32> cms_info_0;  // 
    Register<bit<32>, bit<32>>(CMS_width, 0) cms_reg_0;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_0;
    
    hash_t hash_id_1;
    bit<32> idx_1;
    bit<32> cms_info_1;
    bit<32> cms_info_10;
    bit<32> cms_info_11;
    pair cms_info_11;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_11;
    Register<bit<32>, bit<32>>(CMS_width, 0) cms_reg_1;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_1;
    
    RegisterAction<bit<32>, bit<32>, bit<32>>(cms_reg_0) cms_get_update_0 = {
        void apply(inout bit<32> value, out bit<32> read_value){
            value = value + 1;
            read_value = value;
        }
    };

    RegisterAction<bit<32>, bit<32>, bit<32>>(cms_reg_1) cms_get_update_1 = {
        void apply(inout bit<32> value, out bit<32> read_value){
            value = value + 1;
            read_value = value;
        }
    };
    
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_11) cms_get_update_11 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            //value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            //read_value  = value.packet_count;
            //read_value1 = value.packet_count;
            //read_value2 = value.packet_length;
            //read_value1 = value;
        }
    };
    
    /*
    Register<pair, bit<32>>(32w1024) test_reg;
    RegisterAction<pair, bit<32>, pair>(test_reg) test_reg_action = {
        void apply(inout pair value, out pair read_value){
            //read_value = value.packet_count;
            read_value = value;
            value.packet_count = value.packet_count + 1;
            value.packet_length = value.packet_length + 100;
        }
    };
    */

    action key2index_0() {
        hash_id_0 = (hash_t)hash_0.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr});
        idx_0 = (bit<32>)hash_id_0;
    }
    action key2index_1() {
        hash_id_1 = (hash_t)hash_1.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr});
        idx_1 = (bit<32>)hash_id_1;
    }

    apply {
        key2index_0();
        key2index_1();
        cms_info_0 = cms_get_update_0.execute(idx_0);
        cms_info_1 = cms_get_update_1.execute(idx_1);
        //cms_info_1 = cms_get_update_11.execute(idx_1);
        cms_info_10 = cms_get_update_11.execute(idx_1, conf_info_11);
        //test0();
        //test1();
        //bit<32> test;
        //pair test;
        //test = test_reg_action.execute(0);
        //test1();
        //cms_info_11 = cms_get_update_1.execute(idx_1);
        

    }
}
control SwitchIngress(
    inout switch_header_t hdr,
    inout switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
    inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm) {
    
    CMS() cms;

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
        cms.apply(hdr, ig_md, ig_intr_md, ig_intr_from_prsr, ig_intr_md_for_dprsr, ig_intr_md_for_tm);
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
