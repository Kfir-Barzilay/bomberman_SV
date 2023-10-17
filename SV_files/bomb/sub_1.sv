module sub_1 (
    input logic [0:10] data0,
	 
    output logic [0:10] result
);

parameter  int OBJECT_WIDTH_X = 32;
    
	 assign result = data0 - OBJECT_WIDTH_X;

endmodule
