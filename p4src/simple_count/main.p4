/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
#include "parser.p4"

#define REPORT_TIME 100
#define END_TIMESTEP 400

/************************************************************************* 
**************  I N G R E S S   P R O C E S S I N G   ******************* 
*************************************************************************/
control Count (
        inout switch_header_t hdr,
        inout switch_ingress_metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
        inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
        inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm) {
            
    /*--------------- Variables used Count Min Sketch registers ----------------*/
    bit<32> all_cnt;   // Save temporal packet count 
    bit<32> all_len;   // Save temporal packet length 

    /*------------------ Count Min Sketch registers and Hash -------------------*/
    Register<pair, bit<32>>(1, {0,0}) just_packet_cnt;
    Register<bit<32>,bit<32>>(END_TIMESTEP) report_result;
    Register<bit<64>, bit<48>>(1,0) report_point;
    Register<bit<64>, bit<48>>(3,0) for_debug;

    /*------------------- All Packet Count registers Action --------------------*/
    RegisterAction<pair, bit<32>, bit<32>>(just_packet_cnt) all_cnt_len = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
<<<<<<< HEAD:p4src/simple_reg/reg.p4
    
    action key2index_0() {
        hash_id_0 = (hash_t)hash_0.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr});
        idx_0 = (bit<32>)hash_id_0;
    }
    action key2index_1() {
        hash_id_1 = (hash_t)hash_1.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr});
        idx_1 = (bit<32>)hash_id_1;
    }
=======
    RegisterAction<bit<64>, bit<32>, bit<32>>(report_result) repo_action = {
        void apply(inout bit<64> value) {

        }
    };
    RegisterAction<bit<64>, bit<48>, bit<48>>(for_debug) debug_tbl = {
        void apply(inout bit<64> value) {
            //value = (bit<32>)ig_intr_from_prsr.global_tstamp;
<<<<<<< HEAD
            value = ig_intr_md.ingress_mac_tstamp;
>>>>>>> 89f751bdf08fed9895ab60a240a51f1bec7c1619:p4src/simple_count/main.p4
=======
            value = (bit<64>)ig_intr_md.ingress_mac_tstamp;
>>>>>>> d98867d81e5e2bec5badb510c67e7627cf92f88c

        }
    };
    apply {
        bit<64> now_time;   // in-packet time
        bit<64> before_time; // before report time
        bit<32> diff_time;   // difference
        now_time   = (bit<64>)ig_intr_from_prsr.global_tstamp;
        for_debug.write(0, now_time);
        debug_tbl.execute(0);
        before_time = report_point.read(0);
        debug_tbl.execute(1);
        //all_len = repo_action.push();
                /*
        if ((bit<10>)now_time > 100) {
            all_cnt = all_cnt_len.execute(0, all_len);
            all_len = repo_action.push();
            //just_packet_cnt.clear({0,0});
        }
        */
        if (hdr.ipv4.isValid()) {
            all_cnt = all_cnt_len.execute(0, all_len);
            //for_debug.write(0, all_len);
        }
    }
}
control SwitchIngress(
    inout switch_header_t hdr,
    inout switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
    inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm) {
    
    Count() count;

    action set_port(bit<9> port) {
        ig_intr_md_for_tm.ucast_egress_port = port;
    }
    action drop() {
        ig_intr_md_for_dprsr.drop_ctl = 0x1;
    }
    
    table ipv4_exact {
        key = { 
            hdr.ipv4.dst_addr : exact;
        }
        actions = { 
            set_port;
            drop();
        }
        size           = 1024; // in const.p4
        default_action = drop();
    }
    apply {
        count.apply(hdr, ig_md, ig_intr_md, ig_intr_from_prsr, ig_intr_md_for_dprsr, ig_intr_md_for_tm);
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
