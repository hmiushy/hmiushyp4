## Error I got
I got error like below when I ran `${SDE_INSTALL}/bin/veth_setup.sh` removed `set -e` in the code.
```bash
No of Veths is 64
Adding CPU veth
Cannot find device "veth0"
Cannot find device "veth1"
Cannot find device "veth2"
Cannot find device "veth3"
Cannot find device "veth4"
Cannot find device "veth5"
Cannot find device "veth6"
Cannot find device "veth7"
Cannot find device "veth8"
Cannot find device "veth9"
Cannot find device "veth10"
Cannot find device "veth11"
Cannot find device "veth12"
Cannot find device "veth13"
Cannot find device "veth14"
Cannot find device "veth15"
Cannot find device "veth16"
Cannot find device "veth17"
Cannot find device "veth18"
Cannot find device "veth19"
Cannot find device "veth20"
Cannot find device "veth21"
Cannot find device "veth22"
Cannot find device "veth23"
Cannot find device "veth24"
Cannot find device "veth25"
...
```
This means you cannot add ip link such as `veth0` and `veth1` before `ip link set dev` command.
```bash
# failed to adding the veth here (L19 of veth_setup.sh)
ip link add name $intf0 type veth peer name $intf1 &> /dev/null
```
And you are getting an RTNETLINK operation not permitted with a docker container
([Reference](https://stackoverflow.com/questions/27708376/why-am-i-getting-an-rtnetlink-operation-not-permitted-when-using-pipework-with-d)). <br>
(I researched `RTNETLINK answers: Operation not permitted`)

## Resolution ([Reference](https://stackoverflow.com/questions/27708376/why-am-i-getting-an-rtnetlink-operation-not-permitted-when-using-pipework-with-d))
You have to run the code below.
```bash
docker run --cap-add=NET_ADMIN -it -v ${PROJECT_DIR}:/home/build/src --name debian-stretch-sde-${USER}-970-2 debian:build-docker-new
```
Not this code:
```bash
docker run -it -v ${PROJECT_DIR}:/home/build/src --name debian-stretch-sde-${USER}-970 debian:build-docker-new
```
You have to change the container name like `--name debian-stretch-sde-${USER}-970-2`.
You can execute the code `${SDE_INSTALL}/bin/veth_setup.sh` after run the setup code of P4studio.
## Specific order
1. Build docker iamge
```bash
cd barefoot-sde-9.7.0/
cd build-docker
docker build -t debian:build-docker-new .
cd ..
```

2. Set env and create container
```bash
docker run -it -v ${PROJECT_DIR}:/home/build/src --name debian-stretch-sde-${USER}-970 debian:build-docker-new
# or docker exec -it <container hash> bash
```

3. In container
```bash
sudo -s
source .env
```

4. Build profile using p4studio
```bash
./build.sh -p angel_eye -u switch
```
After run these code, you can do p4 simulation.
The after code is summarized in `mydocker.sh` and run1.sh.