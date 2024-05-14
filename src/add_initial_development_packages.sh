apt-get update && apt-get install -y \
    build-essential stgit u-boot-tools util-linux \
    gperf device-tree-compiler python-all-dev xorriso \
    autoconf automake bison flex texinfo libtool libtool-bin \
    dosfstools mtools pkg-config git wget help2man libexpat1 \
    libexpat1-dev fakeroot rst2pdf \
    libefivar-dev libnss3-tools libnss3-dev libpopt-dev \
    libssl-dev sbsigntool uuid-runtime uuid-dev cpio \
    bsdmainutils curl sudo vim dh-make python3-dev python3-pip python-yaml
# error occurs installing python-sphinx so remove 
# add python-yaml

pip3 install click==7.1.2 click-logging==1.0.1 cmakeast==0.0.18 PyYAML==5.3.1 jsonschema==2.6.0
echo export PATH="/sbin:/usr/sbin:\$PATH" >> .bashrc