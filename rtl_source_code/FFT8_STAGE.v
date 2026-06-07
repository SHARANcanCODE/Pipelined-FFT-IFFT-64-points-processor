`timescale 1ps / 1ps
`include "FFT64_CONFIG.inc"

module FFT8_STAGE ( DOR ,DII ,RST ,ED ,CLK ,DOI ,START ,DIR ,RDY );
	`FFT64_PARAMNB

	input ED ;
	wire ED ;
	input RST ;
	wire RST ;
	input CLK ;
	wire CLK ;
	input [nb-1:0] DII ;
	wire [nb-1:0] DII ;
	input START ;
	wire START ;
	input [nb-1:0] DIR ;
	wire [nb-1:0] DIR ;

	output [nb+2:0] DOI ;
	wire [nb+2:0] DOI ;
	output [nb+2:0] DOR ;
	wire [nb+2:0] DOR ;
	output RDY ;
	reg RDY ;

	reg [2:0] ct;
	reg [3:0] ctd;

	always @(posedge CLK) begin
		if (RST) begin
			ct  <= 0;
			ctd <= 15;
			RDY <= 0;
		end else if (START) begin
			ct  <= 0;
			ctd <= 0;
			RDY <= 0;
		end else if (ED) begin
			RDY <= 0;
			ct  <= ct + 1;
			if (ctd != 4'b1111)
				ctd <= ctd + 1;
			if (ctd == 12)
				RDY <= 1;
		end
	end

	reg signed [nb-1:0] dr,d1r,d2r,d3r,d4r,di,d1i,d2i,d3i,d4i;
	always @(posedge CLK) begin
		if (ED) begin
			dr  <= DIR;
			d1r <= dr;
			d2r <= d1r;
			d3r <= d2r;
			d4r <= d3r;
			di  <= DII;
			d1i <= di;
			d2i <= d1i;
			d3i <= d2i;
			d4i <= d3i;
		end
	end

	reg signed [nb:0] s1r,s2r,s1d1r,s1d2r,s1d3r,s2d1r,s2d2r,s2d3r;
	reg signed [nb:0] s1i,s2i,s1d1i,s1d2i,s1d3i,s2d1i,s2d2i,s2d3i;
	always @(posedge CLK) begin
		if (ED && ((ct==5) || (ct==6) || (ct==7) || (ct==0))) begin
			s1r <= d4r + dr;
			s1i <= d4i + di;
			s2r <= d4r - dr;
			s2i <= d4i - di;
		end
		if (ED) begin
			s1d1r <= s1r;
			s1d2r <= s1d1r;
			s1d1i <= s1i;
			s1d2i <= s1d1i;
			if (ct==0 || ct==1) begin
				s1d3r <= s1d2r;
				s1d3i <= s1d2i;
			end
			if (ct==6 || ct==7 || ct==0) begin
				s2d1r <= s2r;
				s2d2r <= s2d1r;
				s2d1i <= s2i;
				s2d2i <= s2d1i;
			end
			if (ct==0) begin
				s2d3r <= s2d2r;
				s2d3i <= s2d2i;
			end
		end
	end

	reg signed [nb+1:0] s3r,s4r,s3d1r,s3d2r,s3d3r;
	reg signed [nb+1:0] s3i,s4i,s3d1i,s3d2i,s3d3i;
	always @(posedge CLK) begin
		if (ED)
			case (ct)
				0: begin s3r <= s1d2r + s1r;  s3i <= s1d2i + s1i; end
				1: begin s3r <= s1d3r - s1d1r; s3i <= s1d3i - s1d1i; end
				2: begin s3r <= s1d3r + s1r;  s3i <= s1d3i + s1i; end
				3: begin s3r <= s1d3r - s1r;  s3i <= s1d3i - s1i; end
			endcase
		if (ED) begin
			if (ct==1 || ct==2 || ct==3) begin
				s3d1r <= s3r;
				s3d1i <= s3i;
			end
			if (ct==2 || ct==3) begin
				s3d2r <= s3d1r;
				s3d3r <= s3d2r;
				s3d2i <= s3d1i;
				s3d3i <= s3d2i;
			end
		end
	end

	always @(posedge CLK) begin
		if (ED) begin
			if (ct==1) begin
				s4r <= s2d2r + s2r;
				s4i <= s2d2i + s2i;
			end else if (ct==2) begin
				s4r <= s2d2r - s2r;
				s4i <= s2d2i - s2i;
			end
		end
	end

	wire em;
	assign em = ((ct==2 || ct==3 || ct==4) && ED);

	wire signed [nb+1:0] m4m7r, m4m7i;
	CMPLX_MUL #(nb) UMR (.CLK(CLK), .EI(em), .DI(s4r), .DO(m4m7r));
	CMPLX_MUL #(nb) UMI (.CLK(CLK), .EI(em), .DI(s4i), .DO(m4m7i));

	reg signed [nb+1:0] sjr,sji,m6r,m6i;
	always @(posedge CLK) begin
		if (ED) begin
			case (ct)
				3: begin sjr <= s2d1i;    sji <= 0 - s2d1r; end
				4: begin sjr <= m4m7i;    sji <= 0 - m4m7r; end
				6: begin sjr <= s3i;      sji <= 0 - s3r;   end
			endcase
			if (ct==4) begin
				m6r <= sjr;
				m6i <= sji;
			end
		end
	end

	reg signed [nb+2:0] s5r,s5d1r,s5d2r,q1r;
	reg signed [nb+2:0] s5i,s5d1i,s5d2i,q1i;
	always @(posedge CLK)
		if (ED)
			case (ct)
				5: begin
					q1r <= s2d3r + m4m7r;
					q1i <= s2d3i + m4m7i;
					s5r <= m6r + sjr;
					s5i <= m6i + sji;
				end
				6: begin
					s5r   <= m6r - sjr;
					s5i   <= m6i - sji;
					s5d1r <= s5r;
					s5d1i <= s5i;
				end
				7: begin
					s5r   <= s2d3r - m4m7r;
					s5i   <= s2d3i - m4m7i;
					s5d1r <= s5r;
					s5d1i <= s5i;
					s5d2r <= s5d1r;
					s5d2i <= s5d1i;
				end
			endcase

	reg signed [nb+3:0] s6r,s6i;

	`ifdef FFT64_PARAMIFFT
	always @(posedge CLK) begin
		if (ED)
			case (ct)
				5: begin s6r <= s3d3r + s3d1r; s6i <= s3d3i + s3d1i; end
				6: begin s6r <= q1r - s5r;     s6i <= q1i - s5i;     end
				7: begin s6r <= s3d2r - sjr;   s6i <= s3d2i - sji;   end
				0: begin s6r <= s5r + s5d1r;   s6i <= s5i + s5d1i;   end
				1: begin s6r <= s3d3r - s3d1r; s6i <= s3d3i - s3d1i; end
				2: begin s6r <= s5r - s5d1r;   s6i <= s5i - s5d1i;   end
				3: begin s6r <= s3d3r + sjr;   s6i <= s3d3i + sji;   end
				4: begin s6r <= q1r + s5d2r;   s6i <= q1i + s5d2i;   end
			endcase
	end
	`else
	always @(posedge CLK) begin
		if (ED)
			case (ct)
				5: begin s6r <= s3d3r + s3d1r; s6i <= s3d3i + s3d1i; end
				6: begin s6r <= q1r + s5r;     s6i <= q1i + s5i;     end
				7: begin s6r <= s3d2r + sjr;   s6i <= s3d2i + sji;   end
				0: begin s6r <= s5r - s5d1r;   s6i <= s5i - s5d1i;   end
				1: begin s6r <= s3d3r - s3d1r; s6i <= s3d3i - s3d1i; end
				2: begin s6r <= s5r + s5d1r;   s6i <= s5i + s5d1i;   end
				3: begin s6r <= s3d3r - sjr;   s6i <= s3d3i - sji;   end
				4: begin s6r <= q1r - s5d2r;   s6i <= q1i - s5d2i;   end
			endcase
	end
	`endif

	assign #1 DOR = s6r[nb+2:0];
	assign #1 DOI = s6i[nb+2:0];

endmodule
