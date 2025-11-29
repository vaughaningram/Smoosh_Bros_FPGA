// module top();
// wire clk;
// logic [5:0] addr;
// logic [3:0] data;
// logic [3:0] data_comb;
// logic timer = counter[25]; // timer for changing addresses. Depends on what
//                            // speed you need.
// // HSOSC component -> On chip oscillator
//     SB_HFOSC #(
//         .CLKHF_DIV("0b00")
//     ) osc (
//         .CLKHFPU(1'b1), // Power up
//         .CLKHFEN(1'b1), // Enable
//         .CLKHF(clk)     // Clock output
//         // (TRIM pins omitted intentionally)
//     );

// always_ff @(posedge clk) begin
//     data <= data_comb; // takes data from ROM on clock tick to data
// end

// always_ff @(posedge timer) begin
//     addr <= addr + 1; // increment address
// end

// // writing always_comb in this way tells System Verilog it is ROM
// always_comb begin
//     case(addr)
//  6'b000000 : data_comb = 4'd1;
//  6'b000001 : data_comb = 4'd2;
//  6'b000010 : data_comb = 4'd3;
//  6'b000011 : data_comb = 4'd4;
//  6'b000100 : data_comb = 4'd5;
//  6'b000101 : data_comb = 4'd6;
//  6'b000110 : data_comb = 4'd7;
//  6'b000111 : data_comb = 4'd8;
//  6'b001000 : data_comb = 4'd9;
//  6'b001001 : data_comb = 4'd1;
//  6'b001010 : data_comb = 4'd0;
//  6'b001011 : data_comb = 4'd1;
//  6'b001100 : data_comb = 4'd1;
//  6'b001101 : data_comb = 4'd1;
//  6'b001110 : data_comb = 4'd2;
//  6'b001111 : data_comb = 4'd1;
//  6'b010000 : data_comb = 4'd3;
//  6'b010001 : data_comb = 4'd1;
//  6'b010010 : data_comb = 4'd4;
//  6'b010011 : data_comb = 4'd1;
//  6'b010100 : data_comb = 4'd5;
//  6'b010101 : data_comb = 4'd1;
//  6'b010110 : data_comb = 4'd6;
//  6'b010111 : data_comb = 4'd1;
//  6'b011000 : data_comb = 4'd7;
//  6'b011001 : data_comb = 4'd1;
//  6'b011010 : data_comb = 4'd8;
//  6'b011011 : data_comb = 4'd1;
//  6'b011100 : data_comb = 4'd9;
//  6'b011101 : data_comb = 4'd2;
//  6'b011110 : data_comb = 4'd0;
//  6'b011111 : data_comb = 4'd2;
//  6'b100000 : data_comb = 4'd1;
//  6'b100001 : data_comb = 4'd2;
//  6'b100010 : data_comb = 4'd2;
//  6'b100011 : data_comb = 4'd2;
//  6'b100100 : data_comb = 4'd3;
//  6'b100101 : data_comb = 4'd2;
//  6'b100110 : data_comb = 4'd4;
//  6'b100111 : data_comb = 4'd2;
//  6'b101000 : data_comb = 4'd5;
//  6'b101001 : data_comb = 4'd2;
//  6'b101010 : data_comb = 4'd6;
//  6'b101011 : data_comb = 4'd2;
//  6'b101100 : data_comb = 4'd7;
//  6'b101101 : data_comb = 4'd2;
//  6'b101110 : data_comb = 4'd8;
//  6'b101111 : data_comb = 4'd2;
//  6'b110000 : data_comb = 4'd9;
//  6'b110001 : data_comb = 4'd3;
//  6'b110010 : data_comb = 4'd0;
//  6'b110011 : data_comb = 4'd3;
//  6'b110100 : data_comb = 4'd1;
//  6'b110101 : data_comb = 4'd3;
//  6'b110110 : data_comb = 4'd2;
//  6'b110111 : data_comb = 4'd3;
//  6'b111000 : data_comb = 4'd3;
//  6'b111001 : data_comb = 4'd3;
//  6'b111010 : data_comb = 4'd4;
//  6'b111011 : data_comb = 4'd3;
//  6'b111100 : data_comb = 4'd5;
//  6'b111101 : data_comb = 4'd3;
//  6'b111110 : data_comb = 4'd6;
//  6'b111111 : data_comb = 4'd3; 
//     default: data_comb = 4'd0;
//     endcase
// end
// endmodule
