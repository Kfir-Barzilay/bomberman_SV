// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9  down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module down_counter
	(
	input logic clk, 
	input logic resetN, 
	input logic loadN, 
	input logic enable1,
	input logic enable2, 
	input logic enable3, 
	input logic [3:0] datain,
	
	output logic [3:0] count,
	output logic tc
   );

// Down counter
parameter int VALUE = 9;
parameter int INIT_VALUE = 0;

always_ff @(posedge clk or negedge resetN)
   begin
	      
      if ( !resetN )	begin// Asynchronic reset
			
			count = INIT_VALUE;
			
		end
				
      else 	begin		// Synchronic logic		
			
			if (!loadN)
				count= datain;
			else if (enable1 ==1 && enable2 ==1 && enable3==1)
				if (count == 0)
					count = VALUE;
				else 
					count = count -1;
				
			
		end //Synch
	end //always


	
	// Asynchronic tc
	
	assign tc = (count == 4'h0); 

	
	
endmodule
