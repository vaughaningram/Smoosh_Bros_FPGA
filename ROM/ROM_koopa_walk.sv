module ROM_koopa_walk (
    input logic clk,
    input logic [11:0] addr,
    output logic [5:0] rgb
);

// next rgb value to pass to rgb
logic [5:0] next_rgb;

// 4 bit output with 2760 addresses
logic [2:0] mem [0:2759];

initial begin 
    // reads from a hex file to memory
    $readmemh("koopa_walk.mem", mem);
end
// combinational since sv will implement own clk
assign rgb = next_rgb;

// get the color from the pallet
koopa_palette_lookup u_palette (
    .index(mem[addr[11:0]]),
    .rgb(next_rgb)
);

endmodule

module koopa_palette_lookup (
    input  logic [2:0] index,
    output logic [5:0] rgb
);
// convert from 3 bits to 6 bit color
always_comb begin
    case (index)
        3'h0: rgb = 6'b110011;
        3'h1: rgb = 6'b000100;
        3'h2: rgb = 6'b001000;
        3'h3: rgb = 6'b101100;
        3'h4: rgb = 6'b000000;
        3'h5: rgb = 6'b111111;
        3'h6: rgb = 6'b111100;
        3'h7: rgb = 6'b111000;
    endcase
end
endmodule


