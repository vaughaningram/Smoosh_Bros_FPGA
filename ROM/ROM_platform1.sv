module ROM_platform (
    input logic clk,
    input logic [9:0] addr,
    output logic [5:0] rgb
);

logic [3:0] mem [0:899];

initial begin 
    // reads from a hex file to memory
    $readmemh("platform_test.txt", mem);
end
// combinational since sv will implement own clk
assign rgb = mem[addr];

endmodule

