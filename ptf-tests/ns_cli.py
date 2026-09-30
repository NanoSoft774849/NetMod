from imports import *

class nano():
    def __init__(self) -> None:

        pass

netMod3 = bfrt_cli.bfrt.NanoMod

bfrt_cli.bfrt._get_full_leaf_info()

grpc_client = gc.ClientInterface(grpc_addr = "localhost:50052", client_id = 0, device_id = 0)

bfrt_info = grpc_client.bfrt_info_get(p4_name=None)

print("P4 Program Name :", bfrt_info.p4_name)

grpc_client.bind_pipeline_config(bfrt_info.p4_name)

# this a comm
# bfrt = cli.bfrt.

# for c in bfrt._children:
#     print(c.name)
