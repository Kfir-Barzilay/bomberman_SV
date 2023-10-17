// (c) Technion IIT, Department of Electrical Engineering 2023 


module	bomb_fsm	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input logic oneSecCounter, // clock that count seconds
					input logic bomb_init,		// initial bomb sequence
					
					input	logic signed 	[10:0]	topLeftX_in, // output the top left corner 
					input logic signed	[10:0]	topLeftY_in,  // can be negative , if the object is partliy outside 
					
					output	logic bomb_exist,	   // is there bomb on the screen
					output	logic bomb_exploded,	// is there explosion on the screen
					output	logic signed 	[10:0]	topLeftX_out, // output the top left corner 
					output	logic signed	[10:0]	topLeftY_out  // can be negative , if the object is partliy outside
						
					
					
);

/*----------------------Parameters-----------------------------------------*/  


parameter int BOMB_FRAME_TIME = 60;
parameter int BOMB_WAIT_TIME = 4;


enum  logic [2:0] {IDLE_ST, // initial state
					INIT_BOMB, // moving no colision 
					WAIT_FOR_EXPLOSION, // change speed done, wait for startOfFrame  
					EXPLODED// position interpolate   
					}  SM_PS, 
						SM_NS ;

 int Xposition_PS,  Xposition_NS  ;     
 int Yposition_PS,  Yposition_NS  ; 
 int bomb_exploded_PS, bomb_exploded_NS;   
 int bomb_exist_PS, bomb_exist_NS; 
 int counter_PS, counter_NS;
 
 
 


 //---------------------------------------------------------------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ; 
				bomb_exist_PS <= 0   ; 
				bomb_exploded_PS <= 0 ; 
				counter_PS <= 0 ;  
				Xposition_PS <= 0;
				Yposition_PS <= 0;
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				bomb_exist_PS   <= bomb_exist_NS;  
				bomb_exploded_PS <=  bomb_exploded_NS; 
				counter_PS <=  counter_NS; 
				Xposition_PS <= Xposition_NS;
				Yposition_PS <= Yposition_NS;			 
			end ; 
		end // end fsm_sync

 
 ///------------------state machine------------------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS  ;
		 bomb_exist_NS  = bomb_exist_PS; 
		 bomb_exploded_NS =  bomb_exploded_PS; 
		 counter_NS = counter_PS; 
		 Xposition_NS =  Xposition_PS ; 
		 Yposition_NS  = Yposition_PS  ; 
		 
	 	

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------
		
		 if(bomb_init)
			SM_NS = INIT_BOMB;
 	
	end
	
//------------
		INIT_BOMB:  begin     // placing the bomb and display it on the screen 
//------------
		
		
			Xposition_NS = topLeftX_in;
			Yposition_NS = topLeftY_in;
			bomb_exist_NS = 1'b1;
			counter_NS = 0;
			SM_NS = WAIT_FOR_EXPLOSION;
					

	end			
//--------------------
		WAIT_FOR_EXPLOSION: begin  //  counting time till explosion
//--------------------
			 
		 if(oneSecCounter) begin
			counter_NS = counter_PS + 1;
			bomb_exist_NS = 1'b1;
		end

			
		if(counter_NS == BOMB_WAIT_TIME) begin
			SM_NS = EXPLODED;
			bomb_exploded_NS = 1'b1;
			bomb_exist_NS = 1'b0;
			counter_NS = 0;
		end
		
	end

//------------------------
 		EXPLODED : begin  // explosion dispaly on the screen  
//------------------------
	
			 if(startOfFrame) begin
				counter_NS = counter_PS + 1;
				bomb_exploded_NS = 1'b1;
			end
			
			if(counter_NS >= BOMB_FRAME_TIME) begin
				bomb_exploded_NS = 1'b0;
				counter_NS = 0;
				SM_NS = IDLE_ST;
				
			end
		end
		

endcase  // case 
end		
//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX_out = Xposition_PS;    
assign 	topLeftY_out = Yposition_PS;    
assign	bomb_exist = bomb_exist_PS;
assign	bomb_exploded = bomb_exploded_PS;
	

endmodule	
//---------------

