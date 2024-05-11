## 1. Create P4studio env
## 2. 

./build.sh -p angel_eye -u switch
cd ${SDE}
. ./tools/set_sde.bash
bash ./tools/p4_build.sh ./tools/shared/switch_tofino2_y1.p4 --with-tofino2
