#ifndef __BPSK__P4
#define __BPSK__P4

control bpsktb(in bit<8> bank0, in bit<8> bank1 , inout net_mod_iq_hdr16_t iq)
{

    action map0( iq_t s0, iq_t s1, iq_t s2 , iq_t s3, iq_t s4, iq_t s5, iq_t s6, iq_t s7)
    {
        iq.s0 = s0;
        iq.s1 = s1;
        iq.s2 = s2;
        iq.s3 = s3;
        iq.s4 = s4;
        iq.s5 = s5;
        iq.s6 = s6;
        iq.s7 = s7;
    }

    action map1( iq_t s0, iq_t s1, iq_t s2 , iq_t s3, iq_t s4, iq_t s5, iq_t s6, iq_t s7)
    {
        iq.s8  = s0;
        iq.s9  = s1;
        iq.s10 = s2;
        iq.s11 = s3;
        iq.s12 = s4;
        iq.s13 = s5;
        iq.s14 = s6;
        iq.s15 = s7;
    }

    table tbl0
    {
        key =
        {
            bank0 : exact;
        }
        actions=
        {
            map0;
        }
        size = 256;
        //default_action = NOAction();
    }
    table tbl1
    {
        key =
        {
            bank1 : exact;
        }
        actions=
        {
            map1;
        }
        size = 256;
        //default_action = NOAction();
    }

    apply{
        iq.setValid();
        tbl0.apply();
        tbl1.apply();
    }
    // 8 -bit --> if each has 8-bit for I and 8-bit for Q then the symbol should be 8-bits and 8*8 = 64-bit...
    // 4 = 4*8 -> 32...
}
control BPSKMapper(inout ns_headers hdr, inout meta_data meta)
{
      bpsktb() map0;
      bpsktb() map1;
      bpsktb() map2;
      bpsktb() map3;
      bpsktb() map4;
      bpsktb() map5;
      bpsktb() map6;
      bpsktb() map7;
      #define bxx(m) hdr.payload0.b##m
      #define sxx(m) hdr.IQ##m
      apply{
                map0.apply( bxx(0) ,   bxx(1),   sxx(0));
                map1.apply( bxx(2) ,   bxx(3),   sxx(1));
                map2.apply( bxx(4) ,   bxx(5),   sxx(2));
                map3.apply( bxx(6) ,   bxx(7),   sxx(3));
                map4.apply( bxx(8) ,   bxx(9),   sxx(4));
                map5.apply( bxx(10) ,  bxx(11),   sxx(5));
                map6.apply( bxx(12) ,  bxx(13),   sxx(6));
                map7.apply( bxx(14) ,  bxx(15),   sxx(7));
                hdr.mod.mhl = hdr.mod.mhl + 256;
                hdr.udp.len = hdr.udp.len + 256;
                hdr.ipv4.total_len = hdr.ipv4.total_len + 256;
      }
}
#endif