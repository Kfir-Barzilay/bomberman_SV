
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller_all	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_Smiley,    // smiley 
			input	logic	drawing_request_wall,	   // wall who can't break
			input logic drawing_request_tempWall,  // wall who can break 
			input logic drawing_request_bomb,	   // bomb
			input logic [0:4] drawing_request_mine,// mines
			input logic drawing_request_explosion, // explosion
			input logic block_broke,					// when a temp wall collied with explosion
			input logic plus_pressed,
			
			output logic collision, 				 // active in case of collision between wall
			output logic collision_lostLife,	 	 // collision of smiley and explosion
			output logic [0:4] MINE_EXP, 			 // witch mine exploded
			output logic SingleHitPulse, 			 // critical code, generating A single pulse in a frame
			output logic collision_destroy_wall, // collision of temp wall with explosion
			output logic [3:0] score_top,			 // score digit
			output logic [3:0] score_bottom,		 // score second digit
			output logic mineHitPulse,  			 // critical code, generating A single pulse in a frame
			output logic direction
	
);
logic [0:4] mine_exp ; 

assign collision = ( drawing_request_Smiley &&  (drawing_request_wall || drawing_request_tempWall ));// collision between Smiley and walls
assign collision_lostLife = ( drawing_request_Smiley && drawing_request_explosion );
assign MINE_EXP = mine_exp;
assign collision_destroy_wall = drawing_request_tempWall && drawing_request_explosion;						 						
						

//_______________________________________________________


logic flag ; 		// a semaphore to set the output only once per frame / regardless of the number of collisions 
logic flag_1 ;		// same as above
logic flag_2;		//same as above
logic flag_plus;	//same as above

logic [7:0] score = 0;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		flag_1	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
		mineHitPulse <= 1'b0; 
		mine_exp <= 0;
		score <= 8'h00;
		flag_plus <= 1'b0;
		direction <= 1'b0;
	end 
	else begin
			mine_exp[0] <=  (drawing_request_mine[0]) && (drawing_request_explosion || drawing_request_Smiley);
			mine_exp[1] <=  (drawing_request_mine[1]) && (drawing_request_explosion || drawing_request_Smiley);
			mine_exp[2] <=  (drawing_request_mine[2]) && (drawing_request_explosion || drawing_request_Smiley);
			mine_exp[3] <=  (drawing_request_mine[3]) && (drawing_request_explosion || drawing_request_Smiley);
			mine_exp[4] <=  (drawing_request_mine[4]) && (drawing_request_explosion || drawing_request_Smiley);

			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) begin
			
				flag <= 1'b0 ; // reset for next time
				
				if (!mine_exp)
					flag_1 <= 1'b0;
					
				if (!collision_destroy_wall)
					flag_2 <= 1'b0;
					
				flag_plus <= 1'b0;
			end
				
//		change the section below  to collision between number and smiley

//--------------change direction-------------------
if (plus_pressed && !flag_plus) begin // change direction
	direction <= (direction == 1'b0) ? 1'b1 : 1'b0;
end 

flag_plus <= plus_pressed;
//-------------------------------------------------


if ( collision  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse <= 1'b1 ; 
		end ;
	
//----------------game score gain------------------
	
if ( mine_exp  && (flag_1 == 1'b0)) begin 
			flag_1	<= 1'b1; // to enter only once 
			mineHitPulse <= 1'b1 ;
			score <= score + 5;
		end ;
		
if ( collision_destroy_wall && flag_2 == 1'b0 && block_broke) begin	
		flag_2 <= 1'b1;
		score <= score + 2;
	end
	
//-----------------------------------------------------
	end 
end

assign score_bottom = score % 10;
assign score_top = score / 10;

endmodule
