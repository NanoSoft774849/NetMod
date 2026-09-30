#ifndef __headers__p4

#define __headers__p4


#include"defs.p4"


header ethernet_h{
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    bit<16> ether_type;
}


header ipv4_h {
    bit<4>   version;
    bit<4>   ihl;
    // Type of Service field : bit6-7 are reserved therefore it can be used to distinguish NetMod from other protocols..
    bit<8>   diffserv;
    bit<16>  total_len;
    bit<16>  identification;
    bit<3>   flags;
    bit<13>  frag_offset;
    bit<8>   ttl;
    bit<8>   protocol;
    bit<16>  hdr_checksum;
    ipv4_addr_t  src_addr;
    ipv4_addr_t  dst_addr;
}
header udp_h 
{
    // An reserved Port address can be used to distinguish NetMod protocol from other network protocols ;
    // We used 55442 as a reserved port ...
    port_addr_t src_port;
    port_addr_t dest_port;
    bit<16> len;
    bit<16> checksum;
}

header icmp_h {
    icmp_type_t msg_type;
    bit<8>      msg_code;
    bit<16>     checksum;
}

header arp_h {
    bit<16>       hw_type;
    ether_type_t  proto_type;
    bit<8>        hw_addr_len;
    bit<8>        proto_addr_len;
    arp_opcode_t  opcode;
} 

header arp_ipv4_h {
    mac_addr_t   src_hw_addr;
    ipv4_addr_t  src_proto_addr;
    mac_addr_t   dst_hw_addr;
    ipv4_addr_t  dst_proto_addr;
}





header net_mod_hdr_t
{
    bit<8> bps;
    bit<16> mhl;
    bit<32> seq;
    bit<8> worker_id;
}
// QAM64 header
header net_mod_payload_hdr_qam64_t
{
    qam64_t b0;
    qam64_t b1;
    qam64_t b2;
    qam64_t b3;
    qam64_t b4;
    qam64_t b5;
    qam64_t b6;
    qam64_t b7;
    qam64_t b8;
    qam64_t b9;
    qam64_t b10;
    qam64_t b11;
    qam64_t b12;
    qam64_t b13;
    qam64_t b14;
    qam64_t b15;
}
// QAM headers -- 192 bit
struct net_mod_payload_str_qam64_t
{
    net_mod_payload_hdr_qam64_t payload0;
    net_mod_payload_hdr_qam64_t payload1;
    net_mod_payload_hdr_qam64_t payload2;
    net_mod_payload_hdr_qam64_t payload3;

}
// Input payload header
header net_mod_payload_hdr_t
{
    bs_t b0;
    bs_t b1;
    bs_t b2;
    bs_t b3;
    bs_t b4;
    bs_t b5;
    bs_t b6;
    bs_t b7;
    bs_t b8;
    bs_t b9;
    bs_t b10;
    bs_t b11;
    bs_t b12;
    bs_t b13;
    bs_t b14;
    bs_t b15;
}
// Output IQ symbols header..


header net_mod_iq_hdr16_t
{
    iq_t s0;
    iq_t s1;
    iq_t s2;
    iq_t s3;
    iq_t s4;
    iq_t s5;
    iq_t s6;
    iq_t s7;
    iq_t s8;
    iq_t s9;
    iq_t s10;
    iq_t s11;
    iq_t s12;
    iq_t s13;
    iq_t s14;
    iq_t s15;
}

// RECIRCULATION header
header net_mod_circ_hdr_t 
{
    // time to recirc
    ttc_t ttc;
    ttc_t bps;
    index_t index; // GP index
    bit<8> payload_hdr_index;
    bit<8> payload_b_index;
    bit<8> payload_b_shift_cntr;
    bit<8> payload_hdr_shift_cntr;
    // this will be incremented when we reach IQ_HDR_S_COUNT
    bit<8> iq_hdr_index;
    // this will be incrememted every circirulation iteration
    bit<8> iq_s_index;
    bs_t current_payload_b;
    bit<8> iq_hdr_end;
    PortId_t inport;
    bit<7> padding;
}

struct ns_headers 
{
    ethernet_h  ethernet;
    arp_h       arp;
    arp_ipv4_h  arp_ipv4;
    ipv4_h      ipv4;
    icmp_h      icmp;
    udp_h       udp;
    net_mod_hdr_t mod; // modulation header...
    net_mod_payload_hdr_t payload0;
    net_mod_payload_str_qam64_t qam64;
    // net_mod_payload_hdr_t payload1;
    // net_mod_payload_hdr_t payload2;
    // net_mod_payload_hdr_t payload3;
    // net_mod_payload_hdr_t payload4;
    // net_mod_payload_hdr_t payload5;
    // net_mod_payload_hdr_t payload6;
    // net_mod_payload_hdr_t payload7;
    //net_mod_circ_hdr_t circ;
    net_mod_iq_hdr16_t IQ0;
    net_mod_iq_hdr16_t IQ1;
    net_mod_iq_hdr16_t IQ2;
    net_mod_iq_hdr16_t IQ3;
    net_mod_iq_hdr16_t IQ4;
    net_mod_iq_hdr16_t IQ5;
    net_mod_iq_hdr16_t IQ6;
    net_mod_iq_hdr16_t IQ7;
    // net_mod_iq_hdr16_t IQ8;
    // net_mod_iq_hdr16_t IQ9;
    // net_mod_iq_hdr16_t IQ10;
    // net_mod_iq_hdr16_t IQ11;
    // net_mod_iq_hdr16_t IQ12;
    // net_mod_iq_hdr16_t IQ13;
    // net_mod_iq_hdr16_t IQ14;
    // net_mod_iq_hdr16_t IQ15;

    //net_mod_iq_hdr16_t tmp_iq;
}

struct meta_data 
{
    ipv4_addr_t   dst_ipv4;
    bit<1>        ipv4_csum_err;
    bit<8> rst;
    bit<32> index;
    qam64_t current_payload_b;
    bool done ;
    //bit_slice_t bit_slice_value;
    //iq_t iq_value;
    //bool is_qam;
}

#endif