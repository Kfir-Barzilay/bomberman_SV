// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	mineBitMap_2	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic bomb_exist,
					input logic bomb_exploded,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
					//output	logic	explodeRequest;  
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^6 = 64 


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 2; //how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 2;

// generating a bomb bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

logic[0:31][0:31][7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h00,8'h97,8'h97,8'h97,8'h0e,8'h00,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hff,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'hff,8'h97,8'h97,8'h97,8'h80,8'h00,8'hff,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'hff,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hff,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'hff,8'h97,8'h97,8'h8e,8'h80,8'hd7,8'hff,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'hff,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'h97,8'h97,8'h97,8'h6e,8'h80,8'hd7,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'hd7,8'h00,8'h97,8'h97,8'h97,8'h97,8'h9b,8'h80,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'hd7,8'h00,8'h97,8'h97,8'h97,8'h97,8'h97,8'h80,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'h00,8'h00,8'h2d,8'h2d,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb2,8'h00,8'h00,8'h97,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'h91,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'h00,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfa,8'h00,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfa,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfa,8'h00,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfe,8'hda,8'h00,8'h00,8'h00,8'hfe,8'h00,8'hfa,8'hfe,8'h00,8'hfe,8'h00,8'h00,8'h00,8'h20,8'hfa,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hfe,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'h00,8'h00,8'hfe,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'hfa,8'h00,8'hfc,8'hfc,8'hf8,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hfe,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'h00,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'hfa,8'h00,8'hfc,8'hfc,8'hf8,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfe,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'h00,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'hfa,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'h00,8'hfe,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'h00,8'hfe,8'hfe,8'hfa,8'h00,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfa,8'h00,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'h00,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfa,8'h00,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'hb3,8'h00,8'h97,8'h97,8'h97,8'h97,8'h97,8'h80,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'hd7,8'h00,8'h97,8'h97,8'h97,8'h97,8'h72,8'h80,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'hd7,8'h00,8'h97,8'h97,8'h97,8'h97,8'h8e,8'h80,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'hff,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hff,8'hd7,8'hd7,8'hd7,8'h00,8'h97,8'hff,8'h97,8'h97,8'had,8'h80,8'h00,8'hff,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'hff,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'hd7,8'hd7,8'hd7,8'hd7,8'hd7,8'h00,8'h97,8'hff,8'h97,8'h97,8'h0e,8'h80,8'h20,8'hff,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h97,8'h97,8'h97,8'h97,8'h0e,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'hd7,8'hd7,8'hd7,8'haf,8'h00,8'h00,8'h97,8'h97,8'h97,8'h0e,8'h00,8'h00,8'hd7,8'hd7,8'hd7,8'hcc,8'h00,8'h00,8'ha4,8'h97,8'h97,8'h97,8'h20,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h6d,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hda,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff}};




//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


logic [0:3] [0:3] [3:0] hit_colors = 
		  {16'hC446,     
			16'h8C62,    
			16'h8932,
			16'h9113};


// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk )//or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'hff;
		//HitEdgeCode <= 4'h0;
	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		//HitEdgeCode <= 4'h0;
	end

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket
			if (bomb_exist == 1'b1) begin
				//HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge from the colors table  
				RGBout <= object_colors[offsetY][offsetX];
			end
			
		end 


			
			
	
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 

assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule


