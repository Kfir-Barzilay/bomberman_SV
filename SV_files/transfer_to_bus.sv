module	transfer_to_bus	(	
			input	logic	in_1,  // short pulse every start of frame 30Hz 
			input	logic	in_2,
			input	logic	in_3,
			input logic in_4,
			input logic in_5,
						
			output logic [4:0] out // active in case of collision between wall 
);

assign out = {in_1, in_2, in_3, in_4, in_5};

endmodule 