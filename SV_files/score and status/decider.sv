module decider (
    input logic [0:7] data0,
    input logic DR0,
    input logic [0:7] data1,
    input logic DR1,
	 input logic [0:7] data2,
	 input logic DR2,
    
    output logic [0:7] result,
    output logic DR
);


	always_comb begin
		 if (DR0) begin
			  DR = DR0;
			  result = data0;
		 end
		 
		 else if (DR1) begin
			  DR = DR1;
			  result = data1;
		 end
		 
		 else if (DR2) begin
			  DR = DR2;
			  result = data2;
		 end
		 
		 else begin
				DR = 0;
				result = 8'hff;
		end
		
	end
	
endmodule
