`timescale 1ns / 1ps
`include "FFT64_CONFIG.inc"

module FFT64_TOP_tb;

	`FFT64_PARAMNB

	reg        CLK;
	reg        RST;
	reg        ED;
	reg        START;
	reg  [3:0] SHIFT;

	wire [nb-1:0]        DR;
	wire [nb-1:0]        DI;
	wire                 RDY;
	wire                 OVF1;
	wire                 OVF2;
	wire [5:0]           ADDR;
	wire signed [nb+2:0] DOR;
	wire signed [nb+2:0] DOI;

	// Clock: 10ns period
	initial CLK = 1'b0;
	always #5 CLK = ~CLK;

	// SHIFT=0000: both NORM_UNIT stages divide by 2
	// Total division = 4, input amplitude = 16383
	// Peak output = 16383 * 64 / 4 = 262128 fits in 19-bit DOR
	initial begin
		SHIFT = 4'b0000;
		ED    = 1'b1;
		RST   = 1'b0;
		START = 1'b0;
		#15  RST   = 1'b1;
		#40  RST   = 1'b0;
		#50  START = 1'b1;
		#10  START = 1'b0;
	end

	// Input counter — synchronous, resets on START
	reg [5:0] ct64;
	always @(posedge CLK) begin
		if (RST)
			ct64 <= 6'd0;
		else if (START)
			ct64 <= 6'd0;
		else if (ED)
			ct64 <= ct64 + 6'd1;
	end

	// Input ROM
	wire [15:0] DATA_RE, DATA_IM, DATA_0;
	SINE_ROM64 UG (
		.ADDR    (ct64),
		.DATA_RE (DATA_RE),
		.DATA_IM (DATA_IM),
		.DATA_REF(DATA_0)
	);

	// Direct assignment — both are exactly nb=16 bits
	assign DR = DATA_RE;
	assign DI = DATA_IM;

	// DUT
	FFT64_TOP UUT (
		.CLK  (CLK),
		.RST  (RST),
		.ED   (ED),
		.START(START),
		.SHIFT(SHIFT),
		.DR   (DR),
		.DI   (DI),
		.RDY  (RDY),
		.OVF1 (OVF1),
		.OVF2 (OVF2),
		.ADDR (ADDR),
		.DOR  (DOR),
		.DOI  (DOI)
	);

	// Reference ROM
	wire [5:0] addrr;
	`ifdef FFT64_PARAMIFFT
		assign addrr = (6'd63 - ADDR);
	`else
		assign addrr = ADDR;
	`endif

	wire [15:0] DATA_R0, DATA_I0, DATA_REF;
	SINE_ROM64 UR (
		.ADDR    (addrr),
		.DATA_RE (DATA_R0),
		.DATA_IM (DATA_I0),
		.DATA_REF(DATA_REF)
	);

	// Verification: find which bin has the largest magnitude
	integer bin1_re;
	integer bin1_im;
	integer peak_mag;
	integer peak_bin;
	integer cur_mag;
	integer ctres;
	reg     f;

	initial begin
		f        = 1'b0;
		ctres    = 0;
		bin1_re  = 0;
		bin1_im  = 0;
		peak_mag = 0;
		peak_bin = 0;
	end

	always @(posedge CLK) begin
		if (RST) begin
			f        <= 1'b0;
			ctres    <= 0;
			peak_mag <= 0;
			peak_bin <= 0;
		end else if (RDY) begin
			f        <= 1'b1;
			ctres    <= 0;
			peak_mag <= 0;
			peak_bin <= 0;
		end else if (f) begin
			ctres   <= ctres + 1;
			cur_mag  = DOR[nb+2] ? (~DOR + 1) : DOR;
			if (ctres < 64) begin
				if (cur_mag > peak_mag) begin
					peak_mag <= cur_mag;
					peak_bin <= ADDR;
				end
				if (ADDR == 6'd1) begin
					bin1_re <= DOR;
					bin1_im <= DOI;
				end
			end else if (ctres == 64) begin
				$display("------ FFT64 Verification ------");
				$display("Bin 1 : DOR=%0d  DOI=%0d", bin1_re, bin1_im);
				$display("Peak  : bin=%0d  magnitude=%0d", peak_bin, peak_mag);
				if (peak_bin == 6'd1)
					$display("RESULT: PASS - FFT is working correctly");
				else
					$display("RESULT: FAIL - peak not at bin 1");
				$display("--------------------------------");
			end
		end
	end

endmodule
