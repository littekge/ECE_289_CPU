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

parameter MEM_ERROR = 8'd0,
		LOAD_BYTE = 8'd1,
		LOAD_HALF = 8'd2,
		LOAD_WORD = 8'd3,
		LOAD_BYTE_U = 8'd4,
		LOAD_HALF_U = 8'd5,
		STORE_BYTE = 8'd6,
		STORE_HALF = 8'd7,
		STORE_WORD = 8'd8;
		
always @ (*) begin
	case (mem_op)
	
		LOAD_BYTE: begin
			sys_wren = 1'b0;
			sys_rden = 1'b1;
			sys_data_in = 32'd0;
			sys_addr = mem_addr >> 16'd2;
			case (mem_addr % 4)
				2'd0:	begin
					sys_byte_en = 4'b1000;
					mem_data_out = {{24{sys_data_out[31]}}, sys_data_out[31:24]};
				end
				2'd1:	begin
					sys_byte_en = 4'b0100;
					mem_data_out = {{24{sys_data_out[23]}}, sys_data_out[23:16]};
				end
				2'd2:	begin
					sys_byte_en = 4'b0010;
					mem_data_out = {{24{sys_data_out[15]}}, sys_data_out[15:8]};
				end
				2'd3:	begin
					sys_byte_en = 4'b0001;
					mem_data_out = {{24{sys_data_out[7]}}, sys_data_out[7:0]};
				end
			endcase
		end
		
		LOAD_HALF: begin
			sys_wren = 1'b0;
			sys_rden = 1'b1;
			sys_data_in = 32'd0;
			sys_addr = mem_addr >> 16'd2;
			case (mem_addr % 4)
				2'd0:	begin
					sys_byte_en = 4'b1100;
					mem_data_out = {{16{sys_data_out[31]}}, sys_data_out[31:16]};
				end
				2'd2:	begin
					sys_byte_en = 4'b0011;
					mem_data_out = {{16{sys_data_out[15]}}, sys_data_out[15:0]};
				end
				default: begin
					sys_byte_en = 4'b0000;
					mem_data_out = 32'd329030;
				end
			endcase
		end
		
		LOAD_WORD: begin
			sys_wren = 1'b0;
			sys_rden = 1'b1;
			sys_data_in = 32'd0;
			sys_addr = mem_addr >> 16'd2;
			sys_byte_en = 4'b1111;
			mem_data_out = sys_data_out;
		end
		
		LOAD_BYTE_U: begin
			sys_wren = 1'b0;
			sys_rden = 1'b1;
			sys_data_in = 32'd0;
			sys_addr = mem_addr >> 16'd2;
			case (mem_addr % 4)
				2'd0:	begin
					sys_byte_en = 4'b1000;
					mem_data_out = {24'd0, sys_data_out[31:24]};
				end
				2'd1:	begin
					sys_byte_en = 4'b0100;
					mem_data_out = {24'd0, sys_data_out[23:16]};
				end
				2'd2:	begin
					sys_byte_en = 4'b0010;
					mem_data_out = {24'd0, sys_data_out[15:8]};
				end
				2'd3:	begin
					sys_byte_en = 4'b0001;
					mem_data_out = {24'd0, sys_data_out[7:0]};
				end
			endcase
		end
		
		LOAD_HALF_U: begin
			sys_wren = 1'b0;
			sys_rden = 1'b1;
			sys_data_in = 32'd0;
			sys_addr = mem_addr >> 16'd2;
			case (mem_addr % 4)
				2'd0:	begin
					sys_byte_en = 4'b1100;
					mem_data_out = {16'd0, sys_data_out[31:16]};
				end
				2'd2:	begin
					sys_byte_en = 4'b0011;
					mem_data_out = {16'd0, sys_data_out[15:0]};
				end
				default: begin
					sys_byte_en = 4'b0000;
					mem_data_out = 32'd329031;
				end
			endcase
		end
		
		STORE_BYTE: begin
			sys_wren = 1'b1;
			sys_rden = 1'b0;
			sys_addr = mem_addr >> 16'd2;
			mem_data_out = 32'd0;
			case (mem_addr % 4)
				2'd0:	begin
					sys_byte_en = 4'b1000;
					sys_data_in[31:24] = mem_data_in[7:0];
				end
				2'd1:	begin
					sys_byte_en = 4'b0100;
					sys_data_in[23:16] = mem_data_in[7:0];
				end
				2'd2:	begin
					sys_byte_en = 4'b0010;
					sys_data_in[15:8] = mem_data_in[7:0];
				end
				2'd3:	begin
					sys_byte_en = 4'b0001;
					sys_data_in[7:0] = mem_data_in[7:0];
				end
			endcase
		end
		
		STORE_HALF: begin
			sys_wren = 1'b1;
			sys_rden = 1'b0;
			sys_addr = mem_addr >> 16'd2;
			mem_data_out = 32'd0;
			case (mem_addr % 4)
				2'd0:	begin
					sys_byte_en = 4'b1100;
					sys_data_in[31:15] = mem_data_in[15:0];
				end
				2'd2:	begin
					sys_byte_en = 4'b0011;
					sys_data_in[15:0] = mem_data_in[15:0];
				end
				default: begin
					sys_byte_en = 4'b0000;
					sys_data_in = 32'd0;
				end
			endcase
		end
		
		STORE_WORD: begin
			sys_wren = 1'b1;
			sys_rden = 1'b0;
			sys_addr = mem_addr >> 16'd2;
			mem_data_out = 32'd0;
			sys_byte_en = 4'b1111;
			sys_data_in = mem_data_in;
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