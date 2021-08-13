#!/bin/bash

export PATH=$PATH:~/.local/bin
export SRC_PATH=$PWD
export TRG_PATH=$PWD/../post_synth_sim

sandpiper-saas -i $SRC_PATH/module/rvmyth.tlv -o rvmyth.v \
    --bestsv --noline -p verilog --outdir $TRG_PATH

if [ "$(docker ps -q -f name=openlane)" ]; then
    if [ "$(docker ps -aq -f status=running -f name=openlane)" ]; then
        echo "$(docker stop openlane) stopped."
    fi
    if [ "$(docker ps -aq -f status=exited -f name=openlane)" ]; then
        echo "$(docker rm openlane) removed."
    fi
fi

docker run -t -d --name openlane \
    -v /home/manili/OpenLane:/openLANE_flow \
    -v /home/manili/openlane/pdks:/home/manili/openlane/pdks \
    -v /home/manili/Desktop/VSDBabySoC/:/home/manili/VSDBabySoC \
    -e PDK_ROOT=/home/manili/openlane/pdks \
    -u 1000:1000 efabless/openlane:2021.08.02_05.21.44
docker exec -it openlane /home/manili/VSDBabySoC/src/script/docker.sh

iverilog -o $TRG_PATH/post_synth_sim.out \
    $SRC_PATH/testbench/post_synth_sim_tb.v \
    -I $SRC_PATH/include -I $SRC_PATH/module -I $SRC_PATH/gls_model -I $TRG_PATH

cd $TRG_PATH; ./post_synth_sim.out
