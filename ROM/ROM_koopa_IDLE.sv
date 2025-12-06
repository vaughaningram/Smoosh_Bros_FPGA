module ROM_koopa_IDLE (
    input logic clk,
    input logic [10:0] addr,
    output logic [5:0] rgb
);

// next rgb value to pass to rgb
logic [5:0] next_rgb;

// 4 bit output with 2760 addresses
logic [2:0] mem [0:1379];

initial begin 
    // reads from a hex file to memory
    $readmemh("koopa_IDLE.mem", mem);
end
// combinational since sv will implement own clk
assign rgb = next_rgb;

// get the color from the pallet
koopa_palette_lookup u_palette (
    .index(mem[addr[10:0]]),
    .rgb(next_rgb)
);

endmodule

