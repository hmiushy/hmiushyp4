apt-get update && apt-get install -y \
    build-essential stgit u-boot-tools util-linux \
    gperf device-tree-compiler python-all-dev xorriso \
    autoconf automake bison flex texinfo libtool libtool-bin \
    dosfstools mtools pkg-config git wget help2man libexpat1 \
    libexpat1-dev fakeroot rst2pdf \
    libefivar-dev libnss3-tools libnss3-dev libpopt-dev \
    libssl-dev sbsigntool uuid-runtime uuid-dev cpio \
    bsdmainutils curl sudo vim dh-make python3-dev python3-pip python-yaml python-dev
# error occurs installing python-sphinx so remove 
# add python-yaml

pip3 install click==7.1.2 click-logging==1.0.1 cmakeast==0.0.18 PyYAML==5.3.1 jsonschema==2.6.0
echo export PATH="/sbin:/usr/sbin:\$PATH" >> .bashrc

## installing thrift
# remove 'sudo %s -y remove python-thrift' % keyword, in install_thrift.py (L:111)
## installing PI
# which protoc and check the version
# the version is "libprotoc 3.18.1" because I tried to install myself.
# have to remove this (conflict the version)
# "which protoc" and "remove -r /usr/local/bin/protoc"

## I got 
# ebug: [ 64%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/proto/bf_rt_server_mgr.cpp.o
# debug: [ 64%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/cpp_out/bfruntime.pb.cc.o
# debug: [ 64%] Building CXX object pkgsrc/bf-drivers/src/bf_rt/CMakeFiles/bfrt_o.dir/cpp_out/bfruntime.grpc.pb.cc.o
# debug: [ 64%] Built target bfrt_o
# debug: make: *** [Makefile:130: all] Error 2
# debug: Cmd 'make --jobs=5 install' took: 0:08:04.750411
# Error: Installation completed unsuccessfully

# sudo apt install lua5.3 lua5.3-dev
