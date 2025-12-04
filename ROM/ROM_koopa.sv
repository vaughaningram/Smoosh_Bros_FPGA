module ROM_koopa (
    input logic clk,
    input logic [13:0] addr,
    output logic [5:0] rgb
);

// next rgb value to pass to rgb
logic [5:0] next_rgb;

// 4 bit output with 4140 addresses
logic [3:0] mem [0:4139];

initial begin 
    // reads from a hex file to memory
    $readmemh("ROM_Koopa_Data.txt", mem);
end
// combinational since sv will implement own clk
assign rgb = next_rgb;

// get the color from the pallet
koopa_palette_lookup u_palette (
    .index(mem[addr[13:0]]),
    .rgb(next_rgb)
);

endmodule

module koopa_palette_lookup (
    input  logic [3:0] index,
    output logic [5:0] rgb
);
// convert from 4 bits to 6 bit color
always_comb begin
    case (index)
        4'h0: rgb = 6'b110011;
        4'h1: rgb = 6'b000100;
        4'h2: rgb = 6'b001000;
        4'h3: rgb = 6'b101100;
        4'h4: rgb = 6'b000000;
        4'h5: rgb = 6'b111111;
        4'h6: rgb = 6'b111100;
        4'h7: rgb = 6'b111110;
        4'h8: rgb = 6'b101000;
        4'h9: rgb = 6'b111000;
        default: rgb = 6'b000000;
    endcase
end


endmodule


