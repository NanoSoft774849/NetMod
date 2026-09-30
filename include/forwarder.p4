#ifndef __forwarder__p4
#define __forwarder__p4


//#include"defs.p4"
//#include"headers.p4"


/*** -------------- Ingress Control ---------------*/

control Forwarder(
    /* User */
    inout ns_headers                       hdr,
    inout meta_data                        meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_t               ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t   ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md)
    {

         
       

        action send_back()
        {
            ig_tm_md.bypass_egress = 1w0;
            ig_dprsr_md.drop_ctl[0:0]=0; // make sure becuasue this bit might be set before/.
            mac_addr_t tmp = hdr.ethernet.dst_addr;
            hdr.ethernet.dst_addr = hdr.ethernet.src_addr;
            hdr.ethernet.src_addr = tmp;
            // swap ipv4 

            ipv4_addr_t temp_v4 = hdr.ipv4.src_addr;
            hdr.ipv4.src_addr= hdr.ipv4.dst_addr;
            hdr.ipv4.dst_addr = temp_v4;

          
            port_addr_t tm = hdr.udp.dest_port;
            hdr.udp.dest_port = hdr.udp.src_port;
            hdr.udp.src_port = tm;

            ig_tm_md.ucast_egress_port = ig_intr_md.ingress_port;

            //hdr.multi.second = count;
            
        }

        action send( PortId_t port)
        {
            //send_back();
            // indirect counter to count the number of packets and bytes that has been sent.
            // on a given port/
            //sent_indr_counter.count();
            ig_tm_md.bypass_egress = 1w0;
            ig_dprsr_md.drop_ctl[0:0]=0; // make sure becuasue this bit might be set before/.
            ig_tm_md.ucast_egress_port = port;

             //count_packet();
        }
     
        action drop()
        {
           // sent_indr_counter.count();
            ig_dprsr_md.drop_ctl = 1;
        }


        table ipv4_host 
        {
            key ={
                hdr.ipv4.dst_addr : exact;
            }
            actions = {
                send;
                drop;
                send_back;
            }
            size = 1024;
            default_action = send_back();
            //counters = sent_indr_counter;
        }
       
        
       
    
        
        apply{
            ipv4_host.apply();
        }
         
}


#endif