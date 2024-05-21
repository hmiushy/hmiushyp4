# Super Simple Switch
1. build <br>
   `path/to/tools/tools/p4_build.sh ./path/to/src/sss.p4 --with-tofino2`
2. run tofino2_y1 model (terminal 1) <br>
   `path/to/model/run_tofino.sh -p sss --arch Tofino2`
3. run switchd (terminal 2) <br>
   `path/to/swid/run_switchd.sh -p sss --arch Tofino2`
4. run bfrt_python (terminal 2 or 3) <br>
   - terminal 2 <br>
    `bfrt_python path/to/test_table.py`
   - terminal 3 <br>
    `$SDE_INSTALL/bin/bfshell -b path/to/test_table.py`
5. check using scapy
   run wireshark in advance <br>
   `sudo python test_scapy.py`
