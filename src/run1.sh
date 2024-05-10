# 1. bash mydocker.sh
# 2. sudo -s
# 3. bash run1.sh
source .env
echo $SDE
echo $SDE_INSTALL

bash ${SDE_INSTALL}/bin/veth_setup.sh
${SDE}/run_tofino_model.sh -p switch_tofino2_y1 --arch Tofino2
