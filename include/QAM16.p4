#ifndef __QAM16__P4
#define __QAM16__P4

control qam16tb(in bs_t bank0 , inout iq_t iq0, inout iq_t iq1)
{
    action map(iq_t s0, iq_t s1)
    {
        iq0 = s0;
        iq1 = s1;
    }
    table qam16_table 
    {
        key = { bank0 : exact; }
        actions = 
        {
            map;
        }
        size = 256;
    }
    apply{
        qam16_table.apply();
    }
}

control QAM16Mapper(inout ns_headers hdr, inout meta_data meta)
{

   qam16tb() map0;
   qam16tb() map1;
   qam16tb() map2;
   qam16tb() map3;
   qam16tb() map4;
   qam16tb() map5;
   qam16tb() map6;
   qam16tb() map7;
   qam16tb() map8;
   qam16tb() map9;
   qam16tb() map10;
   qam16tb() map11;
   qam16tb() map12;
   qam16tb() map13;
   qam16tb() map14;
   qam16tb() map15;

    
    #define bx(m) hdr.payload0.b##m
    #define sx(q, m) hdr.IQ##q.s##m

    apply{
       hdr.IQ0.setValid();
       hdr.IQ1.setValid();

       map0.apply( bx(0), sx(0, 0),  sx(0, 1) );
       map1.apply( bx(1), sx(0, 2),  sx(0, 3) );
       map2.apply( bx(2), sx(0, 4),  sx(0, 5) );
       map3.apply( bx(3), sx(0, 6),  sx(0, 7) );
       map4.apply( bx(4), sx(0, 8),  sx(0, 9) );
       map5.apply( bx(5), sx(0, 10), sx(0, 11) );
       map6.apply( bx(6), sx(0, 12), sx(0, 13) );
       map7.apply( bx(7), sx(0, 14), sx(0, 15) );
       
       map8.apply(  bx(8),   sx(1, 0),   sx(1, 1) );
       map9.apply(  bx(9),   sx(1, 2),   sx(1, 3) );
       map10.apply( bx(10),  sx(1, 4),   sx(1, 5) );
       map11.apply( bx(11),  sx(1, 6),   sx(1, 7) );
       map12.apply( bx(12),  sx(1, 8),   sx(1, 9) );
       map13.apply( bx(13),  sx(1, 10),  sx(1, 11) );
       map14.apply( bx(14),  sx(1, 12),  sx(1, 13) );
       map15.apply( bx(15),  sx(1, 14),  sx(1, 15) );
       hdr.mod.mhl = hdr.mod.mhl + 64;
       hdr.udp.len = hdr.udp.len + 64;
       hdr.ipv4.total_len = hdr.ipv4.total_len + 64;
    }

}

#endif



