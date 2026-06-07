`timescale 1 ns / 1 ps
`include "FFT64_CONFIG.inc"	 

module DUAL_RAM64 ( CLK ,ED ,WE ,ODD ,ADDRW ,ADDRR ,DR ,DI ,DOR ,DOI );
	`FFT64_PARAMNB	

	output [nb-1:0] DOR ;
	wire [nb-1:0] DOR ;
	output [nb-1:0] DOI ;
	wire [nb-1:0] DOI ;
	input CLK ;
	wire CLK ;
	input ED ;
	wire ED ;
	input WE ;	     
	wire WE ;
	input ODD ;	  
	wire ODD ;
	input [5:0] ADDRW ;
	wire [5:0] ADDRW ;
	input [5:0] ADDRR ;
	wire [5:0] ADDRR ;
	input [nb-1:0] DR ;
	wire [nb-1:0] DR ;
	input [nb-1:0] DI ;
	wire [nb-1:0] DI ;	

	reg	oddd,odd2;
	always @( posedge CLK) begin 
			if (ED)	begin
					oddd<=ODD;
					odd2<=oddd;
				end
		end 
	`ifdef 	FFT64_BUFPORTS1

	wire we0,we1;
	wire	[nb-1:0] dor0,dor1,doi0,doi1;
	wire	[5:0] addr0,addr1;		   

	assign	addr0 =ODD?  ADDRW: ADDRR;		
	assign	addr1 = ~ODD? ADDRW:ADDRR;	
	assign	we0   =ODD?  WE: 0;		     
	assign	we1   =~ODD? WE: 0;			 

	SRAM64 #(nb) URAM0(.CLK(CLK),.ED(ED),.WE(we0), .ADDR(addr0),.DI(DR),.DO(dor0)); 
	SRAM64 #(nb) URAM1(.CLK(CLK),.ED(ED),.WE(we0), .ADDR(addr0),.DI(DI),.DO(doi0));	 

	SRAM64 #(nb) URAM2(.CLK(CLK),.ED(ED),.WE(we1), .ADDR(addr1),.DI(DR),.DO(dor1));
	SRAM64 #(nb) URAM3(.CLK(CLK),.ED(ED),.WE(we1), .ADDR(addr1),.DI(DI),.DO(doi1));		

	assign	DOR=~odd2? dor0 : dor1;		 
	assign	DOI=~odd2? doi0 : doi1;	

	`else 		

	wire [6:0] addrr2 = {ODD,ADDRR};
	wire [6:0] addrw2 = {~ODD,ADDRW};
	wire [2*nb-1:0] di= {DR,DI} ;	
	wire [2*nb-1:0] doi;	

	reg [2*nb-1:0] ram [127:0];
	reg [6:0] read_addra;
	always @(posedge CLK) begin
			if (ED)
				begin
					if (WE)
						ram[addrw2] <= di;
					read_addra <= addrr2;
				end
		end
	assign doi = ram[read_addra];				 

	assign	DOR=doi[2*nb-1:nb];		 
	assign	DOI=doi[nb-1:0];		 

	`endif 	
endmodule
