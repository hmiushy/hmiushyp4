#!/bin/bash
#HOMEUSER="/home/user1"
HOMEUSER=${HOME}
OSNAME="Ubuntu"
OSVERS="20.04"
JOBS=5
SDEINSTALL=${HOMEUSER}/bf-sde-9.7.0/install
KEYWORD="apt-get"
WITHPROTO="yes"

#bash
## install boost
env python3 /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/install_boost.py --os-name Ubuntu --os-version 20.04 --jobs 5 --sde-install /home/user1/bf-sde-9.7.0/install --keyword apt-get --with-proto yes

## install grpc and protobuf
env python3 /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/install_grpc.py --os-name Ubuntu --os-version 20.04 --jobs 5 --sde-install /home/user1/bf-sde-9.7.0/install --keyword apt-get --with-proto yes

## install thrift
env python3 /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/install_thrift.py --os-name Ubuntu --os-version 20.04 --jobs 5 --sde-install /home/user1/bf-sde-9.7.0/install --keyword apt-get --with-proto yes

## install bridge_utils
env python3 /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/install_bridge_utils.py --os-name Ubuntu --os-version 20.04 --jobs 5 --sde-install /home/user1/bf-sde-9.7.0/install --keyword apt-get --with-proto yes

## install libcli
env python3 /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/install_libcli.py --os-name Ubuntu --os-version 20.04 --jobs 5 --sde-install /home/user1/bf-sde-9.7.0/install --keyword apt-get --with-proto yes

## install PI
env python3 /home/user1/bf-sde-9.7.0/p4studio/dependencies/source/install_pi.py --os-name Ubuntu --os-version 20.04 --jobs 5 --sde-install /home/user1/bf-sde-9.7.0/install --keyword apt-get --with-proto yes

