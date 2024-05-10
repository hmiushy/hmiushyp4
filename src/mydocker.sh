#!bin/bash
#set -u
## get the container id
function print_help() { ## Output help message
    echo "USAGE: bash $(basename ""$0"") -i <container number>"
    echo "1. Check the container number."
    echo "  `docker ps -a`"
    echo "2. Which container you want to start and count from the top."
    echo "3. Run \"bash $(basename ""$0"") -i 1\" if you want to start the top container."
    exit 0
}
trap 'exit' ERR

CID="1"     ## default container id
HELP=false  ## default help message

## parse
for i in "$@"; do
    case $i in
        --) shift; break;;
        -h) HELP=true; shift 1;;
        -i) CID=$2; shift 2;;
    esac
done

if [ $HELP == true ]; then
    print_help
fi

dhash=`docker ps -a | grep "970" | awk '{print $1}'`
dhash=` echo $dhash| awk -v val="$CID" '{print $val}'`
docker start ${dhash}
docker exec -it ${dhash} bash
#docker exec -it ${dhash} bash -c "bash --rcfile mybash.sh"

# memo
# bash ./tools/p4_build.sh ./tools/shared/switch_tofino2_y1.p4 --with-tofino2
# docker run --cap-add=NET_ADMIN -it -v ${PROJECT_DIR}:/home/build/src --name debian-stretch-sde-${USER}-970-2 debian:build-docker-new

#./run_tofino_model.sh -p switch_tofino2_y1 --arch Tofino2
