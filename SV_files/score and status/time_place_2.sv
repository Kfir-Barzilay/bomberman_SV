// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022


module time_place 
	(
	output	[10:0] xPos,
	output	[10:0] yPos
	
	); 
parameter int x_pos = 100;
parameter int y_pos = 100;
	
assign xPos = x_pos;
assign yPos = y_pos;

endmodule 