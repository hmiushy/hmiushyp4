/* -*- P4_16 -*- */
#include <core.p4>
#include <t2na.p4>

#define REPORT_TIME       5
#define REPORT_TIME_MIRI  5000
#define REPORT_TIME_MICRO 5000000

#define CMS_depth 8


#define CRC_BIT     10    // Used at CRC   // 2/4 /5/8/10/11/16
#define IP_SIZE_BIT 5     // Used at ipget // 5/16
#define THRESHOLD   0.3
#define W_SIZE      5     // The number of possessed packets
#define OBS_TIME    10000

// Pow(2,CRC_BIT) (Sketch Size)
#if CRC_BIT == 2
#define CMS_width 4
#define MY_PADDING 6

#elif CRC_BIT == 4
#define CMS_width 16
#define MY_PADDING 4

#elif CRC_BIT == 5
#define CMS_width 32
#define MY_PADDING 3

#elif CRC_BIT == 8
#define CMS_width 256
#define MY_PADDING 8

#elif CRC_BIT == 10
#define CMS_width 1024
#define MY_PADDING 6

#elif CRC_BIT == 11
#define CMS_width 2048
#define MY_PADDING 7

#elif CRC_BIT == 16
#define CMS_width 65536
#define MY_PADDING 8

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
    hash_t idx; // idx: index
    bit<MY_PADDING> pad;
}

struct cms_value {
    value_t[CMS_depth] v; // cnt, len, and idx
}

control CMS (
    inout switch_header_t hdr,
    inout switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
    inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm,
    in bit<16> time_microsec,
    in bit<16> time_mirisec,
    in bit<16> time_sec) {
    
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
    bit<32> tmp_cnt;   // Save temporal packet count 
    bit<32> tmp_len;   // Save temporal packet length
    bit<32> tmp_ip_src;
    bit<32> tmp_ip_dst;
    cms_value val;  // Aarray Structure // temporal values of cnt and len of pkt and index
    /*------------------- All Packet Count registers Action --------------------*/    
    Register<bit<32>, _>(CMS_width, 0) all_reg_cnt;
    Register<bit<32>, _>(CMS_width, 0) all_reg_len;
    
    /*------------------ Count Min Sketch registers and Hash -------------------*/
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_cnt_0;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_cnt_1;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_cnt_2;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_cnt_3;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_cnt_4;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_cnt_5;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_cnt_6;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_cnt_7;
    
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_len_0;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_len_1;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_len_2;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_len_3;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_len_4;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_len_5;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_len_6;
    Register<bit<32>, hash_t>(CMS_width, 0) cms_reg_len_7;
    
    RegisterAction<bit<32>, _, bit<32>>(all_reg_cnt) all_cnt = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    
    RegisterAction<bit<32>, _, bit<32>>(all_reg_len) all_len = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };
    /*------------------- Count Min Sketch registers Action --------------------*/
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_cnt_0) cms_cnt_0 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_cnt_1) cms_cnt_1 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_cnt_2) cms_cnt_2 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_cnt_3) cms_cnt_3 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_cnt_4) cms_cnt_4 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_cnt_5) cms_cnt_5 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_cnt_6) cms_cnt_6 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_cnt_7) cms_cnt_7 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + 1; read_value = value; }
    };
    /*------------------- Count Min Sketch registers Action --------------------*/
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_len_0) cms_len_0 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_len_1) cms_len_1 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_len_2) cms_len_2 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_len_3) cms_len_3 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_len_4) cms_len_4 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_len_5) cms_len_5 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_len_6) cms_len_6 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };
    RegisterAction<bit<32>, hash_t, bit<32>>(cms_reg_len_7) cms_len_7 = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = value + (bit<32>)hdr.ipv4.total_len;
            read_value = value; }
    };

    
    /*---------------- Get index of register using hash Action------------------*/
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_0;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_1;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_2;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_3;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_4;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_5;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_6;
    Hash<hash_t>(HashAlgorithm_t.CRC32) hash_7;
    action key2index_0(bit<32> tmp_ip) {
        val.v[0].idx = (hash_t)hash_0.get({tmp_ip, 32w0});
    }
    action key2index_1(bit<32> tmp_ip) {
        val.v[1].idx = (hash_t)hash_1.get({tmp_ip, 32w1});
    }
    action key2index_2(bit<32> tmp_ip) {
        val.v[2].idx = (hash_t)hash_2.get({tmp_ip, 32w2});
    }
    action key2index_3(bit<32> tmp_ip) {
        val.v[3].idx = (hash_t)hash_3.get({tmp_ip, 32w3});
    }
    action key2index_4(bit<32> tmp_ip) {
        val.v[4].idx = (hash_t)hash_4.get({tmp_ip, 32w4});
    }
    action key2index_5(bit<32> tmp_ip) {
        val.v[5].idx = (hash_t)hash_5.get({tmp_ip, 32w5});
    }
    action key2index_6(bit<32> tmp_ip) {
        val.v[6].idx = (hash_t)hash_6.get({tmp_ip, 32w6});
    }
    action key2index_7(bit<32> tmp_ip) {
        val.v[7].idx = (hash_t)hash_7.get({tmp_ip, 32w7});
    }

    /* ----- Mirisecond-time or Second-time packet arrival time reg ----- */
    Register<bit<8>,_>(1,0) enq_count;
    Register<bit<8>,_>(1,0) deq_count; 
    //MathUnit<bit<16>>(MathOp_t.DIV, 1, 16) rshift;
    RegisterAction<bit<8>, _, bit<8>>(enq_count) enq_act = {
        void apply (inout bit<8> value, out bit<8> read_value){
            value = value + 1;
            read_value = value;
        }
    };
    RegisterAction<bit<8>, _, bit<8>>(deq_count) deq_act = {
        void apply (inout bit<8> value, out bit<8> read_value){
            value = value + 1;
            read_value = value;
        }
    };

    /* ----- Store IP address */
    Register<bit<32>, bit<32>>(IP_SIZE, 0) src_ip_reg;  // store srcip 
    Register<bit<32>, bit<32>>(IP_SIZE, 0) dst_ip_reg;  // store dstip
    Register<bit<32>, bit<32>>(1, 0) element_count_src; // count element
    Register<bit<32>, bit<32>>(1, 0) element_count_dst; // count element
    
    
    
    Register<bit<32>, bit<32>>(OBS_TIME, 0) src_ip_queue; // possess packets
    Register<bit<32>, bit<32>>(W_SIZE, 0) dst_ip_queue; // 
    Hash<ipsize_t>(HashAlgorithm_t.CRC32) hash_src_ip;  // 
    Hash<ipsize_t>(HashAlgorithm_t.CRC32) hash_dst_ip;
    RegisterAction<bit<32>, _, bit<1>> (src_ip_reg) store_src_ip = {
        void apply(inout bit<32> value, out bit<1> read_value) {
            if (value != 0) {
                read_value = 1;
            }
            else {
                value = hdr.ipv4.src_addr;
                read_value = 0;
            }
        }
    };
    RegisterAction<bit<32>, _, bit<1>> (dst_ip_reg) store_dst_ip = {
        void apply(inout bit<32> value, out bit<1> read_value) {
            if (value != 0) {
                read_value = 1;
            }
            else {
                value = hdr.ipv4.dst_addr;
                read_value = 0;
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
    action src_ip2index(bit<32> tmp_ip) {
        ig_md.info.srcip2idx = (bit<32>)hash_src_ip.get({tmp_ip, 32w8});
    }
    action dst_ip2index(bit<32> tmp_ip) {
        ig_md.info.dstip2idx = (bit<32>)hash_dst_ip.get({tmp_ip, 32w9});
    }
    
    RegisterAction<bit<32>, _, bit<32>> (src_ip_queue) src_ip_queue_act = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            value = hdr.ipv4.dst_addr;
            read_value = value;
        }
    };

    
    Register<bit<32>,_>(10,0) check_value;
    RegisterAction<bit<32>,_,_> (check_value) cact = {
        void apply(inout bit<32> value){
            value = 1;
        }
    };

    /* Clock REPORT_TIME [sec] */
    Register<bit<32>,_>(1, 0) next_report;
    RegisterAction<bit<32>,_,bit<32>>(next_report) next_report_act = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            if (ig_md.info.ts_sec - value > REPORT_TIME) {
                value = ig_md.info.ts_sec;
                read_value = value;
            }
            else if (value < ig_md.info.ts_sec) {
                value = value + REPORT_TIME;
                read_value = value;
            }
            else {
                read_value = 0;
            }
        }
    };
    
    Register<bit<32>,_>(1, 0) next_report_miri;
    RegisterAction<bit<32>, bit<32>, bit<32>>(next_report_miri) next_report_miri_act = {
        void apply (inout bit<32> value, out bit<32> read_value){
            if (ig_md.info.ts_miri - value > REPORT_TIME_MIRI) {
                value = ig_md.info.ts_miri;
                read_value = value;
            }
            else if (value < ig_md.info.ts_miri) {
                value = value + REPORT_TIME_MIRI;
                read_value = value;
            }
            read_value = 0;
        }
    };
    Register<bit<32>,_>(1, 0) miri_sec;
    RegisterAction<bit<32>, bit<32>, bit<32>>(miri_sec) miri_clock = {
        void apply (inout bit<32> value, out bit<32> read_value) {
            value = ig_md.info.ts_miri;
        }
    };
    
    Register<bit<32>,_>(1, 0) next_report_micro;
    RegisterAction<bit<32>,_,bit<32>>(next_report_micro) next_report_micro_act = {
        void apply(inout bit<32> value, out bit<32> read_value) {
            if (ig_md.info.ts_micro - value > REPORT_TIME_MICRO) {
                value = ig_md.info.ts_micro;
                read_value = value;
            }
            else if (value < ig_md.info.ts_micro) {
                value = value + REPORT_TIME_MICRO;
                read_value = value;
            }
            else {
                read_value = 0;
            }
        }
    };
    //MathUnit<bit<32>>(MathOp_t.MUL, 1,1) power;
    Register<bit<32>,_> (1,0) f2;
    RegisterAction<bit<32>,_,bit<32>>(f2) f2_cal = {
        void apply (inout bit<32> value) {
            
        }
    };
    apply {
        if (hdr.ipv4.isValid()) {
            // Get to the packets of stream.
            tmp_cnt = all_cnt.execute(0);
            tmp_len = all_len.execute(0);
            // 2^20 = 1048576 (nearest 10^6) and get nano to mirisecond time
            ig_md.info.ts_micro = (bit<32>)ig_intr_md.ingress_mac_tstamp[47:10];
            ig_md.info.ts_miri = (bit<32>)ig_intr_md.ingress_mac_tstamp[47:20];
            ig_md.info.ts_sec = (bit<32>)ig_intr_md.ingress_mac_tstamp[47:30];
            tmp_ip_src = hdr.ipv4.src_addr;
            tmp_ip_dst = hdr.ipv4.dst_addr;
            key2index_0(tmp_ip_src);
            key2index_1(tmp_ip_src);
            key2index_2(tmp_ip_src);
            key2index_3(tmp_ip_src);
            key2index_4(tmp_ip_src);
            key2index_5(tmp_ip_src);
            key2index_6(tmp_ip_src);
            key2index_7(tmp_ip_src);

            // get ip addr to index to save the host info
            src_ip2index(hdr.ipv4.src_addr);
            dst_ip2index(hdr.ipv4.dst_addr);
            // get the ip hash and get flag
            ig_md.info.src_exist = store_src_ip.execute(ig_md.info.srcip2idx);
            ig_md.info.dst_exist = store_dst_ip.execute(ig_md.info.dstip2idx);
            el_act_s.execute(0); // element count action src
            el_act_d.execute(0); // element count action dst
            
            /* Update and Get Estimate packet count (cnt) and packet length (len) */
            val.v[0].cnt = cms_cnt_0.execute(val.v[0].idx);
            val.v[1].cnt = cms_cnt_1.execute(val.v[1].idx);
            val.v[2].cnt = cms_cnt_2.execute(val.v[2].idx);
            val.v[3].cnt = cms_cnt_3.execute(val.v[3].idx);
            val.v[4].cnt = cms_cnt_4.execute(val.v[4].idx);
            val.v[5].cnt = cms_cnt_5.execute(val.v[5].idx);
            val.v[6].cnt = cms_cnt_6.execute(val.v[6].idx);
            val.v[7].cnt = cms_cnt_7.execute(val.v[7].idx);
            
            val.v[0].len = cms_len_0.execute(val.v[0].idx);
            val.v[1].len = cms_len_1.execute(val.v[1].idx);
            val.v[2].len = cms_len_2.execute(val.v[2].idx);
            val.v[3].len = cms_len_3.execute(val.v[3].idx);
            val.v[4].len = cms_len_4.execute(val.v[4].idx);
            val.v[5].len = cms_len_5.execute(val.v[5].idx);
            val.v[6].len = cms_len_6.execute(val.v[6].idx);
            val.v[7].len = cms_len_7.execute(val.v[7].idx);
            /* Compute Estimate packet count (cnt) and packet length (len) */
            bit<32> estimate_packet_count;
            estimate_packet_count = min(val.v[0].cnt, val.v[1].cnt);
            estimate_packet_count = min(val.v[1].cnt, val.v[2].cnt); 
            estimate_packet_count = min(val.v[2].cnt, val.v[3].cnt);
            estimate_packet_count = min(val.v[3].cnt, val.v[4].cnt);
            estimate_packet_count = min(val.v[4].cnt, val.v[5].cnt);
            estimate_packet_count = min(val.v[5].cnt, val.v[6].cnt);
            estimate_packet_count = min(val.v[6].cnt, val.v[7].cnt);
            bit<32> estimate_packet_length;
            estimate_packet_length = min(val.v[0].len, val.v[1].len);
            estimate_packet_length = min(val.v[1].len, val.v[2].len); 
            estimate_packet_length = min(val.v[2].len, val.v[3].len);
            estimate_packet_length = min(val.v[3].len, val.v[4].len);
            estimate_packet_length = min(val.v[4].len, val.v[5].len);
            estimate_packet_length = min(val.v[5].len, val.v[6].len);
            estimate_packet_length = min(val.v[6].len, val.v[7].len);

            ig_md.info.estimate_pkt_cnt = estimate_packet_count;
            estimate_pcnt_act.execute(0);
            ig_md.info.estimate_pkt_len = estimate_packet_length;
            estimate_plen_act.execute(0);

            miri_clock.execute(0);
            bit<32> rv_sec;
            //bit<16> rv_miri;
            //bit<32> rv3;
            rv_sec = next_report_act.execute(0);
            //rv_miri = (bit<16>)next_report_miri_act.execute(0);
            //rv3 = next_report_micro_act.execute(0);
            /*
            if (rv_miri > 0) {
                // clear cms
                check_value.write(0, rv_sec);
                bit<32> ansf2;
                ansf2 = estimate_packet_count*estimate_packet_count;
                
            }
            */
            /*
            bit<32> now_h;
            bit<32> now_t;
            bit<8> fill;
            fill = fill_flag.read(0);
            now_h = head.read(0);
            if (fill > 0) {
                src_ip_queue.write(now_h, hdr.ipv4.dst_addr);
                now_t = tail.read(0);
                bit<32> tmp_src_ip;
                tmp_src_ip = src_ip_queue.read(now_t);
                now_t = now_t + 1;
                if ((bit<10>)now_t >= W_SIZE) {
                    now_t = 0;
                }
                tail.write(0, now_t);
                now_h = now_h + 1;
                if ((bit<10>)now_h >= W_SIZE) {
                    fill_flag.write(0, 1);
                    now_h = 0;
                }
                head.write(0, now_h);
            }
            else {
                src_ip_queue.write(now_h, hdr.ipv4.dst_addr);
                now_h = now_h + 1;
                if ((bit<10>)now_h >= W_SIZE) {
                    fill_flag.write(0, 1);
                    now_h = 0;
                }
                head.write(0, now_h);
            }
            */
            /*
            bit<1> rtf_last;
            
            src_ip_queue_act.execute(0); // action
            //dst_ip_queue_act.execute(0);
            bit<8> rtflag;
            bit<8> pre_time;
            bit<16> diff;
            //rtflag = rtf_act.dequeue();//rtf_act.execute(0);
            get_flag();
            rtf_last = rtfl_act.execute(0);
            if (ig_md.info.rtflag == 0 || rtf_last == 1) {
                set_time(); // Set time
            }
            else {
                get_time(); // Get time to ig_md.info.pre_time
            }
            pre_time = ig_md.info.pre_time; // get pre_repo_time
            diff = (bit<16>)(time_sec - pre_time); // 
            check_value.write(0, (bit<32>)diff);
            check_value.write(0, (bit<32>)rtflag);
            
            if (diff < REPORT_TIME) {
                src_ip_queue_act.enqueue(); // set srcIP
                //report_time0.write(0, time_sec);
                //
                rtfl_act.push();
                //rt_flag_last.write(0, 1);
                //set_time();
            }
            */
            // else {
            //     // update report time
            //     //repo_t = repo_act1.execute(0);
                
            // }
            
            /*
            bit<8> now_w;
            bit<32> reva;
            now_w = enq_act.execute(0);
            // reva = src_ip_queue_act.enqueue();
            // check_value.write(0, reva);
            // reva = src_ip_queue_act.dequeue();
            // check_value.write(1, reva);
            if (now_w <= W_SIZE) { // in window
                bit<32> tmp_src_ip;
                tmp_src_ip = src_ip_queue_act.enqueue();
                check_value.write(0, tmp_src_ip);
                //src_ip_queue_act.enqueue();
            }
            else { // over windowsize
                deq_act.execute(0);
                bit<32> tmp_src_ip;
                bit<32> tmp_dst_ip;
                //tmp_src_ip = src_ip_queue_act.dequeue();  // get removing ip
                //src_ip_queue_act.enqueue();
                //src_ip_queue_act.enqueue();
                tmp_src_ip = src_ip_queue_act.dequeue();  // get removing ip
                check_value.write(0, tmp_src_ip);
                //tmp_dst_ip = dst_ip_queue_act.dequeue();
                //src_ip2index(tmp_src_ip); // get index       
                //dst_ip2index(tmp_dst_ip);
                //src_ip_queue_act.enqueue();
                //dst_ip_queue_act.enqueue();
                
            }
            */
            
        }

    }
}

control CMS_b(
    inout switch_header_t hdr,
    inout switch_ingress_metadata_t ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_intr_from_prsr,
    inout ingress_intrinsic_metadata_for_deparser_t ig_intr_md_for_dprsr,
    inout ingress_intrinsic_metadata_for_tm_t ig_intr_md_for_tm) {
    
    CMS() cms;
    /*
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
    */
    apply {
        cms.apply(hdr, ig_md, ig_intr_md, ig_intr_from_prsr,
            ig_intr_md_for_dprsr, ig_intr_md_for_tm,
            ig_intr_md.ingress_mac_tstamp[25:10],
            ig_intr_md.ingress_mac_tstamp[35:20],
            ig_intr_md.ingress_mac_tstamp[45:30]);
        //ipv4_exact.apply();
    }
}

