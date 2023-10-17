module Control_Sounds (            

		input logic clk,            
		input logic resetN,
		input logic startOfFrame,
		input logic smiley_collision,       //collision of smiley and bricks
		input logic explosion_collision,    //collision of explosion and temp bricks
		input logic lostLife_collision,     //losing life
		input logic endgame,                //end of the game
		input logic score,                  //score of the game
		
		
		output	logic	[3:0] frequency,     //frequency of the sound 
		output	logic	enable_sound         //decide if there is sound or not

);

one_sec_counter one_sec_counter (.clk(clk),
								 .resetN(resetN),
								 .turbo(1),
								 .one_sec(t_sec) );

/*----------Parameters--------------------*/								 

localparam logic DEAD = 3;								 
								 
logic smiley_flag, explosion_flag, life_flag, wins_flag;
int sec_counter, once, dead_counter;

/*----------------------------------------*/


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) // starting position to decide on the sound frequency
	begin
		smiley_flag = 0;
		life_flag = 0;
		explosion_flag = 0;
		frequency = 0;
		enable_sound = 0;
		sec_counter = 0;
		once = 0;
	end
	
	else begin
	
/*--------------------- game sounds flags ----------------------*/
		
		if (smiley_collision) begin //raising flag that smiley_collision was detected
			smiley_flag = 1;
			sec_counter = 1;
			enable_sound = 1;
			frequency = 0;
				
		end
		
		if (explosion_collision) begin // raising flag that explosion
			explosion_flag = 1;
			sec_counter = 1;
			enable_sound = 1;
			frequency = 7;
		end
		
		if (lostLife_collision) begin // raising flag that explosion
			life_flag = 1;
			sec_counter = 1;
			enable_sound = 1;
			frequency = 21;
		end
		
		if (lostLife_collision && dead_counter < DEAD)
			dead_counter = dead_counter + 1;
		
		if (dead_counter == DEAD && once == 0) begin // raising flag on win game
			wins_flag = 1;
			sec_counter = 9;
			enable_sound = 1;
			frequency = 0;
			once = 27;
		end
		
/*-------------------------------------------------------------*/
			
		
		if (smiley_flag && t_sec && sec_counter > 0) begin
			frequency = frequency +2;
			sec_counter = sec_counter -1;
		end
		
		if (explosion_flag && t_sec && sec_counter > 0) begin
			frequency = frequency -2;
			sec_counter = sec_counter -1;	
		end
		
		if (life_flag && t_sec && sec_counter > 0) begin
			frequency = frequency -2;
			sec_counter = sec_counter -1;	
		end
		
		if (wins_flag && t_sec && sec_counter > 0) begin
			frequency = frequency +1;
			sec_counter = sec_counter -1;	
		end
		
/*-----------------------------------------------------*/
		
		if (sec_counter == 0) begin
			smiley_flag = 0;
			explosion_flag = 0;
			life_flag = 0;
			enable_sound = 0;
			wins_flag = 0;
		end
		
		if (once > 0 && t_sec) begin
			if (once == 1)
				once = -1;
			else
				once = once -1;
		end
		
	end	
				
end

endmodule 