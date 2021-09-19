SRC_PATH = src
LIB_PATH = $(SRC_PATH)/lib
GDS_PATH = $(SRC_PATH)/gds
LEF_PATH = $(SRC_PATH)/lef
SDC_PATH = $(SRC_PATH)/sdc
MODULE_PATH = $(SRC_PATH)/module
INCLUDE_PATH = $(SRC_PATH)/include
LAYOUT_CONF_PATH = $(SRC_PATH)/layout_conf
OUTPUT_PATH = output
OPENLANE_PATH = /home/manili/OpenLane
PDKS_PATH = $(OPENLANE_PATH)/pdks
OPENLANE_VER = 2021.09.09_03.00.48

STA_PATH = $(OUTPUT_PATH)/sta
SYNTH_PATH = $(OUTPUT_PATH)/synth
COMPILED_TLV_PATH = $(OUTPUT_PATH)/compiled_tlv
PRE_SYNTH_SIM_PATH = $(OUTPUT_PATH)/pre_synth_sim
POST_SYNTH_SIM_PATH = $(OUTPUT_PATH)/post_synth_sim

.PHONY: all
all: sim

.PHONY: sim
sim: pre_synth_sim post_synth_sim

.PHONY: clean
clean:
	rm -rf $(OUTPUT_PATH)
	rm -rf $(OPENLANE_PATH)/designs/rvmyth
	rm -rf $(OPENLANE_PATH)/designs/vsdbabysoc

.PHONY: mount
mount:
	docker run -it --rm \
		-v $(OPENLANE_PATH):/openLANE_flow \
		-v $(OPENLANE_PATH)/pdks:/openLANE_flow/pdks \
		-v $(shell pwd):/VSDBabySoC \
		-e PDK_ROOT=/openLANE_flow/pdks \
		-u 1000:1000 \
		efabless/openlane:$(OPENLANE_VER) \
		bash

$(COMPILED_TLV_PATH): $(MODULE_PATH)/*.tlv
	sandpiper-saas -i $< -o rvmyth.v \
		--bestsv --noline -p verilog --outdir $@

pre_synth_sim: $(COMPILED_TLV_PATH)
	if [ ! -f "$(PRE_SYNTH_SIM_PATH)/pre_synth_sim.vcd" ]; then \
		mkdir -p $(PRE_SYNTH_SIM_PATH); \
		iverilog -o $(PRE_SYNTH_SIM_PATH)/pre_synth_sim.out -DPRE_SYNTH_SIM \
			$(MODULE_PATH)/testbench.v \
			-I $(SRC_PATH)/include -I $(MODULE_PATH) -I $(COMPILED_TLV_PATH); \
		cd $(PRE_SYNTH_SIM_PATH); ./pre_synth_sim.out; \
	fi

post_synth_sim: synth
	if [ ! -f "$(POST_SYNTH_SIM_PATH)/post_synth_sim.vcd" ]; then \
		mkdir -p $(POST_SYNTH_SIM_PATH); \
		iverilog -o $(POST_SYNTH_SIM_PATH)/post_synth_sim.out -DPOST_SYNTH_SIM -DFUNCTIONAL -DUNIT_DELAY=#1 \
			$(MODULE_PATH)/testbench.v \
			-I $(SRC_PATH)/include -I $(MODULE_PATH) -I $(SRC_PATH)/gls_model -I $(SYNTH_PATH); \
		cd $(POST_SYNTH_SIM_PATH); ./post_synth_sim.out; \
	fi

synth: $(COMPILED_TLV_PATH)
	if [ ! -f "$(SYNTH_PATH)/vsdbabysoc.synth.v" ]; then \
		mkdir -p $(SYNTH_PATH); \
		docker run -it --rm \
			-v $(OPENLANE_PATH):/openLANE_flow \
			-v $(OPENLANE_PATH)/pdks:/openLANE_flow/pdks \
			-v $(shell pwd):/VSDBabySoC \
			-e PDK_ROOT=/openLANE_flow/pdks \
			-u 1000:1000 \
			efabless/openlane:$(OPENLANE_VER) \
			bash -c "cd /VSDBabySoC/src; yosys -s /VSDBabySoC/src/script/yosys.ys | tee ../output/synth/synth.log"; \
	fi

sta: synth
	if [ ! -f "$(STA_PATH)/sta.log" ]; then \
		mkdir -p $(STA_PATH); \
		docker run -it --rm \
			-v $(OPENLANE_PATH):/openLANE_flow \
			-v $(OPENLANE_PATH)/pdks:/openLANE_flow/pdks \
			-v $(shell pwd):/VSDBabySoC \
			-e PDK_ROOT=/openLANE_flow/pdks \
			-u 1000:1000 \
			efabless/openlane:$(OPENLANE_VER) \
			bash -c "cd /VSDBabySoC/src; sta -exit -threads max /VSDBabySoC/src/script/sta.conf | tee ../output/sta/sta.log"; \
	fi

rvmyth_layout: $(COMPILED_TLV_PATH)
	if [ ! -d "$(OPENLANE_PATH)/designs/rvmyth" ]; then \
		mkdir -p $(OUTPUT_PATH)/rvmyth_layout; \
		mkdir -p $(OPENLANE_PATH)/designs/rvmyth; \
		mkdir -p $(OPENLANE_PATH)/designs/rvmyth/src; \
		mkdir -p $(OPENLANE_PATH)/designs/rvmyth/src/module; \
		mkdir -p $(OPENLANE_PATH)/designs/rvmyth/src/include; \
		cp -r $(LAYOUT_CONF_PATH)/rvmyth/* $(OPENLANE_PATH)/designs/rvmyth; \
		cp $(COMPILED_TLV_PATH)/rvmyth.v $(OPENLANE_PATH)/designs/rvmyth/src/module; \
		cp $(MODULE_PATH)/clk_gate.v $(OPENLANE_PATH)/designs/rvmyth/src/module; \
		cp $(COMPILED_TLV_PATH)/rvmyth_gen.v $(OPENLANE_PATH)/designs/rvmyth/src/include; \
		cp $(INCLUDE_PATH)/*.vh $(OPENLANE_PATH)/designs/rvmyth/src/include; \
		docker run -it --rm \
			-v $(OPENLANE_PATH):/openLANE_flow \
			-v $(OPENLANE_PATH)/pdks:/openLANE_flow/pdks \
			-v $(shell pwd):/VSDBabySoC \
			-e PDK_ROOT=/openLANE_flow/pdks \
			-u 1000:1000 \
			efabless/openlane:$(OPENLANE_VER) \
			bash -c "./flow.tcl -design rvmyth -tag rvmyth_test | tee /VSDBabySoC/output/rvmyth_layout/layout.log"; \
		rm -rf $(OUTPUT_PATH)/rvmyth_layout/rvmyth_test; \
		cp -r $(OPENLANE_PATH)/designs/rvmyth/runs/* $(OUTPUT_PATH)/rvmyth_layout; \
	elif [ ! -d "$(OUTPUT_PATH)/rvmyth_layout/rvmyth_test" ]; then \
		mkdir -p $(OUTPUT_PATH)/rvmyth_layout; \
		cp -r $(OPENLANE_PATH)/designs/rvmyth/runs/* $(OUTPUT_PATH)/rvmyth_layout; \
	fi

rvmyth_post_routing_sim: rvmyth_layout
	if [ ! -f "$(OUTPUT_PATH)/rvmyth_layout/post_routing_sim.vcd" ]; then \
		iverilog -o $(OUTPUT_PATH)/rvmyth_layout/post_routing_sim.out \
			-DFUNCTIONAL -DUSE_POWER_PINS -DUNIT_DELAY=#1 \
			$(MODULE_PATH)/testbench.rvmyth.post-routing.v \
			$(OUTPUT_PATH)/rvmyth_layout/rvmyth_test/results/lvs/rvmyth.lvs.powered.v \
			-I $(SRC_PATH)/gls_model; \
		cd $(OUTPUT_PATH)/rvmyth_layout; ./post_routing_sim.out; \
	fi

vsdbabysoc_layout: $(COMPILED_TLV_PATH)
	if [ ! -d "$(OPENLANE_PATH)/designs/vsdbabysoc" ]; then \
		mkdir -p $(OUTPUT_PATH)/vsdbabysoc_layout; \
		mkdir -p $(OPENLANE_PATH)/designs/vsdbabysoc; \
		mkdir -p $(OPENLANE_PATH)/designs/vsdbabysoc/src; \
		mkdir -p $(OPENLANE_PATH)/designs/vsdbabysoc/src/module; \
		mkdir -p $(OPENLANE_PATH)/designs/vsdbabysoc/src/include; \
		cp -r $(LAYOUT_CONF_PATH)/vsdbabysoc/* $(OPENLANE_PATH)/designs/vsdbabysoc; \
		cp $(MODULE_PATH)/vsdbabysoc.v $(OPENLANE_PATH)/designs/vsdbabysoc/src/module; \
		cp $(COMPILED_TLV_PATH)/rvmyth.v $(OPENLANE_PATH)/designs/vsdbabysoc/src/module; \
		cp $(MODULE_PATH)/clk_gate.v $(OPENLANE_PATH)/designs/vsdbabysoc/src/module; \
		cp $(COMPILED_TLV_PATH)/rvmyth_gen.v $(OPENLANE_PATH)/designs/vsdbabysoc/src/include; \
		cp $(INCLUDE_PATH)/*.vh $(OPENLANE_PATH)/designs/vsdbabysoc/src/include; \
		cp $(LIB_PATH)/*.lib $(OPENLANE_PATH)/designs/vsdbabysoc/src; \
		cp $(GDS_PATH)/*.gds $(OPENLANE_PATH)/designs/vsdbabysoc/src; \
		cp $(LEF_PATH)/*.lef $(OPENLANE_PATH)/designs/vsdbabysoc/src; \
		cp $(SDC_PATH)/vsdbabysoc_layout.sdc $(OPENLANE_PATH)/designs/vsdbabysoc/src; \
		docker run -it --rm \
			-v $(OPENLANE_PATH):/openLANE_flow \
			-v $(OPENLANE_PATH)/pdks:/openLANE_flow/pdks \
			-v $(shell pwd):/VSDBabySoC \
			-e PDK_ROOT=/openLANE_flow/pdks \
			-u 1000:1000 \
			efabless/openlane:$(OPENLANE_VER) \
			bash -c "./flow.tcl -design vsdbabysoc -tag vsdbabysoc_test | tee /VSDBabySoC/output/vsdbabysoc_layout/layout.log"; \
		rm -rf $(OUTPUT_PATH)/vsdbabysoc_layout/vsdbabysoc_test; \
		cp -r $(OPENLANE_PATH)/designs/vsdbabysoc/runs/* $(OUTPUT_PATH)/vsdbabysoc_layout; \
	elif [ ! -d "$(OUTPUT_PATH)/vsdbabysoc_layout/vsdbabysoc_test" ]; then \
		mkdir -p $(OUTPUT_PATH)/vsdbabysoc_layout; \
		cp -r $(OPENLANE_PATH)/designs/vsdbabysoc/runs/* $(OUTPUT_PATH)/vsdbabysoc_layout; \
	fi