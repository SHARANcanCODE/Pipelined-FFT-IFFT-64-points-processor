`timescale 1 ns / 1 ps
`include "FFT64_CONFIG.inc"	 

module FFT64_TOP ( CLK ,RST ,ED ,START ,SHIFT ,DR ,DI ,RDY ,OVF1 ,OVF2 ,ADDR ,DOR ,DOI );
	`FFT64_PARAMNB		  	 		

	output RDY ;   			
	wire RDY ;
	output OVF1 ;			
	wire OVF1 ;
	output OVF2 ;			
	wire OVF2 ;
	output [5:0] ADDR ;	
	wire [5:0] ADDR ;
	output [nb+2:0] DOR ;
	wire [nb+2:0] DOR ;	 
	output [nb+2:0] DOI ;
	wire [nb+2:0] DOI ;

	input CLK ;        			
	wire CLK ;
	input RST ;				
	wire RST ;
	input ED ;					
	wire ED ;
	input START ;  			
	wire START ;			 	
	input [3:0] SHIFT ;		
	wire [3:0] SHIFT ;	   	
	input [nb-1:0] DR ;		
	wire [nb-1:0] DR ;	    
	input [nb-1:0] DI ;		
	wire [nb-1:0] DI ;

	wire [nb-1:0] dr1,di1;
	wire [nb+1:0] dr3,di3,dr4,di4, dr5,di5 ;
	wire [nb+2:0] dr2,di2;
	wire [nb+4:0] dr6,di6; 	
	wire [nb+2:0] dr7,di7,dr8,di8;   
	wire rdy1,rdy2,rdy3,rdy4,rdy5,rdy6,rdy7,rdy8;			 
	reg [5:0] addri ;

	BIT_REV_BUF #(nb) U_BUF1(.CLK(CLK), .RST(RST), .ED(ED),	.START(START),
	.DR(DR),	.DI(DI),			.RDY(rdy1),	.DOR(dr1), .DOI(di1));	   

	FFT8_STAGE #(nb) U_FFT1(.CLK(CLK), .RST(RST), .ED(ED),
		.START(rdy1),.DIR(dr1),.DII(di1),
		.RDY(rdy2),	.DOR(dr2),.	DOI(di2));	

	wire	[1:0] shiftl=	 SHIFT[1:0]; 
	NORM_UNIT #(nb) U_NORM1( .CLK(CLK),	.ED(ED),  
		.START(rdy2),	
		.DR(dr2),	.DI(di2),
		.SHIFT(shiftl), 
		.OVF(OVF1),
		.RDY(rdy3),
		.DOR(dr3),.DOI(di3));	

	TWIDDLE_ROT U_MPU (.CLK(CLK),.RST(RST),.ED(ED),
		.START(rdy3),. DR(dr3),.DI(di3),
		.RDY(rdy4), .DOR(dr4),	.DOI(di4));

	BIT_REV_BUF #(nb+2) U_BUF2(.CLK(CLK),.RST(RST),.ED(ED),	
		.START(rdy4),. DR(dr4),.DI(di4),
		.RDY(rdy5), .DOR(dr5),	.DOI(di5));	 

	FFT8_STAGE #(nb+2) U_FFT2(.CLK(CLK), .RST(RST), .ED(ED),
		.START(rdy5),. DIR(dr5),.DII(di5),
		.RDY(rdy6), .DOR(dr6),	.DOI(di6));

	wire	[1:0] shifth=	 SHIFT[3:2]; 

	NORM_UNIT #(nb+2) U_NORM2 ( .CLK(CLK),	.ED(ED),
		.START(rdy6),	
		.DR(dr6),	.DI(di6),
		.SHIFT(shifth), 
		.OVF(OVF2),
		.RDY(rdy7),
		.DOR(dr7),	.DOI(di7));

		BIT_REV_BUF  #(nb+3) 	Ubuf3(.CLK(CLK),.RST(RST),.ED(ED),	
		.START(rdy7),. DR(dr7),.DI(di7),
		.RDY(rdy8), .DOR(dr8),	.DOI(di8));	 	

	`ifdef FFT64_BUFFERS3  	 	
	always @(posedge CLK)	begin	
			if (RST)
				addri<=6'b000000;
			else if (rdy8==1 )  
				addri<=6'b000000;
			else if (ED)
				addri<=addri+1; 
		end

		assign ADDR=  addri ;
	assign	DOR=dr8;
	assign	DOI=di8;
	assign	RDY=rdy8;	

	`else
	 	always @(posedge CLK)	begin	
			if (RST)
				addri<=6'b000000;
			else if (rdy7) 
				addri<=6'b000000;
			else if (ED)
				addri<=addri+1; 
		end	  
	assign ADDR=  {addri[2:0] , addri[5:3]} ;
	assign	DOR= dr7;
	assign	DOI= di7;
	assign	RDY= rdy7;	
	`endif	
endmodule
