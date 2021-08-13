`timescale 1ns / 1ps
`undef post_synth_sim
`define pre_synth_sim

`include "vsdbabysoc.v"
`include "avsddac.v"
`include "avsd_pll_1v8.v"
`include "rvmyth.v"
`include "clk_gate.v"

module vsdbabysoc_tb;
   reg       PLL_VCO_IN;
   reg       PLL_VDDA;
   reg       PLL_VDDD;
   reg       PLL_VSSA;
   reg       PLL_VSSD;
   reg       PLL_EN_VCO;
   reg       PLL_REF;
   
   reg       reset;
   wire      CLK;
   wire real OUT;


   vsdbabysoc uut ( .PLL_VCO_IN(PLL_VCO_IN), .PLL_VDDA(PLL_VDDA), .PLL_VDDD(PLL_VDDD), .PLL_VSSA(PLL_VSSA), .PLL_VSSD(PLL_VSSD), 
      .PLL_EN_VCO(PLL_EN_VCO), .PLL_REF(PLL_REF), .reset(reset), .CLK(CLK), .OUT(OUT) );

   initial begin
      {PLL_REF, PLL_EN_VCO} = 0;
      PLL_VCO_IN = 1'b0 ;
      PLL_VDDA = 1.8;
      PLL_VDDD = 1.8;
      PLL_VSSA = 0.0;
      PLL_VSSD = 0.0;
      reset = 0;
      #20 reset = 1;
      #100 reset = 0;
   end
   
   initial
   begin
      $dumpfile("pre_synth_sim.vcd");
      $dumpvars(0, vsdbabysoc_tb);
   end
 
   initial begin
      repeat(400) begin
         PLL_EN_VCO = 1;
         #100 PLL_REF = ~PLL_REF;
         #(83.33/2) PLL_VCO_IN = ~PLL_VCO_IN;
      end
      $finish;
   end
   
endmodule