module top (
  input logic clk_in,
  output logic hsync,
  output logic vsync,
  output logic [5:0] rgb,
  output logic latch1,
  output logic latch2,
  output logic ctrl_clk1,
  output logic ctrl_clk2,
  input logic data1,
  input logic data2
);
  

logic valid;
logic [9:0] col;
logic [9:0] next_col;
logic [9:0] row;
logic [9:0] next_row;



logic clk_out;

    // character rgb from ROM
    logic [5:0] char_rgb1;
    logic [5:0] next_char_rgb1;
    logic inside_char_tile1;
    logic [5:0] char_rgb2;
    logic [5:0] next_char_rgb2;
    logic inside_char_tile2;
    // tile from ROM
    logic [5:0] tile_rgb;
    logic [5:0] next_tile_rgb;
    // final rgb value to pass to VGA
    logic [5:0] final_rgb;
    logic [5:0] next_final_rgb;
    // logic [5:0] final_rgb2;
    // logic [5:0] next_final_rgb2;

    // character position for top left pixel
    logic [9:0] char_x1;
    logic [9:0] char_y1;
    logic [9:0] anim_row1 = 0;
    logic [9:0] anim_col1 = 0;
    logic [9:0] char_x2 = 480;
    logic [9:0] char_y2 = 0;
    logic [9:0] anim_row2 = 0;
    logic [9:0] anim_col2 = 0;

    logic facing_right1;
    logic facing_right2 = 1;
    // frame refresh
    logic frame_rate;

    // ROM address
    logic [16:0] back_addr;
    logic [16:0] next_back_addr;
    logic [13:0] char_addr1;
    logic [13:0] next_char_addr1;
    logic [13:0] char_addr2;
    logic [13:0] next_char_addr2;

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

    logic inside_char_tile_next1;
    logic inside_char_tile_next_next1;
    logic inside_char_tile_next2;
    logic inside_char_tile_next_next2;

    // will work on making this modular in pattern_gen.sv
    
    always_comb begin
      // PLAYER 1 LOGIC
      inside_char_tile_next1 = (col >= char_x1 && col < char_x1 + 23*2  
                          && row >= char_y1 && row < char_y1 + 30*2);
      next_char_addr1 = inside_char_tile_next1 ?  facing_right1 ? ((((row - char_y1)>>1) + anim_row1 )* 69) + (69 - 1) - (((col - char_x1)>>1) + anim_col1):
                                                               ((((row - char_y1)>>1) + anim_row1 )* 69) + (((col - char_x1)>>1) + anim_col1)
                                          : 0;
      // if (inside_char_tile1 && char_rgb1 != 6'b110011) next_final_rgb = char_rgb1;
      // else next_final_rgb = tile_rgb;
      //PLAYER 2
      inside_char_tile_next2 = (col >= char_x2 && col < char_x2 + 30*2  
                          && row >= char_y2 && row < char_y2 + 40*2);
      next_char_addr2 = inside_char_tile_next2 ?  facing_right2 ? ((((row - char_y2)>>1))* 30) + (30 - 1) - (((col - char_x2)>>1)):
                                                               ((((row - char_y2)>>1))* 30) + (((col - char_x2)>>1))
                                          : 0;
      // if (inside_char_tile2 && char_rgb2 != 6'b110011) next_final_rgb = char_rgb2;
      // else next_final_rgb = tile_rgb;

      if (inside_char_tile1 && char_rgb1 != 6'b110011) begin
        next_final_rgb = char_rgb1;
      end else if (inside_char_tile2 && char_rgb2 != 6'b110011) begin
        next_final_rgb = char_rgb2;
      end else begin
        next_final_rgb = tile_rgb;
      end

      // // platform drawing
      // inside_plt_tile_next = (col >= plt_x && col < plt_x + 100 && row >= plt_y && row < plt_y + 9);
      // next_plt_addr = inside_plt_tile_next ? (((row - plt_y))* 100) + (((col - plt_x))): 0;

      // if (inside_plt_tile) next_final_rgb = plt_rgb;
      // else next_final_rgb = tile_rgb;

    end



    logic [9:0] new_x1;
    logic [9:0] new_y1;
    logic [9:0] new_x2 = 480;
    logic [9:0] new_y2 = 0;
    logic [23:0] counter;
    logic [5:0] d_rgb;
    always_ff @(posedge clk_out) begin
      counter <= counter + 1;
      row <= next_row;
      col <= next_col;
      char_x1 <= new_x1;
      char_y1 <= new_y1;
      char_rgb1 <= next_char_rgb1;
      char_addr1 <= next_char_addr1;
      char_x2 <= new_x2;
      char_y2 <= new_y2;
      char_rgb2 <= next_char_rgb2;
      char_addr2 <= next_char_addr2;
      // inside_char_tile <= inside_char_tile_next;
      inside_char_tile_next_next1 <= inside_char_tile_next1;
      inside_char_tile1 <= inside_char_tile_next_next1; // must delay cycle twice because rom is slow
      inside_char_tile_next_next2 <= inside_char_tile_next2;
      inside_char_tile2 <= inside_char_tile_next_next2; // must delay cycle twice because rom is slow
      back_addr <= next_back_addr;
      final_rgb <= next_final_rgb;
      // final_rgb2 <= next_final_rgb2;
      tile_rgb <= next_tile_rgb;
    end


    typedef enum logic [2:0] {S1, S2, S3, S4, S5, S6} anim_state;
    anim_state state, next_state;
    always_ff @(posedge counter[23]) begin
      state <= next_state;
    end

    always_ff @(posedge frame_rate) begin
      if (~buttons1[0] && new_x1 < 610) begin 
        new_x1 <= new_x1 + 5;
        facing_right1 <= 1;
      end
      if (~buttons1[1] && new_x1 > 0) begin 
        new_x1 <= new_x1 - 5;
        facing_right1 <= 0;
      end
      if (~buttons1[2] && new_y1 < 440) new_y1 <= new_y1 + 5;
      if (~buttons1[3] && new_y1 > 0) new_y1 <= new_y1 - 5;
      
    end

    always_ff @(posedge frame_rate) begin
      if (~buttons2[0] && new_x2 < 610) begin 
        new_x2 <= new_x2 + 5;
        facing_right2 <= 1;
      end
      if (~buttons2[1] && new_x2 > 0) begin 
        new_x2 <= new_x2 - 5;
        facing_right2 <= 0;
      end
      if (~buttons2[2] && new_y2 < 440) new_y2 <= new_y2 + 5;
      if (~buttons2[3] && new_y2 > 0) new_y2 <= new_y2 - 5;
      
    end

  
    always_comb begin
      case(state) 
      S1: begin
        anim_row1 = 0;
        anim_col1 = 0;
        next_state = S2;
      end
      S2: begin
        anim_row1 = 0;
        anim_col1 = 23;
        next_state = S3;
      end
      S3: begin
        anim_row1 = 0;
        anim_col1 = 46;
        next_state = S4;
      end
      S4: begin
        anim_row1 = 30;
        anim_col1 = 0;
        next_state = S5;
      end
      S5: begin
        anim_row1 = 30;
        anim_col1 = 23;
        next_state = S6;
      end
      S6: begin
        anim_row1 = 30;
        anim_col1 = 46;
        next_state = S1;
      end
      default: begin
        anim_col1 = 0;
        anim_row1 = 0;
        next_state = S1;
        end
      endcase
    end


  logic [7:0] buttons1;
  logic button_up1, button_down1, button_left1, button_right1;
  logic button_select1, button_start1, button_B1, button_A1;
  logic [7:0] LED;

  logic [7:0] buttons2;
  logic button_up2, button_down2, button_left2, button_right2;
  logic button_select2, button_start2, button_B2, button_A2;

  controller u_controller1 (
      .latch(latch1),
      .clock(ctrl_clk1),
      .LED(LED),
      .buttons(buttons1),
      .button_up(button_up1),
      .button_down(button_down1),
      .button_left(button_left1),
      .button_right(button_right1),
      .button_select(button_select1),
      .button_start(button_start1),
      .button_B(button_B1),
      .button_A(button_A1),
      .data(data1),
      .clk(clk_in)
    );

  controller u_controller2 (
      .latch(latch2),
      .clock(ctrl_clk2),
      .LED(LED),
      .buttons(buttons2),
      .button_up(button_up2),
      .button_down(button_down2),
      .button_left(button_left2),
      .button_right(button_right2),
      .button_select(button_select2),
      .button_start(button_start2),
      .button_B(button_B2),
      .button_A(button_A2),
      .data(data2),
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
      .addr(char_addr1),
      .rgb(next_char_rgb1)
    );

    ROM_marco u_marco_rom (
      .clk(clk_out),
      .addr(char_addr2),
      .rgb(next_char_rgb2)
    );

    // ROM_platform u_platform_rom (
    //   .clk(clk_out),
    //   .addr(plt_addr),
    //   .rgb(next_plt_rgb)
    // );

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
