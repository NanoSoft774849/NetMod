import logging 
import tofino.bfrt_grpc  as bfrt_grpc 
import pdb

######### PTF modules for BFRuntime Client Library APIs #######
# import importlib

from ptf import *
from ptf.testutils import *
from ptf.dataplane import *

from p4testutils.bfruntime_client_base_tests import BfRuntimeTest
import tofino.bfrt_grpc.bfruntime_pb2 as bfruntime_pb2
import tofino.bfrt_grpc.client as gc

######## PTF modules for Fixed APIs (Thrift) ######
import p4testutils.pd_base_tests as pd_base_tests
from ptf.thriftutils   import *
from tofino.res_pd_rpc.ttypes import *       # Common data types
from tofino.mc_pd_rpc.ttypes  import *       # Multicast-specific data types


import bfrtcli as bfrt_cli