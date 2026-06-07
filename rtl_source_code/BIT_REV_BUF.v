`timescale 1 ns / 1 ps
`include "FFT64_CONFIG.inc"	 

module BIT_REV_BUF ( CLK ,RST ,ED ,START ,DR ,DI ,RDY ,DOR ,DOI );
	`FFT64_PARAMNB
	output RDY ;
	reg RDY ;
	output [nb-1:0] DOR ;
	wire [nb-1:0] DOR ;
	output [nb-1:0] DOI ;
	wire [nb-1:0] DOI ;

	input CLK ;
	wire CLK ;
	input RST ;
	wire RST ;
	input ED ;
	wire ED ;
	input START ;
	wire START ;
	input [nb-1:0] DR ;
	wire [nb-1:0] DR ;
	input [nb-1:0] DI ;
	wire [nb-1:0] DI ;

	wire odd, we;
	wire [5:0] addrw,addrr;
	reg [6:0] addr;
	reg [7:0] ct2;		

	always @(posedge CLK)	
		begin
			if (RST) begin
					addr<=6'b000000;
					ct2<= 7'b1000001;  
				RDY<=1'b0; end
			else if (START) begin 
					addr<=6'b000000;
					ct2<= 6'b000000;  
				RDY<=1'b0;end
			else if (ED)	begin
					RDY<=1'b0;
					addr<=addr+1; 
					if (ct2!=65) 
					ct2<=ct2+1;
					if (ct2==64) 
					RDY<=1'b1;
				end 
		end

assign	addrw=	addr[5:0];
assign	odd=addr[6];	   			
assign	addrr={addr[2 : 0], addr[5 : 3]};	  
assign	we = ED;	  

	DUAL_RAM64 #(nb)	URAM(.CLK(CLK),.ED(ED),.WE(we),.ODD(odd),
	.ADDRW(addrw),	.ADDRR(addrr),
	.DR(DR),.DI(DI),
	.DOR(DOR),	.DOI(DOI));	   

endmodule
