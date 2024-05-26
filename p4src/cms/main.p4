/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
#include "parser.p4"

#define REPORT_TIME 1

#define CMS_depth 8


#define CRC_BIT 5      // Used at CRC   // 2/4/5/8/10/11/16
#define IP_SIZE_BIT 5 // Used at ipget // 5/16
#define THRESHOLD 0.3
#define W_SIZE 1000       // The number of possessed packets

// Pow(2,CRC_BIT) (Sketch Size)
#if CRC_BIT == 2
    #define CMS_width 4   
#elif CRC_BIT == 4
    #define CMS_width 16  
#elif CRC_BIT == 5
    #define CMS_width 32  
#elif CRC_BIT == 8
    #define CMS_width 256 
#elif CRC_BIT == 10
    #define CMS_width 1024 
#elif CRC_BIT == 11
    #define CMS_width 2048 
#elif CRC_BIT == 16
    #define CMS_width 65536 
#endif

// Pow(2,IP_SIZE_BIT)
#if IP_SIZE == 5 // to Debug
    #define IP_SIZE 32
#elif IP_SIZE == 16
    #define IP_SIZE 65536
#else
    #define IP_SIZE 65536
#endif


typedef bit<CRC_BIT>  hash_t;
typedef bit<IP_SIZE_BIT> ipsize_t;

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
    RegisterAction<bit<32>, bit<32>, bit<32>>(estimate_pcnt) estimate_pcnt_act = {
        void apply (inout bit<32> value){
            value = ig_md.info.estimate_pkt_cnt;
        }
    };
    RegisterAction<bit<32>, bit<32>, bit<32>>(estimate_plen) estimate_plen_act = {
        void apply (inout bit<32> value){
            value = ig_md.info.estimate_pkt_len;
        }
    };
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
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_3) cms_cnt_len_3 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_4) cms_cnt_len_4 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_5) cms_cnt_len_5 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_6) cms_cnt_len_6 = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
        }
    };
    RegisterAction<pair, bit<32>, bit<32>>(cms_reg_7) cms_cnt_len_7 = {
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

    /* ----- Mirisecond packet arrival time reg ----- */
    Register<bit<32>,_>(1,0) arrival_miri;
    RegisterAction<bit<32>, bit<32>, bit<32>>(arrival_miri) arrival_miri_act= {
        void apply (inout bit<32> value){
            value = (bit<32>)ig_md.info.ts_miri;
        }
    };

    /* ----- Store IP address */
    Register<bit<32>, bit<32>>(IP_SIZE, 0) src_ip_reg;  // store srcip 
    Register<bit<32>, bit<32>>(IP_SIZE, 0) dst_ip_reg;  // store dstip
    Register<bit<32>, bit<32>>(1, 0) element_count_src; // count element
    Register<bit<32>, bit<32>>(1, 0) element_count_dst; // count element
    Register<bit<32>, bit<32>>(W_SIZE, 0) src_ip_queue; //
    Register<bit<32>, bit<32>>(W_SIZE, 0) dst_ip_queue; // 
    Hash<ipsize_t>(HashAlgorithm_t.CRC32) hash_src_ip;  // 
    Hash<ipsize_t>(HashAlgorithm_t.CRC32) hash_dst_ip;
    RegisterAction<bit<32>, _, bit<1>> (src_ip_reg) store_src_ip = {
        void apply(inout bit<32> value, out bit<1> return_value) {
            if (value != 0) {
                return_value = 1;
            }
            else {
                value = hdr.ipv4.src_addr;
                return_value = 0;
            }
        }
    };
    RegisterAction<bit<32>, _, bit<1>> (dst_ip_reg) store_dst_ip = {
        void apply(inout bit<32> value, out bit<1> return_value) {
            if (value != 0) {
                return_value = 1;
            }
            else {
                value = hdr.ipv4.dst_addr;
                return_value = 0;
            }
        }
    };
    RegisterAction<bit<32>, _, bit<32>> (element_count_src) el_act_s = {
        void apply(inout bit<32> value) {
            if (ig_md.info.src_exist == 0) {
                value = value + 1;
            }
        }
    };
    RegisterAction<bit<32>, _, bit<32>> (element_count_dst) el_act_d = {
        void apply(inout bit<32> value) {
            if (ig_md.info.dst_exist == 0) {
                value = value + 1;
            }
        }
    };
    action src_ip2index() {
        ig_md.info.srcip2idx = (bit<32>)hash_src_ip.get({hdr.ipv4.src_addr, 32w8});
    }
    action dst_ip2index() {
        ig_md.info.dstip2idx = (bit<32>)hash_dst_ip.get({hdr.ipv4.dst_addr, 32w9});
    }
    
    apply {
        if (hdr.ipv4.isValid()) {
            // 2^20 = 1048576 (nearest 10^6) and get nano to mirisecond time
            ig_md.info.ts_miri = (bit<32>)ig_intr_md.ingress_mac_tstamp[47:20];
            key2index_0();
            key2index_1();
            key2index_2();
            key2index_3();
            key2index_4();
            key2index_5();
            key2index_6();
            key2index_7();

            src_ip2index();
            dst_ip2index();
            // get the ip hash and get flag
            ig_md.info.src_exist = store_src_ip.execute(ig_md.info.srcip2idx);
            ig_md.info.dst_exist = store_dst_ip.execute(ig_md.info.dstip2idx);
            el_act_s.execute(0); // element count action src
            el_act_d.execute(0); // element count action dst

            // Get to the packets of stream.
            all_cnt = all_cnt_len.execute(0, all_len);
            /* Update and Get Estimate packet count (cnt) and packet length (len) */
            val.v[0].cnt = cms_cnt_len_0.execute(val.v[0].idx, val.v[0].len);
            val.v[1].cnt = cms_cnt_len_1.execute(val.v[1].idx, val.v[1].len);
            val.v[2].cnt = cms_cnt_len_2.execute(val.v[2].idx, val.v[2].len);
            val.v[3].cnt = cms_cnt_len_3.execute(val.v[3].idx, val.v[3].len);
            val.v[4].cnt = cms_cnt_len_4.execute(val.v[4].idx, val.v[4].len);
            val.v[5].cnt = cms_cnt_len_5.execute(val.v[5].idx, val.v[5].len);
            val.v[6].cnt = cms_cnt_len_6.execute(val.v[6].idx, val.v[6].len);
            val.v[7].cnt = cms_cnt_len_7.execute(val.v[7].idx, val.v[7].len);
            /* Save time */
            arrival_miri_act.execute(0);
            check_val.write(0, val.v[0].idx);
            /* Compute Estimate packet count (cnt) and packet length (len) */
            bit<32> estimate_packet_count;
            bit<32> estimate_packet_length;
            estimate_packet_count = min(val.v[0].cnt, val.v[1].cnt);
            estimate_packet_count = min(val.v[1].cnt, val.v[2].cnt); 
            estimate_packet_count = min(val.v[2].cnt, val.v[3].cnt);
            estimate_packet_count = min(val.v[3].cnt, val.v[4].cnt);
            estimate_packet_count = min(val.v[4].cnt, val.v[5].cnt);
            estimate_packet_count = min(val.v[5].cnt, val.v[6].cnt);
            estimate_packet_count = min(val.v[6].cnt, val.v[7].cnt);
            
            estimate_packet_length = min(val.v[0].len, val.v[1].len);
            estimate_packet_length = min(val.v[1].len, val.v[2].len); 
            estimate_packet_length = min(val.v[2].len, val.v[3].len);
            estimate_packet_length = min(val.v[3].len, val.v[4].len);
            estimate_packet_length = min(val.v[4].len, val.v[5].len);
            estimate_packet_length = min(val.v[5].len, val.v[6].len);
            estimate_packet_length = min(val.v[6].len, val.v[7].len);

            ig_md.info.estimate_pkt_cnt = estimate_packet_count;
            ig_md.info.estimate_pkt_len = estimate_packet_length;
            estimate_pcnt_act.execute(0);
            estimate_plen_act.execute(0);
            
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
