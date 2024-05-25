/* -*- P4_16 -*- */

#include <core.p4>
#include <t2na.p4>

#include "std_hdrs.p4"
#include "const.p4"
#include "parser.p4"

#define REPORT_TIME 100
#define END_TIMESTEP 20



struct for_debug_s {
    bit<16> g_t;
    bit<16> m_t;
}
struct my_time {
    bit<16> micro_s;
    bit<16> miri_s;
}
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

    Register<bit<64>, bit<48>>(1,0) test;
    
    /*--------------- Variables used Count Min Sketch registers ----------------*/
    bit<32> all_cnt;   // Save temporal packet count 
    bit<32> all_len;   // Save temporal packet length 

    /*------------------ Count Min Sketch registers and Hash -------------------*/
    Register<pair, bit<32>>(1, {0,0}) just_packet_cnt;
    Register<bit<32>, bit<32>>(1, 0) all_pkt_cnt;
    Register<bit<32>, bit<32>>(1, 0) all_pkt_len;
    Register<for_debug_s, bit<48>>(3,{0,0}) for_debug;
    Register<my_time, bit<48>>(3,{0,0}) micro_sec;

    Register<bit<16>, bit<48>>(1,0) before_pkt_nano;
    Register<bit<16>, bit<48>>(1,0) before_pkt_miri;
    Register<bit<16>, bit<48>>(3,0) diff_nano;
    Register<bit<16>, bit<48>>(3,0) diff_miri;
    
    Register<bit<32>,bit<32>>(END_TIMESTEP) report_result_cnt;
    Register<bit<32>,bit<32>>(END_TIMESTEP) report_result_len;
    Register<bit<64>, bit<48>>(1,0) report_point;
    
    
    // action test2 (bit<32> read_value1, bit<32> read_value2){
    //     ig_md.my_info.pkt_cnt = (bit<32>)read_value1;
    //     ig_md.my_info.pkt_len = (bit<32>)read_value2;
    // }
    /*------------------- All Packet Count registers Action --------------------*/
    RegisterAction<pair, bit<32>, bit<32>>(just_packet_cnt) all_cnt_len = {
        void apply(inout pair value, out bit<32> read_value1, out bit<32> read_value2){
            value.packet_count  = value.packet_count  + 1;
            value.packet_length = value.packet_length + (bit<32>)hdr.ipv4.total_len;
            read_value1 = value.packet_count;
            read_value2 = value.packet_length;
            //test2(read_value1, read_value2);
        }
    };
    /*------------------- All Packet Count registers Action --------------------*/
    RegisterAction<bit<32>, bit<32>, bit<32>>(all_pkt_cnt) cnt_tbl = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            value = value + 1;
            read_value = value;
        }
    };
    /*------------------- All Packet Count registers Action --------------------*/
    RegisterAction<bit<32>, bit<32>, bit<32>>(all_pkt_len) len_tbl = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value;
        }
    };
    //RegisterAction<bit<64>, bit<32>, bit<32>>
    
    RegisterAction<bit<64>, bit<32>, bit<32>>(report_result_cnt) repo_action_cnt = {
        void apply (inout bit<64> value) {
            value = (bit<64>)ig_md.info.pkt_cnt;
        }
    };
    RegisterAction<bit<64>, bit<32>, bit<32>>(report_result_len) repo_action_len = {
        void apply (inout bit<64> value) {
            value = (bit<64>)ig_md.info.pkt_len;
        }
    };
    
    RegisterAction<for_debug_s, bit<48>, bit<64>>(for_debug) debug_tbl = {
      void apply(inout for_debug_s value){//, out bit<64> a, out bit<64> b) {
            // This is [sec] // 2^30 = 1.073741824*(10^9)
            // The nearest number of 10^9
            value.g_t = (bit<16>)(ig_intr_md.ingress_mac_tstamp[47:30]);

            // This is [microsec] // 2^10 = 1024 // If you want to change
            // [nanosec] to [microsec], divide [nsec] by 10^3.
            // 2^10 is the nearest number to 10^3 (1024, 1000).
            //value.g_t = (bit<16>)(ig_intr_md.ingress_mac_tstamp[47:10]);
            
        }
    };
    
    
    RegisterAction<my_time, bit<48>, bit<64>>(micro_sec) my_time_table = {
      void apply(inout my_time value){
            // This is [microsec] // 2^10 = 1024 // If you want to change
            // [nanosec] to [microsec], divide [nsec] by 10^3.
            // 2^10 is the nearest number to 10^3 (1024, 1000).
            value.micro_s = (bit<16>)(ig_intr_md.ingress_mac_tstamp[47:10]);

            //This is [msec] // 2^20
            //The nearest number of 10^6
            value.miri_s  = (bit<16>)(ig_intr_md.ingress_mac_tstamp[47:20]);
            
            // This is [sec] // 2^30 = 1.073741824*(10^9)
            // The nearest number of 10^9
            //value.sec     = (bit<16>)(ig_intr_md.ingress_mac_tstamp[47:30]);
            
        }
    };
    
    
    RegisterAction<bit<16>, bit<48>, bit<64>>(before_pkt_nano) bfr_pkt_n = {
      void apply(inout bit<16> value){
            value = (bit<16>)(ig_intr_md.ingress_mac_tstamp[21:10]);
        }
    };
    RegisterAction<bit<16>, bit<48>, bit<64>>(before_pkt_miri) bfr_pkt_m = {
      void apply(inout bit<16> value){
            value = (bit<16>)(ig_intr_md.ingress_mac_tstamp[33:20]); // 1000 = 1 [sec]
        }
    };
    
    
    apply {
        if (hdr.ipv4.isValid()) {
            all_cnt = all_cnt_len.execute(0, all_len);
            ig_md.info.pkt_cnt = cnt_tbl.execute(0);
            ig_md.info.pkt_len = len_tbl.execute(0);
            ig_md.info.ts_nano =  ig_intr_md.ingress_mac_tstamp;
            ig_md.info.ts_micr = (bit<16>)ig_intr_md.ingress_mac_tstamp[21:10];
            ig_md.info.ts_micr_last = (bit<16>)ig_intr_md.ingress_mac_tstamp[11:0];
            ig_md.info.ts_miri = (bit<16>)ig_intr_md.ingress_mac_tstamp[35:20];
            ig_md.info.ts_miri_last = (bit<16>)ig_intr_md.ingress_mac_tstamp[21:0];
            
            bit<48> tmp_bfr_pkt_miri;
            bit<48> diff_time_miri;
            debug_tbl.execute(0);
            
            tmp_bfr_pkt_miri = (bit<48>)before_pkt_miri.read(0);
            diff_time_miri = (bit<48>)(ig_md.info.ts_miri - tmp_bfr_pkt_miri[35:20]);
            
            bit<16> value;
            value = 1000;
            if (value >  (bit<16>)(diff_time_miri[33:20])) {
                repo_action_cnt.execute(0);
                repo_action_len.execute(0);
                repo_action_cnt.push();
                repo_action_len.push();
            }
        }
        /*
        bit<64> now_time;   // in-packet time
        bit<64> before_time; // before report time
        bit<32> diff_time;   // difference
        //now_time    = (bit<64>)ig_intr_from_prsr.global_tstamp;
        //before_time = (bit<64>)ig_intr_md.ingress_mac_tstamp;
        for_debug_s fds;
        fds.g_t = now_time;
        fds.m_t = before_time;
        
        
        bit<10> t2;
        t2 = (bit<10>)report_result.read(0);
        //if (t2 > 5) repo_action.pop();
        repo_action.execute(0);
        my_time_table.execute(0);
        */
        //repo_action.execute(0);
        //now_time = debug_tbl.execute(0, before_time);
        //debug_tbl.write(0,)
        //before_time = report_point.read(0);
        //all_len = repo_action.push(all_cnt);
        //repo_action.push(all_len);
        //repo_action.synchronous(1);
        

                /*
        if ((bit<10>)now_time > 100) {
            all_cnt = all_cnt_len.execute(0, all_len);
            all_len = repo_action.push();
            //just_packet_cnt.clear({0,0});
        }
        */
        if (hdr.ipv4.isValid()) {
            //all_cnt = all_cnt_len.execute(0, all_len);
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

    /*
    Register<bit<32>,bit<32>>(END_TIMESTEP) report_result;
    Register<bit<64>, bit<48>>(1,0) report_point;

    Register<for_debug_s, bit<48>>(3,{0,0}) for_debug;
    RegisterAction<for_debug_s, bit<48>, bit<64>>(for_debug) debug_tbl = {
      void apply(inout for_debug_s value){

            // value.g_t = (bit<64>)ig_intr_from_prsr.global_tstamp;
            // value.m_t = (bit<64>)ig_intr_md.ingress_mac_tstamp;
            value.g_t = (bit<64>)eg_intr_md.deq_timedelta;
            value.m_t = (bit<64>)eg_intr_md_from_prsr.global_tstamp;
        }
    };
    */
    apply {
        //test.write(0, 111);
        //eg_md.tna_timestamps_hdr.enqueue = eg_intr_md.enq_tstamp;
        //eg_md.tna_timestamps_hdr.dequeue_delta = eg_intr_md.deq_timedelta;
        //eg_md.tna_timestamps_hdr.egress_global = eg_intr_md_from_prsr.global_tstamp;
        // tx timestamping is only available on hardware

        // request tx ptp correction timestamp insertion
        // eg_intr_md_for_oport.update_delay_on_tx = true;

        // Instructions for the ptp correction timestamp writer
        // eg_md.tx_ptp_md_hdr.setValid();
        // eg_md.tx_ptp_md_hdr.cf_byte_offset = 8w76;
        // eg_md.tx_ptp_md_hdr.udp_cksum_byte_offset = 8w34;
        // eg_md.tx_ptp_md_hdr.updated_cf = 0;
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
