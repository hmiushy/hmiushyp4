```
:05-21 11:19:23.102466:    :-:-:<0,-,0>:Begin packet processing
:05-21 11:19:23.102873:    :0xd:-:<0,0,0>:========== Ingress Pkt from port 8 (64 bytes)  ==========
:05-21 11:19:23.102902:    :0xd:-:<0,0,0>:Packet :
:05-21 11:19:23.102926:        :0xd:-:<0,0,0>:ff ff ff ff ff ff 46 ae c2 39 db d0 08 06 00 01 
:05-21 11:19:23.102945:        :0xd:-:<0,0,0>:08 00 06 04 00 01 46 ae c2 39 db d0 c0 a8 44 0d 
:05-21 11:19:23.102966:        :0xd:-:<0,0,0>:00 00 00 00 00 00 c0 a8 44 0d 00 00 00 00 00 00 
:05-21 11:19:23.102985:        :0xd:-:<0,0,0>:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
:05-21 11:19:23.103014:    :0xd:-:<0,0,->:========== Packet to input parser: from port 8 (96 bytes)  ==========
:05-21 11:19:23.103029:    :0xd:-:<0,0,->:Packet :
:05-21 11:19:23.103048:        :0xd:-:<0,0,->:00 08 00 21 e9 6a a0 80 00 00 00 00 00 00 00 00 
:05-21 11:19:23.103066:        :0xd:-:<0,0,->:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
:05-21 11:19:23.103085:        :0xd:-:<0,0,->:ff ff ff ff ff ff 46 ae c2 39 db d0 08 06 00 01 
:05-21 11:19:23.103104:        :0xd:-:<0,0,->:08 00 06 04 00 01 46 ae c2 39 db d0 c0 a8 44 0d 
:05-21 11:19:23.103214:    :0xd:-:<0,0,4>:Ingress Parser state '$entry_point'
:05-21 11:19:23.103293:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0x1000, updating PHV word 129 to value     0x0010 I [POV]
:05-21 11:19:23.103327:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0x0008, updating PHV word 179 to value     0x0008 I [_ipv4_lpm_partition_index[10:8], _ipv4_lpm_subtree_id[0:0], hdr.bridged_md.__pad_6[6:0], hdr.bridged_md.base_ingress_port[8:0], ig_md.port[8:0]]
:05-21 11:19:23.103391:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0x0021, updating PHV word 197 to value     0x0021 I [hdr.bridged_md.base_timestamp[47:32], ig_md.timestamp[47:32]]
:05-21 11:19:23.103427:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0xe96a,  setting PHV word  11 to value 0xe96a0000 I [hdr.bridged_md.base_timestamp[31:0], ig_md.timestamp[31:0]]
:05-21 11:19:23.103458:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0xa080,  setting PHV word  11 to value 0xe96aa080 I [hdr.bridged_md.base_timestamp[31:0], ig_md.timestamp[31:0]]
:05-21 11:19:23.103490:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0x0000, updating PHV word 128 to value     0x0000 I [hdr.bridged_md.__pad_5[5:0], hdr.bridged_md.base_ingress_port_lag_index[9:0], ig_md.port_lag_index[9:0]]
:05-21 11:19:23.103520:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0x0000,  setting PHV word  27 to value 0x00000000 I [_ipv4_lpm_partition_index[7:0], _ipv6_lpm128_partition_index[7:0], ig_md.port_lag_label[31:8]]
:05-21 11:19:23.103550:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0x0000,  setting PHV word  27 to value 0x00000000 I [_ipv4_lpm_partition_index[7:0], _ipv6_lpm128_partition_index[7:0], ig_md.port_lag_label[31:8]]
:05-21 11:19:23.103588:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0x0000,  setting PHV word   1 to value 0x00000000 I [_ipv4_lpm_partition_key[17:0], _ipv6_lpm64_partition_index[9:0], ig_md.port_lag_label[7:0]]
:05-21 11:19:23.103626:        :0xd:-:<0,0,4>:Ingress Parser state '$entry_point': extracted     0x0000,  setting PHV word   1 to value 0x00000000 I [_ipv4_lpm_partition_key[17:0], _ipv6_lpm64_partition_index[9:0], ig_md.port_lag_label[7:0]]
:05-21 11:19:23.103660:    :0xd:-:<0,0,4>:Ingress Parser state 'start.$oob_stall_0'
:05-21 11:19:23.103705:    :0xd:-:<0,0,4>:Ingress Parser state 'start.$split_0'
:05-21 11:19:23.103756:        :0xd:-:<0,0,4>:Ingress Parser state 'start.$split_0': extracted     0xffff,  setting PHV word  29 to value 0xffff0000 I [hdr.ethernet.dst_addr[47:16]]
:05-21 11:19:23.103810:        :0xd:-:<0,0,4>:Ingress Parser state 'start.$split_0': extracted     0xffff,  setting PHV word  29 to value 0xffffffff I [hdr.ethernet.dst_addr[47:16]]
:05-21 11:19:23.103840:        :0xd:-:<0,0,4>:Ingress Parser state 'start.$split_0': extracted     0xffff, updating PHV word 141 to value     0xffff I [hdr.ethernet.dst_addr[15:0]]
:05-21 11:19:23.103869:        :0xd:-:<0,0,4>:Ingress Parser state 'start.$split_0': extracted     0x46ae,  setting PHV word  28 to value 0x46ae0000 I [hdr.ethernet.src_addr[47:16]]
:05-21 11:19:23.103898:        :0xd:-:<0,0,4>:Ingress Parser state 'start.$split_0': extracted     0xc239,  setting PHV word  28 to value 0x46aec239 I [hdr.ethernet.src_addr[47:16]]
:05-21 11:19:23.103928:        :0xd:-:<0,0,4>:Ingress Parser state 'start.$split_0': extracted     0xdbd0, updating PHV word 140 to value     0xdbd0 I [hdr.ethernet.src_addr[15:0]]
:05-21 11:19:23.103960:        :0xd:-:<0,0,4>:Ingress Parser state 'start.$split_0': extracted     0x0806, updating PHV word 194 to value     0x0806 I [hdr.ethernet.ether_type[15:0]]
:05-21 11:19:23.103994:    :0xd:-:<0,0,4>:Ingress Parser state 'parse_arp'
:05-21 11:19:23.104040:        :0xd:-:<0,0,4>:Ingress Parser state 'parse_arp': extracted     0x0200, updating PHV word  88 to value       0x02 I [ig_md.lkp.ip_frag[1:0], ig_md.lkp.ip_type[1:0], POV]
:05-21 11:19:23.104077:        :0xd:-:<0,0,4>:Ingress Parser state 'parse_arp': extracted     0x0001, updating PHV word 188 to value     0x0001 I [hdr.arp.opcode[15:0], hdr.icmp.code[7:0], hdr.icmp.type[7:0], hdr.tcp.src_port[15:0], hdr.udp.src_port[15:0]]
:05-21 11:19:23.104104:        :0xd:-:<0,0,->:Ingress Headers:
:05-21 11:19:23.104130:        :0xd:-:<0,0,->:Header hdr.arp.$valid is valid
:05-21 11:19:23.104145:        :0xd:-:<0,0,->:Header hdr.ethernet.$valid is valid
:05-21 11:19:23.104227:    :0xd:-:<0,0,->:------------ Stage 0 ------------
:05-21 11:19:23.105072:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.pkt_validation.validate_ethernet is miss
:05-21 11:19:23.105094:        :0xd:-:<0,0,0>:Key:
:05-21 11:19:23.105148:        :0xd:-:<0,0,0>:	hdr.ethernet.dst_addr[15:0] = 0xFFFF
:05-21 11:19:23.105164:        :0xd:-:<0,0,0>:	hdr.ethernet.dst_addr[47:16] = 0xFFFFFFFF
:05-21 11:19:23.105179:        :0xd:-:<0,0,0>:	hdr.ethernet.src_addr[15:0] = 0xDBD0
:05-21 11:19:23.105194:        :0xd:-:<0,0,0>:	hdr.ethernet.src_addr[47:16] = 0x46AEC239
:05-21 11:19:23.105209:        :0xd:-:<0,0,0>:	--validity_check--hdr.vlan_tag$0.$valid = 0x0
:05-21 11:19:23.105224:        :0xd:-:<0,0,0>:	--validity_check--hdr.vlan_tag$1.$valid = 0x0
:05-21 11:19:23.105247:        :0xd:-:<0,0,0>:Execute Default Action: NoAction
:05-21 11:19:23.105320:        :0xd:-:<0,0,0>:Action Results:
:05-21 11:19:23.105336:        :0xd:-:<0,0,0>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.105353:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.ingress_port_mapping.port_mirror.port_mirror is miss
:05-21 11:19:23.105368:        :0xd:-:<0,0,0>:Key:
:05-21 11:19:23.105391:        :0xd:-:<0,0,0>:	ig_md.port[8:0] = 0x8
:05-21 11:19:23.105410:        :0xd:-:<0,0,0>:Execute Default Action: NoAction
:05-21 11:19:23.105450:        :0xd:-:<0,0,0>:Action Results:
:05-21 11:19:23.105464:        :0xd:-:<0,0,0>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.105480:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.ingress_port_mapping.port_mapping is miss
:05-21 11:19:23.105495:        :0xd:-:<0,0,0>:Key:
:05-21 11:19:23.105513:        :0xd:-:<0,0,0>:	ig_md.port[8:0] = 0x8
:05-21 11:19:23.105530:        :0xd:-:<0,0,0>:Execute Default Action: NoAction
:05-21 11:19:23.105569:        :0xd:-:<0,0,0>:Action Results:
:05-21 11:19:23.105583:        :0xd:-:<0,0,0>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.105599:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.ingress_port_mapping.rmac.pv_rmac is not active(inhibited/skipped)
:05-21 11:19:23.105616:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.ingress_port_mapping.port_double_tag_to_bd_mapping is not active(inhibited/skipped)
:05-21 11:19:23.105641:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.ingress_port_mapping.port_vlan_to_bd_mapping is not active(inhibited/skipped)
:05-21 11:19:23.105658:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.pkt_validation.validate_ip is miss
:05-21 11:19:23.105672:        :0xd:-:<0,0,0>:Key:
:05-21 11:19:23.105754:        :0xd:-:<0,0,0>:	--validity_check--hdr.arp.$valid = 0x1
:05-21 11:19:23.105769:        :0xd:-:<0,0,0>:	--validity_check--hdr.ipv4.$valid = 0x0
:05-21 11:19:23.105784:        :0xd:-:<0,0,0>:	hdr.ipv4.flags[2:0] = 0x0
:05-21 11:19:23.105799:        :0xd:-:<0,0,0>:	hdr.ipv4.frag_offset[12:0] = 0x0
:05-21 11:19:23.105813:        :0xd:-:<0,0,0>:	hdr.ipv4.ihl[3:0] = 0x0
:05-21 11:19:23.105828:        :0xd:-:<0,0,0>:	hdr.ipv4.src_addr[31:0] = 0x0
:05-21 11:19:23.105842:        :0xd:-:<0,0,0>:	hdr.ipv4.ttl[7:0] = 0x0
:05-21 11:19:23.105857:        :0xd:-:<0,0,0>:	hdr.ipv4.version[3:0] = 0x0
:05-21 11:19:23.105871:        :0xd:-:<0,0,0>:	--validity_check--hdr.ipv6.$valid = 0x0
:05-21 11:19:23.105885:        :0xd:-:<0,0,0>:	hdr.ipv6.hop_limit[7:0] = 0x0
:05-21 11:19:23.105900:        :0xd:-:<0,0,0>:	hdr.ipv6.src_addr[15:0] = 0x0
:05-21 11:19:23.105914:        :0xd:-:<0,0,0>:	hdr.ipv6.src_addr[31:16] = 0x0
:05-21 11:19:23.105928:        :0xd:-:<0,0,0>:	hdr.ipv6.src_addr[63:32] = 0x0
:05-21 11:19:23.105943:        :0xd:-:<0,0,0>:	hdr.ipv6.src_addr[95:64] = 0x0
:05-21 11:19:23.105957:        :0xd:-:<0,0,0>:	hdr.ipv6.src_addr[127:96] = 0x0
:05-21 11:19:23.105972:        :0xd:-:<0,0,0>:	hdr.ipv6.version[3:0] = 0x0
:05-21 11:19:23.105986:        :0xd:-:<0,0,0>:	ig_md.flags.ipv4_checksum_err[0:0] = 0x0
:05-21 11:19:23.106006:        :0xd:-:<0,0,0>:Execute Default Action: NoAction
:05-21 11:19:23.106056:        :0xd:-:<0,0,0>:Action Results:
:05-21 11:19:23.106073:        :0xd:-:<0,0,0>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.106092:    :0xd:-:<0,0,0>:Ingress : Gateway table condition () not matched.
:05-21 11:19:23.106108:    :0xd:-:<0,0,0>:Ingress : Gateway attached to SwitchIngress.pkt_validation.validate_other
:05-21 11:19:23.106132:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.pkt_validation.validate_other is inhibited by a gateway condition
:05-21 11:19:23.106150:        :0xd:-:<0,0,0>:Execute Default Action: NoAction
:05-21 11:19:23.106189:        :0xd:-:<0,0,0>:Action Results:
:05-21 11:19:23.106211:        :0xd:-:<0,0,0>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.106229:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.ingress_port_mapping.vlan_to_bd_mapping is not active(inhibited/skipped)
:05-21 11:19:23.106245:    :0xd:-:<0,0,0>:Ingress : Table SwitchIngress.ingress_port_mapping.rmac.vlan_rmac is not active(inhibited/skipped)
:05-21 11:19:23.106267:    :0xd:-:<0,0,->:------------ Stage 1 ------------
:05-21 11:19:23.106966:    :0xd:-:<0,0,1>:Ingress : Gateway table condition ((ig_md.flags.rmac_hit)) not matched.
:05-21 11:19:23.106984:    :0xd:-:<0,0,1>:Ingress : Gateway attached to cond-64
:05-21 11:19:23.106999:    :0xd:-:<0,0,1>:Ingress : Associated table cond-64 is executed
:05-21 11:19:23.107013:    :0xd:-:<0,0,1>:Ingress : Gateway did provide payload.
:05-21 11:19:23.107028:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.107045:    :0xd:-:<0,0,1>:Ingress : Table SwitchIngress.lou.l4_dst_port is miss
:05-21 11:19:23.107059:        :0xd:-:<0,0,1>:Key:
:05-21 11:19:23.107080:        :0xd:-:<0,0,1>:	ig_md.lkp.l4_dst_port[15:0] = 0x0
:05-21 11:19:23.107097:        :0xd:-:<0,0,1>:Execute Default Action: NoAction
:05-21 11:19:23.107141:        :0xd:-:<0,0,1>:Action Results:
:05-21 11:19:23.107155:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.107171:    :0xd:-:<0,0,1>:Ingress : Table SwitchIngress.lou.l4_src_port is miss
:05-21 11:19:23.107185:        :0xd:-:<0,0,1>:Key:
:05-21 11:19:23.107203:        :0xd:-:<0,0,1>:	ig_md.lkp.l4_src_port[15:0] = 0x0
:05-21 11:19:23.107219:        :0xd:-:<0,0,1>:Execute Default Action: NoAction
:05-21 11:19:23.107259:        :0xd:-:<0,0,1>:Action Results:
:05-21 11:19:23.107281:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.107303:    :0xd:-:<0,0,1>:Ingress : Table ipv6_host is not active(inhibited/skipped)
:05-21 11:19:23.107319:    :0xd:-:<0,0,1>:Ingress : Table tbl_validation321 is miss
:05-21 11:19:23.107333:        :0xd:-:<0,0,1>:Key:
:05-21 11:19:23.107396:        :0xd:-:<0,0,1>:Execute Default Action: validation321
:05-21 11:19:23.107484:        :0xd:-:<0,0,1>:Action Results:
:05-21 11:19:23.107499:        :0xd:-:<0,0,1>:	----- DirectAluPrimitive -----
:05-21 11:19:23.107515:        :0xd:-:<0,0,1>:	Operation:
:05-21 11:19:23.107530:        :0xd:-:<0,0,1>:	xor
:05-21 11:19:23.107545:        :0xd:-:<0,0,1>:	Destination:
:05-21 11:19:23.107561:        :0xd:-:<0,0,1>:	ig_md.same_mac[15:0] = 0x0
:05-21 11:19:23.107575:        :0xd:-:<0,0,1>:	mask=0xFFFF
:05-21 11:19:23.107591:        :0xd:-:<0,0,1>:	Source 1:
:05-21 11:19:23.107605:        :0xd:-:<0,0,1>:	ig_md.lkp.mac_src_addr[15:0] = 0x0
:05-21 11:19:23.107620:        :0xd:-:<0,0,1>:	ig_md.lkp.mac_src_addr[47:16] = 0x0
:05-21 11:19:23.107634:        :0xd:-:<0,0,1>:	Source 2:
:05-21 11:19:23.107649:        :0xd:-:<0,0,1>:	ig_md.lkp.mac_dst_addr[15:0] = 0x0
:05-21 11:19:23.107663:        :0xd:-:<0,0,1>:	ig_md.lkp.mac_dst_addr[47:16] = 0x0
:05-21 11:19:23.107679:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.107698:    :0xd:-:<0,0,1>:Ingress : Gateway table condition ((ig_md.bypass & 16 == 0 && ig_md.qos.trust_mode & 1 == 1 && ig_md.lkp.ip_type != 0)) matched.
:05-21 11:19:23.107715:    :0xd:-:<0,0,1>:Ingress : Table SwitchIngress.qos_map.dscp_tc_map is inhibited by a gateway condition
:05-21 11:19:23.107731:    :0xd:-:<0,0,1>:Ingress : Gateway did provide payload.
:05-21 11:19:23.107746:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.107767:    :0xd:-:<0,0,1>:Ingress : Gateway table condition ((ig_md.lkp.ip_frag != 0)) matched.
:05-21 11:19:23.107783:    :0xd:-:<0,0,1>:Ingress : Gateway attached to tbl_hash116
:05-21 11:19:23.107798:    :0xd:-:<0,0,1>:Ingress : Associated table tbl_hash116 is executed
:05-21 11:19:23.107812:    :0xd:-:<0,0,1>:Ingress : Gateway did provide payload.
:05-21 11:19:23.107828:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.107845:    :0xd:-:<0,0,1>:Ingress : Table SwitchIngress.ecn_acl.acl is miss
:05-21 11:19:23.107860:        :0xd:-:<0,0,1>:Key:
:05-21 11:19:23.107895:        :0xd:-:<0,0,1>:	ig_md.lkp.ip_tos[7:0] = 0x0
:05-21 11:19:23.107910:        :0xd:-:<0,0,1>:	ig_md.lkp.tcp_flags[7:0] = 0x0
:05-21 11:19:23.107924:        :0xd:-:<0,0,1>:	ig_md.port_lag_label[7:0] = 0x0
:05-21 11:19:23.107939:        :0xd:-:<0,0,1>:	ig_md.port_lag_label[31:8] = 0x0
:05-21 11:19:23.107957:        :0xd:-:<0,0,1>:Execute Default Action: NoAction
:05-21 11:19:23.108007:        :0xd:-:<0,0,1>:Action Results:
:05-21 11:19:23.108022:        :0xd:-:<0,0,1>:	----- ModifyFieldPrimitive -----
:05-21 11:19:23.108036:        :0xd:-:<0,0,1>:	Operation:
:05-21 11:19:23.108050:        :0xd:-:<0,0,1>:	set
:05-21 11:19:23.108065:        :0xd:-:<0,0,1>:	Destination:
:05-21 11:19:23.108079:        :0xd:-:<0,0,1>:	mask=0x3
:05-21 11:19:23.108096:        :0xd:-:<0,0,1>:	Source 1:
:05-21 11:19:23.108111:        :0xd:-:<0,0,1>:	Val=0x2
:05-21 11:19:23.108127:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.108146:    :0xd:-:<0,0,1>:Ingress : Gateway table condition ((ig_md.flags.ctag_flag)) not matched.
:05-21 11:19:23.108161:    :0xd:-:<0,0,1>:Ingress : Gateway attached to cond-62
:05-21 11:19:23.108176:    :0xd:-:<0,0,1>:Ingress : Associated table cond-62 is executed
:05-21 11:19:23.108190:    :0xd:-:<0,0,1>:Ingress : Gateway did provide payload.
:05-21 11:19:23.108205:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.108224:    :0xd:-:<0,0,1>:Ingress : Gateway table condition ((ig_md.lkp.ip_type == 0)) matched.
:05-21 11:19:23.108239:    :0xd:-:<0,0,1>:Ingress : Gateway attached to tbl_hash168
:05-21 11:19:23.108253:    :0xd:-:<0,0,1>:Ingress : Associated table tbl_hash168 is executed
:05-21 11:19:23.108268:    :0xd:-:<0,0,1>:Ingress : Gateway did provide payload.
:05-21 11:19:23.108293:        :0xd:-:<0,0,1>:Execute Action: hash168
:05-21 11:19:23.108342:        :0xd:-:<0,0,1>:Action Results:
:05-21 11:19:23.108357:        :0xd:-:<0,0,1>:	----- SetFieldToHashIndexPrimitive -----
:05-21 11:19:23.108372:        :0xd:-:<0,0,1>:	Destination:
:05-21 11:19:23.108386:        :0xd:-:<0,0,1>:	ig_md.lag_hash[15:0] = 0x87D2
:05-21 11:19:23.108400:        :0xd:-:<0,0,1>:	ig_md.lag_hash[31:16] = 0x2332
:05-21 11:19:23.108415:        :0xd:-:<0,0,1>:Next Table = --END_OF_PIPELINE--
:05-21 11:19:23.108436:    :0xd:-:<0,0,->:------------ Stage 2 ------------
:05-21 11:19:23.108700:    :0xd:-:<0,0,2>:
```