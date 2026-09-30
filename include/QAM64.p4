#ifndef __QAM64__P4
#define __QAM64__P4



control qam64tb(in qam64_t bank0, inout iq_t iq)
{
    action map(iq_t s)
    {
        iq = s;
    }

    table qam64_table 
    {
        key = { bank0 : exact;}
        actions =
        {
            map;
        }
        size = 256;
    }
    apply{
        qam64_table.apply();
    }
}

control QAM64Mapper(inout ns_headers hdr, inout meta_data meta)
{
   qam64tb() map0;
   qam64tb() map1;
   qam64tb() map2;
   qam64tb() map3;
   qam64tb() map4;
   qam64tb() map5;
   qam64tb() map6;
   qam64tb() map7;
   qam64tb() map8;
   qam64tb() map9;
   qam64tb() map10;
   qam64tb() map11;
   qam64tb() map12;
   qam64tb() map13;
   qam64tb() map14;
   qam64tb() map15;

    #define bx(m) hdr.qam64.payload0.b##m
    #define sx(q, m) hdr.IQ##q.s##m

    apply{
        hdr.IQ0.setValid();
       map0.apply( bx(0),   sx(0, 0) );
       map1.apply( bx(1),   sx(0, 1) );
       map2.apply( bx(2),   sx(0, 2) );
       map3.apply( bx(3),   sx(0, 3) );
       map4.apply( bx(4),   sx(0, 4) );
       map5.apply( bx(5),   sx(0, 5) );
       map6.apply( bx(6),   sx(0, 6) );
       map7.apply( bx(7),   sx(0, 7) );
       map8.apply( bx(8),   sx(0, 8) );
       map9.apply( bx(9),   sx(0, 9) );
       map10.apply( bx(10), sx(0, 10) );
       map11.apply( bx(11), sx(0, 11) );
       map12.apply( bx(12), sx(0, 12) );
       map13.apply( bx(13), sx(0, 13) );
       map14.apply( bx(14), sx(0, 14) );
       map15.apply( bx(15), sx(0, 15) );
       hdr.mod.mhl = hdr.mod.mhl + 32;
       hdr.udp.len = hdr.udp.len + 32;
       hdr.ipv4.total_len = hdr.ipv4.total_len + 32;
    }

}

#endif



