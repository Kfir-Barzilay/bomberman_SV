// (c) Technion IIT, Department of Electrical Engineering 2018 

// Implements the hexadecimal to 7Segment conversion unit
// by using a two-dimensional array

module hexss 
	(
	input logic [3:0] hexin, // Data input: hex numbers 0 to f
	input logic darkN, 
	input logic LampTest, 	// Aditional inputs
	output logic [6:0] ss 	// Output for 7Seg display
	);

// Declaration of two-dimensional array that holds the 7seg codes
	logic [0:15] [6:0] SevenSeg = 
									{	7'h40, //0
										7'h79, //1
										7'h24, //2
										7'h30, //3
										7'h19, //4
										7'h12, //5
										7'h02, //6
										7'h78, //7
										7'h00, //8
										7'h10, //9
										7'h08, //A
										7'h03, //B
										7'h46, //C
										7'h21, //D
										7'h06, //E
										7'h0E, //F
									};

	
always_comb
begin
	if (darkN == 1'b0)
		ss = 7'h7F;
	else if (LampTest == 1'b1)
		ss = 7'h00;
	else
		ss = SevenSeg[hexin];
end
endmodule


