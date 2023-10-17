// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022


module number_lives 
	(
	output	[3:0] lives
	
	); 
parameter int live = 3;
	
assign lives = live;

endmodule 