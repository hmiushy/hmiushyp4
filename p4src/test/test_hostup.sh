# [ref](https://hana-shin.hatenablog.com/entry/2022/02/21/214149)

sudo ip netns add host1
sudo ip netns add host2

sudo ip link set veth1 netns host1
sudo ip netns exec host1 ip addr add 10.0.0.8/24 dev veth1
sudo ip netns exec host1 ip link set veth1 up
sudo ip netns exec host1 ip link set lo up
#sudo ip netns exec host1 route add default gw 10.0.0.8


sudo ip link set veth3 netns host2
sudo ip netns exec host2 ip addr add 10.0.0.9/24 dev veth3
sudo ip netns exec host2 ip link set veth3 up
sudo ip netns exec host2 ip link set lo up
#sudo ip netns exec host2 route add default gw 10.0.0.9

# check ip addr
sudo ip netns exec host1 ip a

# in host
sudo ip netns exec host1 bash

# down
#!/usr/bin/bash
sudo ip netns exec host1 ip link set veth1 down
sudo ip netns exec host1 ip link set lo down
sudo ip netns exec host2 ip link set veth2 down
sudo ip netns exec host2 ip link set lo down
sudo ip netns delete host1
sudo ip netns delete host2

# repair
sudo ip link add name veth1 type veth peer name veth0
sudo ip link add name veth3 type veth peer name veth2

# force repairing
./tools2/veth_teardown.sh