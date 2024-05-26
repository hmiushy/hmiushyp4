/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
#include "parser.p4"

#define REPORT_TIME 1
#define CMS_depth 8

#define POWER2 10      // Used at CRC

#if POWER2 == 2
    #define CMS_width 4   // 2^POWER2 (Sketch Size)
#elif POWER2 == 4
    #define CMS_width 16  // 2^POWER2 (Sketch Size)
#elif POWER2 == 5
    #define CMS_width 32  // 2^POWER2 (Sketch Size)
#elif POWER2 == 8
    #define CMS_width 256 // 2^POWER2 (Sketch Size)
#elif POWER2 == 10
    #define CMS_width 1024 // 2^POWER2 (Sketch Size)
#elif POWER2 == 11
    #define CMS_width 2048 // 2^POWER2 (Sketch Size)
#elif POWER2 == 16
    #define CMS_width 65536 // 2^POWER2 (Sketch Size)
#endif

typedef bit<POWER2> hash_t;

header value_t {
    bit<32> cnt; // cnt: packet count
    bit<32> len; // len: packet length
    bit<32> idx; // idx: index
}
struct cms_value {
    value_t[CMS_depth] v; // cnt, len, and idx
}

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
            
    Register<bit<32>,bit<32>>(1) check_val;
    /*-------------------- Estimate packet count and length --------------------*/
    Register<bit<32>,bit<32>>(1) estimate_pcnt;
    Register<bit<32>,bit<32>>(1) estimate_plen;
    /*--------------- Variables used Count Min Sketch registers ----------------*/
    bit<32> all_cnt;   // Save temporal packet count 
    bit<32> all_len;   // Save temporal packet length 
    cms_value val;  // Aarray Structure // temporal values of cnt and len of pkt and index

    /*------------------ Count Min Sketch registers and Hash -------------------*/
    Register<pair, bit<32>>(1, {0,0}) just_packet_cnt;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_0;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_1;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_2;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_3;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_4;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_5;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_6;
    Register<pair, bit<32>>(CMS_width, {0,0}) cms_reg_7;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_0;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_1;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_2;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_3;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_4;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_5;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_6;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_7;


    Register<bit<48>, bit<48>>(1,0) report_point;

    /*------------------- All Packet Count registers Action --------------------*/
    RegisterAction<pair, bit<32>, bit<32>>(just_packet_cnt) all_cnt_len = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
    /*------------------- Count Min Sketch registers Action --------------------*/
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_0) cms_cnt_len_0 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_1) cms_cnt_len_1 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_2) cms_cnt_len_2 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_2) cms_cnt_len_3 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };

    /*---------------- Get index of register using hash Action------------------*/
    action key2index_0() {
        val.v[0].idx = (bit<32>)hash_0.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, 32w0});
    }
    action key2index_1() {
        val.v[1].idx = (bit<32>)hash_1.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, 32w1});
    }
    action key2index_2() {
        val.v[2].idx = (bit<32>)hash_2.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, 32w2});
    }
    action key2index_3() {
        val.v[3].idx = (bit<32>)hash_3.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, 32w3});
    }
    action key2index_4() {
        val.v[4].idx = (bit<32>)hash_4.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, 32w4});
    }
    action key2index_5() {
        val.v[5].idx = (bit<32>)hash_5.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, 32w5});
    }
    action key2index_6() {
        val.v[6].idx = (bit<32>)hash_6.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, 32w6});
    }
    action key2index_7() {
        val.v[7].idx = (bit<32>)hash_7.get({hdr.ipv4.src_addr, hdr.ipv4.dst_addr, 32w7});
    }
    
    apply {
        if (hdr.ipv4.isValid()) {
            key2index_0();
            key2index_1();
            key2index_2();
            key2index_3();
            key2index_4();
            key2index_5();
            key2index_6();
            key2index_7();
            
            all_cnt = all_cnt_len.execute(0, all_len);
            /* Update and Get Estimate packet count (cnt) and packet length (len) */
            val.v[0].cnt = cms_cnt_len_0.execute(val.v[0].idx, val.v[0].len);
            val.v[1].cnt = cms_cnt_len_1.execute(val.v[1].idx, val.v[1].len);
            check_val.write(0, val.v[0].idx);
            /* Compute Estimate packet count (cnt) and packet length (len) */
            bit<32> estimate_packet_count;
            bit<32> estimate_packet_length;
            estimate_packet_count = min(val.v[0].cnt, val.v[1].cnt);
            estimate_packet_length = min(val.v[0].len, val.v[1].len);
            estimate_pcnt.write(0, estimate_packet_count);
            estimate_plen.write(0, estimate_packet_length);
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
    
    CMS() cms;

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
