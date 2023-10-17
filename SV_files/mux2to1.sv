//mux 2 to 1

module mux_2to1 (
    input logic [7:0] data0,
    input logic [7:0] data1,
    input logic select,
	 
    output logic [7:0] result
);

    
	 assign result = (select) ? data1 : data0;

endmodule
