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
reg [31:0]registers[0:31];
reg [31:0]pc;

//register control variables
reg [4:0]rd_addr;
reg [4:0]rs1_addr;
reg [4:0]rs2_addr;
reg [31:0]rd_data;
reg [31:0]rs1_data;
reg [31:0]rs2_data;
reg reg_wren;

//decoding variables
reg [31:0]current_instruction;
reg [31:0]immediate;
reg [6:0]funct7;
reg [2:0]funct3;
reg [6:0]opcode;

//ALU variables
reg [31:0]alu_in_1;
reg [31:0]alu_in_2;
wire [31:0]alu_out;
reg [3:0]alu_op;

//debugging variables
reg exception_thrown;

//state variables
reg [31:0]S, NS;

//count variables
parameter WAIT_TIME = 32'd20;
reg [31:0] wait_count;

//fsm states
parameter ERROR = 32'd0,
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
		//zeroing pc
		pc <= 32'd0;
	end
	else begin
		case (S)
			
			FETCH: begin
				reg_wren <= 1'b0;
				//getting instruction from value of pc
				sys_addr <= pc[15:0];
				sys_byte_en <= 4'b1111;
			end
			
			DECODE: begin
				//setting instruction to decode
				current_instruction <= sys_data_out;
			end
			
			EXECUTE: begin
				case (opcode)
					OP: begin
						alu_in_1 <= rs1_data;
						alu_in_2 <= rs2_data;
					end
					OP_IMM: begin
						alu_in_1 <= rs1_data;
						alu_in_2 <= immediate;
					end
					JAL: begin
						alu_in_1 <= pc;
						alu_in_2 <= immediate;
					end
				endcase
			end
			
			WRITEBACK: begin
				case (opcode)
					OP: begin
						pc <= pc + 32'd4;
						rd_data <= alu_out;
						reg_wren <= 1'b1;
					end
					OP_IMM: begin
						pc <= pc + 32'd4;
						rd_data <= alu_out;
						reg_wren <= 1'b1;
					end
					JAL: begin
						pc <= alu_out;
						reg_wren <= 1'b0;
					end
				
				endcase
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

//OPCODE parameters
parameter OP = 7'b0110011,
			OP_IMM = 7'b0010011,
			JAL = 7'b1101111;
			
//ALU parameters
parameter ADD = 4'd0,
			SUB = 4'd1,
			XOR = 4'd2,
			OR = 4'd3,
			AND = 4'd4,
			SLL = 4'd5,
			SRL = 4'd6,
			SRA = 4'd7,
			SLT = 4'd8,
			SLTU = 4'd9;
	
//Instruction Decoding
always @ (*) begin
	
	//register decoding
	rs1_data = registers[rs1_addr];
	rs2_data = registers[rs2_addr];
	
	//instruction type decoding
	opcode = current_instruction[6:0];
	case (opcode)
	
		//integer register-register instructions
		OP: begin
			//decode instruction
			funct7 = current_instruction[31:25];
			rs2_addr = current_instruction[24:20];
			rs1_addr = current_instruction[19:15];
			funct3 = current_instruction[14:12];
			rd_addr = current_instruction[11:7];
			//set alu_op
			case (funct7)
				7'h00: begin
					case (funct3)
						3'h0: alu_op = ADD; //add
						3'h1:	alu_op = SLL; //sll
						3'h2:	alu_op = SLT; //slt
						3'h3: alu_op = SLTU; //sltu
						3'h4: alu_op = XOR; //xor
						3'h5: alu_op = SRL; //srl
						3'h6: alu_op = OR; //or
						3'h7: alu_op = AND; //and
					endcase
				end
				7'h20: begin
					case (funct3)
						3'd0: alu_op = SUB; //sub
						3'd5: alu_op = SRA; //sra
					endcase
				end
			endcase
		end
		
		//integer register-immediate instructions
		OP_IMM: begin
			//sign extending immediate
			immediate = {{20{current_instruction[31]}}, current_instruction[31:20]};
			//decode instruction
			rs1_addr = current_instruction[19:15];
			funct3 = current_instruction[14:12];
			rd_addr = current_instruction[11:7];
			case (immediate[11:5])
				7'h20: begin
					case (funct3)
						3'h5: alu_op = SRA; //srai
					endcase
				end
				7'h00: begin
					case (funct3)
						3'h1: alu_op = SLL; //slli
						3'h5: alu_op = SRL; //srli
					endcase
				end
				default: begin
					case (funct3)
						3'h0: alu_op = ADD; //addi
						3'h2:	alu_op = SLT; //slti
						3'h3: alu_op = SLTU; //sltui
						3'h4: alu_op = XOR; //xori
						3'h6: alu_op = OR; //ori
						3'h7: alu_op = AND; //andi
					endcase
				end
			endcase
		end
		
		//jump and link instruction
		JAL: begin
			//immediate decoding and sign extension
			immediate = {{11{current_instruction[31]}}, current_instruction[31], current_instruction[19:12], current_instruction[20], current_instruction[30:21], 1'b0};
			//decode instruction
			rd_addr = current_instruction[11:7];
			alu_op = ADD;
		end
		
	
		default: begin
		
		end
	endcase
end

//register control
always @ (posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		//zeroing registers
		registers[0] <= 32'd0;
		registers[1] <= 32'd0;
		registers[2] <= 32'd0;
		registers[3] <= 32'd0;
		registers[4] <= 32'd0;
		registers[5] <= 32'd0;
		registers[6] <= 32'd0;
		registers[7] <= 32'd0;
		registers[8] <= 32'd0;
		registers[9] <= 32'd0;
		registers[10] <= 32'd0;
		registers[11] <= 32'd0;
		registers[12] <= 32'd0;
		registers[13] <= 32'd0;
		registers[14] <= 32'd0;
		registers[15] <= 32'd0;
		registers[16] <= 32'd0;
		registers[17] <= 32'd0;
		registers[18] <= 32'd0;
		registers[19] <= 32'd0;
		registers[20] <= 32'd0;
		registers[21] <= 32'd0;
		registers[22] <= 32'd0;
		registers[23] <= 32'd0;
		registers[24] <= 32'd0;
		registers[25] <= 32'd0;
		registers[26] <= 32'd0;
		registers[27] <= 32'd0;
		registers[28] <= 32'd0;
		registers[29] <= 32'd0;
		registers[30] <= 32'd0;
		registers[31] <= 32'd0;
	end
	else if (reg_wren == 1'b1 && rd_addr != 5'd0) begin
		registers[rd_addr] <= rd_data;
	end
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

ALU alu1 (
	.in_1(alu_in_1),
	.in_2(alu_in_2),
	.operation(alu_op),
	.out(alu_out)
);


// --------------- DEBUG CODE ---------------
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

always @ (*) begin
	x0 = registers[0];
	x1 = registers[1];
	x2 = registers[2];
	x3 = registers[3];
	x4 = registers[4];
	x5 = registers[5];
	x6 = registers[6];
	x7 = registers[7];
	x8 = registers[8];
	x9 = registers[9];
	x10 = registers[10];
	x11 = registers[11];
	x12 = registers[12];
	x13 = registers[13];
	x14 = registers[14];
	x15 = registers[15];
	x16 = registers[16];
	x17 = registers[17];
	x18 = registers[18];
	x19 = registers[19];
	x20 = registers[20];
	x21 = registers[21];
	x22 = registers[22];
	x23 = registers[23];
	x24 = registers[24];
	x25 = registers[25];
	x26 = registers[26];
	x27 = registers[27];
	x28 = registers[28];
	x29 = registers[29];
	x30 = registers[30];
	x31 = registers[31];
end

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