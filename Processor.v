module Processor (
  
	//////////// ADC //////////
	// output		          		ADC_CONVST,
	// output		          		ADC_DIN,
	// input 		          		ADC_DOUT,
	// output		          		ADC_SCLK,

	//////////// Audio //////////
	// input 		          		AUD_ADCDAT,
	// inout 		          		AUD_ADCLRCK,
	// inout 		          		AUD_BCLK,
	// output		          		AUD_DACDAT,
	// inout 		          		AUD_DACLRCK,
	// output		          		AUD_XCK,

	//////////// CLOCK //////////
	// input 		          		CLOCK2_50,
	// input 		          		CLOCK3_50,
	// input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	// output		    [12:0]		DRAM_ADDR,
	// output		     [1:0]		DRAM_BA,
	// output		          		DRAM_CAS_N,
	// output		          		DRAM_CKE,
	// output		          		DRAM_CLK,
	// output		          		DRAM_CS_N,
	// inout 		    [15:0]		DRAM_DQ,
	// output		          		DRAM_LDQM,
	// output		          		DRAM_RAS_N,
	// output		          		DRAM_UDQM,
	// output		          		DRAM_WE_N,

	//////////// I2C for Audio and Video-In //////////
	// output		          		FPGA_I2C_SCLK,
	// inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// IR //////////
	// input 		          		IRDA_RXD,
	// output		          		IRDA_TXD,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// PS2 //////////
	// inout 		          		PS2_CLK,
	// inout 		          		PS2_CLK2,
	// inout 		          		PS2_DAT,
	// inout 		          		PS2_DAT2,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// Video-In //////////
	// input 		          		TD_CLK27,
	// input 		     [7:0]		TD_DATA,
	// input 		          		TD_HS,
	// output		          		TD_RESET_N,
	// input 		          		TD_VS,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	// inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	// inout 		    [35:0]		GPIO_1
);
//clk and rst
reg clk;
assign clk = CLOCK_50;
reg rst;
assign rst = KEY[0];

//system memory variables
reg sys_wren;
reg sys_rden;
reg [15:0]sys_addr;
reg [7:0]sys_data_in;
reg [7:0]sys_data_out;

//registers
reg [31:0]x0;
reg [31:0]x1;
reg [31:0]x2;
reg [31:0]x3;
reg [31:0]x4;
reg [31:0]x5;
reg [31:0]x6;
reg [31:0]x7;
reg [31:0]x8;
reg [31:0]x9;
reg [31:0]x10;
reg [31:0]x11;
reg [31:0]x12;
reg [31:0]x13;
reg [31:0]x14;
reg [31:0]x15;
reg [31:0]x16;
reg [31:0]x17;
reg [31:0]x18;
reg [31:0]x19;
reg [31:0]x20;
reg [31:0]x21;
reg [31:0]x22;
reg [31:0]x23;
reg [31:0]x24;
reg [31:0]x25;
reg [31:0]x26;
reg [31:0]x27;
reg [31:0]x28;
reg [31:0]x29;
reg [31:0]x30;
reg [31:0]x31;
reg [31:0]pc;

//hardwiring zero register
assign x0 = 32'd0;

//state variables
reg [31:0]S, NS;

//count variables
parameter WAIT_TIME = 32'd20;
reg [31:0] wait_count;

//fsm states
parameter 
ERROR = 32'd0,
START = 32'd1,
WAIT_START = 32'd2,
FETCH = 32'd3,
WAIT_FETCH = 32'd4,
DECODE = 32'd5,
WAIT_DECODE = 32'd6,
EXECUTE = 32'd7,
WAIT_EXECUTE = 32'd8,
WRITEBACK = 32'd9,
WAIT_WRITEBACK = 32'd10;


always @ (posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
	
		//specifying initial state
		S <= START;
	
		//zeroing registers
		x1 <= 32'd0;
		x2 <= 32'd0;
		x3 <= 32'd0;
		x4 <= 32'd0;
		x5 <= 32'd0;
		x6 <= 32'd0;
		x7 <= 32'd0;
		x8 <= 32'd0;
		x9 <= 32'd0;
		x10 <= 32'd0;
		x11 <= 32'd0;
		x12 <= 32'd0;
		x13 <= 32'd0;
		x14 <= 32'd0;
		x15 <= 32'd0;
		x16 <= 32'd0;
		x17 <= 32'd0;
		x18 <= 32'd0;
		x19 <= 32'd0;
		x20 <= 32'd0;
		x21 <= 32'd0;
		x22 <= 32'd0;
		x23 <= 32'd0;
		x24 <= 32'd0;
		x25 <= 32'd0;
		x26 <= 32'd0;
		x27 <= 32'd0;
		x28 <= 32'd0;
		x29 <= 32'd0;
		x30 <= 32'd0;
		x31 <= 32'd0;
		pc <= 32'd0;
	end
	else begin
		S <= NS;
	end
end


always @ (*) begin
	//determining NS
	case (S)	
		//start
		START: NS = WAIT_START;
		WAIT_START: NS = (wait_count < WAIT_TIME)?FETCH:WAIT_START;
		
		//fetch
		FETCH: NS = WAIT_FETCH;
		WAIT_FETCH: NS = (wait_count < WAIT_TIME)?DECODE:WAIT_FETCH;
		
		//decode
		DECODE: NS = WAIT_DECODE;
		WAIT_DECODE: NS = (wait_count < WAIT_TIME)?EXECUTE:WAIT_DECODE;
		
		//execute
		EXECUTE: NS = WAIT_EXECUTE;
		WAIT_EXECUTE: NS = (wait_count < WAIT_TIME)?WRITEBACK:WAIT_EXECUTE;
		
		//writeback
		WRITEBACK: NS = WAIT_WRITEBACK
		WAIT_WRITEBACK: NS = (wait_count < WAIT_TIME)?FETCH:WAIT_WRITEBACK;
		
		//error
		default: NS = ERROR;
	endcase
end
	
always @ (posedge clk or negedge rst) begin
	case (S)
	
		//incrementing wait counts
		WAIT_START: wait_count <= (NS = WAIT_START)?(wait_count + 32'd1):32'd0;
		WAIT_FETCH:	wait_count <= (NS = WAIT_FETCH)?(wait_count + 32'd1):32'd0;
		WAIT_DECODE: wait_count <= (NS = WAIT_DECODE)?(wait_count + 32'd1):32'd0;
		WAIT_EXECUTE: wait_count <= (NS = WAIT_EXECUTE)?(wait_count + 32'd1):32'd0;
		WAIT_WRITEBACK: wait_count <= (NS = WAIT_WRITEBACK)?(wait_count + 32'd1):32'd0;
	endcase
end
	
	

system_ram system_ram1 (
	.clock(clk),
	.wren(sys_wren),
	.rden(sys_rden),
	.data(sys_data_in),
	.q(sys_data_out),
	.address(sys_address)
);


// --------------- DEBUG CODE ---------------

debug debug1 (


);



endmodule