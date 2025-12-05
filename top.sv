module top (
  input logic clk_in,
  output logic hsync,
  output logic vsync,
  output logic [5:0] rgb,
  output logic latch,
  output logic ctrl_clk,
  input logic data
);
  

logic valid;
logic [9:0] col;
logic [9:0] next_col;
logic [9:0] row;
logic [9:0] next_row;



logic clk_out;

    // character rgb from ROM
    logic [5:0] char_rgb;
    logic [5:0] next_char_rgb;
    logic inside_char_tile;

    logic [5:0] plt_rgb;
    logic [5:0] next_plt_rgb;
    logic inside_plt_tile;
    // tile from ROM
    logic [5:0] tile_rgb;
    logic [5:0] next_tile_rgb;
    // final rgb value to pass to VGA
    logic [5:0] final_rgb;
    logic [5:0] next_final_rgb;

    // character position for top left pixel
    logic [9:0] char_x;
    logic [9:0] char_y;
    logic [9:0] anim_row = 0;
    logic [9:0] anim_col = 0;

    logic [9:0] plt_x;
    logic [9:0] plt_y;

    logic facing_right;
    // frame refresh
    logic frame_rate;

    // ROM address
    logic [16:0] back_addr;
    logic [16:0] next_back_addr;
    logic [13:0] char_addr;
    logic [13:0] next_char_addr;
    logic [9:0] plt_addr;
    logic [9:0] next_plt_addr;

  mypll u_mypll (
    .clock_in(clk_in),
    .clock_out(clk_out)
  );

  vga u_vga (
    .clk(clk_out),
    .hsync(hsync),
    .vsync(vsync),
    .col(next_col),  
    .row(next_row),    
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
    assign next_back_addr = tile_y * TILES_X + tile_x;

    logic inside_char_tile_next;
    logic inside_char_tile_next_next;

    logic inside_plt_tile_next;
    logic inside_plt_tile_next_next;

    // will work on making this modular in pattern_gen.sv
    always_comb begin
      //character drawing
      inside_char_tile_next = (col >= char_x && col < char_x + 23*2  
                          && row >= char_y && row < char_y + 30*2);
      next_char_addr = inside_char_tile_next ?  facing_right ? ((((row - char_y)>>1) + anim_row )* 69) + (69 - 1) - (((col - char_x)>>1) + anim_col):
                                                               ((((row - char_y)>>1) + anim_row )* 69) + (((col - char_x)>>1) + anim_col)
                                          : 0;
      if (inside_char_tile && char_rgb != 6'b110011) next_final_rgb = char_rgb;
      else next_final_rgb = tile_rgb;

      // platform drawing
      inside_plt_tile_next = (col >= plt_x && col < plt_x + 100 && row >= plt_y && row < plt_y + 9);
      next_plt_addr = inside_plt_tile_next ? (((row - plt_y))* 100) + (((col - plt_x))): 0;

      if (inside_plt_tile) next_final_rgb = plt_rgb;
      else next_final_rgb = tile_rgb;
    end
    logic [9:0] new_x;
    logic [9:0] new_y;
    logic [23:0] counter;
    logic [5:0] d_rgb;

    always_ff @(posedge clk_out) begin
      counter <= counter + 1;
      row <= next_row;
      col <= next_col;
      char_x <= new_x;
      char_y <= new_y;
      char_rgb <= next_char_rgb;
      char_addr <= next_char_addr;
      // inside_char_tile <= inside_char_tile_next;
      inside_char_tile_next_next <= inside_char_tile_next;
      inside_char_tile <= inside_char_tile_next_next; // must delay cycle twice because rom is slow

      plt_x <= new_x;
      plt_y <= new_y;
      plt_rgb <= new_plt_rgb;
      plt_addr <= next_plt_addr;

      inside_plt_tile_next_next <= inside_plt_tile_next;
      inside_plt_tile <= inside_plt_tile_next_next;

      back_addr <= next_back_addr;
      final_rgb <= next_final_rgb;
      tile_rgb <= next_tile_rgb;
    end


    typedef enum logic [2:0] {S1, S2, S3, S4, S5, S6} anim_state;
    anim_state state, next_state;
    always_ff @(posedge counter[23]) begin
      state <= next_state;
    end

    always_ff @(posedge frame_rate) begin
      if (~buttons[0] && new_x < 610) begin 
        new_x <= new_x + 5;
        facing_right <= 1;
      end
      if (~buttons[1] && new_x > 0) begin 
        new_x <= new_x - 5;
        facing_right <= 0;
      end
      if (~buttons[2] && new_y < 440) new_y <= new_y + 5;
      if (~buttons[3] && new_y > 0) new_y <= new_y - 5;
      
    end

  
    always_comb begin
      case(state) 
      S1: begin
        anim_row = 0;
        anim_col = 0;
        next_state = S2;
      end
      S2: begin
        anim_row = 0;
        anim_col = 23;
        next_state = S3;
      end
      S3: begin
        anim_row = 0;
        anim_col = 46;
        next_state = S4;
      end
      S4: begin
        anim_row = 30;
        anim_col = 0;
        next_state = S5;
      end
      S5: begin
        anim_row = 30;
        anim_col = 23;
        next_state = S6;
      end
      S6: begin
        anim_row = 30;
        anim_col = 46;
        next_state = S1;
      end
      default: begin
        anim_col = 0;
        anim_row = 0;
        next_state = S1;
        end
      endcase
    end


  logic [7:0] buttons;
  logic button_up, button_down, button_left, button_right;
  logic button_select, button_start, button_B, button_A;
  logic [7:0] LED;

  controller u_controller (
      .latch(latch),
      .clock(ctrl_clk),
      .LED(LED),
      .buttons(buttons),
      .button_up(button_up),
      .button_down(button_down),
      .button_left(button_left),
      .button_right(button_right),
      .button_select(button_select),
      .button_start(button_start),
      .button_B(button_B),
      .button_A(button_A),
      .data(data),
      .clk(clk_in)
    );
    // // ROM instance for marco
    // ROM_marco u_marco_rom (
    //   .clk(clk_out),
    //   .addr(char_addr),
    //   .rgb(next_char_rgb)
    // );
    ROM_koopa u_koopa_rom (
      .clk(clk_out),
      .addr(char_addr),
      .rgb(next_char_rgb)
    );

    ROM_platform u_platform_rom (
      .clk(clk_out),
      .addr(plt_addr),
      .rgb(next_plt_rgb)
    );

    // ROM instance
    ROM_Screen u_rom (
        .clk(clk_out),
        .addr(back_addr),
        .data(next_tile_rgb)
    );

  pattern_gen u_pattern_gen (
    .valid(valid),
    .col(col),  
    .row(row),
    .tile(final_rgb),    
    .rgb(rgb)     
  );



endmodule
