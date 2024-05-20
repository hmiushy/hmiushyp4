## Error related glibc
```bash
$  ./switchd.sh -p test --arch Tofino2
Using SDE /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0
Using SDE_INSTALL /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install
Setting up DMA Memory Pool
Using TARGET_CONFIG_FILE /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/share/p4/targets/tofino2/test.conf
Using PATH /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/bin:/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/bin:/sbin:/usr/sbin:/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/include:/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/include/lld
Using LD_LIBRARY_PATH /usr/local/lib:/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib:/usr/local/lib:/home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/include
bf_switchd: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/libdriver.so)
bf_switchd: /usr/lib/x86_64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.26' not found (required by /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/libdriver.so)
bf_switchd: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/libpiall.so.0)
bf_switchd: /usr/lib/x86_64-linux-gnu/libstdc++.so.6: version `GLIBCXX_3.4.26' not found (required by /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/libpifeproto.so.0)
bf_switchd: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/libgrpc.so.7)
bf_switchd: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.29' not found (required by /home/rdpuser/barefoot/barefoot-sde-9.7.0/bf-sde-9.7.0/install/lib/libpip4info.so.0)

```
try to update or install glibc.
[Ref](https://stackoverflow.com/questions/72513993/how-to-install-glibc-2-29-or-higher-in-ubuntu-18-04)
[Ref](https://stackoverflow.com/questions/74740941/how-can-i-resolve-this-issue-libm-so-6-version-glibc-2-29-not-found-c-c)
[Ref](https://www.silicloud.com/ja/blog/linux%E3%81%A7glibc%E3%81%AE%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3%E3%82%92%E3%82%A2%E3%83%83%E3%83%97%E3%82%B0%E3%83%AC%E3%83%BC%E3%83%89%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95/)
[How to update glibc](https://tutorials.tinkink.net/en/linux/how-to-update-glibc.html)
## script
```bash
wget -c https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.gz
tar -zxvf glibc-2.29.tar.gz
mkdir glibc-2.29/build
cd glibc-2.29/build
../configure --prefix=/opt/glibc
make 
make install
(get error`not found /opt/glibc/etc/ld.so.conf`, so did `sudo echo > sudo tee /opt/glibc/etc/ld.so.conf`)
make install
```
memo: original ldd is placed in `/usr/bin/ldd`
