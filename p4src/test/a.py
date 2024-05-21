import os
import sys
import pdb
import logging
import copy
import pprint
SDE_INSTALL   = os.environ['SDE_INSTALL']
SDE_PYTHON_27 = os.path.join(SDE_INSTALL, 'lib', 'python2.7', 'site-packages')
sys.path.append(SDE_PYTHON_27)
sys.path.append(os.path.join(SDE_PYTHON_27, 'tofino'))

sys.path.append(SDE_INSTALL+'/include')
sys.path.append(SDE_INSTALL+'/lib/python3.8/site-packages/tofino/bfrt_grpc')
sys.path.append(SDE_INSTALL+'/lib/python3.8/site-packages/tofino')
sys.path.append(SDE_INSTALL+'/bin')
sys.path.append(SDE_INSTALL+'/lib/python3.8/lib-dynload')
sys.path.append(SDE_INSTALL+'/lib/python3.8/site-packages/tofino2pd/diag')
sys.path.append(SDE_INSTALL+'/lib/python3.8/site-packages/tofino_pd_api')
sys.path.append(SDE_INSTALL+'/lib/python3.8/site-packages/bf-ptf/ptf')
sys.path.append(SDE_INSTALL+'/lib/python3.8/lib-dynload')

import bfrtcli
import bfrt_grpc.client as bfrt_client
