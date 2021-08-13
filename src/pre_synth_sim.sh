#!/bin/bash

export PATH=$PATH:~/.local/bin
export SRC_PATH=$PWD
export TRG_PATH=$PWD/../pre_synth_sim

sandpiper-saas -i $SRC_PATH/module/rvmyth.tlv -o rvmyth.v \
    --bestsv --noline -p verilog --outdir $TRG_PATH

iverilog -o $TRG_PATH/pre_synth_sim.out \
    $SRC_PATH/testbench/pre_synth_sim_tb.v \
    -I $SRC_PATH/include -I $SRC_PATH/module -I $TRG_PATH

cd $TRG_PATH; ./pre_synth_sim.out
