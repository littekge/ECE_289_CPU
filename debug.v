module debug (
	//clk and rst
	input wire clk,
	input wire rst,
	
	//registers
	input wire [31:0]x0,
	input wire [31:0]x1,
	input wire [31:0]x2,
	input wire [31:0]x3,
	input wire [31:0]x4,
	input wire [31:0]x5,
	input wire [31:0]x6,
	input wire [31:0]x7,
	input wire [31:0]x8,
	input wire [31:0]x9,
	input wire [31:0]x10,
	input wire [31:0]x11,
	input wire [31:0]x12,
	input wire [31:0]x13,
	input wire [31:0]x14,
	input wire [31:0]x15,
	input wire [31:0]x16,
	input wire [31:0]x17,
	input wire [31:0]x18,
	input wire [31:0]x19,
	input wire [31:0]x20,
	input wire [31:0]x21,
	input wire [31:0]x22,
	input wire [31:0]x23,
	input wire [31:0]x24,
	input wire [31:0]x25,
	input wire [31:0]x26,
	input wire [31:0]x27,
	input wire [31:0]x28,
	input wire [31:0]x29,
	input wire [31:0]x30,
	input wire [31:0]x31,
	input wire [31:0]pc,
	
	//vga output data
	output wire vga_blank,
	output wire [7:0]vga_b,
	output wire	[7:0]vga_r,
	output wire	[7:0]vga_g,
	output wire	vga_clk,
	output wire	vga_hs,
	output wire	vga_vs,
	output wire	vga_sync

);

//state variables
reg [31:0]HS, HNS, VS, VNS;

//count variables
reg [31:0]h_count, h_wait, v_count;

//other variables
wire [3:0]current_digit;
wire [7:0]encoded_digit;
wire [31:0]current_reg;
wire [12:0]vga_write_address;
wire [31:0]vga_write_data;
wire vga_write_en;

//fsm state parameters
parameter H_START = 32'd1,
		H_DISP = 32'd2,
		H_WAIT = 32'd3,
		H_RESET = 32'd4,
		V_START = 32'd5,
		V_DISP = 32'd6,
		V_RESET = 32'd7,
		ERROR = 32'd0;

//other parameters
parameter WAIT_TIME = 5;

//fsm for displaying registers
/*
horizontal states display each digit horizontally
vertical states display each register line by line
*/
always @ (posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		HS <= H_START;
		VS <= V_START;
	end
	else begin
		HS <= HNS;
		VS <= VNS;
	end	
end

always @ (*) begin
	case (HS)
		H_START: HNS = H_DISP;
		H_COMPARE: HNS = HNS = (h_count < 32'd33)?(H_DISP):(H_RESET);
		H_DISP: HNS = 
		H_WAIT: HNS = 
		H_INC: HNS = 
		H_RESET: HNS = H_DISP;
	endcase
	case (VS)
		V_START: VNS = V_DISP;
		V_DISP: VNS = (v_count = 32'd32)?(V_DISP):(V_RESET);
		V_RESET: VNS = V_DISP;
	endcase
end

always @ (posedge clk or negedge rst) begin 
	case (HS)
		H_DISP: h_count <= h_count + 32'd1;
		H_WAIT: h_wait <= (HNS == H_WAIT)?(h_wait + 32'd1):32'd0;
		H_RESET: h_count <= 32'd0;
	endcase
	case (VS)
		V_DISP: v_count = v_count + 32'd1;
		V_RESET: v_count = 32'd0;
	endcase
end

//combinational decoding (IN ORDER OF WIRING)
always @ (*) begin
	//setting vga write address
	vga_write_address = (13'd80 * v_count) + h_count;

	//selecting register based on vertical count
	case (v_count) 
		32'd0: current_reg = x0;
		32'd1: current_reg = x1;
		32'd2: current_reg = x2;
		32'd3: current_reg = x3;
		32'd4: current_reg = x4;
		32'd5: current_reg = x5;
		32'd6: current_reg = x6;
		32'd7: current_reg = x7;
		32'd8: current_reg = x8;
		32'd9: current_reg = x9;
		32'd10: current_reg = x10;
		32'd11: current_reg = x11;
		32'd12: current_reg = x12;
		32'd13: current_reg = x13;
		32'd14: current_reg = x14;
		32'd15: current_reg = x15;
		32'd16: current_reg = x16;
		32'd17: current_reg = x17;
		32'd18: current_reg = x18;
		32'd19: current_reg = x19;
		32'd20: current_reg = x20;
		32'd21: current_reg = x21;
		32'd22: current_reg = x22;
		32'd23: current_reg = x23;
		32'd24: current_reg = x24;
		32'd25: current_reg = x25;
		32'd26: current_reg = x26;
		32'd27: current_reg = x27;
		32'd28: current_reg = x28;
		32'd29: current_reg = x29;
		32'd30: current_reg = x30;
		32'd31: current_reg = x31;
		32'd32: current_reg = pc;
	endcase

	//two's complement conversion
	is_negative = current_reg[31];
	two_comp = (is_negative == 1'b1)?((~current_reg) + 1'b1):current_reg;
	
	//seperating out each digit from words
	case (h_count)
		32'd10: current_digit = two_comp % 10;
		32'd9: current_digit = (two_comp / 10) % 10;
		32'd8: current_digit = (two_comp / 100) % 10;
		32'd7: current_digit = (two_comp / 1000) % 10;
		32'd6: current_digit = (two_comp / 10000) % 10;
		32'd5: current_digit = (two_comp / 100000) % 10;
		32'd4: current_digit = (two_comp / 1000000) % 10;
		32'd3: current_digit = (two_comp / 10000000) % 10;
		32'd2: current_digit = (two_comp / 100000000) % 10;
		32'd1: current_digit = (two_comp / 1000000000) % 10;
		32'd0: current_digit = (is_negative)?(4'd10):(4'd11);
	endcase
	
	//decoding from decimal to ascii
	case (current_digit)
		4'd0: encoded_digit = 8'h30;
		4'd1: encoded_digit = 8'h31;
		4'd2: encoded_digit = 8'h32;
		4'd3: encoded_digit = 8'h33;
		4'd4: encoded_digit = 8'h34;
		4'd5: encoded_digit = 8'h35;
		4'd6: encoded_digit = 8'h36;
		4'd7: encoded_digit = 8'h37;
		4'd8: encoded_digit = 8'h38;
		4'd9: encoded_digit = 8'h39;
		4'd10: encoded_digit = 8'h2D;
		4'd11: encoded_digit = 8'h2B;
	endcase

	//setting vga write data
	vga_write_data = {encoded_digit, 24'b111111111111111111111111};

	//setting write enable to 1
	vga_write_en = 1'b1;
end

//ascii controller
ascii_master_controller ascii_master_controller1 (
	.clk(clk),
	.rst(rst),
	
	.ascii_write_en(vga_write_en),
	.ascii_input(vga_write_data),
	.ascii_write_address(vga_write_address),
	
	.vga_blank(vga_blank),
	.vga_b(vga_b),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_clk(vga_clk),
	.vga_hs(vga_hs),
	.vga_vs(vga_vs),
	.vga_sync(vga_sync)
	
);

endmodule