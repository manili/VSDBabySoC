#!/bin/bash

export PATH=$PATH:~/.local/bin
sandpiper-saas -i rvmyth.tlv -o rvmyth.v --bestsv --noline -p verilog --outdir ./out
cp ../Prerequisites/* ./out
cp ./vsdbabysoc_tb.v ./vsdbabysoc.v ./avsd_pll_1v8.v ./avsddac.v ./out
iverilog out/vsdbabysoc_tb.v out/vsdbabysoc.v out/rvmyth.v out/clk_gate.v out/avsd_pll_1v8.v out/avsddac.v -I $PWD/out
./a.out
mv a.out ./out
mv vsdbabysoc.vcd ./out
