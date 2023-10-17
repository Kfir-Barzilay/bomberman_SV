
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux_new	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
 
					input		logic	smileyDrawingRequest, // player drawing request
					input		logic	[7:0] smileyRGB, 

					input 	logic BombDrawingRequest,  // if the bomb will be shown on the screen
					input 	logic [7:0] BombRGB, 
					
					input		logic time_DR,					// reamain time display on the screen
					input		logic [7:0] timeRGB,
					
					input		logic mine_DR,					// mines drawing request
					input		logic [7:0] mine_RGB,
					
					input		logic tempWalls_DR,			// tempWalls dispaly
					input		logic [7:0] tempWallsRGB,

					input    logic WallsDrawingRequest, // box of numbers
					input		logic	[7:0] WallsRGB, 
					
					input		logic	[7:0] backGroundRGB, 
					input		logic	BGDrawingRequest, 
					input		logic	[7:0] RGB_MIF,
					
					input 	logic endOfGame,				//darken part of the screen when the game is over
					input 	logic [10:0] PixelX,
					
					input		logic gameOver_DR,			// dispaly that the game is over
					input		logic [7:0] gameOverRGB,
			  
				   output	logic	[7:0] RGBOut			//what will be display on the screen
					
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin

	
		if (endOfGame && (PixelX > 86)) begin  // end game dispaly
			if (gameOver_DR)
				RGBOut <= gameOverRGB;
			else
				RGBOut <= 8'h00;
		end
/*-------------display priority on the screen--------------------------------------*/
			
		else if (smileyDrawingRequest == 1'b1 )   
			RGBOut <= smileyRGB;  //first priority 
		  
		else if (BombDrawingRequest == 1'b1 )
					RGBOut <= BombRGB;  //Second priority 

		 
//----------------------------------------------------------------------------------		

 //third priority and more 

		else if (time_DR == 1'b1 )
					RGBOut <= timeRGB;   
		
		
		else if (tempWalls_DR == 1'b1 )
					RGBOut <= tempWallsRGB;
					
		else if (mine_DR == 1'b1 )
					RGBOut <= mine_RGB; 
	

 		else if (WallsDrawingRequest == 1'b1)
				RGBOut <= WallsRGB;
				
		else if (BGDrawingRequest == 1'b1)
				RGBOut <= backGroundRGB ;
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


