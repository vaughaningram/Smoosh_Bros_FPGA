module ROM_marco (
    input logic clk,
    input logic [13:0] addr,
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

// // getting next address on clock edge
// always_ff @(posedge clk) begin
    assign rgb = next_rgb; 
//end

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
        4'h0: rgb = 6'b110011;
        4'h1: rgb = 6'b000000;
        4'h2: rgb = 6'b111010;
        4'h3: rgb = 6'b010110;
        4'h4: rgb = 6'b000001;
        default: rgb = 6'b110011;
    endcase
end

endmodule
