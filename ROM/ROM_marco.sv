module ROM_marco (
    input logic clk,
    input logic [10:0] addr,
    output logic [5:0] rgb
);

// next rgb value to pass to rgb
logic [5:0] next_rgb;

// 4 bit output with 1200 addresses
logic [3:0] mem [0:1199];

initial begin 
    // reads from a hex file to memory
    $readmemh("marco_ROM.txt", mem);
end

// getting next address on clock edge
always_ff @(posedge clk) begin
    rgb <= next_rgb; 
end

// get the color from the pallet
palette_lookup u_palette (
    .index(mem[addr]),
    .rgb(next_rgb)
);

endmodule

module palette_lookup (
    input  logic [3:0] index,
    output logic [5:0] rgb
);
// convert from 4 bits to 6 bit color
always_comb begin
    case (index)
        4'h0: rgb = 6'b000000; // (0,0,0)
        4'h1: rgb = 6'b000000; // (18,11,2)
        4'h2: rgb = 6'b000000; // (33,25,14)
        4'h3: rgb = 6'b010101; // (90,105,136)
        4'h4: rgb = 6'b111111; // (255,255,255)
        4'h5: rgb = 6'b110101; // (194,133,105)
        4'h6: rgb = 6'b110100; // (184,111,80)
        4'h7: rgb = 6'b100100; // (156,94,68)
        4'h8: rgb = 6'b000000; // (48,34,14)
        4'h9: rgb = 6'b000000; // (61,43,18)
        4'hA: rgb = 6'b000000; // (38,23,5)
        4'hB: rgb = 6'b010110; // (106,119,145)
        4'hC: rgb = 6'b010011; // (53,60,94)
        4'hD: rgb = 6'b010010; // (38,43,68)
        4'hE: rgb = 6'b110011; // (255,0,255)
        4'hF: rgb = 6'b111100; // (247,118,34)
    endcase
end

endmodule
