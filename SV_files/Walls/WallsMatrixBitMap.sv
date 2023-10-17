// HartsMatrixBitMap File 
// A two level bitmap. displaying harts on the screen Apr  2023  
// (c) Technion IIT, Department of Electrical Engineering 2023 



module	WallsMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic startOfFrame,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic Wall_bomb_Collision,

					output	logic	wallsDrawingRequest, 
					output	logic	BreakablesDrawingRequest, 
					output	logic	[7:0] RGBout,  
					output	logic block_broke

 ) ;
 
/*-------------------------------------------------*/
 
// Size represented as Number of X and Y bits 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 
localparam logic FRAME = 400;
 logic BrokenFlag;
 logic collisionInFrame;
 logic counter;
 
 /*------------------------------------------------*/

// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 16*16 and use only the top left 16*15 squares 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the  understanding 



logic [0:12] [0:17] [3:0]  MazeBiMapMask= {
		{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00},
		{4'h00, 4'h00, 4'h03, 4'h02, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h02, 4'h00, 4'h04, 4'h03, 4'h02, 4'h00, 4'h00},
		{4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h04, 4'h01, 4'h00},
		{4'h00, 4'h02, 4'h02, 4'h02, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h02, 4'h02, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00},
		{4'h01, 4'h03, 4'h01, 4'h04, 4'h01, 4'h00, 4'h01, 4'h02, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00},
		{4'h00, 4'h00, 4'h04, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h02, 4'h02, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h01, 4'h00, 4'h01, 4'h02, 4'h01, 4'h02, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h02, 4'h01, 4'h00},
		{4'h00, 4'h00, 4'h02, 4'h03, 4'h02, 4'h00, 4'h00, 4'h02, 4'h03, 4'h03, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h01, 4'h03, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00},
		{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00}}; 
	
 
 
logic [0:4] [0:31] [0:31] [7:0]  object_colors  = {
//WALL
{
	{8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hb4,8'hb4,8'h00,8'h00},
	{8'hfd,8'hfd,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00},
	{8'hfd,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24},
	{8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24}}
, //Breakable wall
{
	
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'hb5,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00},
	{8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00},
	{8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00},
	{8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfd,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfd,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfd,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfd,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfd,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfd,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h90,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}}
, // Breakable wall -1 hit
{
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'hd8,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'h00},
	{8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hd8,8'hd8,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'h00},
	{8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'hc4,8'hfc,8'hfc,8'hfc,8'h00,8'hd5,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfd,8'hfd,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00},
	{8'h00,8'hc4,8'hfc,8'hfc,8'hfc,8'h00,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfd,8'hfd,8'hfe,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'hc4,8'hfd,8'hfc,8'hfc,8'h00,8'hfe,8'hfd,8'hfd,8'h00,8'h00,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'h00,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'hfd,8'hfd,8'hfe,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'hc4,8'hfc,8'h00,8'hfc,8'h00,8'hfe,8'hfd,8'hfd,8'h00,8'h00,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'h00,8'hfd,8'hfd,8'hfe,8'h00,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'h00},
	{8'h00,8'hc4,8'hfc,8'hfc,8'h00,8'h00,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'h00,8'hfd,8'h00,8'hfd,8'h00,8'h00,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfe,8'h00,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'hec,8'hfc,8'hfc,8'hfc,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'hfd,8'h6c,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfd,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'hf8,8'hd8,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'hd8,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'hd8,8'h00,8'h00,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd9,8'h00,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfd,8'h00,8'h00,8'hfd,8'hfc,8'h00},
	{8'h00,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'hf8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h24,8'hd8,8'hd8,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfd,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hd9,8'hfd,8'hfd,8'hfe,8'h00},
	{8'h00,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h24,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd9,8'hfd,8'hfd,8'hfe,8'h00},
	{8'h00,8'hd8,8'hd8,8'h00,8'h90,8'hd8,8'h24,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'h00,8'hd9,8'hfd,8'hfd,8'hfe,8'h00},
	{8'h00,8'hd8,8'hd8,8'h00,8'h00,8'hd8,8'h24,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hd9,8'hfd,8'hfd,8'hfe,8'h00},
	{8'h00,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h24,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h24,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfc,8'hfc,8'h00,8'hd9,8'hfd,8'hfd,8'hfe,8'h00},
	{8'h00,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h24,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'hd9,8'hfd,8'hfd,8'hfe,8'h00},
	{8'h00,8'hd8,8'h00,8'h00,8'h00,8'hd8,8'h24,8'h00,8'hfc,8'hfc,8'h00,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}}
, //Breakable wall - 2
{
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfd,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hd8,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd8,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'hd8,8'hd8,8'h00,8'h6c,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h00,8'hd8,8'h90,8'h00,8'hd8,8'h00},
	{8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'he2,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hd8,8'hd8,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'h00,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'h00,8'hd8,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he1,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he1,8'h00,8'h00,8'h00,8'h00,8'h00,8'he2,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he1,8'h00,8'h00,8'h00,8'h00,8'h00,8'he2,8'he2,8'h00,8'h00,8'h00,8'h00,8'he1,8'hc1,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'h00,8'he2,8'he2,8'h00,8'hfd,8'hfd,8'h20,8'he2,8'he2,8'h00,8'hfd,8'h00,8'h00,8'he2,8'h00,8'hfd,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'h00,8'he2,8'he2,8'he2,8'h00,8'h00,8'he2,8'he2,8'he2,8'h00,8'hfd,8'h00,8'he2,8'he2,8'h00,8'hfd,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'h00},
	{8'h00,8'h00,8'hfc,8'h00,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'hfd,8'hfd,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'h00},
	{8'h00,8'h00,8'hfc,8'h00,8'hfc,8'h00,8'h00,8'hfd,8'hfd,8'he1,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'hfe,8'h00,8'h00,8'h80,8'he2,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'h00,8'hfc,8'h00,8'h00},
	{8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'he1,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hb4,8'hd8,8'hd8,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'h24,8'h00,8'h00,8'h00,8'h24,8'hfc,8'h00},
	{8'h00,8'h00,8'h00,8'hd8,8'hd8,8'h00,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he1,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'hd8,8'hd8,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he1,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'he2,8'h60,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'he1,8'he2,8'he2,8'he2,8'he2,8'he2,8'h00,8'h00,8'he2,8'he2,8'h00,8'h00,8'h00,8'he2,8'he2,8'ha1,8'h00,8'h00,8'he2,8'he2,8'he1,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'h00,8'he2,8'he1,8'h00,8'h00,8'he2,8'h00,8'h00,8'hfc,8'h00,8'he2,8'h00,8'hfc,8'h00,8'he2,8'he2,8'h00,8'hfc,8'h00,8'he2,8'he2,8'he2,8'h00,8'h00,8'hfd,8'hfd,8'hfd,8'h00},
	{8'h00,8'h00,8'hd8,8'hd8,8'h00,8'h00,8'hd8,8'h00,8'hfd,8'h00,8'h00,8'h00,8'hfc,8'h00,8'he2,8'h00,8'hfc,8'h00,8'he2,8'he1,8'h00,8'hfc,8'h00,8'he2,8'he2,8'h00,8'h00,8'h00,8'hfd,8'hfd,8'hfe,8'h00},
	{8'h00,8'h00,8'hd8,8'h00,8'h00,8'hd8,8'hd8,8'h00,8'hfc,8'h00,8'hfc,8'h00,8'h00,8'h00,8'he2,8'h00,8'h00,8'hfc,8'h00,8'he1,8'h00,8'h90,8'h00,8'h00,8'h00,8'hfc,8'hfd,8'h00,8'hfd,8'hfd,8'h00,8'h00},
	{8'h00,8'h00,8'hd8,8'h00,8'h00,8'hd8,8'hd8,8'h00,8'hfc,8'h00,8'hfc,8'h00,8'h00,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfd,8'h00,8'hfd,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfd,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfd,8'h00,8'h00,8'h00,8'hfd,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd8,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'h00,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfd,8'h00,8'h00,8'h00,8'hfd,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd8,8'h00,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'h00,8'hfc,8'hfc,8'hfc,8'h00,8'h00,8'hfc,8'hfc,8'hfd,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hd8,8'hd8,8'h24,8'h00,8'h20,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h20,8'h00,8'h00,8'h20,8'h00,8'h00,8'h20,8'h20,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}},

{//empty brick
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}}
	};



// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		BrokenFlag <= 1'b0;
		counter <= 0;
		
		MazeBiMapMask <= 
		{
		{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00},
		{4'h00, 4'h00, 4'h03, 4'h02, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h02, 4'h00, 4'h04, 4'h03, 4'h02, 4'h00, 4'h00},
		{4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h04, 4'h01, 4'h00},
		{4'h00, 4'h02, 4'h02, 4'h02, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h02, 4'h02, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00},
		{4'h01, 4'h03, 4'h01, 4'h04, 4'h01, 4'h00, 4'h01, 4'h02, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00},
		{4'h00, 4'h00, 4'h04, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h02, 4'h02, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h01, 4'h00, 4'h01, 4'h02, 4'h01, 4'h02, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h02, 4'h01, 4'h00},
		{4'h00, 4'h00, 4'h02, 4'h03, 4'h02, 4'h00, 4'h00, 4'h02, 4'h03, 4'h03, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h00},
		{4'h01, 4'h03, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00},
		{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00}}; 
		end
	else begin
	//---------RBG------------------------------------------
		RGBout <= TRANSPARENT_ENCODING ; // default 

		if ((InsideRectangle == 1'b1 )		& 	// Wall 
		   (MazeBiMapMask[offsetY[8:5]][offsetX[9:5]] == 4'h01 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[4'h00][offsetY[4:0]][offsetX[4:0]] ;
		else if ((InsideRectangle == 1'b1 )		& 	// breakable wall 
		   (MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] == 4'h02 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[4'h01][offsetY[4:0]][offsetX[4:0]] ;
		else if ((InsideRectangle == 1'b1 )		& 	// breakable wall 1hit 
		   (MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] == 4'h03 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[4'h02][offsetY[4:0]][offsetX[4:0]] ;
		else if ((InsideRectangle == 1'b1 )		& 	//breakable wall 2 hits 
		   (MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] == 4'h04 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[4'h03][offsetY[4:0]][offsetX[4:0]] ;
		else if ((InsideRectangle == 1'b1 )		& 	//breakable wall 3 hits 
		   (MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] == 4'h05 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[4'h04][offsetY[4:0]][offsetX[4:0]] ;
						
						
	//----------------------------------------------------------------------------------
	
	//--------Update on collision-------------------------------------------
		
		
		
			if ((InsideRectangle == 1'b1 )	& 	// breakable wall first hit
				(MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] == 4'h02 ) & (Wall_bomb_Collision) & (!BrokenFlag)) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
							begin
							MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] <= 4'h03 ;
							BrokenFlag <= 1'b1;
							end
							
			if ((InsideRectangle == 1'b1 )	& // breakable wall second hit
				(MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] == 4'h03 ) & (Wall_bomb_Collision) & (!BrokenFlag)) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
					begin
					MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] <= 4'h04 ;
					BrokenFlag <= 1'b1;
					end
					
			if ((InsideRectangle == 1'b1 )	& // breakable wall second hit
				(MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] == 4'h04 ) & (Wall_bomb_Collision) & (!BrokenFlag)) // take bits 5,6,7,8,9,10 from address to select  position in the maze   
					begin
					MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] <= 4'h05 ;
					BrokenFlag <= 1'b1;
					end
					
			if ((InsideRectangle == 1'b1 )	& // breakable wall second hit
				(MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] == 4'h05 ) & (Wall_bomb_Collision) & (!BrokenFlag)) // take bits 5,6,7,8,9,10 from address to select  position in the maze   
					begin
					MazeBiMapMask[offsetY[8:5] ][offsetX[9:5]] <= 4'h00 ;
					BrokenFlag <= 1'b1;
					end
			

		
	//-----------------------------------------
	
			if(Wall_bomb_Collision) begin //Wall_bomb_Collision
				collisionInFrame <= 1'b1;
				BrokenFlag <= 1'b1;
			end
			
			if(startOfFrame && !collisionInFrame) 
				BrokenFlag <= 1'b0;
			
			if (startOfFrame)
				collisionInFrame <= 1'b0;
				
	//	-------------------------------------------- 
	end
	
end

//==----------------------------------------------------------------------------------------------------------------=

// decide if to draw the pixel or not 

assign block_broke = !BrokenFlag ;
assign wallsDrawingRequest = ((RGBout != TRANSPARENT_ENCODING) && (MazeBiMapMask[offsetY[8:5]][offsetX[9:5]] == 4'h01)); // get optional transparent command from the bitmpap
assign BreakablesDrawingRequest =  ((MazeBiMapMask[offsetY[8:5]][offsetX[9:5]] == 4'h02) || //0hits
												(MazeBiMapMask[offsetY[8:5]][offsetX[9:5]] == 4'h03) ||// 1hit
												(MazeBiMapMask[offsetY[8:5]][offsetX[9:5]] == 4'h04)); //2hits
												

endmodule

