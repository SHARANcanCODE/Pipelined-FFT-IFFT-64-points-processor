`timescale 1ps / 1ps
`include "FFT64_CONFIG.inc"	 

module TWIDDLE_ROT (CLK ,RST,ED,START, DR,DI, DOR, DOI,RDY  );
	`FFT64_PARAMNB	
	`FFT64_PARAMNW	

	input RST ;
	wire RST ;
	input CLK ;
	wire CLK ;
	input ED ; 
	input [nb+1:0] DI;  
	wire [nb+1:0]  DI ;
	input [nb+1:0]  DR ; 
	input START ;		   
	wire START ;

	output [nb+1:0]  DOI ; 
	wire [nb+1:0]  DOI ;
	output [nb+1:0]  DOR ; 
	wire [nb+1:0]  DOR ;
	output RDY ;	   
	reg RDY ;		 

	reg [5:0] addrw;
	reg sd1,sd2;
	always	@( posedge CLK)	  
		begin
			if (RST) begin
					addrw<=0;
					sd1<=0;
					sd2<=0;
				end
			else if (START && ED)  begin
					addrw[5:0]<=0;
					sd1<=START;
					sd2<=0;		 
				end
			else if (ED) 	  begin
					addrw<=addrw+1; 
					sd1<=START;
					sd2<=sd1;
					RDY<=sd2;	 
				end
		end			  

		wire signed [nw-1:0] wr,wi; 

	COEF_ROM UROM( .ADDR(addrw),	.WR(wr),.WI(wi) );	

	reg signed [nb+1 : 0] drd,did;
	reg signed [nw-1 : 0] wrd,wid;
	wire signed [nw+nb+1 : 0] drri,drii,diri,diii;
	reg signed [nb+2:0] drr,dri,dir,dii,dwr,dwi;

	assign  	drri=drd*wrd;  
	assign	diri=did*wrd;  
	assign	drii=drd*wid;
	assign	diii=did*wid;  

	always @(posedge CLK)	 
		begin
			if (ED) begin	
					drd<=DR;
					did<=DI;
					wrd<=wr;
					wid<=wi;
					drr<=drri[nw+nb+1 :nw-1]; 
					dri<=drii[nw+nb+1 : nw-1];
					dir<=diri[nw+nb+1 : nw-1];
					dii<=diii[nw+nb+1 : nw-1];
					dwr<=drr - dii;				
					dwi<=dri + dir;  
				end	 
		end 		
	assign DOR=dwr[nb+2:1];       
	assign DOI=dwi[nb+2 :1];

endmodule
