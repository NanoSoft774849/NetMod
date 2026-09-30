
#ifndef __Test_Ingress__p4
#define __Test_Ingress__p4

//#include"headers.p4"
#include"forwarder.p4"

// #include"BPSK.p4"
// #include"QPSK.p4"
// #include"QAM256.p4"
// #include"QAM16.p4"
// #include"QAM64.p4"
#include"arp_icmp.p4"

control c1(inout ns_headers hdr, inout meta_data meta, in bit<8> bank)
{
    action map(iq_t q)
    {

    }
    table  mytable {
        key = { bank : exact;}
        actions=
        {
            map;
        }
        size = 256;
    }
    apply{
        mytable.apply();
    }
}

control c2(inout ns_headers hdr, inout meta_data meta,   inout  c1  x)
{
    apply{
        x.apply(hdr, meta, hdr.payload0.b0);
    }
}

control Ingress(
    /* User */
    inout ns_headers                       hdr,
    inout meta_data                        meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_t               ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t   ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md)
    {

        
       Forwarder() nexthop;
    //    BPSKMapper() BPSK;
    //    QPSKMapper() QPSK;
    //    QAM256Mapper() QAM256;
    //    QAM16Mapper() QAM16;
    //    QAM64Mapper() QAM64;
        ARPandICMPResponder() arp_icmp;
        c1() mapx;
        c2() mymapper;
       apply{

        if( hdr.mod.isValid())
        {
            mymapper.apply(hdr, meta, mapx);
        }
        if(hdr.arp_ipv4.isValid() || hdr.icmp.isValid())
            arp_icmp.apply(hdr, meta, ig_intr_md, ig_prsr_md, ig_dprsr_md, ig_tm_md);
         else
         nexthop.apply(hdr, meta, ig_intr_md, ig_prsr_md, ig_dprsr_md, ig_tm_md);
       }
         
    }


control IngressDeparser(packet_out pkt,
    /* User */
    inout ns_headers                       hdr,
    in    meta_data                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md)
{
    Checksum() ipv4_checksum;
    apply {

        hdr.ipv4.hdr_checksum = ipv4_checksum.update({
                hdr.ipv4.version,
                hdr.ipv4.ihl,
                hdr.ipv4.diffserv,
                hdr.ipv4.total_len,
                hdr.ipv4.identification,
                hdr.ipv4.flags,
                hdr.ipv4.frag_offset,
                hdr.ipv4.ttl,
                hdr.ipv4.protocol,
                hdr.ipv4.src_addr,
                hdr.ipv4.dst_addr
                /* Adding hdr.ipv4_options.data results in an error */
            });
        pkt.emit(hdr);
    }
}

#endif