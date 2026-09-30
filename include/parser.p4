

#ifndef __parser__p4

#define __parser__p4

#include"headers.p4"

// #define NET_MOD_PARSER_STATE_NAME(t) parse_payload_##t


// // c current , n for next.
// #define PARSE_IQ(c, n)\
// state parse_IQ##c\
//     {\
//         pkt.extract(hdr.IQ##c);\
//         transition select( hdr.circ.iq_hdr_index, hdr.circ.iq_hdr_end)\
//         {\
//             (n, 0): parse_tmp_iq;\
//             (n, 1): accept;\
//             (_, _): parse_IQ##n;\
//         }\
//     }\
// //
// #define PARSE_PAYLOAD(c, n)\
// state parse_payload##c\
//     {\
//         pkt.extract(hdr.payload##c);\
//         transition select(hdr.mod.mhl, hdr.mod.ec)\
//         {\
//             (c, 1w0): accept;\
//             (c, 1w1):parse_circ;\
//             (_, 1w0): parse_payload##n;\
//             (_, 1w1): parse_payload##n;\
//         }\
//     }\
// //

// #define NET_MOD_QAM64_PARSER(c, n)\
// state NET_MOD_PARSER_STATE_NAME(qam64##c)\
// {\
//     pkt.extract(hdr.qam64.payload##c);\
//     transition NET_MOD_PARSER_STATE_NAME(qam64##n);\
// }\
// //


parser IngressParser (
    packet_in pkt, 
    out ns_headers hdr,
    out meta_data meta, 
    out ingress_intrinsic_metadata_t ig_md

)
{
    Checksum() ipv4_checksum;

    state start 
    {
        pkt.extract(ig_md);
        pkt.advance(PORT_METADATA_SIZE);
        transition meta_init;
    }
    state meta_init {
        meta.ipv4_csum_err = 0;
        meta.dst_ipv4      = 0;
        meta.index = 0;
        meta.done = false;
        transition parse_ethernet;
    }
    
    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ether_type_t.IPV4 :  parse_ipv4;
            ether_type_t.ARP  :  parse_arp;
            default:  accept;
        }
    }
    
    state parse_arp {
        pkt.extract(hdr.arp);
        transition select(hdr.arp.hw_type, hdr.arp.proto_type) {
            (0x0001, ether_type_t.IPV4) : parse_arp_ipv4;
            default: reject; // Currently the same as accept
        }
    }

    state parse_arp_ipv4 {
        pkt.extract(hdr.arp_ipv4);
        meta.dst_ipv4 = hdr.arp_ipv4.dst_proto_addr;
        transition accept;
    }  
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        meta.dst_ipv4 = hdr.ipv4.dst_addr;
        
        ipv4_checksum.add(hdr.ipv4);
        meta.ipv4_csum_err = (bit<1>)ipv4_checksum.verify();
        
        transition select(
            hdr.ipv4.ihl,
            hdr.ipv4.frag_offset,
            hdr.ipv4.protocol)
        {
            (5, 0, ip_protocol_t.ICMP) : parse_icmp;
            (_, _, ip_protocol_t.UDP)  : parse_udp;
            default: accept;
        }
    }
    state parse_icmp {
        pkt.extract(hdr.icmp);
        transition accept;
    }
    state parse_udp
    {
        pkt.extract(hdr.udp);
        transition select(hdr.udp.src_port)
        {
            (NET_MOD_UDP_SRC_PORT): parse_mod;
            (_): accept;
        }
    }
    state parse_mod{
        pkt.extract(hdr.mod);
        transition select(hdr.mod.bps)
        {
            (6): parse_qam64_payload0;
            (_):parse_payload0;
        }
       
    }
    state parse_payload0
    {
        pkt.extract(hdr.payload0);

        transition accept;
    }
    

    // NET_MOD_QAM64_PARSER(0, 1)
    // NET_MOD_QAM64_PARSER(1, 2)
    // NET_MOD_QAM64_PARSER(2, 3)
    state parse_qam64_payload0
    {
        pkt.extract(hdr.qam64.payload0);
        transition accept;
    }

    // state parse_circ_payload0
    // {
    //    // pkt.extract(hdr.payload0);
    //     pkt.extract(hdr.circ);
    //     // depends on the value of hdr.circ.iq_s_index, hdr.iq_hdr_index 
    //     // when hdr.circ.iq_s_index = 7 then you should put temp into 
    //     // each time we circulate the packet the hdr.circ.iq_s_index is incremented and a value is passed to hdr.tmp_iq.s##k 
    //     // but this is not valid in fact , when the value of iq_s_index == 7 then you shoudl pass the value of hdr.tmp_iq to the 
    //     // hdr.IQ hdr with the value of iq_hdr_index 
    //     // transition select( hdr.circ.iq_s_index, hdr.iq_hdr_index)
    //     // {
    //     //     (7, 0): 
    //     // }
    //     // let the parser do the job, but how 
    //     // if hdr.circ.iq_hdr_end == 1 then parse hdr
    //      transition select( hdr.circ.iq_hdr_end, hdr.circ.iq_hdr_index)
    //     {
    //         (0, 0) : parse_tmp_iq;
    //         (1, _): parse_IQ0;
    //         default : parse_IQ0;
    //     }
    // }

    

    // state parse_iq0 
    // {
    //     transition select( hdr.circ.iq_hdr_end, hdr.circ.iq_hdr_index)
    //     {
    //         (0, c) : parse_tmp_iq;
    //         (1): parse_IQ0;
    //     }
    // }

//     PARSE_IQ(0, 1)
//     PARSE_IQ(1, 2)
//     PARSE_IQ(2, 3)
//     PARSE_IQ(3, 4)
//     PARSE_IQ(4, 5)
//     PARSE_IQ(5, 6)
//     PARSE_IQ(6, 7)
//     PARSE_IQ(7, 8)
//     PARSE_IQ(8, 9)
//     PARSE_IQ(9,  10)
//     PARSE_IQ(10, 11)
//     PARSE_IQ(11, 12)
//     PARSE_IQ(12, 13)
//     PARSE_IQ(13, 14)
//     PARSE_IQ(14, 15)
//     //PARSE_IQ(14, 7)
    

//     state parse_IQ15
//     {
//         pkt.extract(hdr.IQ15);
//         transition select(hdr.circ.iq_hdr_index, hdr.circ.iq_hdr_end)
//         {
//             (15, 0):parse_tmp_iq;
//             (15, 1): accept;
//             default:accept;
//         }
//     }
//  state parse_tmp_iq
//     {
//         pkt.extract(hdr.tmp_iq);
//         transition accept;
//     }

}

#endif
