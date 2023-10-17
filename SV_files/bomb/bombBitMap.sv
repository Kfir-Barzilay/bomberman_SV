// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	bombBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic bomb_exist,
					input logic bomb_exploded,
					input logic changeHero,

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

logic [0:1][0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors ={ {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h04,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h3c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h1c,8'h3c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h10,8'h1c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h14,8'h0c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h14,8'h04,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h14,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h10,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h3c,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h38,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h0c,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h0c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h38,8'hff,8'hff},
	{8'hff,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'hb6,8'hff},
	{8'hff,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h38,8'h3c,8'h38,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h00,8'hff},
	{8'hff,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h00,8'h00,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h00,8'hff},
	{8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'hff},
	{8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'hff},
	{8'hff,8'hb6,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h0c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff},
	{8'hff,8'hff,8'h14,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hb6,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h10,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h3c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h6d,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h1c,8'h3c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h3c,8'h1c,8'h1c,8'h1c,8'h1c,8'h3c,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}},
 {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hff,8'h60,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h80,8'hff,8'hff,8'h80,8'hc4,8'hff,8'h80,8'hff,8'hfa,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc4,8'ha4,8'hc0,8'hc4,8'hec,8'hf0,8'he4,8'hff,8'hff,8'hf6,8'had},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h60,8'h80,8'h80,8'h60,8'hf6,8'hfa,8'hf4,8'hfc,8'hfc,8'hfc,8'hfc,8'h80,8'he4,8'h80,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'ha0,8'hcc,8'hf4,8'hfc,8'hfc,8'hfc,8'hfc,8'hcc,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hfe,8'hf9,8'hb1,8'ha4,8'he4,8'hf8,8'hfc,8'hfc,8'hfc,8'hfc,8'hf0,8'had,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hfa,8'hf9,8'h8c,8'h00,8'h00,8'h20,8'hfc,8'hf8,8'hfc,8'hf0,8'h80,8'hf0,8'hcc,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h00,8'h24,8'h6d,8'h8d,8'hf9,8'hb5,8'h00,8'hff,8'hff,8'ha0,8'hf8,8'hf1,8'hfc,8'hf4,8'hfa,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h24,8'h00,8'hfa,8'hd5,8'h00,8'h00,8'hff,8'hff,8'h80,8'h80,8'hff,8'hf0,8'hff,8'he4,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h00,8'h24,8'h24,8'hda,8'hff,8'hc0,8'hff,8'hff,8'hc0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hc0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h24,8'h00,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'ha0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h24,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'h60,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'h24,8'h24,8'h24,8'h91,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h24,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'h00,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h64,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h20,8'hff,8'hff,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h24,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'hff,8'h24,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h24,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h00,8'h24,8'h00,8'h00,8'h00,8'h00,8'h20,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h00,8'h20,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}}
	};


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
always_ff@(posedge clk )
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		
	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		
	end

		if (InsideRectangle == 1'b1 ) begin // inside an external bracket
		
			if (bomb_exist == 1'b1) begin
				 
				RGBout <= object_colors[changeHero][offsetY][offsetX];
			end
			
		end 


			
			
	
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 

assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule