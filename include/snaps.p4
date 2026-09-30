#ifndef __snaps__p4

#define __snaps__p4

#define CreateRegisterMap(m) \ 
Register<iq_t, _ >( (1 << m) ) SMAP##m;\
RegisterAction<iq_t, _, iq_t>(SMAP##m) act##m ={\
 void apply( inout iq_t value, out iq_t rv)\
 {\
    rv = value;\
 }\
 \
 };\
//
// hdr.circ.current_payload_b =  hdr.circ.current_payload_b >> m;
#define NET_MOD_IQ(m, b, i) \
action net##m##i##b() \
{\
        hdr.IQ##b.setValid();\
        hdr.IQ##b.s##i = act##m.execute((bit<32>)hdr.circ.current_payload_b[m-1:0]);\
        hdr.circ.current_payload_b =  hdr.circ.current_payload_b >> m;\
}\
//


#define NET_MOD_IQ_BPSK(b, s)      NET_MOD_IQ(1, b, s)
#define NET_MOD_IQ_QPSK(b, s)      NET_MOD_IQ(2, b, s)
#define NET_MOD_IQ_QAM16(b,s)      NET_MOD_IQ(4, b, s)
#define NET_MOD_IQ_QAM64(b,s)      NET_MOD_IQ(6, b, s)
#define NET_MOD_IQ_QAM256(b,s)     NET_MOD_IQ(8, b, s)

#define NET_MOD_IQ_BANK_DEFINE_ACTIONS(b, x) \
        NET_MOD_IQ_##x(b, 0) \
        NET_MOD_IQ_##x(b, 1) \
        NET_MOD_IQ_##x(b, 2) \
        NET_MOD_IQ_##x(b, 3) \
        NET_MOD_IQ_##x(b, 4) \
        NET_MOD_IQ_##x(b, 5) \
        NET_MOD_IQ_##x(b, 6) \
        NET_MOD_IQ_##x(b, 7) \
//


// A single Action item
#define NET_MOD_IQ_ACTION_BPSK(b, s)       net1##s##b
#define NET_MOD_IQ_ACTION_QPSK(b, s)       net2##s##b
#define NET_MOD_IQ_ACTION_QAM16(b, s)      net4##s##b
#define NET_MOD_IQ_ACTION_QAM64(b, s)      net6##s##b
#define NET_MOD_IQ_ACTION_QAM256(b, s)     net8##s##b
// A single Entry Item
#define NET_MOD_IQ_ENTRY_BPSK(b,s)     (b,s):net1##s##b()
#define NET_MOD_IQ_ENTRY_QPSK(b,s)     (b,s):net2##s##b()
#define NET_MOD_IQ_ENTRY_QAM16(b,s)    (b,s):net4##s##b()
#define NET_MOD_IQ_ENTRY_QAM64(b,s)    (b,s):net6##s##b()
#define NET_MOD_IQ_ENTRY_QAM256(b,s)   (b,s):net8##s##b()


// Generic ACTIONS LIST
#define NET_MOD_IQ_ACTIONS_LIST(b, x)\
        NET_MOD_IQ_ACTION_##x(b, 0);\
        NET_MOD_IQ_ACTION_##x(b, 1);\
        NET_MOD_IQ_ACTION_##x(b, 2);\
        NET_MOD_IQ_ACTION_##x(b, 3);\
        NET_MOD_IQ_ACTION_##x(b, 4);\
        NET_MOD_IQ_ACTION_##x(b, 5);\
        NET_MOD_IQ_ACTION_##x(b, 6);\
        NET_MOD_IQ_ACTION_##x(b, 7);\


// Generic ENTRIES list
#define NET_MOD_IQ_ENTRY_LIST(b, x)\
        NET_MOD_IQ_ENTRY_##x(b, 0); \
        NET_MOD_IQ_ENTRY_##x(b, 1); \
        NET_MOD_IQ_ENTRY_##x(b, 2); \
        NET_MOD_IQ_ENTRY_##x(b, 3); \
        NET_MOD_IQ_ENTRY_##x(b, 4); \
        NET_MOD_IQ_ENTRY_##x(b, 5); \
        NET_MOD_IQ_ENTRY_##x(b, 6); \
        NET_MOD_IQ_ENTRY_##x(b, 7); \
//
//
// payload b slect pbs
// b : is the payload hdr select 
// i : is the b_i selector 
#define NET_MOD_PB_SELECT(x, i) \
action pbs##i##x() \
{\
    hdr.circ.current_payload_b = hdr.payload##x.b##i;\
}\
//
#define NET_MOD_PB_CREATE_ACTION(b)\
        NET_MOD_PB_SELECT(b, 0) \
        NET_MOD_PB_SELECT(b, 1) \
        NET_MOD_PB_SELECT(b, 2) \
        NET_MOD_PB_SELECT(b, 3) \
        NET_MOD_PB_SELECT(b, 4) \
        NET_MOD_PB_SELECT(b, 5) \
        NET_MOD_PB_SELECT(b, 6) \
        NET_MOD_PB_SELECT(b, 7) \
//
#define NET_MOD_PB_ACTION(b,i) pbs##i##b
#define NET_MOD_PB_ENTRY(b,i)  (b, i):pbs##i##b
//
#define NET_MOD_PB_ACTIONS_LIST(b)\
        NET_MOD_PB_ACTION(b, 0);\
        NET_MOD_PB_ACTION(b, 1);\
        NET_MOD_PB_ACTION(b, 2);\
        NET_MOD_PB_ACTION(b, 3);\
        NET_MOD_PB_ACTION(b, 4);\
        NET_MOD_PB_ACTION(b, 5);\
        NET_MOD_PB_ACTION(b, 6);\
        NET_MOD_PB_ACTION(b, 7);\
//

#define NET_MOD_PB_ENTRY_LIST(b)\
        NET_MOD_PB_ENTRY(b, 0);\
        NET_MOD_PB_ENTRY(b, 1);\
        NET_MOD_PB_ENTRY(b, 2);\
        NET_MOD_PB_ENTRY(b, 3);\
        NET_MOD_PB_ENTRY(b, 4);\
        NET_MOD_PB_ENTRY(b, 5);\
        NET_MOD_PB_ENTRY(b, 6);\
        NET_MOD_PB_ENTRY(b, 7);\
//
// IQ Selector , this will push the value to the hdr.IQx = hdr.tmp_iq;

#define NET_MOD_PB_QAM64_SELECT(x, i) \
action qam64##i##x() \
{\
  meta.current_payload_b =  hdr.qam64.payload##x.b##i;\
}\
//
#define NET_MOD_PB_QAM64_CREATE_ACTION(b)\
        NET_MOD_PB_QAM64_SELECT(b, 0) \
        NET_MOD_PB_QAM64_SELECT(b, 1) \
        NET_MOD_PB_QAM64_SELECT(b, 2) \
        NET_MOD_PB_QAM64_SELECT(b, 3) \
        NET_MOD_PB_QAM64_SELECT(b, 4) \
        NET_MOD_PB_QAM64_SELECT(b, 5) \
        NET_MOD_PB_QAM64_SELECT(b, 6) \
        NET_MOD_PB_QAM64_SELECT(b, 7) \
//
#define NET_MOD_PB_QAM64_ACTION(b,i) qam64##i##b
#define NET_MOD_PB_QAM64_ENTRY(b,i)  (b,i):qam64##i##b
//
#define NET_MOD_PB_QAM64_ACTIONS_LIST(b)\
        NET_MOD_PB_QAM64_ACTION(b, 0);\
        NET_MOD_PB_QAM64_ACTION(b, 1);\
        NET_MOD_PB_QAM64_ACTION(b, 2);\
        NET_MOD_PB_QAM64_ACTION(b, 3);\
        NET_MOD_PB_QAM64_ACTION(b, 4);\
        NET_MOD_PB_QAM64_ACTION(b, 5);\
        NET_MOD_PB_QAM64_ACTION(b, 6);\
        NET_MOD_PB_QAM64_ACTION(b, 7);\
//

#define NET_MOD_PB_QAM64_ENTRY_LIST(b)\
        NET_MOD_PB_QAM64_ENTRY(b, 0);\
        NET_MOD_PB_QAM64_ENTRY(b, 1);\
        NET_MOD_PB_QAM64_ENTRY(b, 2);\
        NET_MOD_PB_QAM64_ENTRY(b, 3);\
        NET_MOD_PB_QAM64_ENTRY(b, 4);\
        NET_MOD_PB_QAM64_ENTRY(b, 5);\
        NET_MOD_PB_QAM64_ENTRY(b, 6);\
        NET_MOD_PB_QAM64_ENTRY(b, 7);\
//
// ADVANCE SNAPS ...

#define CREATE_REGISTER_CONTROL(m)\
control smap##m(in bit<m> b , out iq_t s )\
{\
    Register<iq_t, _>(1 << m) map;\
    RegisterAction<iq_t, _, iq_t>(map) map_action = \
    {\
        void apply(inout iq_t value, out iq_t rv)\
        {\
            rv = value;\
        }\
    };\
    action mapx()\
    {\
        s = map_action.execute((bit<32>) b);\
    }\
    apply{\
        mapx();\
    }\
}\
//
// #define CREATE_SINGLE_BPSK_MAP(i, m , k)\
// control bpsk##i(inout ns_headers hdr, inout meta_data meta)\
// {\
//         smap1() map0;\
//         smap1() map1;\
//         smap1() map2;\
//         smap1() map3;\
//         smap1() map4;\
//         smap1() map5;\
//         smap1() map6;\
//         smap1() map7;\
//         smap1() map8;\
//         smap1() map9;\
//         smap1() map10;\
//         smap1() map11;\
//         smap1() map12;\
//         smap1() map13;\
//         smap1() map14;\
//         smap1() map15;\
//         apply{\
//                 hdr.IQ##m.setValid();\
//                 map0.apply(hdr.circ.current_payload_b[0:0], hdr.IQ##m.s0);\
//                 map1.apply(hdr.circ.current_payload_b[1:1], hdr.IQ##m.s1);\
//                 map2.apply(hdr.circ.current_payload_b[2:2], hdr.IQ##m.s2);\
//                 map3.apply(hdr.circ.current_payload_b[3:3], hdr.IQ##m.s3);\
//                 map4.apply(hdr.circ.current_payload_b[4:4], hdr.IQ##m.s4);\
//                 map5.apply(hdr.circ.current_payload_b[5:5], hdr.IQ##m.s5);\
//                 map6.apply(hdr.circ.current_payload_b[6:6], hdr.IQ##m.s6);\
//                 map7.apply(hdr.circ.current_payload_b[7:7], hdr.IQ##m.s7);\
//                 hdr.IQ##k.setValid();\
//                 map8.apply(hdr.circ.current_payload_b[8:8],    hdr.IQ##k.s0);\
//                 map9.apply(hdr.circ.current_payload_b[9:9],    hdr.IQ##k.s1);\
//                 map10.apply(hdr.circ.current_payload_b[10:10], hdr.IQ##k.s2);\
//                 map11.apply(hdr.circ.current_payload_b[11:11], hdr.IQ##k.s3);\
//                 map12.apply(hdr.circ.current_payload_b[12:12], hdr.IQ##k.s4);\
//                 map13.apply(hdr.circ.current_payload_b[13:13], hdr.IQ##k.s5);\
//                 map14.apply(hdr.circ.current_payload_b[14:14], hdr.IQ##k.s6);\
//                 map15.apply(hdr.circ.current_payload_b[15:15], hdr.IQ##k.s7);\
//         }\
// }\

//

#endif