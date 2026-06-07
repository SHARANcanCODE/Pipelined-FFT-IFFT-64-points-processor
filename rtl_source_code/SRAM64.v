`timescale 1 ns / 1 ps
`include "FFT64_CONFIG.inc"	 

module SRAM64 ( CLK, ED,WE ,ADDR ,DI ,DO );
	`FFT64_PARAMNB	

	output [nb-1:0] DO ;
	reg [nb-1:0] DO ;
	input CLK ;
	wire CLK ;	 
	input ED;
	input WE ;
	wire WE ;
	input [5:0] ADDR ;
	wire [5:0] ADDR ;
	input [nb-1:0] DI ;
	wire [nb-1:0] DI ;
	reg [nb-1:0] mem [63:0];
	reg [5:0] addrrd;		  

	always @(posedge CLK) begin
			if (ED) begin
					if (WE)		mem[ADDR] <= DI;
					addrrd <= ADDR;	         
					DO <= mem[addrrd];	   
				end	  
		end

endmodule
