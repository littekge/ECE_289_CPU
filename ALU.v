module ALU (
	
	input wire [31:0]in_1,
	input wire [31:0]in_2,
	input wire [3:0]operation,
	
	output reg [31:0]out
);

reg signed [31:0]signed_in_1;
reg signed [31:0]signed_in_2;

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
			SLTU = 4'd9,
			EQL = 4'd10,
			NEQ = 4'd11,
			GTE = 4'd12,
			GTEU = 4'd13,
			NOP = 4'd14,
			ERR = 4'd15;
			
always @ (*) begin
	signed_in_1 = in_1;
	signed_in_2 = in_2;
	case (operation)
		ADD: out = in_1 + in_2;
		SUB: out = in_1 - in_2;
		XOR: out = in_1 ^ in_2;
		OR: out = in_1 | in_2;
		AND: out = in_1 & in_2;
		SLL: out = in_1 << in_2;
		SRL: out = in_1 >> in_2;
		SRA: out = in_1 <<< in_2;
		SLT: out = (signed_in_1 < signed_in_2)?32'd1:32'd0;
		SLTU: out = (in_1 < in_2)?32'd1:32'd0;
		EQL: out = (in_1 == in_2)?32'd1:32'd0;
		NEQ: out = (in_1 != in_2)?32'd1:32'd0;
		GTE: out = (signed_in_1 >= signed_in_2)?32'd1:32'd0;
		GTEU: out = (in_1 >= in_2)?32'd1:32'd0;
		NOP: out = 32'd0;
		ERR: out = 32'd329010;
		default: out = 32'd329011;
	endcase
end



endmodule