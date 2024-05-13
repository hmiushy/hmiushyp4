#!/bin/bash
OSNAME="Ubuntu"
OSVERS="20.04"
JOBS=5
SDE_INSTALL=${HOME}/bf-sde-9.7.0/install
KEYWORD="apt-get"
WITHPROTO="yes"

#bash
## install boost
env python3 ${HOME}/bf-sde-9.7.0/p4studio/dependencies/source/install_boost.py --os-name ${OSNAME} --os-version ${OSVERS} --jobs ${JOBS} --sde-install ${SDE_INSTALL} --keyword ${KEYWORD} --with-proto ${WITHPROTO}

## install grpc and protobuf
env python3 ${HOME}/bf-sde-9.7.0/p4studio/dependencies/source/install_grpc.py --os-name ${OSNAME} --os-version ${OSVERS} --jobs ${JOBS} --sde-install ${SDE_INSTALL} --keyword ${KEYWORD} --with-proto ${WITHPROTO}

## install thrift
env python3 ${HOME}/bf-sde-9.7.0/p4studio/dependencies/source/install_thrift.py --os-name ${OSNAME} --os-version ${OSVERS} --jobs ${JOBS} --sde-install ${SDE_INSTALL} --keyword ${KEYWORD} --with-proto ${WITHPROTO}

## install bridge_utils
env python3 ${HOME}/bf-sde-9.7.0/p4studio/dependencies/source/install_bridge_utils.py --os-name ${OSNAME} --os-version ${OSVERS} --jobs ${JOBS} --sde-install ${SDE_INSTALL} --keyword ${KEYWORD} --with-proto ${WITHPROTO}

## install libcli
env python3 ${HOME}/bf-sde-9.7.0/p4studio/dependencies/source/install_libcli.py --os-name ${OSNAME} --os-version ${OSVERS} --jobs ${JOBS} --sde-install ${SDE_INSTALL} --keyword ${KEYWORD} --with-proto ${WITHPROTO}

## install PI
env python3 ${HOME}/bf-sde-9.7.0/p4studio/dependencies/source/install_pi.py --os-name ${OSNAME} --os-version ${OSVERS} --jobs ${JOBS} --sde-install ${SDE_INSTALL} --keyword ${KEYWORD} --with-proto ${WITHPROTO}

