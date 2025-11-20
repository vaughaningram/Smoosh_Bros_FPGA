module pattern_gen (
    input logic valid,
    input logic [9:0] col,  
    input logic [9:0] row, 
    input logic [5:0] tile,   
    output logic [5:0] rgb      
);

assign rgb = valid ? tile : 6'd0;

endmodule 