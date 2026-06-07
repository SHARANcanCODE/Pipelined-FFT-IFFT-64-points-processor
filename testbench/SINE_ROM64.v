`timescale 1ns / 1ps

module SINE_ROM64 ( ADDR, DATA_RE, DATA_IM, DATA_REF );

	input  [5:0]  ADDR;
	output [15:0] DATA_RE;
	output [15:0] DATA_IM;
	output [15:0] DATA_REF;

	// Signed 16-bit sine table, amplitude = 16383
	// One full cycle across 64 samples = complex tone at FFT bin 1
	// Amplitude chosen so output fits in 19-bit DOR:
	// peak = 16383 * 64 = 1,048,512
	// After 2 NORM_UNIT stages (each SHIFT=0 = divide by 2):
	// 1,048,512 / 4 = 262,128 < 262,143 (19-bit max)
	reg signed [15:0] sine[0:63];
	initial begin
		sine[ 0]=16'sh0000; sine[ 1]=16'sh0646; sine[ 2]=16'sh0C7C; sine[ 3]=16'sh1294;
		sine[ 4]=16'sh187E; sine[ 5]=16'sh1E2B; sine[ 6]=16'sh238E; sine[ 7]=16'sh2899;
		sine[ 8]=16'sh2D41; sine[ 9]=16'sh3178; sine[10]=16'sh3536; sine[11]=16'sh3871;
		sine[12]=16'sh3B20; sine[13]=16'sh3D3E; sine[14]=16'sh3EC4; sine[15]=16'sh3FB0;
		sine[16]=16'sh3FFF; sine[17]=16'sh3FB0; sine[18]=16'sh3EC4; sine[19]=16'sh3D3E;
		sine[20]=16'sh3B20; sine[21]=16'sh3871; sine[22]=16'sh3536; sine[23]=16'sh3178;
		sine[24]=16'sh2D41; sine[25]=16'sh2899; sine[26]=16'sh238E; sine[27]=16'sh1E2B;
		sine[28]=16'sh187E; sine[29]=16'sh1294; sine[30]=16'sh0C7C; sine[31]=16'sh0646;
		sine[32]=16'sh0000; sine[33]=-16'sh0646; sine[34]=-16'sh0C7C; sine[35]=-16'sh1294;
		sine[36]=-16'sh187E; sine[37]=-16'sh1E2B; sine[38]=-16'sh238E; sine[39]=-16'sh2899;
		sine[40]=-16'sh2D41; sine[41]=-16'sh3178; sine[42]=-16'sh3536; sine[43]=-16'sh3871;
		sine[44]=-16'sh3B20; sine[45]=-16'sh3D3E; sine[46]=-16'sh3EC4; sine[47]=-16'sh3FB0;
		sine[48]=-16'sh3FFF; sine[49]=-16'sh3FB0; sine[50]=-16'sh3EC4; sine[51]=-16'sh3D3E;
		sine[52]=-16'sh3B20; sine[53]=-16'sh3871; sine[54]=-16'sh3536; sine[55]=-16'sh3178;
		sine[56]=-16'sh2D41; sine[57]=-16'sh2899; sine[58]=-16'sh238E; sine[59]=-16'sh1E2B;
		sine[60]=-16'sh187E; sine[61]=-16'sh1294; sine[62]=-16'sh0C7C; sine[63]=-16'sh0646;
	end

	// Cosine = sine shifted by 16 samples (quarter period = 90 degrees)
	assign DATA_RE  = sine[(ADDR + 6'd16) & 6'd63];
	// Sine
	assign DATA_IM  = sine[ADDR];
	// Reference
	assign DATA_REF = sine[(ADDR + 6'd16) & 6'd63];

endmodule
