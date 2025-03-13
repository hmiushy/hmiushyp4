
# Error Content
```
---> Removed intermediate container 54608377f768
 ---> cb6d6ebb3836
Step 3/12 : COPY ./uname-deb10 /bin/uname
 ---> af9d3fd2cf78
Step 4/12 : RUN apt-get install -y linux-headers-$(uname -r)
 ---> Running in b32cdfa1a192
Reading package lists...
Building dependency tree...
Reading state information...
E: Unable to locate package linux-headers-4.19.0-14-amd64
E: Couldn't find any package by glob 'linux-headers-4.19.0-14-amd64'
E: Couldn't find any package by regex 'linux-headers-4.19.0-14-amd64'
The command '/bin/sh -c apt-get install -y linux-headers-$(uname -r)' returned a non-zero code: 100
```

# Solution
Change from `FROM debian:10` to `FROM debian/snapshot:buster-20210208`
```
FROM debian/snapshot:buster-20210208
RUN apt-get update && apt-get install -y \
    build-essential stgit u-boot-tools util-linux \
    gperf device-tree-compiler python-all-dev xorriso \
    autoconf automake bison flex texinfo libtool libtool-bin \
    dosfstools mtools pkg-config git wget help2man libexpat1 \
    libexpat1-dev fakeroot python-sphinx rst2pdf \
    libefivar-dev libnss3-tools libnss3-dev libpopt-dev \
    libssl-dev sbsigntool uuid-runtime uuid-dev cpio \
    bsdmainutils curl sudo vim dh-make python3-dev python3-pip
COPY ./uname-deb10 /bin/uname
RUN apt-get update && apt-get install -y linux-headers-$(uname -r)
RUN pip3 install click==7.1.2 click-logging==1.0.1 cmakeast==0.0.18 PyYAML==5.3.1 jsonschema==2.6.0
RUN useradd -m -s /bin/bash build && \
        adduser build sudo && \
        echo "build:build" | chpasswd
RUN echo export PATH="/sbin:/usr/sbin:\$PATH" >> .bashrc
RUN mkdir src
WORKDIR /home/build/src
RUN chown -R build:build .
USER build
CMD ["/bin/bash", "--login"]
```
