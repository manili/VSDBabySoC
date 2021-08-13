#!/bin/bash

export SRC_PATH=/home/manili/VSDBabySoC/src

cd $SRC_PATH
yosys -s $SRC_PATH/script/yosys.sh
