import sys

sys.path.append("$SDE/install/lib/python3.8/site-packages")
sys.path.append("$SDE/install/lib/python3.8/site-packages/tofino")
sys.path.append("$SDE/install/lib/python3.8/site-packages/p4testutils")

from tofino.bfrt_grpc import *
import bfrt_grpc.client as gc

NET_MOD_APP_NAME ="NetMod"

APP_NAME = None 

bfsh = gc.ClientInterface(grpc_addr="0.0.0.0:50052" , client_id= 0, device_id=0)

bfrt_info = bfsh.bfrt_info_get(p4_name= None)

bfsh.bind_pipeline_config(p4_name= bfrt_info.p4_name)

APP_NAME = bfrt_info.p4_name


print("The Available P4 Name : ", bfrt_info.p4_name)

class NetMod:
    def __init__(self):
        
        self.NETMOD_TABLES = { "BPSK1"     : [] ,
                               "BPSK2"     : [],
                                "QPSK"     : [] ,
                                "QAM16"    : [], 
                                "QAM64"    : [], 
                                "QAM256"   : []
                        }


    def get_table_maps( count , ingress : str, table_name : str):
        maps = []
        for i in range(0, count ):
            maps.append(bfrt_info.table_get(f"{ingress}.map{i}.{table_name}"))
        return maps
  
    def get_tables(self):
        for (mtype , map) in self.NETMOD_TABLES.items():
            if( mtype == "BPSK1"):
                for i in range(0, 8):
                    map.append(bfrt_info.table_get(f"Ingress.BPSK.map{i}.tbl0"))
                    #map.append(bfrt_info.get_table(f"Ingress.BPSK.map{i}.tbl1"))
            elif( mtype == "BPSK2"):
                for i in range(0, 8):
                    #map.append(bfrt_info.get_table(f"Ingress.BPSK.map{i}.tbl0"))
                    map.append(bfrt_info.table_get(f"Ingress.BPSK.map{i}.tbl1"))
            else:
                for i in range(0, 16):
                    map.append(bfrt_info.table_get(f"Ingress.{mtype}.map{i}.{mtype.lower()}_table"))

        return self.NETMOD_TABLES

# class NetModActions:
#     @staticmethod
#     def BPSK_add_map0(map, b):
#                  map.add_with_map0(bank0=b,
#                  s0=BPSK_SMAP[b >> 0 & 0x1]& 0xFFFF,
#                  s1=BPSK_SMAP[b >> 1 & 0x1]& 0xFFFF,
#                  s2=BPSK_SMAP[b >> 2 & 0x1]& 0xFFFF,
#                  s3=BPSK_SMAP[b >> 3 & 0x1]& 0xFFFF,
#                  s4=BPSK_SMAP[b >> 4 & 0x1]& 0xFFFF,
#                  s5=BPSK_SMAP[b >> 5 & 0x1]& 0xFFFF,
#                  s6=BPSK_SMAP[b >> 6 & 0x1]& 0xFFFF,
#                  s7=BPSK_SMAP[b >> 7 & 0x1]& 0xFFFF)

class MapSymbols:
    """
    To initialize IQ symbol maps you can use any IQ map...
    """
    def __init__(self):
        ## you 
        self.BPSK_SMAP  = [ 1, 2]
        self.QAM256_SMAP = [ i for i in range(0, 256)]
        self.QAM16_SMAP = [ i for i in range(0, 16)]
        self.QPSK_SMAP = [ i for i in range(0, 4)]
        self.QAM64_SMAP = [i for i in range(0, 64)]
        self.tables = NetMod().get_tables()
        #self.BPSK_TABLE_MAPS_1 = self.tables["BPSK1"]

    def clear_table(self, table):
        table.clear()
    
    def clear_all(self):
        for (t, map) in self.tables.items():
            for table in map:
                print(table.info.name_get())
                #table.clear()
        return 1
    


    def BPSK_add_map0(self, map, b):
        map.add_with_map0(bank0=b,
             s0=self.BPSK_SMAP[b >> 0 & 0x1]& 0xFFFF,
             s1=self.BPSK_SMAP[b >> 1 & 0x1]& 0xFFFF,
             s2=self.BPSK_SMAP[b >> 2 & 0x1]& 0xFFFF,
             s3=self.BPSK_SMAP[b >> 3 & 0x1]& 0xFFFF,
             s4=self.BPSK_SMAP[b >> 4 & 0x1]& 0xFFFF,
             s5=self.BPSK_SMAP[b >> 5 & 0x1]& 0xFFFF,
             s6=self.BPSK_SMAP[b >> 6 & 0x1]& 0xFFFF,
             s7=self.BPSK_SMAP[b >> 7 & 0x1]& 0xFFFF)
        return b
    
    def BPSK_add_map1(self, map, b):
        map.add_with_map1(bank1=b,
                 s0=self.BPSK_SMAP[b >> 0 & 0x1]& 0xFFFF,
                 s1=self.BPSK_SMAP[b >> 1 & 0x1]& 0xFFFF,
                 s2=self.BPSK_SMAP[b >> 2 & 0x1]& 0xFFFF,
                 s3=self.BPSK_SMAP[b >> 3 & 0x1]& 0xFFFF,
                 s4=self.BPSK_SMAP[b >> 4 & 0x1]& 0xFFFF,
                 s5=self.BPSK_SMAP[b >> 5 & 0x1]& 0xFFFF,
                 s6=self.BPSK_SMAP[b >> 6 & 0x1]& 0xFFFF,
                 s7=self.BPSK_SMAP[b >> 7 & 0x1]& 0xFFFF)
        return b

    def QPSK_add_map(self, map, b):
        map.add_with_map(bank0=b,
                     s0=self.QPSK_SMAP[b >> 0 & 0x3]& 0xFFFF,
                     s1=self.QPSK_SMAP[b >> 2 & 0x3]& 0xFFFF,
                     s2=self.QPSK_SMAP[b >> 4 & 0x3]& 0xFFFF,
                     s3=self.QPSK_SMAP[b >> 6 & 0x3]& 0xFFFF)
        return b
    
    def QAM16_add_map(self, map, b):
        map.add_with_map(bank0=b,
                     s0=self.QAM16_SMAP[b >> 0 & 0xF]& 0xFFFF,
                     s1=self.QAM16_SMAP[b >> 4 & 0xF]& 0xFFFF)
        return b
    

    def QAM256_add_map(self, map, b):

        map.add_with_map(bank0 = b, s = self.QAM256_SMAP[b] & 0xFFFF)

        return 1


    def QAM64_add_map(self, map, b):
        map.add_with_map(bank0 = b & 0x3F, s = self.QAM64_SMAP[b & 0x3F] & 0xFFFF)

        return 1

    def Configure_BPSK(self):
        for (t1,t2) in zip(self.tables["BPSK1"], self.tables["BPSK2"]):
            for b in range(0, 256):
                self.BPSK_add_map0(t1 , b)
                self.BPSK_add_map1(t2,  b)
        return 1
    
    def Configure_QPSK(self):
        for t in self.tables["QPSK"]:
            for b in range(0, 256):
                self.QPSK_add_map(t, b)
            
        return 1
    


    def Configure_QAM16(self):
        for t in self.tables["QAM16"]:
            for b in range(0, 256):
                self.QAM16_add_map(t, b)

        return 1
    

    def Configure_QAM64(self):
        for t in self.tables["QAM64"]:
            for b in range(0, 64):
                self.QAM64_add_map(t, b)
        return 1
    

    def Configure_QAM256(self):

        for t in self.tables["QAM256"]:
            for b in range(0 , 256):
                self.QAM256_add_map(t, b)
            return 1
    
    def Configure_all(self):
        print("Clearing Tables to avoid duplicates ,,,,")
        self.clear_all()

        print("Adding BPSK Symbols ....")
        self.Configure_BPSK()

        print("Adding QPSK symbols ....")
        self.Configure_QPSK()

        print("Adding QAM16 symbols ....")
        self.Configure_QAM16()

        print("Adding QAM64 symbols .....")
        self.Configure_QAM64()

        print("Adding QAM256 symbols .....")
        self.Configure_QAM256()
        print("Done .....")
        


def main():
    if APP_NAME != NET_MOD_APP_NAME:
        print("Error : P4 Program mismatch ... ", APP_NAME)
        return -1
    

    net_mod = MapSymbols()

    net_mod.Configure_all()


if __name__ == "__main__":
    main()


    
        