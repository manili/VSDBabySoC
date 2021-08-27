`timescale 1ns / 1ps
`ifdef PRE_SYNTH_SIM
   `include "vsdbabysoc.v"
   `include "avsddac.v"
   `include "avsd_pll_1v8.v"
   `include "rvmyth.v"
   `include "clk_gate.v"
`elsif POST_SYNTH_SIM
   `include "vsdbabysoc.synth.v"
   `include "avsddac.v"
   `include "avsd_pll_1v8.v"
   `include "primitives.v"
   `include "sky130_fd_sc_hd.v"
`endif

module vsdbabysoc_tb;
   reg       reset;
   reg  real DAC_VREFH;
   reg  real DAC_VREFL;
   reg       PLL_VCO_IN;
   reg       PLL_VDDA;
   reg       PLL_VDDD;
   reg       PLL_VSSA;
   reg       PLL_VSSD;
   reg       PLL_EN_VCO;
   reg       PLL_REF;
   wire real OUT;

   vsdbabysoc uut (
      .OUT(OUT),
      .reset(reset),
      .DAC_VREFH(DAC_VREFH),
      .DAC_VREFL(DAC_VREFL),
      .PLL_VCO_IN(PLL_VCO_IN),
      .PLL_VDDA(PLL_VDDA),
      .PLL_VDDD(PLL_VDDD),
      .PLL_VSSA(PLL_VSSA),
      .PLL_VSSD(PLL_VSSD), 
      .PLL_EN_VCO(PLL_EN_VCO),
      .PLL_REF(PLL_REF)
   );

   initial begin
      reset = 0;
      DAC_VREFH = 3.3;
      DAC_VREFL = 0.0;
      {PLL_REF, PLL_EN_VCO} = 0;
      PLL_VCO_IN = 1'b0 ;
      PLL_VDDA = 1.8;
      PLL_VDDD = 1.8;
      PLL_VSSA = 0.0;
      PLL_VSSD = 0.0;
      
      #20 reset = 1;
      #100 reset = 0;
   end
   
   initial
   begin
`ifdef PRE_SYNTH_SIM
      $dumpfile("pre_synth_sim.vcd");
`elsif POST_SYNTH_SIM
      $dumpfile("post_synth_sim.vcd");
`endif
      $dumpvars(0, vsdbabysoc_tb);
   end
 
   initial begin
      repeat(600) begin
         PLL_EN_VCO = 1;
         #100 PLL_REF = ~PLL_REF;
         #(83.33/2) PLL_VCO_IN = ~PLL_VCO_IN;
      end
      $finish;
   end
   
endmodule