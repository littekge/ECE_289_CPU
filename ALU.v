module ALU {
	
	input wire [31:0]in_1,
	input wire [31:0]in_2,
	input wire [3:0]operation,
	
	output wire [31:0]out
};

wire [31:0]unsigned_in_1;
wire [31:0]unsigned_in_2;

always @ (*) begin
	unsigned_in_1 = (~in_1) + 32'd1;
	unsigned_in_2 = (~in_2) + 32'd1;
	case (operation)
		ADD: out = in_1 + in_2;
		SUB: out = in_1 - in_2;
		XOR: out = in_1 ^ in_2;
		OR: out = in_1 | in_2;
		AND: out = in_1 & in_2;
		SLL: out = in_1 << in_2;
		SRL: out = in_1 >> in_2;
		SRA: out = in_1 <<< in_2;
		SLT: out = (in_1 < in_2)?32'd1:32'd0;
		SLTU: out = (unsigned_in_1 < unsigned_in_2)?32'd1:32'd0;
	endcase
end



endmodule