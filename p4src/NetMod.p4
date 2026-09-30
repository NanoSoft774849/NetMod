#include<core.p4>
#include<tna.p4>


// #include"../include/defs.p4"
//#include"../include/headers.p4"
 #include"../include/parser.p4"
 #include"../include/egress.p4"

 #include"../include/ingress.p4"

// #include"../include/deparsers.p4"



Pipeline(
    IngressParser(),
    Ingress(),
    IngressDeparser(),
    EgressParser(),
    Egress(),
    EgressDeparser()
) pipe;


Switch(pipe) main;
