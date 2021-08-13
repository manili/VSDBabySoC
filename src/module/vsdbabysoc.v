module vsdbabysoc (
   input  wire      reset,
   output wire      CLK,
`ifdef pre_synth_sim
   input  wire real PLL_VCO_IN,
   input  wire real PLL_VDDA,
   input  wire real PLL_VDDD,
   input  wire real PLL_VSSA,
   input  wire real PLL_VSSD,
   input  wire real PLL_EN_VCO,
   input  wire real PLL_REF,
   output wire real OUT
`else
   input  wire      PLL_VCO_IN,
   input  wire      PLL_VDDA,
   input  wire      PLL_VDDD,
   input  wire      PLL_VSSA,
   input  wire      PLL_VSSD,
   input  wire      PLL_EN_VCO,
   input  wire      PLL_REF,
   output wire      OUT
`endif
);

   //DAC
   wire [9:0] RVtoDAC;
`ifdef pre_synth_sim
   wire real  DAC_VSS;
   wire real  DAC_VDD;
   wire real  DAC_VREFH;
   wire real  DAC_VREFL;
`else
   wire       DAC_VSS;
   wire       DAC_VDD;
   wire       DAC_VREFH;
   wire       DAC_VREFL;
`endif
   
   //DAC
   assign DAC_VREFH = 3.3;
   assign DAC_VREFL = 0.0;
   
   rvmyth core ( .clk(CLK), .reset(reset), .out(RVtoDAC) );
   avsddac dac ( .OUT(OUT), .D(RVtoDAC), .VREFH(DAC_VREFH), .VREFL(DAC_VREFL) );
   avsd_pll_1v8 pll ( .CLK(CLK), .VCO_IN(PLL_VCO_IN), .VDDA(PLL_VDDA), .VDDD(PLL_VDDD), 
      .VSSA(PLL_VSSA), .VSSD(PLL_VSSD), .EN_VCO(PLL_EN_VCO), .REF(PLL_REF) );
   
endmodule
