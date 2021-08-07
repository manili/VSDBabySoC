`timescale 1ns / 1ps

module vsdbabysoc_tb;
   reg VSSD;
   reg EN_VCO;
   reg VSSA;
   reg VDDD;
   reg VDDA;
   reg VCO_IN;
   reg REF;
   
   reg       reset;
   wire      CLK;
   wire real OUT;


   vsdbabysoc uut ( .PLL_VCO_IN(VCO_IN), .PLL_VDDA(VDDA), .PLL_VDDD(VDDD), .PLL_VSSA(VSSA), .PLL_VSSD(VSSD), 
      .PLL_EN_VCO(EN_VCO), .PLL_REF(REF), .reset(reset), .CLK(CLK), .OUT(OUT) );

   initial begin
      {REF,EN_VCO} = 0;
      VCO_IN = 1'b0 ;
      VDDA = 1.8;
      VDDD = 1.8;
      VSSA = 0;
      VSSD = 0;
      reset = 0;
      #20 reset = 1;
      #100 reset = 0;
   end
   
   initial
   begin
      $dumpfile("vsdbabysoc.vcd");
      $dumpvars(0, vsdbabysoc_tb);
   end
 
   initial begin
      repeat(400) begin
         EN_VCO = 1;
         #100 REF = ~REF;
         #(83.33/2)  VCO_IN = ~VCO_IN;
      end
      $finish;
   end
   
endmodule
