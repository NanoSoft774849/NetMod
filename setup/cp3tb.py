
P4 = bfrt.NetMod.pipe
Ingress = P4.Ingress
BPSK = Ingress.BPSK
QAM256 = Ingress.QAM256
QAM64 = Ingress.QAM64
QAM16 = Ingress.QAM16
QPSK = Ingress.QPSK

BPSK_MAPS = [
    BPSK.map0,
    BPSK.map1,
    BPSK.map2,
    BPSK.map3,
    BPSK.map4,
    BPSK.map5,
    BPSK.map6,
    BPSK.map7
]
QAM256_MAPS =[
    QAM256.map0,
    QAM256.map1,
    QAM256.map2,
    QAM256.map3,
    QAM256.map4,
    QAM256.map5,
    QAM256.map6,
    QAM256.map7,
    QAM256.map8,
    QAM256.map9,
    QAM256.map10,
    QAM256.map11,
    QAM256.map12,
    QAM256.map13,
    QAM256.map14,
    QAM256.map15
]
QAM64_MAPS =[
    QAM64.map0,
    QAM64.map1,
    QAM64.map2,
    QAM64.map3,
    QAM64.map4,
    QAM64.map5,
    QAM64.map6,
    QAM64.map7,
    QAM64.map8,
    QAM64.map9,
    QAM64.map10,
    QAM64.map11,
    QAM64.map12,
    QAM64.map13,
    QAM64.map14,
    QAM64.map15
]

QAM16_MAPS =[
    QAM16.map0,
    QAM16.map1,
    QAM16.map2,
    QAM16.map3,
    QAM16.map4,
    QAM16.map5,
    QAM16.map6,
    QAM16.map7,
    QAM16.map8,
    QAM16.map9,
    QAM16.map10,
    QAM16.map11,
    QAM16.map12,
    QAM16.map13,
    QAM16.map14,
    QAM16.map15
]
QPSK_MAPS =[
    QPSK.map0,
    QPSK.map1,
    QPSK.map2,
    QPSK.map3,
    QPSK.map4,
    QPSK.map5,
    QPSK.map6,
    QPSK.map7,
    QPSK.map8,
    QPSK.map9,
    QPSK.map10,
    QPSK.map11,
    QPSK.map12,
    QPSK.map13,
    QPSK.map14,
    QPSK.map15
]

nexthop = Ingress.nexthop.ipv4_host

BPSK_SMAP  = [ 1, 2]
QAM256_SMAP = [ i for i in range(0, 256)]
QAM16_SMAP = [ i for i in range(0, 16)]
QPSK_SMAP = [ i for i in range(0, 4)]
QAM64_SMAP = [i for i in range(0, 64)]

def clear_table(table):
    table.clear();

def QAM256_add_map(map, b):
    map.add_with_map(bank0 = b, s = QAM256_SMAP[b] & 0xFFFF)


def QAM64_add_map(map, b):
    map.add_with_map(bank0 = b & 0x3F, s = QAM64_SMAP[b & 0x3F] & 0xFFFF)

def BPSK_add_map0(map, b):
    map.add_with_map0(bank0=b,
                 s0=BPSK_SMAP[b >> 0 & 0x1]& 0xFFFF,
                 s1=BPSK_SMAP[b >> 1 & 0x1]& 0xFFFF,
                 s2=BPSK_SMAP[b >> 2 & 0x1]& 0xFFFF,
                 s3=BPSK_SMAP[b >> 3 & 0x1]& 0xFFFF,
                 s4=BPSK_SMAP[b >> 4 & 0x1]& 0xFFFF,
                 s5=BPSK_SMAP[b >> 5 & 0x1]& 0xFFFF,
                 s6=BPSK_SMAP[b >> 6 & 0x1]& 0xFFFF,
                 s7=BPSK_SMAP[b >> 7 & 0x1]& 0xFFFF)


def BPSK_add_map1(map, b):
    map.add_with_map1(bank1=b,
                 s0=BPSK_SMAP[b >> 0 & 0x1]& 0xFFFF,
                 s1=BPSK_SMAP[b >> 1 & 0x1]& 0xFFFF,
                 s2=BPSK_SMAP[b >> 2 & 0x1]& 0xFFFF,
                 s3=BPSK_SMAP[b >> 3 & 0x1]& 0xFFFF,
                 s4=BPSK_SMAP[b >> 4 & 0x1]& 0xFFFF,
                 s5=BPSK_SMAP[b >> 5 & 0x1]& 0xFFFF,
                 s6=BPSK_SMAP[b >> 6 & 0x1]& 0xFFFF,
                 s7=BPSK_SMAP[b >> 7 & 0x1]& 0xFFFF)

def QPSK_add_map(map, b):
    map.add_with_map(bank0=b,
                 s0=QPSK_SMAP[b >> 0 & 0x3]& 0xFFFF,
                 s1=QPSK_SMAP[b >> 2 & 0x3]& 0xFFFF,
                 s2=QPSK_SMAP[b >> 4 & 0x3]& 0xFFFF,
                 s3=QPSK_SMAP[b >> 6 & 0x3]& 0xFFFF)
    
def QAM16_add_map(map, b):
    map.add_with_map(bank0=b,
                 s0=QAM16_SMAP[b >> 0 & 0xF]& 0xFFFF,
                 s1=QAM16_SMAP[b >> 4 & 0xF]& 0xFFFF)

def Configure_BPSK_tables():
    
    for map in BPSK_MAPS:
        clear_table(map.tbl0)
        clear_table(map.tbl1)
        for b in range(0, 256):
            BPSK_add_map0(map.tbl0, b)
            BPSK_add_map1(map.tbl1, b)

def Configure_QAM256_tables():
    for map in QAM256_MAPS:
        clear_table(map.qam256_table)
        for b in range(0, 256):
            QAM256_add_map(map.qam256_table, b)


def Configure_QAM64_tables():
    for map in QAM64_MAPS:
        clear_table(map.qam64_table)
        for b in range(0, 64):
            QAM64_add_map(map.qam64_table, b)



def Configure_QAM16_tables():
    for map in QAM16_MAPS:
        clear_table(map.qam16_table)
        for b in range(0, 256):
            QAM16_add_map(map.qam16_table, b)

def Configure_QPSK_tables():
    for map in QPSK_MAPS:
        clear_table(map.qpsk_table)
        for b in range(0, 256):
            QAM16_add_map(map.qpsk_table, b)


def add_with_send(ip, port):
    nexthop.add_with_send(dst_addr = ip, port = port)

def add_with_send_many( _list):
    for (port, ip) in _list:
        add_with_send(ip = ip, port = port)




def main():
    
    
    
    Configure_BPSK_tables()
    Configure_QPSK_tables()
    Configure_QAM16_tables()
    Configure_QAM64_tables()
    Configure_QAM256_tables()

    clear_table(nexthop)
    #add The IPV4 table entries..
    add_with_send(ip = "198.18.0.2", port = 64) # this will forward any incoming packet to the port 2 ( veth5, veth4)
    add_with_send(ip = "198.18.0.1", port = 64)
    add_with_send(ip = "192.168.1.3",port = 64)
    
    bfrt.complete_operations()

if __name__=="__main__":
    main()


