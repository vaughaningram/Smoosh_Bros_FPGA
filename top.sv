module top (
  input logic clk_in,
  output logic clk_out,
  output logic hsync,
  output logic vsync,
  output logic [5:0] rgb
);
  

logic valid;
logic [9:0] col;
logic [9:0] row;


    // tile from ROM
    logic [5:0] tile;

    // ROM address
    logic [16:0] addr;

  mypll u_mypll (
    .clock_in(clk_in),
    .clock_out(clk_out)
  );

  vga u_vga (
    .clk(clk_out),
    .hsync(hsync),
    .vsync(vsync),
    .col(col),  
    .row(row),    
    .valid(valid) 
  );

    localparam int TILE_SIZE = 8;
    localparam int TILES_X = 640 / TILE_SIZE;  // = 80

    logic [6:0]   tile_x;
    logic [6:0]   tile_y;
    // logic [16:0]  rom_addr;
    // logic [5:0]   rom_data;

    // Determine which tile this pixel belongs to
    assign tile_x = col[9:3];   // col / 8
    assign tile_y = row[9:3];   // row / 8

    // Compute address EXACTLY like Python script
    assign addr = tile_y * TILES_X + tile_x;

    // ROM instance
    ROM_Screen u_rom (
        .clk(clk_out),
        .addr(addr),
        .data(tile)
    );

  pattern_gen u_pattern_gen (
    .valid(valid),
    .col(col),  
    .row(row),
    .tile(tile),    
    .rgb(rgb)     
  );



endmodule
