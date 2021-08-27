SRC_PATH = src
MODULE_PATH = $(SRC_PATH)/module
OUTPUT_PATH = output
OPENLANE_PATH = /home/manili/OpenLane
OPENLANE_VER = 2021.08.22_03.28.34

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
	if [ "$(shell docker ps -aq -f name=openlane)" ]; then \
		if [ "$(shell docker ps -aq -f status=running -f name=openlane)" ]; then \
			docker stop openlane; \
		fi; \
		if [ "$(shell docker ps -aq -f status=exited -f name=openlane)" ]; then \
			docker rm openlane; \
		fi; \
	fi

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

openlane:
	if [ "$(shell docker ps -aq -f name=$@)" ]; then \
		if [ "$(shell docker ps -aq -f status=exited -f name=$@)" ]; then \
			docker start $@; \
		fi; \
	else \
		docker run -t -d --name openlane \
			-v $(OPENLANE_PATH):/openLANE_flow \
			-v $(OPENLANE_PATH)/pdks:$(OPENLANE_PATH)/pdks \
			-v $(shell pwd):/VSDBabySoC \
			-e PDK_ROOT=$(OPENLANE_PATH)/pdks \
			-u 1000:1000 \
			efabless/openlane:$(OPENLANE_VER); \
	fi

synth: openlane $(COMPILED_TLV_PATH)
	if [ ! -f "$(SYNTH_PATH)/vsdbabysoc.synth.v" ]; then \
		mkdir -p $(SYNTH_PATH); \
		docker exec -it $< bash -c "cd /VSDBabySoC/src; yosys -s /VSDBabySoC/src/script/yosys.ys"; \
	fi

sta: openlane synth
	mkdir -p $(STA_PATH)
	docker exec -it $< bash -c "cd /VSDBabySoC/src; sta -exit -threads max /VSDBabySoC/src/script/sta.conf"