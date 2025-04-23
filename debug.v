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
	input wire [31:0]pc
	
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
reg [31:0]S, NS;

//fsm states


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
		H_DISP: HNS = (h_count = 32'd9)?(H_WAIT):(H_RESET);
		H_WAIT: HNS = (h_wait < WAIT_TIME)?(H_WAIT):(H_DISP);
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
		H_DISP: h_count = h_count + 32'd1;
		H_WAIT: h_wait = (HNS == H_WAIT)?(h_wait + 32'd1):32'd0;
		H_RESET: h_count = 32'd0;
	endcase
	case (VS)
		V_DISP: v_count = v_count + 32'd1;
		V_RESET: v_count = 32'd0;
	endcase
end



//combinational decoding
always @ (*) begin
	//seperating out each digit from words
	case (h_count)
		4'd0: current_digit = current_reg % 10;
		4'd1: current_digit = (current_reg / 10) % 10;
		4'd2: current_digit = (current_reg / 100) % 10;
		4'd3: current_digit = (current_reg / 1000) % 10;
		4'd4: current_digit = (current_reg / 10000) % 10;
		4'd5: current_digit = (current_reg / 100000) % 10;
		4'd6: current_digit = (current_reg / 1000000) % 10;
		4'd7: current_digit = (current_reg / 10000000) % 10;
		4'd8: current_digit = (current_reg / 100000000) % 10;
		4'd9: current_digit = (current_reg / 1000000000) % 10;
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
	endcase
end

//ascii controller
ascii_master_controller ascii_master_controller1 (
	.clk(clk),
	.rst(rst),
	
	.ascii_write_en(),
	.ascii_input(),
	.ascii_write_address(),
	
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