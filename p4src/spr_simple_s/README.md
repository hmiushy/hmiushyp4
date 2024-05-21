# Super Simple Switch
1. build
```bash
    path/to/tools/tools/p4_build.sh ./path/to/src/sss.p4 --with-tofino2
```
3. run tofino2_y1 model (terminal 1) 
```bash
    path/to/model/run_tofino.sh -p sss --arch Tofino2
```
5. run switchd (terminal 2)
```
    path/to/swid/run_switchd.sh -p sss --arch Tofino2
```
7. run bfrt_python (terminal 2 or 3) <br>
   - terminal 2
    ```
    bfrt_python path/to/test_table.py
    ```
   - terminal 3
    ```
    $SDE_INSTALL/bin/bfshell -b path/to/test_table.py
    ```
8. check using scapy <br>
   run wireshark in advance 
   ```
   sudo python test_scapy.py
   ```
