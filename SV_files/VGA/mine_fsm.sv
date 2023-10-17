// (c) Technion IIT, Department of Electrical Engineering 2023 


module	mine_fsm	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input logic collision, // can be with a bomb or with smiley

					
					output	logic bomb_exist,							  // if the bomb did'nt explode and the bomb is on the screen
					output	logic bomb_exploded,						  // if the bomb exploded
					output	logic signed 	[10:0]	topLeftX_out, // output the top left corner 
					output	logic signed	[10:0]	topLeftY_out  // can be negative , if the object is partliy outside
						
					
					
);

				

/*----------------- Parameters --------------*/  
parameter int BOMB_FRAME_TIME = 90;
parameter int INITIAL_X = 1000;
parameter int INITIAL_Y = 1000;






enum  logic [2:0] {IDLE_ST, // initial state 
						EXPLODED_ST,// position interpolate
						OFF_SCREEN_ST // vanish from the screen
						}  SM_PS, 
							SM_NS ;

/*----------------- States of the machine --------------*/	
						
 
 int bomb_exploded_PS, bomb_exploded_NS;   
 int bomb_exist_PS, bomb_exist_NS; 
 int counter_PS, counter_NS;
 
 
 


 //------------------------------------------------------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin //initial position state
				SM_PS <= IDLE_ST ; 
				bomb_exist_PS <= 1   ; 
				bomb_exploded_PS <= 0 ; 
				counter_PS <= 0 ;  

			
			end 	
			else begin //syncronizing
				SM_PS  <= SM_NS ;
				bomb_exist_PS   <= bomb_exist_NS;  
				bomb_exploded_PS <=  bomb_exploded_NS; 
				counter_PS <=  counter_NS; 
			 
			end ; 
		end // end fsm_sync

 
 ///------------------------------------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS  ;
		 bomb_exist_NS  = bomb_exist_PS; 
		 bomb_exploded_NS =  bomb_exploded_PS; 
		 counter_NS = counter_PS; 

	 	

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------
		
		 if(collision)
			SM_NS = EXPLODED_ST;
 	
	end
	


//------------------------
 		EXPLODED_ST : begin  // exploding the bomb 
//------------------------
	
			 if(startOfFrame) begin
				counter_NS = counter_PS + 1;
				bomb_exploded_NS = 1'b1;
				bomb_exist_NS = 1'b0;
			end
			
			if(counter_NS >= BOMB_FRAME_TIME) begin
				SM_NS = OFF_SCREEN_ST;
				
			end
		end
		
//------------------------
 		OFF_SCREEN_ST : begin  // switching the draw request of the bomb to zero 
//------------------------
				counter_NS = 0;
				bomb_exploded_NS = 1'b0;


		end
		
endcase  // case 
end		
//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX_out = INITIAL_X;    
assign 	topLeftY_out = INITIAL_Y;    
assign	bomb_exist = bomb_exist_PS;
assign	bomb_exploded = bomb_exploded_PS;
	

endmodule	
//---------------

