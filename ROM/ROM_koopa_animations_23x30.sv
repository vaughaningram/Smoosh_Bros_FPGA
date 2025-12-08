module ROM_koopa_animations_23x30 (
    input logic clk,
    input logic [13:0] addr1,
    input logic [13:0] addr2,
    output logic [5:0] rgb1,
    output logic [5:0] rgb2
);



// 3 bit output with 9659 addresses
logic [2:0] mem [0:9659];

initial begin 
    // reads from a hex file to memory
    $readmemh("koopa_23x30_animations.koopa", mem);
end

// get the color from the pallet
koopa_palette_lookup u_palette1 (
    .index(mem[addr1]),
    .player(1),
    .rgb(rgb1)
);
koopa_palette_lookup u_palette2 (
    .index(mem[addr2]),
    .player(0),
    .rgb(rgb2)
);

endmodule

module koopa_palette_lookup (
    input  logic [2:0] index,
    input logic player,
    output logic [5:0] rgb
);
// convert from 3 bits to 6 bit color
always_comb begin
    if (player) begin
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
    end else begin
        case (index)
            3'h0: rgb = 6'b110011;
            3'h1: rgb = 6'b010000;
            3'h2: rgb = 6'b100000;
            3'h3: rgb = 6'b111001;
            3'h4: rgb = 6'b000000;
            3'h5: rgb = 6'b111111;
            3'h6: rgb = 6'b111100;
            3'h7: rgb = 6'b111000;
        endcase
    end
end
endmodule


