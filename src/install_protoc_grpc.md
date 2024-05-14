# Memo
# [p4lang/PI](https://github.com/p4lang/PI)
## Install ubuntu not container
First, copy `bf-sde-9.7.0`, `build.sh` in `barefoot-sde-9.7.0`, `tools`, `.env` and `bf-reference-bsp-9.7.0` on `/home/${USER}`, and run below:
```bash
# (in /home/${USER})
sudo -s
source .env
./build.sh -p angel_eye -u switch
```
but I cannot build p4studio because I got the error below:
```bash
...
...
debug: Cmd 'env python3 /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/install_pi.py --os-name Ubuntu --os-version 20.04 --jobs 5 --sde-install /home/user1/bf-sde-9.7.0/install --keyword apt-get --with-proto yes' took: 0:01:01.567996
Error: Problem occurred while installing pi
```

## protobuf
```bash
git clone --depth=1 -b v3.18.1 https://github.com/google/protobuf.git
cd protobuf/
./autogen.sh
./configure --prefix=/home/user1/bf-sde-9.7.0/install #./configure
make
make install
sudo ldconfig
sudo -E python3 -m  pip install protobuf==3.18.1
```
## grpc
``` bash
git clone --depth=1 -b v1.43.2 https://github.com/google/grpc.git
cd grpc/
git submodule update --init --recursive
mkdir -p cmake/build
cd cmake/build
cmake ../..
make
make install
ldconfig

- Building GRPC ... 
		COMMAND: [git clone https://github.com/google/grpc.git]
	 	- Patch1 Makefile created ... 
	 	- Patch2 Makefile created ... 
		COMMAND: [git checkout tags/v1.17.0]
		COMMAND: [git submodule update --init --recursive]
		COMMAND: [patch < /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/grpc-makefile-patch1_240514_110532]
		COMMAND: [git apply /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/grpc-makefile-patch2_240514_110532]
		COMMAND: [PKG_CONFIG_PATH=/home/user1/bf-sde-9.7.0/install/lib/pkgconfig:$PKG_CONFIG_PATH make prefix=/home/user1/bf-sde-9.7.0/install CFLAGS="-Wno-error" CXXFLAGS="-Wno-error=class-memaccess -Wno-error=ignored-qualifiers -Wno-error=stringop-truncation -Wno-stringop-overflow  -Wno-error=unused-function -Wno-error" -j5]
		COMMAND: [make install prefix=/home/user1/bf-sde-9.7.0/install]
```

```bash
PROTOC_ZIP=protoc-3.15.8-linux-x86_64.zip
curl -OL https://github.com/google/protobuf/releases/download/v3.15.8/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local include/*
rm -f $PROTOC_ZIP
```
## cmake version up
```bash
mkdir cmake  
wget https://github.com/Kitware/CMake/releases/download/v3.24.3/cmake-3.24.3-linux-x86_64.sh # download
chmod +x cmake-3.24.3-linux-x86_64.sh # attach
sudo mv cmake-3.24.3-linux-x86_64.sh /opt/ # move opt
cd /opt
sudo ./cmake-3.24.3-linux-x86_64.sh # run bash double yes
cd cmake-3.24.3-linux-x86_64/ 
sudo ln -s /opt/cmake-3.24.3-linux-x86_64/bin/* /usr/local/bin/ # generate linker
cmake --version # checking cmake version
```
## protobuf
```bash
sudo apt-get remove protobuf-compiler
sudo apt-get remove libprotobuf-dev
sudo apt-get remove libprotobuf-lite10

sudo apt-get install autoconf automake libtool curl make g++ unzip
#git clone -b 3.6.x https://github.com/protocolbuffers/protobuf.git
git clone -b 3.18.x https://github.com/protocolbuffers/protobuf.git
cd protobuf
git submodule update --init --recursive
./autogen.sh

./configure
make
make check
sudo make install
sudo ldconfig # refresh shared library cache.

```
## grpc
```bash
export MY_INSTALL_DIR=$HOME/.local
mkdir -p $MY_INSTALL_DIR
export PATH="$PATH:$MY_INSTALL_DIR/bin"
export PATH=$PATH:$HOME/.local/bin
## cmake
sudo apt-get install cmake
wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0-Linux-x86_64.sh
sh cmake-linux.sh -- --skip-license --prefix=$MY_INSTALL_DIR
rm cmake-linux.sh


## get repository
sudo apt-get install build-essential autoconf libtool pkg-config libssl-dev
git clone --recurse-submodules -b v1.18.0 https://github.com/grpc/grpc
cd grpc

## c-area
cd third_party/cares/cares
git fetch origin
git checkout cares-1_13_0
mkdir -p cmake/build
cd cmake/build
cmake -DCMAKE_BUILD_TYPE=Release ../..
sudo make -j4 install
rm -rf third_party/cares/cares  # wipe out to prevent influencing the grpc build
cd ../../../..

## zlib
cd third_party/zlib
mkdir -p cmake/build
cd cmake/build
cmake -DCMAKE_BUILD_TYPE=Release ../..
sudo make -j4 install
rm -rf third_party/zlib  # wipe out to prevent influencing the grpc build
cd ../../../..

## grpc package mode
cd grpc
mkdir -p cmake/build
cd cmake/build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DgRPC_INSTALL=ON \
  -DgRPC_BUILD_TESTS=OFF \
  -DgRPC_CARES_PROVIDER=package \
  -DgRPC_PROTOBUF_PROVIDER=package \
  -DgRPC_SSL_PROVIDER=package \
  -DgRPC_ZLIB_PROVIDER=package \
  -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
  ../..
make -j4 install

```