P4 = bfrt.NetMod.pipe;
# pipe2 = bfrt.NanoMod.pipe2;
bfrt_info = bfrt.info;

# M2 = P4.Ingress.BPSK.SMAP1
# M4 = P4.Ingress.QPSK.SMAP2
# M16 = P4.Ingress.QAM16.SMAP4
# M64 = P4.Ingress.QAM64.SMAP6
QAM256 = P4.Ingress.QAM256;
QAM256MAPS = [ 
    QAM256.map0.map,
    QAM256.map1.map,
    QAM256.map2.map,
    QAM256.map3.map,
    QAM256.map4.map,
    QAM256.map5.map,
    QAM256.map6.map,
    QAM256.map7.map,
    QAM256.map8.map,
    QAM256.map9.map,
    QAM256.map10.map,
    QAM256.map11.map,
    QAM256.map12.map, 
    QAM256.map13.map, 
    QAM256.map14.map, 
    QAM256.map15.map 
]

nexthop = P4.Ingress.nexthop.ipv4_host


def addSymbol(reg, index, value):
    reg.add(REGISTER_INDEX=index, f1=value)


def Fill_QAM256_MAPS():
    for map in QAM256MAPS:
        for i in range(0, 256):
            addSymbol(map, i, i)


def add_with_send(ip, port):
    nexthop.add_with_send(dst_addr = ip, port = port)

def add_with_send_many( _list):
    for (port, ip) in _list:
        add_with_send(ip = ip, port = port)


def clear_table(table):
    table.clear();

def main():
    
    
    
    Fill_QAM256_MAPS()

    clear_table(nexthop)
    #add The IPV4 table entries..
    add_with_send(ip = "198.18.0.2", port = 64) # this will forward any incoming packet to the port 2 ( veth5, veth4)
    add_with_send(ip = "198.18.0.1", port = 64)
    add_with_send(ip = "192.168.1.3",port = 64)
    
    bfrt.complete_operations()

if __name__=="__main__":
    main()



