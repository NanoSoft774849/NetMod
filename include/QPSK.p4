#ifndef __QPSK__P4
#define __QPSK__P4

//#include"snaps.p4"

control qpsktb(in bs_t bank0 , inout iq_t iq0, inout iq_t iq1 , inout iq_t iq2 , inout iq_t iq3)
{
    action map(iq_t s0, iq_t s1 , iq_t s2, iq_t s3)
    {
        iq0 = s0;
        iq1 = s1;
        iq2 = s2;
        iq3 = s3;
    }
    table qpsk_table 
    {
        key = { bank0 : exact; }
        actions = 
        {
            map;
        }
        size = 256;
    }
    apply{
        qpsk_table.apply();
    }
}

control QPSKMapper(inout ns_headers hdr, inout meta_data meta)
{

   qpsktb() map0;
   qpsktb() map1;
   qpsktb() map2;
   qpsktb() map3;
   qpsktb() map4;
   qpsktb() map5;
   qpsktb() map6;
   qpsktb() map7;
   qpsktb() map8;
   qpsktb() map9;
   qpsktb() map10;
   qpsktb() map11;
   qpsktb() map12;
   qpsktb() map13;
   qpsktb() map14;
   qpsktb() map15;

    
    #define bx(m) hdr.payload0.b##m
    #define sx(q, m) hdr.IQ##q.s##m

    apply{
       hdr.IQ0.setValid();
       hdr.IQ1.setValid();
       hdr.IQ2.setValid();
       hdr.IQ3.setValid();
       // 32 * 4 = 64*2 = 128
        // 0
       map0.apply( bx(0), sx(0, 0),  sx(0, 1), sx(0, 2), sx(0, 3) );
       map1.apply( bx(1), sx(0, 4),  sx(0, 5), sx(0, 6), sx(0, 7) );
       map2.apply( bx(2), sx(0, 8),  sx(0, 9), sx(0, 10), sx(0, 11) );
       map3.apply( bx(3), sx(0, 12),  sx(0, 13), sx(0, 14), sx(0, 15) );
        // 1
       map4.apply( bx(0), sx(1, 0),   sx(1, 1),  sx(1, 2),  sx(1, 3) );
       map5.apply( bx(1), sx(1, 4),   sx(1, 5),  sx(1, 6),  sx(1, 7) );
       map6.apply( bx(2), sx(1, 8),   sx(1, 9),  sx(1, 10), sx(1, 11) );
       map7.apply( bx(3), sx(1, 12),  sx(1, 13), sx(1, 14), sx(1, 15) );
       // 2
       map8.apply(  bx(0), sx(2, 0),   sx(2, 1), sx(2, 2),  sx(2, 3) );
       map9.apply(  bx(1), sx(2, 4),   sx(2, 5), sx(2, 6),  sx(2, 7) );
       map10.apply( bx(2), sx(2, 8),   sx(2, 9), sx(2, 10), sx(2, 11) );
       map11.apply( bx(3), sx(2, 12),  sx(2, 13),sx(2, 14), sx(2, 15) );

        // 3
       map12.apply( bx(0), sx(3, 0),  sx(3, 1), sx(3, 2),  sx(3, 3) );
       map13.apply( bx(1), sx(3, 4),  sx(3, 5), sx(3, 6),  sx(3, 7) );
       map14.apply( bx(2), sx(3, 8),  sx(3, 9), sx(3, 10), sx(3, 11) );
       map15.apply( bx(3), sx(3, 12), sx(3, 13),sx(3, 14), sx(3, 15) );
       hdr.mod.mhl = hdr.mod.mhl + 128;
       hdr.udp.len = hdr.udp.len + 128;
       hdr.ipv4.total_len = hdr.ipv4.total_len + 128;
    }

}

#endif



