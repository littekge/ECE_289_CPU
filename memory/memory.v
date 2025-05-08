module memory (
	input wire clk,
	input wire [31:0]mem_addr,
	input wire [7:0]mem_op,
	input wire [31:0]mem_data_in,
	output reg [31:0]mem_data_out
);

reg sys_wren;
reg sys_rden;
reg [31:0]sys_data_in;
wire [31:0]sys_data_out;
reg [15:0]sys_addr;
reg [3:0]sys_byte_en;

parameter MEM_FETCH = 8'd1;

always @ (*) begin
	case (mem_op)
		MEM_FETCH: begin
			sys_wren = 1'b0;
			sys_rden = 1'b1;
			sys_data_in = 32'd0;
			sys_addr = mem_addr >> 16'd2;
			sys_byte_en = 4'b1111;
			mem_data_out = sys_data_out;
		end
		default: begin
			sys_wren = 1'b0;
			sys_rden = 1'b0;
			sys_data_in = 32'd0;
			sys_addr = 16'd0;
			sys_byte_en = 4'b0000;
			mem_data_out = 32'd329020;
		end
	endcase
end

system_ram system_ram1 (
	.clock(clk),
	.wren(sys_wren),
	.byteena(sys_byte_en),
	.rden(sys_rden),
	.data(sys_data_in),
	.q(sys_data_out),
	.address(sys_addr)
);
endmodule