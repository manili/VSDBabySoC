# VSDBabySoC
VSDBabySoC is a small SoC including PLL, DAC and a RISCV-based processor named RVMYTH.

# Table of Contents
- [Introduction to the VSDBabySoC](#introduction-to-the-vsdbabysoc)
  - [Problem statement](#problem-statement)
  - [What is SoC](#what-is-soc)
  - [What is RVMYTH](#what-is-rvmyth)
  - [What is PLL](#what-is-pll)
  - [What is DAC](#what-is-dac)
- [VSDBabySoC Modeling](#vsdbabysoc-modeling)
  - [RVMYTH modeling](#rvmyth-modeling)
  - [PLL and DAC modeling](#pll-and-dac-modeling)
  - [Step by step modeling walkthrough](#step-by-step-modeling-walkthrough)
- [VSDBabySoC Physical Design](#vsdbabysoc-physical-design)
  - [OpenLane installation](#openlane-installation)
  - [Synthesizing using Yosys](#synthesizing-using-yosys)
    - [How to synthesize the design](#how-to-synthesize-the-design)
    - [Post-synthesis simulation (GLS)](#post-synthesis-simulation-gls)
    - [Yosys final report](#yosys-final-report)
- [Contributors](#contributors)
- [Acknowledgements](#acknowledgements)

# Introduction to the VSDBabySoC

VSDBabySoC is a small yet powerful RISCV-based SoC. The main purpose of designing such a small SoC is to test three open-source IP cores together for the first time and calibrate the analog part of it. VSDBabySoC contains one RVMYTH microprocessor, an 8x-PLL to generate a stable clock, and a 10-bit DAC to communicate with other analog devices.

  ![vsdbabysoc_block_diagram](images/vsdbabysoc_block_diagram.png)

## Problem statement

This work discusses the different aspects of designing a small SoC based on RVMYTH (a RISCV-based processor). This SoC will leverage a PLL as its clock generator and controller and a 10-bit DAC as a way to talk to the outside world. Other electrical devices with proper analog input like televisions, and mobile phones could manipulate DAC output and provide users with music sound or video frames. At the end of the day, it is possible to use this small fully open-source and well-documented SoC which has been fabricated under Sky130 technology, for educational purposes.

## What is SoC

An SoC is a single-die chip that has some different IP cores on it. These IPs could vary from microprocessors (completely digital) to 5G broadband modems (completely analog).

## What is RVMYTH

RVMYTH core is a simple RISCV-based CPU, introduced in a workshop by RedwoodEDA and VSD. During a 5-day workshop students (including middle-schoolers) managed to create a processor from scratch. The workshop used the TLV for faster development. All of the present and future contributions to the IP will be done by students and under open-source licenses.

## What is PLL

A phase-locked loop or PLL is a control system that generates an output signal whose phase is related to the phase of an input signal. PLLs are widely used for synchronization purposes, including clock generation and distribution.

## What is DAC

A digital-to-analog converter or DAC is a system that converts a digital signal into an analog signal. DACs are widely used in modern communication systems enabling the generation of digitally-defined transmission signals. As a result, high-speed DACs are used for mobile communications and ultra-high-speed DACs are employed in optical communications systems.

# VSDBabySoC Modeling

Here we are going to model and simulate the VSDBabySoC using `iverilog`, then we will show the results using `gtkwave` tool. Some initial input signals will be fed into `vsdbabysoc` module that make the pll start generating the proper `CLK` for the circuit. The clock signal will make the `rvmyth` to execute instructions in its `imem`. As a result the register `r17` will be filled with some values cycle by cycle. These values are used by dac core to provide the final output signal named `OUT`. So we have 3 main elements (IP cores) and a wrapper as an SoC and of-course there would be also a testbench module out there.

Please note that in the following sections we will mention some repos that we used to model the SoC. However the main source code is resided in [Source-Code Directory](src) and these modules are in [Modules Sub-Directory](src/module).

## RVMYTH modeling

As we mentioned in [What is RVMYTH](#what-is-rvmyth) section, RVMYTH is designed and created by the TL-Verilog language. So we need a way for compile and trasform it to the Verilog language and use the result in our SoC. Here the `sandpiper-saas` could help us do the job.

  [Here](https://github.com/shivanishah269/risc-v-core) is the repo we used as a reference to model the RVMYTH

## PLL and DAC modeling

It is not possible to sythesis an analog design with Verilog, yet. But there is a chance to simulate it using `real` datatype. We will use the following repositories to model the PLL and DAC cores:

  1. [Here](https://github.com/vsdip/rvmyth_avsdpll_interface) is the repo we used as a reference to model the PLL
  2. [Here](https://github.com/vsdip/rvmyth_avsddac_interface) is the repo we used as a reference to model the DAC

## Step by step modeling walkthrough

In this section we will walk you through the whole process of modeling the VSDBabySoC in details. We will increase/decrease the digital output value and feed it to the DAC model so we can watch the changes on the SoC output. Please, note that the following commands are tested on the Ubuntu Bionic (18.04.5) platform and no other OSes.

  1. First we need to install some important packages:

  ```
  $ sudo apt install make python python3 python3-pip git iverilog gtkwave docker.io
  $ sudo chmod 666 /var/run/docker.sock
  $ cd ~
  $ pip3 install pyyaml click sandpiper-saas
  ```

  2. Now you can clone this repository in arbitrary directory (we'll choose home directory here):

  ```
  $ cd ~
  $ git clone https://github.com/manili/VSDBabySoC.git
  ```

  3. It's time to make the `pre_synth_sim.vcd`:

  ```
  $ cd VSDBabySoC
  $ make pre_synth_sim
  ```
  
  The result of the simulation (i.e. `pre_synth_sim.vcd`) will be stored in the `output/pre_synth_sim` directory.

  4. You can see the waveforms with following command:

  ```
  $ gtkwave output/pre_synth_sim/pre_synth_sim.vcd
  ```
  
  Two most important signals are `CLK` and `OUT`. The `CLK` signal is provided by the PLL and the `OUT` is the output of the DAC model. Here is the final result of the modeling process:
  
  ![pre_synth_sim](images/pre_synth_sim.png)

In this picture we can see the following signals:

  * **CLK:** This is the `input CLK` signal of the `RVMYTH` core. This signal comes from the PLL, originally.
  * **reset:** This is the `input reset` signal of the `RVMYTH` core. This signal comes from an external source, originally.
  * **OUT:** This is the `output OUT` signal of the `VSDBabySoC` module. This signal comes from the DAC (due to simulation restrictions it behaves like a digital signal which is incorrect), originally.
  * **RV_TO_DAC[9:0]:** This is the 10-bit `output [9:0] OUT` port of the `RVMYTH` core. This port comes from the RVMYTH register #17, originally.
  * **OUT:** This is a `real` datatype wire which can simulate analog values. It is the `output wire real OUT` signal of the `DAC` module. This signal comes from the DAC, originally.

**PLEASE NOTE** that the sythesis process does not support `real` variables, so we must use the simple `wire` datatype for the `\vsdbabysoc.OUT` instead. The `iverilog` simulator always behaves `wire` as a digital signal. As a result we can not see the analog output via `\vsdbabysoc.OUT` port and we need to use `\dac.OUT` (which is a `real` datatype) instead.

# VSDBabySoC Physical Design

In integrated circuit design, physical design is a step in the standard design cycle which follows after the circuit design. At this step, circuit representations of the components (devices and interconnects) of the design are converted into geometric representations of shapes which, when manufactured in the corresponding layers of materials, will ensure the required functioning of the components. This geometric representation is called integrated circuit layout. This step is usually split into several sub-steps, which include both design and verification and validation of the layout.

  ![physical_design](images/physical_design.png)

## OpenLane installation

* OpenLANE is an automated RTL to GDSII flow based on several components including OpenROAD, Yosys, Magic, Netgen, Fault,SPEF-Extractor and custom methodology scripts for design exploration and optimization.

  ![openlane_flow](images/openlane_flow.png)

The OpenLANE and sky130 installation can be done by following the steps in this repository `https://github.com/nickson-jose/openlane_build_script`.

* More information on OpenLane can be found in the following repositories:

  * `https://github.com/The-OpenROAD-Project/OpenLane`
  * `https://github.com/efabless/openlane`

To summerize the installation processes:

  ```
  $ git clone https://github.com/The-OpenROAD-Project/OpenLane.git
  $ cd OpenLane/
  $ make openlane
  $ make pdk
  $ make test
  ```

For more info please refer to the GitHub repositories.

## Synthesizing using Yosys

* The first step in the design flow is to synthesize the generated RTL code.
* In OpenLane the RTL synthesis is performed by `yosys`.
* The technology mapping is performed by `abc`.
* Finally, the timing reports are generated for the resulting synthesized netlist by `OpenSTA`.

### How to synthesize the design

To perform the synthesis process do the following:

  ```
  $ cd ~/VSDBabySoC
  $ make synth
  ```

The heavy job will be done by the script. When the process has been done, you can see the result in the `output/synth/vsdbabysoc.synth.v` file.

### Post-synthesis simulation (GLS)

There is an issue for post-synthesis simulation (Gate-Level Simulation) which can be tracked [here](https://github.com/google/skywater-pdk/issues/310). However, we hacked the source-code by the following instructions and we managed to workaround the issue for now ([here is the reference](https://github.com/The-OpenROAD-Project/OpenLane/issues/518)):

  1. In `$YOUR_PDK_PATH/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v` file we should manually correct `endif SKY130_FD_SC_HD__LPFLOW_BLEEDER_FUNCTIONAL_V` to `endif //SKY130_FD_SC_HD__LPFLOW_BLEEDER_FUNCTIONAL_V`.
  2. We can simulate with the functional models by passing the `FUNCTIONAL` define to `iverilog`. Also we need to set `UNIT_DELAY` macro to some value. As a result we'll have `iverilog -DFUNCTIONAL -DUNIT_DELAY=#1 <THE SOURCE-CODEs TO BE COMPILED>`.

User could bypass these confusing steps by using our provided Makefile:

  ```
  $ cd ~/VSDBabySoC
  $ make post_synth_sim
  ```
The result of the simulation (i.e. `post_synth_sim.vcd`) will be stored in the `output/post_synth_sim` directory and the waveform could be seen by the following command:

  ```
  $ gtkwave output/post_synth_sim/post_synth_sim.vcd
  ```
Here is the final result:

  ![post_synth_sim](images/post_synth_sim.png)

In this picture we can see the following signals:

  * **\core.CLK:** This is the `input CLK` signal of the `RVMYTH` core. This signal comes from the PLL, originally.
  * **reset:** This is the `input reset` signal of the `RVMYTH` core. This signal comes from an external source, originally.
  * **OUT:** This is the `output OUT` signal of the `VSDBabySoC` module. This signal comes from the DAC (due to simulation restrictions it behaves like a digital signal which is incorrect), originally.
  * **\core.OUT[9:0]:** This is the 10-bit `output [9:0] OUT` port of the `RVMYTH` core. This port comes from the RVMYTH register #17, originally.
  * **OUT:** This is a `real` datatype wire which can simulate analog values. It is the `output wire real OUT` signal of the `DAC` module. This signal comes from the DAC, originally.

**PLEASE NOTE** that the sythesis process does not support `real` variables, so we must use the simple `wire` datatype for the `\vsdbabysoc.OUT` instead. The `iverilog` simulator always behaves `wire` as a digital signal. As a result we can not see the analog output via `\vsdbabysoc.OUT` port and we need to use `\dac.OUT` (which is a `real` datatype) instead.

### Yosys final report

  ```
  === vsdbabysoc ===

   Number of wires:               5559
   Number of wire bits:           5559
   Number of public wires:        1323
   Number of public wire bits:    1323
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:               5552
     avsddac                         1
     avsdpll1v8                      1
     sky130_fd_sc_hd__a211o_2        1
     sky130_fd_sc_hd__a21o_2         4
     sky130_fd_sc_hd__a21oi_2       19
     sky130_fd_sc_hd__a221o_2       56
     sky130_fd_sc_hd__a22o_2        32
     sky130_fd_sc_hd__a2bb2o_2      14
     sky130_fd_sc_hd__a2bb2oi_2     12
     sky130_fd_sc_hd__a311o_2        1
     sky130_fd_sc_hd__a31o_2         7
     sky130_fd_sc_hd__a31oi_2        3
     sky130_fd_sc_hd__a32o_2         8
     sky130_fd_sc_hd__a41o_2         1
     sky130_fd_sc_hd__and2_2        38
     sky130_fd_sc_hd__and3_2         5
     sky130_fd_sc_hd__and4b_2        1
     sky130_fd_sc_hd__buf_1        885
     sky130_fd_sc_hd__conb_1         6
     sky130_fd_sc_hd__dfxtp_2     1144
     sky130_fd_sc_hd__inv_2       1026
     sky130_fd_sc_hd__mux2_1       513
     sky130_fd_sc_hd__nand2_2        3
     sky130_fd_sc_hd__nand4_2       32
     sky130_fd_sc_hd__nor2_2        61
     sky130_fd_sc_hd__nor2b_2        1
     sky130_fd_sc_hd__nor4_2         2
     sky130_fd_sc_hd__o2111a_2       1
     sky130_fd_sc_hd__o2111ai_2     65
     sky130_fd_sc_hd__o211a_2        4
     sky130_fd_sc_hd__o21a_2         6
     sky130_fd_sc_hd__o21ai_2        9
     sky130_fd_sc_hd__o221a_2      955
     sky130_fd_sc_hd__o221ai_2       2
     sky130_fd_sc_hd__o22a_2       427
     sky130_fd_sc_hd__o2bb2a_2      23
     sky130_fd_sc_hd__o2bb2ai_2      2
     sky130_fd_sc_hd__o311a_2        2
     sky130_fd_sc_hd__o31a_2        10
     sky130_fd_sc_hd__o32a_2        15
     sky130_fd_sc_hd__or2_2         48
     sky130_fd_sc_hd__or2b_2        32
     sky130_fd_sc_hd__or3_2         35
     sky130_fd_sc_hd__or4_2         36
     sky130_fd_sc_hd__or4b_2         3

   Area for cell type \avsddac is unknown!
   Area for cell type \avsdpll1v8 is unknown!

   Chip area for module '\vsdbabysoc': 58173.292800
  ```

# Contributors

- [Mohammad A. Nili](https://github.com/manili), M.S. Student at SRBIAU

# Acknowledgements

- [Kunal Ghosh](https://github.com/kunalg123), Co-founder, VSD Corp. Pvt. Ltd.
- [Steve Hoover](https://github.com/stevehoover), Founder, Redwood EDA
- [Shivani Shah](https://github.com/shivanishah269), Research Scholar at IIIT Bangalore
