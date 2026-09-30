import sys

from scapy.all import *
import enum;
#import numpy as np
import random;
                    # IntField("v1", 0),
                    # IntField("v2", 0),
                    # IntField("v3", 0),
                    # IntField("v4", 0),
                    # IntField("v5", 0),
                    # IntField("v6", 0),
                    # IntField("v7", 0),
                    # IntField("v8", 0),
                    # IntField("v9", 0),
                    # IntField("v10", 0)
"""header nr_h
{
    bit<8> op_type;
    nr_packetType_t packet_type;
    bit<32> sequence;
    index_t reg_index;
}
 bit<8> mod_type;
    //
    bit<16> mod_level;
    // bps // bits per symbol
    bit<8> bps ; // log2(mod_level)
"""

class modulation(Packet):
    name = "modulation"
    fields_desc = [ XByteField("mhl", 0x00), XBitField(name="bps", default=0x04,size=8), XBitField(name="M", default=0x0000,size=16), 
                   XBitField(name="seq", default=0x01,size=32), XBitField(name="worker_id", default=0x7F,size=8)]
    def SetModeType(self, t):
        self.setfieldval("mhl", t)
        return self
    def SetBitsPerSymbols(self, bps):
        self.setfieldval("M", 2**bps)
        self.setfieldval("bps", bps)
        return self
    def SetMod_Level(self, M):
        self.setfieldval("M", M)
        return self
    def setSeq(self, seq):
        self.setfieldval("seq", seq)
        return self
    

class ModBitStream(Packet):
    name="bit_streams_for_modulation"
    fields_desc = [ XBitField(name=f"b{i}", default=0,size=16) for i in range(0,8)]
    def SetBitStream(self, _bytes):
        for i, b in zip(range(0,8), _bytes):
            self.setfieldval(f"b{i}", b)
        return self


class ModBitStreamQAM64(Packet):
    name="bit_streams_for_modulation_qam64"
    fields_desc = [ XBitField(name=f"b{i}", default=0,size=8) for i in range(0,24)]
    def SetBitStream(self, _bytes):
        for i, b in zip(range(0,24), _bytes):
            self.setfieldval(f"b{i}", b)
        return self
    

class nr_PacketType(enum.Enum):
    PUSH = 0x10,
    READ0 = 0x40,
    READ1 = 0x41,
    AGGR = 0x60, 
    DISCARD = 0xFF

# Test for reciculation
class multi(Packet):
    name = "multi"
    fields_desc = [IntField("first", 0), IntField("second", 0), IntField("res", 0)]

    def setValues(self, f, s):
        self.setfieldval("first", max(f,s))
        self.setfieldval("second", min(f, s))
        return self

# very important for circulation... (( after UDP))
class ns_proto_h(Packet):
    name = "ns_proto_h"
    fields_desc = [XByteField("proto_type", 0x00)]
    def SetProtoType(self, b):
        self.setfieldval("proto_type", b)
        return self


class nr_h(Packet):
    name = "net_reduce_header"
    fields_desc = [XByteField("op_type", 0x00),
                   XByteField("packet_type", 0x10),
                   IntField("sequence",0),
                   IntField("reg_index", 0)]
    
    def SetSequence(self, seq: int):
        self.setfieldval("sequence", seq)
        return self
    
    def SetPacketType(self, t):
        self.setfieldval("packet_type", t)
        return self
    def SetIndex(self, index):
        self.setfieldval("reg_index", index)
    
    

    def SetPacketType2(self, tx : nr_PacketType):
        if tx == nr_PacketType.PUSH:
            self.SetPacketType(0x10)
        elif tx == nr_PacketType.READ0:
            self.SetPacketType(0x40)
        elif tx == nr_PacketType.READ1:
            self.SetPacketType(0x41)
        elif tx == nr_PacketType.AGGR:
            self.SetPacketType(0x60)
        else:
            self.SetPacketType(0xff)
        return self



# data header field ( 32 int )
class nr_data_h(Packet):
    name = "net_reduce_data"
    fields_desc = [IntField(f"v{i}", 0) for i in range(0,32)]

    #Set the data field from the list 
    def SetValues(self,data : list):
        for i, val in zip(range(0,32), data):

            self.setfieldval(f"v{i}", val)
        return self
    

class nr_result(Packet):
    name = "netResult"
    fields_desc = [ XByteField("rst", 0x00),
                    IntField("sum", 0),
                    IntField("max", 0),
                    ]
    

    def getSum(self):
        return self.get_field("sum")
    

    def setSum(self, fld, val):
        return self.setfieldval(fld, val)
    

    def Reset(self):
        self.setfieldval("rst", 0x01)
        return self
    

def CreateDataPacket(s,e):
    values0 = [1 for i in range(0, 32)]
    values1 = [3 for i in range(0, 32)]
    print(f" values0 sum : {sum(values0)} \n values1 sum : {sum(values1)}")
    data0 = nr_data_h()
    data1 = nr_data_h()
    data0.SetValues(values0)
    data1.SetValues(values1)

    return data0/data1 



def CreatePushPacket(seq):
    nr = nr_h()
    nr.SetIndex(seq)
    nr.SetPacketType2(nr_PacketType.PUSH)
    result = nr_result()
    return nr/CreateDataPacket(0,20)/result

def CreateAggrPacket(seq):
    nr = nr_h()
    nr.SetIndex(seq)
    nr.SetPacketType2(nr_PacketType.AGGR)

    return nr/CreateDataPacket(0,10)/nr_result()

def CreateRead0Packet(seq):
    nr = nr_h()
    nr.SetIndex(seq)
    nr.SetPacketType2(nr_PacketType.READ0)
    return nr/CreateDataPacket(0,10)/nr_result()

def CreateRead1Packet(seq):
    nr = nr_h()
    nr.SetIndex(seq)
    nr.SetPacketType2(nr_PacketType.READ1)
    return nr/CreateDataPacket(0,10)/nr_result()


def main():
    iface = "veth0"
    ip_dst = "192.168.1.3"
    udp_src_port = 2016
    udp_dst_port = 2017

    ether = Ether(dst="00:11:22:33:44:55", src="00:aa:bb:cc:dd:ee")
    ipv4 = IP(src="192.168.1.2", dst=ip_dst)
    udp = UDP(sport = udp_src_port, dport = udp_dst_port)


    # values0 = [i for i in range(0, 32)]
    # values1 = [i for i in range(0, 32)]

   

    seq = 0

    nr_packet = CreatePushPacket(seq)
    nr_packet.show()

    packet_push = (ether/ipv4/udp/nr_packet)

    

    packet_aggr = (ether/ipv4/udp/CreateAggrPacket(0))

    packet_read0 = (ether/ipv4/udp/CreateRead0Packet(0))

    packet_read1 = (ether/ipv4/udp/CreateRead1Packet(0))

    sendp(packet_push, iface = iface)

    sendp(packet_aggr, iface = iface)

    sendp(packet_read0, iface=iface)

    sendp(packet_read1, iface=iface)


def test_reciculation():
    iface = "veth0"
    ip_dst = "192.168.1.3"
    udp_src_port = 2016
    udp_dst_port = 2017

    ether = Ether(dst="00:11:22:33:44:55", src="00:aa:bb:cc:dd:ee")
    ipv4 = IP(src="192.168.1.2", dst=ip_dst)
    udp = UDP(sport = udp_src_port, dport = udp_dst_port)

    proto = ns_proto_h().SetProtoType(0x00)
    first = 20
    sec = 30

    mul = multi().setValues(first,sec)

    print(f" Mul : {first * sec}")

    p = (ether/ipv4/udp/proto/mul)
    sendp(p, iface=iface)

def mod_main():
    iface = "veth0"
    ip_dst = "192.168.1.3"
    # this is the reserved source port for NetMod
    udp_src_port = 55443
    udp_dst_port = 2017

    bits_per_symbol = 4
    try:
        bits_per_symbol = int(sys.argv[1])
        if( bits_per_symbol > 10):
            print("Bits_per symbol is not supported Only from 1..10 can be used.")
            bits_per_symbol = 4
        
    except:
        bits_per_symbol = 4
    

    ether = Ether(dst="00:11:22:33:44:55", src="00:aa:bb:cc:dd:ee")
    ipv4 = IP(src="192.168.1.2", dst=ip_dst)
    udp = UDP(sport = udp_src_port, dport = udp_dst_port)

    if( bits_per_symbol == 6):
        bits = [0x12,0x34, 0x56,0x78, 0xBA,0xDC,0xFE,0x10, 0x99,0x88, 0x77,0x66, 0xaa,0xbb, 0xcc,0xdd, 0x10,0x20, 0x30,0x40, 0x10,0x11, 0x12,0x13]
        qam64 = modulation().SetBitsPerSymbols(bits_per_symbol).SetModeType(0x00).setSeq(0)
        print(bits)
        bit_stream = ModBitStreamQAM64().SetBitStream(bits)
        p = ( ether/ipv4/udp/qam64/bit_stream)
        p.show()
        sendp(p, iface=iface) 

    else:
        B = 8 # banks
        bits = [0x1234, 0x5678, 0xBADC,0xFE10, 0x9988, 0x7766, 0xaabb, 0xccdd, 0x1020, 0x3040, 0x1011,0x1213, 0x1122,0x3344, 0x5566,0x7788 ]
        N = len(bits)
        packets_count = int(N/B)
        for i in range(0,packets_count):
            qpsk = modulation().SetBitsPerSymbols(bits_per_symbol).SetModeType(0x00).setSeq(i)
            _bytes = bits[B*i : B*(i+1)]
            print(f" packet: {i}")
            print(_bytes)
            bit_stream = ModBitStream().SetBitStream(_bytes)
            p = ( ether/ipv4/udp/qpsk/bit_stream)
            p.show()
            sendp(p, iface=iface)




if __name__ =="__main__":
    #main()
    #test_reciculation()
    mod_main();


# try:
#     #ip_dst = sys.argv[1]
#     ip_dst = "192.168.1.3"
#     key = sys.argv[1]
# except:
#     ip_dst = "192.168.1.3"
#     key = 10

# d = [] 
# max_size = 1000
# packet_size = 10
# sum =0 
# max_ele = 0
# for i in range(max_size):
#     ele = random.randint(0, 10)
#     d.append(ele)
#     sum = sum + ele
#     max_ele = max_ele if max_ele>= ele else ele

# rng = int(max_size/packet_size)

# print(f"Sum : {sum}, \t max_ = {max_ele}")

# iface = "veth1"
# print("Sending IP packet to", ip_dst)
# for i in range(rng):
#     j = packet_size*i
#     rst = 0x01 if i == 0 else 0x00
#     p = (Ether(dst="00:11:22:33:44:55", src="00:aa:bb:cc:dd:ee")/
#         IP(src="192.168.1.2", dst=ip_dst)/UDP(sport = 2017, dport = 2027)/
#         NetReduce(r_type=0x00, v1=d[j],v2=d[j+1], v3=d[j+2], v4=d[j+3],v5=d[j+4],v6=d[j+5],v7=d[j+6],
#                   v8=d[j+7],v9=d[j+8],v10=d[j+9])/netResult(rst=rst, sum = 0, max = 0))
    
#     sendp(p, iface=iface)
#     #sendp(p, iface="veth4")
#     #srp1(p,iface=iface)
#     print(f" packet {i}, j={j}") 


