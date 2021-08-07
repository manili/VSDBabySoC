module vsdbabysoc (
   input  wire      PLL_VCO_IN,
   input  wire      PLL_VDDA,
   input  wire      PLL_VDDD,
   input  wire      PLL_VSSA,
   input  wire      PLL_VSSD,
   input  wire      PLL_EN_VCO,
   input  wire      PLL_REF,
   input  wire      reset,
   output wire      CLK,
   output wire real OUT
);

   //DAC
   wire [9:0] RVtoDAC;
   wire real  DAC_VSS;
   wire real  DAC_VDD;
   wire real  DAC_VREFH;
   wire real  DAC_VREFL;
   
   //DAC
   assign DAC_VREFH = 3.3;
   assign DAC_VREFL = 0.0;
   
   //PLL
   assign VDDA = 3.3;
   assign VDDD = 1.8;
   assign VSSA = 0.0;
   assign VSSD = 0.0;
   
   rvmyth core ( .clk(CLK), .reset(reset), .out(RVtoDAC) );
   avsddac dac ( .OUT(OUT), .D(RVtoDAC), .VREFH(DAC_VREFH), .VREFL(DAC_VREFL) );
   avsd_pll_1v8 pll ( .CLK(CLK), .VCO_IN(PLL_VCO_IN), .VDDA(PLL_VDDA), .VDDD(PLL_VDDD), 
      .VSSA(PLL_VSSA), .VSSD(PLL_VSSD), .EN_VCO(PLL_EN_VCO), .REF(PLL_REF) );
   
endmodule
