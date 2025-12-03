module top (
  input logic clk_in,
  output logic hsync,
  output logic vsync,
  output logic [5:0] rgb
);
  

logic valid;
logic [9:0] col;
logic [9:0] row;



logic clk_out;

    // character rgb from ROM
    logic [5:0] char_rgb;
    logic [5:0] next_char_rgb;
    logic inside_char_tile;
    // tile from ROM
    logic [5:0] tile_rgb;
    // final rgb value to pass to VGA
    logic [5:0] final_rgb;

    // character position for top left pixel
    logic [9:0] char_x = 0;
    logic [9:0] char_y = 0;
    logic [9:0] anim_row = 0;
    logic [9:0] anim_col = 0;

    // frame refresh
    logic frame_rate;

    // ROM address
    logic [16:0] back_addr;
    logic [10:0] char_addr;
    logic [10:0] next_char_addr;

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
    .valid(valid),
    .frame_tick(frame_rate)
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
    assign back_addr = tile_y * TILES_X + tile_x;
    logic inside_char_tile_next;

    always_comb begin
      inside_char_tile_next = (col >= char_x && col < char_x + 30 
                          && row >= char_y && row < char_y + 40);
      next_char_addr = inside_char_tile_next ? ((row - char_y + anim_row) * 30) + (col - char_x + anim_col)
                                          : 0;
      if (inside_char_tile && char_rgb != 6'b110011) final_rgb = char_rgb;
      else final_rgb = tile_rgb;
    end
    logic [24:0] counter;
    always_ff @(posedge clk_out) begin
      // counter <= counter + 1;
      // char_x <= new_x;
      // char_y <= new_y;
      char_rgb <= next_char_rgb;
      char_addr <= next_char_addr;
      inside_char_tile <= inside_char_tile_next;
    end


    // typedef enum logic [1:0] {S1, S2, S3, S4} anim_state;
    // anim_state state, next_state;
    // always_ff @(posedge counter[23]) begin
    //   state <= next_state;
    // end

    // movement reference
    // logic [6:0] new_x;
    // logic [6:0] new_y;
    // always_ff @(posedge frame_rate) begin
    //   new_x <= new_x + 1;
    //   new_y <= new_y + 1;
    // end

    // animation reference
    // always_comb begin
    //   case(state) 
    //   S1: begin
    //     anim_row = 0;
    //     anim_col = 0;
    //     next_state = S2;
    //   end
    //   S2: begin
    //     anim_row = 0;
    //     anim_col = 40;
    //     next_state = S3;
    //   end
    //   S3: begin
    //     anim_row = 40;
    //     anim_col = 0;
    //     next_state = S4;
    //   end
    //   S4: begin
    //     anim_row = 40;
    //     anim_col = 40;
    //     next_state = S1;
    //   end
    //   default: begin
    //     anim_col = 0;
    //     anim_row = 0;
    //     next_state = S1;
    //   end
    //   endcase
    // end

    // ROM instance for marco
    ROM_marco u_marco_rom (
      .clk(clk_out),
      .addr(char_addr),
      .rgb(next_char_rgb)
    );

    // ROM instance
    ROM_Screen u_rom (
        .clk(clk_out),
        .addr(back_addr),
        .data(tile_rgb)
    );

  pattern_gen u_pattern_gen (
    .valid(valid),
    .col(col),  
    .row(row),
    .tile(final_rgb),    
    .rgb(rgb)     
  );



endmodule
