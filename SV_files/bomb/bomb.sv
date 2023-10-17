// (c) Technion IIT, Department of Electrical Engineering 2018 
// Updated by Mor Dahan - January 2022
// 
// Implements the state machine of the bomb mini-project
// FSM, with present and next states

module bomb
	(
	input logic clk, 
	input logic resetN, 
	input logic startN, 
	input logic waitN, 
	input logic OneSecPulse, 
	input logic timerEnd,
	
	output logic countLoadN, 
	output logic countEnable, 
	output logic lampEnable,
	output logic lamp_eight
   );

//-------------------------------------------------------------------------------------------

// state machine decleration 
	enum logic [2:0] {s_idle, s_arm, s_run, s_pause, s_lampOff, s_lampOn, s_pause_delay } bomb_ps, bomb_ns;
	logic [2:0] timer_ns, timer_ps;
//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state 
always @(posedge clk or negedge resetN)
   begin
	   
   if ( !resetN ) begin // Asynchronic reset
		bomb_ps <= s_idle;
		timer_ps <= 3'b0;
		end
   
	else 	begin	// Synchronic logic FSM
		bomb_ps <= bomb_ns;
		timer_ps <= timer_ns;
		end
		
	end // always sync
	
//--------------------------------------------------------------------------------------------
//  2.  asynchornous code: logically defining what is the next state, and the ouptput 
//      							(not seperating to two different always sections)  	
always_comb // Update next state and outputs
	begin
	// set all default values 
		bomb_ns = bomb_ps; 
		countEnable = 1'b0;
		countLoadN = 1'b1;
		lampEnable = 1'b1;
		timer_ns = timer_ps;
		lamp_eight = 1'b0;

			
		case (bomb_ps)
		
			//Note: the implementation of the idle state is already given you as an example
			s_idle: begin
				lampEnable = 1'b0;
				if (startN == 1'b0) 
					bomb_ns = s_arm; 
				end // idle
						
			s_arm: begin
				countLoadN = 1'b0;
				if (startN == 1)
					bomb_ns = s_run;
				
				end // arm
						
			s_run: begin
				
				countEnable = 1'b1;
				if (waitN == 0)
					bomb_ns = s_pause;
				else if (timerEnd == 1)
					bomb_ns = s_lampOn;
				
				end // run
					
			s_pause: begin
				
				countEnable = 1'b0;
				if ( waitN == 1)
					//bomb_ns = s_run;   //original, 
					//bomb_ns = s_lampOff; // the code we added in the lab_SV2 to trick the police (ACAB) , date: 13/8 , 
					bomb_ns = s_pause_delay;
				end // pause
				
			s_pause_delay: begin
				countEnable = 1'b0;
				lampEnable = 1'b0;
				if (timer_ps == 3'b111) 
					bomb_ns = s_run;
				if (OneSecPulse == 1)
					timer_ns = timer_ps + 3'b001;
				end
				
						
			s_lampOff: begin
					
					countEnable= 1'b0;
					lampEnable = 1'b0;
					if (OneSecPulse == 1)
						bomb_ns = s_lampOn;
					
				end // lampOff
				
			s_lampOn: begin
						
					countEnable= 1'b0;
					lampEnable = 1'b1;
					lamp_eight = 1'b1;
					if (OneSecPulse == 1)
						bomb_ns = s_lampOff;
						
				end // lampOn
						
						
		endcase
	end // always comb
	
endmodule
