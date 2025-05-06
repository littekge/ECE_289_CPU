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
	input 		          			CLOCK_50,

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
wire clk;
assign clk = CLOCK_50;
wire rst;
assign rst = KEY[0];

//system memory variables
reg sys_wren;
reg sys_rden;
reg [3:0]sys_byte_en;
reg [15:0]sys_addr;
reg [7:0]sys_data_in;
wire [7:0]sys_data_out;

//registers
wire [31:0]x0;
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

//decoding variables
reg [31:0]current_instruction;
wire [4:0]rd_addr;
wire [4:0]rs1_addr;
wire [4:0]rs2_addr;
wire [31:0]rd_data;
wire [31:0]rs1_data;
wire [31:0]rs2_data;

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
	end
	else begin
		S <= NS;
	end
end


always @ (*) begin
	//determining NS
	if (exception_thrown == 1'b1) begin
		NS = ERROR;
	end 
	else begin
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
			WRITEBACK: NS = WAIT_WRITEBACK;
			WAIT_WRITEBACK: NS = (wait_count < WAIT_TIME)?FETCH:WAIT_WRITEBACK;
			
			//error
			default: NS = ERROR;
		endcase
	end
end
	
always @ (posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
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
		case (S)
			
			FETCH: begin
				//getting instruction from value of pc
				sys_addr <= pc[15:0];
				sys_byte_en <= 4'b1111;
			end
			
			DECODE: begin
				//setting instruction to decode
				current_instruction <= sys_data_out;
			end
			
			EXECUTE: begin

			end
			
			WRITEBACK: begin

			end

			//delay in between steps for memory timing reasons
			WAIT_START: wait_count <= (NS == WAIT_START)?(wait_count + 32'd1):32'd0;
			WAIT_FETCH: wait_count <= (NS == WAIT_FETCH)?(wait_count + 32'd1):32'd0;
			WAIT_DECODE: wait_count <= (NS == WAIT_DECODE)?(wait_count + 32'd1):32'd0;
			WAIT_EXECUTE: wait_count <= (NS == WAIT_EXECUTE)?(wait_count + 32'd1):32'd0;
			WAIT_WRITEBACK: wait_count <= (NS == WAIT_WRITEBACK)?(wait_count + 32'd1):32'd0;
		endcase
	end
end
	
//Instruction Decoding
always @ (*) begin

	//instruction type decoding
	opcode = current_instruction[6:0];
	case (opcode)
		OP_IMM: begin
			immediate[11:0] = current_instruction[31:20];
			rs1_addr = current_instruction[19:15];
			funct3 = current_instruction[14:12];
			rd_addr = current_instruction[11:7];
		end
		LUI: begin
			immediate[31:12] = current_instruction[31:12];
			rd_addr = current_instruction[11:7];
		end
		AUIPC: begin
			immediate[31:12] = current_instruction[31:12];
			rd_addr = current_instruction[11:7];
		end
		default: begin
		
		end
	endcase

	//reg instruction decoding
	case (rs1_addr)
		5'd0: rs1_data = x0;
		5'd1: rs1_data = x1;
		5'd2: rs1_data = x2;
		5'd3: rs1_data = x3;
		5'd4: rs1_data = x4;
		5'd5: rs1_data = x5;
		5'd6: rs1_data = x6;
		5'd7: rs1_data = x7;
		5'd8: rs1_data = x8;
		5'd9: rs1_data = x9;
		5'd10: rs1_data = x10;
		5'd11: rs1_data = x11;
		5'd12: rs1_data = x12;
		5'd13: rs1_data = x13;
		5'd14: rs1_data = x14;
		5'd15: rs1_data = x15;
		5'd16: rs1_data = x16;
		5'd17: rs1_data = x17;
		5'd18: rs1_data = x18;
		5'd19: rs1_data = x19;
		5'd20: rs1_data = x20;
		5'd21: rs1_data = x21;
		5'd22: rs1_data = x22;
		5'd23: rs1_data = x23;
		5'd24: rs1_data = x24;
		5'd25: rs1_data = x25;
		5'd26: rs1_data = x26;
		5'd27: rs1_data = x27;
		5'd28: rs1_data = x28;
		5'd29: rs1_data = x29;
		5'd30: rs1_data = x30;
		5'd31: rs1_data = x31;
		default: rs1_data = 32'd1001;
	endcase
	case (rs2_addr)
		5'd0: rs2_data = x0;
		5'd1: rs2_data = x1;
		5'd2: rs2_data = x2;
		5'd3: rs2_data = x3;
		5'd4: rs2_data = x4;
		5'd5: rs2_data = x5;
		5'd6: rs2_data = x6;
		5'd7: rs2_data = x7;
		5'd8: rs2_data = x8;
		5'd9: rs2_data = x9;
		5'd10: rs2_data = x10;
		5'd11: rs2_data = x11;
		5'd12: rs2_data = x12;
		5'd13: rs2_data = x13;
		5'd14: rs2_data = x14;
		5'd15: rs2_data = x15;
		5'd16: rs2_data = x16;
		5'd17: rs2_data = x17;
		5'd18: rs2_data = x18;
		5'd19: rs2_data = x19;
		5'd20: rs2_data = x20;
		5'd21: rs2_data = x21;
		5'd22: rs2_data = x22;
		5'd23: rs2_data = x23;
		5'd24: rs2_data = x24;
		5'd25: rs2_data = x25;
		5'd26: rs2_data = x26;
		5'd27: rs2_data = x27;
		5'd28: rs2_data = x28;
		5'd29: rs2_data = x29;
		5'd30: rs2_data = x30;
		5'd31: rs2_data = x31;
		default: rs2_data = 32'd1001;
	endcase
	case (rd_addr)
		5'd0: rd_data = x0;
		5'd1: rd_data = x1;
		5'd2: rd_data = x2;
		5'd3: rd_data = x3;
		5'd4: rd_data = x4;
		5'd5: rd_data = x5;
		5'd6: rd_data = x6;
		5'd7: rd_data = x7;
		5'd8: rd_data = x8;
		5'd9: rd_data = x9;
		5'd10: rd_data = x10;
		5'd11: rd_data = x11;
		5'd12: rd_data = x12;
		5'd13: rd_data = x13;
		5'd14: rd_data = x14;
		5'd15: rd_data = x15;
		5'd16: rd_data = x16;
		5'd17: rd_data = x17;
		5'd18: rd_data = x18;
		5'd19: rd_data = x19;
		5'd20: rd_data = x20;
		5'd21: rd_data = x21;
		5'd22: rd_data = x22;
		5'd23: rd_data = x23;
		5'd24: rd_data = x24;
		5'd25: rd_data = x25;
		5'd26: rd_data = x26;
		5'd27: rd_data = x27;
		5'd28: rd_data = x28;
		5'd29: rd_data = x29;
		5'd30: rd_data = x30;
		5'd31: rd_data = x31;
		default: rd_data = 32'd1001;
	endcase
end

system_ram system_ram1 (
	.clock(clk),
	.wren(sys_wren),
	.byteena(sys_byte_en),
	.rden(sys_rden),
	.data(sys_data_in),
	.q(sys_data_out),
	.address(sys_address)
);


// --------------- DEBUG CODE ---------------

debug debug1 (
//clk and rst
	.clk(clk),
	.rst(rst),
	
	//registers
	.x0(x0),
	.x1(x1),
	.x2(x2),
	.x3(x3),
	.x4(x4),
	.x5(x5),
	.x6(x6),
	.x7(x7),
	.x8(x8),
	.x9(x9),
	.x10(x10),
	.x11(x11),
	.x12(x12),
	.x13(x13),
	.x14(x14),
	.x15(x15),
	.x16(x16),
	.x17(x17),
	.x18(x18),
	.x19(x19),
	.x20(x20),
	.x21(x21),
	.x22(x22),
	.x23(x23),
	.x24(x24),
	.x25(x25),
	.x26(x26),
	.x27(x27),
	.x28(x28),
	.x29(x29),
	.x30(x30),
	.x31(x31),
	.pc(pc),
	
	//vga output data
	.vga_blank(VGA_BLANK_N),
	.vga_b(VGA_B),
	.vga_r(VGA_R),
	.vga_g(VGA_G),
	.vga_clk(VGA_CLK),
	.vga_hs(VGA_HS),
	.vga_vs(VGA_VS),
	.vga_sync(VGA_SYNC_N)

);



endmodule