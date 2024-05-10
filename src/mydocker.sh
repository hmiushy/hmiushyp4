#!bin/bash

set -ue
## get the container id
dhash=`docker ps -a | grep "970-2" | awk '{print $1}'`
docker start ${dhash}
docker exec -it ${dhash} bash
#docker exec -it ${dhash} bash -c "bash --rcfile mybash.sh"

# memo
# bash ./tools/p4_build.sh ./tools/shared/switch_tofino2_y1.p4 --with-tofino2
# docker run --cap-add=NET_ADMIN -it -v ${PROJECT_DIR}:/home/build/src --name debian-stretch-sde-${USER}-970-2 debian:build-docker-new

#./run_tofino_model.sh -p switch_tofino2_y1 --arch Tofino2
