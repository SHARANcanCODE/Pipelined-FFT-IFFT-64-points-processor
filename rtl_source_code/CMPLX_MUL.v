`include "FFT64_CONFIG.inc"

module CMPLX_MUL ( CLK ,DO ,DI ,EI );
`FFT64_PARAMNB 

	input CLK ;
	wire CLK ;
	input [nb+1:0] DI ;
	wire signed [nb+1:0] DI ;
	input EI ;
	wire EI ;

	output [nb+1:0] DO ;
	reg [nb+1:0] DO ;	 

	reg signed [nb+5 :0] dx5;	 
	reg signed	[nb+2 : 0] dt;		   
	wire signed [nb+6 : 0]  dx5p; 
	wire  signed  [nb+6 : 0] dot;	

	always @(posedge CLK)
		begin
			if (EI) begin
					dx5<=DI+(DI <<2);	 
					dt<=DI;		  
					DO<=dot >>>4;	
				end 
		end		 

	`ifdef FFT64_BITWIDTH_HIGH
	assign   dot=	(dx5p+(dt>>>4)+(dx5>>>12));	   
	`else	                               
	assign    dot=		(dx5p+(dt>>>4) )	;  
	`endif	 	

		assign	dx5p=(dx5<<1)+(dx5>>>2);		

endmodule
