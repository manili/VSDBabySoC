module vsdbabysoc (
   output wire OUT,
   input  wire reset,
   input  wire DAC_VREFH,
   input  wire DAC_VREFL,
   input  wire PLL_VCO_IN,
   input  wire PLL_VDDA,
   input  wire PLL_VDDD,
   input  wire PLL_VSSA,
   input  wire PLL_VSSD,
   input  wire PLL_EN_VCO,
   input  wire PLL_REF
);

   wire CLK;
   wire [9:0] RV_TO_DAC;

   avsd_pll_1v8 pll (
      .CLK(CLK),
      .VCO_IN(PLL_VCO_IN),
      .VDDA(PLL_VDDA),
      .VDDD(PLL_VDDD), 
      .VSSA(PLL_VSSA),
      .VSSD(PLL_VSSD),
      .EN_VCO(PLL_EN_VCO),
      .REF(PLL_REF)
   );

   rvmyth core (
      .OUT(RV_TO_DAC),
      .CLK(CLK),
      .reset(reset)
   );

   avsddac dac (
      .OUT(OUT),
      .D(RV_TO_DAC),
      .VREFH(DAC_VREFH),
      .VREFL(DAC_VREFL)
   );
   
endmodule
